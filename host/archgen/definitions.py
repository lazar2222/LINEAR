import re

from dataclasses import dataclass, KW_ONLY
from enum        import Enum

from validator   import check, seq, tname, validated, Constraint

# Exports

__all__ = [
    "InstructionFieldType",
    "ImmediateType",
    "Index",
    "IndexEntry",
    "InstructionField",
    "InstructionFieldSpecialization",
    "InstructionFormat",
    "Instruction",
    "GenerationHints",
]

# Constraints

def check_valid_slice(field: InstructionField, start: int, end: int) -> bool:
    is_immediate   = field.type is InstructionFieldType.IMMEDIATE
    is_valid_slice = 0 <= start <= end < field.width
    return is_immediate and is_valid_slice

type Identifier      = Constraint("Identifier",      str,                               lambda x: re.fullmatch(r"[a-z][a-z0-9_]*", x) is not None).annot() # type: ignore
type UpperIdentifier = Constraint("UpperIdentifier", str,                               lambda x: re.fullmatch(r"[A-Z][A-Z0-9_]*", x) is not None).annot() # type: ignore
type Description     = Constraint("Description",     str,                               lambda x: bool(x.strip())                                ).annot() # type: ignore
type Width           = Constraint("Width",           int,                               lambda x: x > 0                                          ).annot() # type: ignore
type Value           = Constraint("Value",           int,                               lambda x: x >= 0                                         ).annot() # type: ignore
type Jam             = Constraint("Jam",             InstructionFieldSpecialization,    lambda x: x.jam is True                                  ).annot() # type: ignore
type Specialization  = Constraint("Specialization",  InstructionFieldSpecialization,    lambda x: x.jam is False                                 ).annot() # type: ignore
type Slice           = Constraint("Slice",           tuple[InstructionField, int, int], lambda x: check_valid_slice(x[0], x[1], x[2])            ).annot() # type: ignore

# Enums

class InstructionFieldType(Enum):
    FIXED     = "fixed"
    OPCODE    = "opcode"
    MODIFIER  = "modifier"
    INDEX     = "index"
    IMMEDIATE = "immediate"

class ImmediateType(Enum):
    SIGN_EXTEND = "sign_extend"
    ZERO_EXTEND = "zero_extend"

# Dataclasses

@validated
@dataclass(frozen=True)
class Index:
    name:  Identifier
    width: Width

    def __post_init__(self) -> None:
        pass

    def count(self) -> int:
        return 1 << self.width

    def max_value(self) -> int:
        return self.count() - 1

    def mask(self) -> int:
        return self.max_value()

    def fits(self, value: int) -> bool:
        return 0 <= value <= self.max_value()

    def symbol_name(self) -> str:
        return "INDEX_" + self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(),)

@validated
@dataclass(frozen=True)
class IndexEntry:
    name:  Identifier
    value: Value
    index: Index
    alias: Identifier  | None = None
    _:     KW_ONLY
    desc:  Description | None = None

    def __post_init__(self) -> None:
        check(self.index.fits(self.value),    message=
            f"value of IndexEntry \"{self.name}\" must be representable in the width of index \"{self.index.name}\", got \"{self.value}\", "
            f"which does not fit in \"{self.index.width}\" bits (max: \"{self.index.max_value()}\")")
        check(self.alias != self.name,        message=
            f"alias of IndexEntry \"{self.name}\" must not be the same as its name, got \"{self.alias}\", which is the same as \"{self.name}\"")
        check(self.has_alias(), warning=True, message=
            f"alias of IndexEntry \"{self.name}\" should not be omitted, got \"{self.alias}\", which is None")
        check(self.has_desc(),  warning=True, message=
            f"description of IndexEntry \"{self.name}\" should not be omitted, got \"{self.desc}\", which is None")

    def has_alias(self) -> bool:
        return self.alias is not None

    def has_desc(self) -> bool:
        return self.desc is not None

    def symbol_name(self) -> str:
        return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        result =      [self.symbol_name(), self.index.name.upper() + "_" + self.symbol_name(), self.index.symbol_name() + "_" + self.symbol_name()]
        if self.alias is not None:
            result += [self.alias.upper(), self.index.name.upper() + "_" + self.alias.upper(), self.index.symbol_name() + "_" + self.alias.upper()]
        return tuple(result)

    # Potential helpers: get_alias() to return alias or name, qualified_name() to return "index.name" or "index.alias", max_value(), fits_index()

@validated
@dataclass(frozen=True)
class InstructionField:
    name:  Identifier
    width: Width
    type:  InstructionFieldType
    value: Value | Index | ImmediateType | None = None

    def __post_init__(self) -> None:
        if   self.type is InstructionFieldType.FIXED:
            check(type(self.value) is int,           message=
                f"value of InstructionField \"{self.name}\" of FIXED type must be an int, got \"{self.value}\", which is a \"{tname(self.value)}\"")
            check(self.fits(self.value),             message=
                f"value of InstructionField \"{self.name}\" of FIXED type must be representable in its width, got \"{self.value}\", "
                f"which does not fit in \"{self.width}\" bits (max: \"{self.max_value()}\")")
        elif self.is_specializable(): # OPCODE or MODIFIER
            check(self.value is None,                message=
                f"value of InstructionField \"{self.name}\" of {self.type.value.upper()} type must be None, got \"{self.value}\", which is not None")
        elif self.type is InstructionFieldType.INDEX:
            check(type(self.value) is Index,         message=
                f"value of InstructionField \"{self.name}\" of INDEX type must be an Index, got \"{self.value}\", which is a \"{tname(self.value)}\"")
            check(self.width == self.value.width,    message=
                f"width of InstructionField \"{self.name}\" of INDEX type must be the same as the width of index \"{self.value.name}\", got \"{self.width}\", "
                f"which does not match \"{self.value.width}\"")
        elif self.type is InstructionFieldType.IMMEDIATE:
            check(type(self.value) is ImmediateType, message=
                f"value of InstructionField \"{self.name}\" of IMMEDIATE type must be an ImmediateType, got \"{self.value}\", "
                f"which is a \"{tname(self.value)}\"")
        else:
            assert False, "unreachable"

    def count(self) -> int:
        return 1 << self.width

    def max_value(self) -> int:
        return self.count() - 1

    def mask(self) -> int:
        return self.max_value()

    def fits(self, value: int) -> bool:
        return 0 <= value <= self.max_value()

    def is_specializable(self) -> bool:
        return self.type is InstructionFieldType.OPCODE or self.type is InstructionFieldType.MODIFIER

    def is_jamable(self) -> bool:
        return self.type is InstructionFieldType.INDEX

    def symbol_name(self) -> str:
        return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        result = [self.symbol_name(), self.symbol_name() + "_MASK", self.symbol_name() + "_SHIFT"]
        if self.type is InstructionFieldType.INDEX:
            result.append(self.value.symbol_name() + "_" + self.symbol_name()           )
            result.append(self.value.symbol_name() + "_" + self.symbol_name() + "_MASK" )
            result.append(self.value.symbol_name() + "_" + self.symbol_name() + "_SHIFT")
            result.append(self.value.name.upper()  + "_" + self.symbol_name()           )
            result.append(self.value.name.upper()  + "_" + self.symbol_name() + "_MASK" )
            result.append(self.value.name.upper()  + "_" + self.symbol_name() + "_SHIFT")
        return tuple(result)

    # Potential helpers: is_immediate(), is_index(), is_opcode(), is_modifier(), is_fixed()

@validated
@dataclass(frozen=True)
class InstructionFieldSpecialization:
    name:  Identifier
    value: Value
    field: InstructionField
    _:     KW_ONLY
    jam:   bool = False

    def __post_init__(self) -> None:
        check(self.jam is True, self.field.is_jamable(),        message=
            f"field of InstructionFieldSpecialization \"{self.name}\" that is a jam must be of type INDEX, got \"{self.field}\""
            f", which is of type \"{self.field.type}\"")
        check(self.jam is False, self.field.is_specializable(), message=
            f"field of InstructionFieldSpecialization \"{self.name}\" that is not a jam must be of type OPCODE or MODIFIER, got \"{self.field}\""
            f", which is of type \"{self.field.type}\"")
        check(self.field.fits(self.value),                      message=
            f"value of InstructionFieldSpecialization \"{self.name}\" must be representable in the width of field \"{self.field.name}\", got \"{self.value}\", "
            f"which does not fit in \"{self.field.width}\" bits (max: \"{self.field.max_value()}\")")

    def symbol_name(self) -> str:
        return self.field.symbol_name() + "_" + self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        result = [self.symbol_name()]
        if self.jam:
            result.append("JAM_" + self.symbol_name())
            result.append(self.field.symbol_name() + "_JAM_" + self.name.upper())
            result.append(self.symbol_name() + "_JAM")
        return tuple(result)

    # Potential helpers: is_jam(), is_specialization(), fits_field(), max_value(), mask(), qualified_name(), is_opcode_specialization(), is_modifier_specialization(), is_index_jam()

@validated
@dataclass(frozen=True)
class InstructionFormat:
    name:   Identifier
    fields: tuple[InstructionField | Jam | Slice, ...]

    def __post_init__(self) -> None:
        underlying, _ = self.underlying_fields(separated=True)
        immediates    = self.immediate_infos(detailed=True)
        check(len(underlying) == len(set(underlying)),                                                          message=
            f"non-slice fields of InstructionFormat \"{self.name}\" must be unique and not of IMMEDIATE type with at least one OPCODE type field, "
            f"got \"{seq(field.name for field in underlying)}\", "
            f"which has the following duplicates: \"{seq(sorted(set(field.name for field in underlying if underlying.count(field) > 1)))}\"")
        check(all(field.type is not InstructionFieldType.IMMEDIATE for field in underlying),                    message=
            f"non-slice fields of InstructionFormat \"{self.name}\" must be unique and not of IMMEDIATE type with at least one OPCODE type field, "
            f"got \"{seq(field.name for field in underlying)}\", "
            f"which has the following IMMEDIATE type fields: \"{seq(field.name for field in underlying if field.type is InstructionFieldType.IMMEDIATE)}\"")
        check(any(field.type is     InstructionFieldType.OPCODE    for field in underlying),                    message=
            f"non-slice fields of InstructionFormat \"{self.name}\" must be unique and not of IMMEDIATE type with at least one OPCODE type field, "
            f"got \"{seq(field.name for field in underlying)}\", which has no OPCODE type fields")
        for field, (min_bit, max_bit, all_bits) in immediates.items():
            check(len(all_bits) == len(set(all_bits)),                                                          message=
                f"sliced IMMEDIATE type field \"{field.name}\" in InstructionFormat \"{self.name}\" must have contiguous non-overlapping slices, "
                f"got \"{seq(self.slices_for(field))}\", which have the following overlapping bits: \"{seq(sorted(set(bit for bit in all_bits if all_bits.count(bit) > 1)))}\"")
            check(len(all_bits) == max_bit - min_bit + 1,                                                       message=
                f"sliced IMMEDIATE type field \"{field.name}\" in InstructionFormat \"{self.name}\" must have contiguous non-overlapping slices, "
                f"got \"{seq(self.slices_for(field))}\", which have the following missing bits: \"{seq(sorted(set(range(min_bit, max_bit + 1)) - set(all_bits)))}\"")
        check(sum(field.type is     InstructionFieldType.OPCODE    for field in underlying) == 1, warning=True, message=
            f"non-slice fields of InstructionFormat \"{self.name}\" should have exactly one OPCODE type field, "
            f"got \"{seq(field.name for field in underlying)}\", "
            f"which has \"{sum(field.type is InstructionFieldType.OPCODE for field in underlying)}\" OPCODE type fields")
        for field, (min_bit,       _,        _) in immediates.items():
            check(min_bit == 0,                                                                   warning=True, message=
                f"sliced IMMEDIATE type field \"{field.name}\" in InstructionFormat \"{self.name}\" should have slices that start at bit 0, "
                f"got \"{seq(self.slices_for(field))}\", which start at bit \"{min_bit}\"")

    def underlying_fields(self, separated: bool = False) -> list[InstructionField] | tuple[list[InstructionField], list[InstructionField]]:
        fields     = []
        immediates = {}
        for field in self.fields:
            if   type(field) is InstructionField:
                fields.append(field)
            elif type(field) is InstructionFieldSpecialization:
                fields.append(field.field)
            elif type(field) is tuple:
                immediates.setdefault(field[0], None)
            else:
                assert False, "unreachable"
        if separated:
            return fields,  list(immediates.keys())
        else:
            return fields + list(immediates.keys())

    def immediate_infos(self, detailed: bool = False) -> dict[InstructionField, tuple[int, int]] | dict[InstructionField, tuple[int, int, tuple[int, ...]]]:
        bit_positions = dict()
        for field in self.fields:
            if type(field) is tuple:
                immediate_field, start, end = field
                bit_positions.setdefault(immediate_field, []).extend(range(start, end + 1))
        if detailed:
            return {field: (min(bits), max(bits), tuple(sorted(bits))) for field, bits in bit_positions.items()}
        else:
            return {field: (min(bits), max(bits)                     ) for field, bits in bit_positions.items()}

    def slices_for(self, field: InstructionField) -> tuple[tuple[int, int], ...]:
        return tuple((slice[1], slice[2]) for slice in self.fields if type(slice) is tuple and slice[0] is field)

    def specializable_fields(self) -> tuple[InstructionField, ...]:
        return tuple(field for field in self.underlying_fields() if field.is_specializable())

    def symbol_name(self) -> str:
        return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(), "INST_FMT_" + self.symbol_name())

    # Potential helpers: total_width(), underlying_fields(), opcode_field(), immediate_slices(), arguments, immediate_info(), normalized_fields, iter_segments(), has_opcode(), immediate_slices(), immediate_coverage(), has_overlapping_slices(), has_contiguous_slices(), duplicates(), contains_field(), field_sources()

@validated
@dataclass(frozen=True)
class Instruction:
    name:   Identifier
    format: InstructionFormat
    specs:  tuple[Specialization, ...]
    desc:   Description | None = None

    def __post_init__(self) -> None:
        specialized_fields   = tuple(spec.field for spec in self.specs)
        specializable_fields = self.format.specializable_fields()
        check(specialized_fields == specializable_fields, message=
            f"specializations of Instruction \"{self.name}\" must be the same as specializable fields of InstructionFormat \"{self.format.name}\", "
            f"got \"{seq(field.name for field in specialized_fields)}\", which does not match \"{seq(field.name for field in specializable_fields)}\"")
        check(self.has_desc(),              warning=True, message=
            f"description of Instruction \"{self.name}\" should not be omitted, got \"{self.desc}\", which is None")

    def has_desc(self) -> bool:
        return self.desc is not None

    def symbol_name(self) -> str:
        return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(), "OP_" + self.symbol_name(), "INST_" + self.symbol_name())

    # Potential helpers: arguments, opcode, spec_fields, spec_by_fields, specialization_for_field, decode_key_fields, decode_key_values, decode_key(), effective_desc()

@validated
@dataclass(frozen=True)
class GenerationHints:
    emit_macro: Identifier

    def __post_init__(self) -> None:
        pass

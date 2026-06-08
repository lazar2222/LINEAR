import re

from dataclasses import dataclass, KW_ONLY
from enum        import Enum

from checker     import check, duplicates, empty, fnames, fxmby, got, has, have, none, same_elements, seq, single, tname, unique
from validator   import validated, Constraint

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

type Identifier      = Constraint("Identifier",      str,                               lambda x: re.fullmatch(r"[a-z][a-z0-9_]*", x) is not None       ).annot() # type: ignore
type UpperIdentifier = Constraint("UpperIdentifier", str,                               lambda x: re.fullmatch(r"[A-Z][A-Z0-9_]*", x) is not None       ).annot() # type: ignore
type Description     = Constraint("Description",     str,                               lambda x: bool(x.strip())                                       ).annot() # type: ignore
type Width           = Constraint("Width",           int,                               lambda x: x >  0                                                ).annot() # type: ignore
type Value           = Constraint("Value",           int,                               lambda x: x >= 0                                                ).annot() # type: ignore
type Jam             = Constraint("Jam",             InstructionFieldSpecialization,    lambda x: x.is_jam()                                            ).annot() # type: ignore
type Specialization  = Constraint("Specialization",  InstructionFieldSpecialization,    lambda x: x.is_specialization()                                 ).annot() # type: ignore
type Slice           = Constraint("Slice",           tuple[InstructionField, int, int], lambda x: x[0].is_immediate() and 0 <= x[1] <= x[2] < x[0].width).annot() # type: ignore

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

    def __post_init__(self) -> None: pass

    def count    (self            ) -> int:  return 1 << self.width
    def max_value(self            ) -> int:  return self.count() - 1
    def mask     (self            ) -> int:  return self.max_value()
    def fits     (self, value: int) -> bool: return 0 <= value <= self.max_value()

    def symbol_name(self) -> str: return "INDEX_" + self.name.upper()

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
        check(self.index.fits(self.value),    message=fxmby("value "       "of IndexEntry " + got(self.name), "representable in the width of index " + got(self.index.name), got(self.value), "not representable in " + got(self.index.width) + " bits (max " + got(self.index.max_value()) + ")"))
        check(self.alias != self.name,        message=fxmby("alias "       "of IndexEntry " + got(self.name), "different from its name",                                     got(self.alias), "same as " + got(self.name)                                                                        ))
        check(self.has_alias(), warning=True, message=fxmby("alias "       "of IndexEntry " + got(self.name), "present",                                                     got(self.alias), "None"                                                                                             ))
        check(self.has_desc(),  warning=True, message=fxmby("description " "of IndexEntry " + got(self.name), "present",                                                     got(self.desc ), "None"                                                                                             ))

    def has_alias(self) -> bool: return self.alias is not None
    def has_desc (self) -> bool: return self.desc  is not None

    def symbol_name(self) -> str: return self.name.upper()
    def alias_name (self) -> str: return self.alias.upper() if self.has_alias() else self.symbol_name()

    def projected_names(self) -> tuple[str, ...]:
        result      = [self.symbol_name(), self.index.name.upper() + "_" + self.symbol_name(), self.index.symbol_name() + "_" + self.symbol_name()]
        if self.has_alias():
            result += [self.alias_name(),  self.index.name.upper() + "_" + self.alias_name(),  self.index.symbol_name() + "_" + self.alias_name() ]
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
        if self.is_fixed():
            check(type(self.value) is int,           message=fxmby("value of InstructionField " + got(self.name) + " of FIXED"                        " type", "an int whose value is representable in its width",   got(self.value), "a " + got(tname(self.value))                                                          ))
            check(self.fits(self.value),             message=fxmby("value of InstructionField " + got(self.name) + " of FIXED"                        " type", "an int whose value is representable in its width",   got(self.value), "not representable in " + got(self.width) + " bits (max " + got(self.max_value()) + ")"))
        if self.is_specializable(): # OPCODE or MODIFIER
            check(self.value is None,                message=fxmby("value of InstructionField " + got(self.name) + " of " + self.type.value.upper() + " type", "None",                                               got(self.value), "not None"                                                                             ))
        if self.is_index():
            check(type(self.value) is Index,         message=fxmby("value of InstructionField " + got(self.name) + " of INDEX"                        " type", "an Index",                                           got(self.value), "a " + got(tname(self.value))                                                          ))
            check(self.width == self.value.width,    message=fxmby("width of InstructionField " + got(self.name) + " of INDEX"                        " type", "same as the width of index " + got(self.value.name), got(self.width), "not equal to " + got(self.value.width)                                                ))
        if self.is_immediate():
            check(type(self.value) is ImmediateType, message=fxmby("value of InstructionField " + got(self.name) + " of IMMEDIATE"                    " type", "an ImmediateType",                                   got(self.value), "a " + got(tname(self.value))                                                          ))

    def count    (self            ) -> int:  return 1 << self.width
    def max_value(self            ) -> int:  return self.count() - 1
    def mask     (self            ) -> int:  return self.max_value()
    def fits     (self, value: int) -> bool: return 0 <= value <= self.max_value()

    def is_fixed    (self) -> bool: return self.type is InstructionFieldType.FIXED
    def is_opcode   (self) -> bool: return self.type is InstructionFieldType.OPCODE
    def is_modifier (self) -> bool: return self.type is InstructionFieldType.MODIFIER
    def is_index    (self) -> bool: return self.type is InstructionFieldType.INDEX
    def is_immediate(self) -> bool: return self.type is InstructionFieldType.IMMEDIATE

    def is_specializable(self) -> bool: return self.is_opcode() or self.is_modifier()
    def is_jamable      (self) -> bool: return self.is_index()

    def symbol_name(self) -> str: return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        result = [self.symbol_name(), self.symbol_name() + "_MASK", self.symbol_name() + "_SHIFT"]
        if self.is_index():
            result.append(self.value.symbol_name() + "_" + self.symbol_name()           )
            result.append(self.value.symbol_name() + "_" + self.symbol_name() + "_MASK" )
            result.append(self.value.symbol_name() + "_" + self.symbol_name() + "_SHIFT")
            result.append(self.value.name.upper()  + "_" + self.symbol_name()           )
            result.append(self.value.name.upper()  + "_" + self.symbol_name() + "_MASK" )
            result.append(self.value.name.upper()  + "_" + self.symbol_name() + "_SHIFT")
        return tuple(result)

@validated
@dataclass(frozen=True)
class InstructionFieldSpecialization:
    name:  Identifier
    value: Value
    field: InstructionField
    _:     KW_ONLY
    jam:   bool = False

    def __post_init__(self) -> None:
        check(self.is_jam(),            self.field.is_jamable(),       message=fxmby("field of InstructionFieldSpecialization " + got(self.name) + " that is "     "a jam", "of type INDEX",                                               got(self.field), "of type " + got(self.field.type)                                                                  ))
        check(self.is_specialization(), self.field.is_specializable(), message=fxmby("field of InstructionFieldSpecialization " + got(self.name) + " that is not " "a jam", "of type OPCODE or MODIFIER",                                  got(self.field), "of type " + got(self.field.type)                                                                  ))
        check(self.field.fits(self.value),                             message=fxmby("value of InstructionFieldSpecialization " + got(self.name),                           "representable in the width of field " + got(self.field.name), got(self.value), "not representable in " + got(self.field.width) + " bits (max " + got(self.field.max_value()) + ")"))

    def is_jam           (self) -> bool: return     self.jam
    def is_specialization(self) -> bool: return not self.jam

    def symbol_name(self) -> str: return self.field.symbol_name() + "_" + self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        result = [self.symbol_name()]
        if self.is_jam():
            result.append("JAM_" + self.symbol_name())
            result.append(self.field.symbol_name() + "_JAM_" + self.name.upper())
            result.append(self.symbol_name() + "_JAM")
        return tuple(result)

    # Potential helpers: fits_field(), max_value(), mask(), qualified_name(), is_opcode_specialization(), is_modifier_specialization(), is_index_jam()

@validated
@dataclass(frozen=True)
class InstructionFormat:
    name:   Identifier
    fields: tuple[InstructionField | Jam | Slice, ...]

    def __post_init__(self) -> None:
        check(   unique(self.non_slice_fields()),                                           message=fxmby("non-slice fields"                                 " of InstructionFormat " + got(self.name), "unique and not of IMMEDIATE type with at least one OPCODE type field", got(seq(fnames(self.non_slice_fields()))), has("the following duplicates "            + got(seq(fnames(duplicates(self.non_slice_fields())))))                ))
        check(    empty(self.fields_of_type(InstructionFieldType.IMMEDIATE)),               message=fxmby("non-slice fields"                                 " of InstructionFormat " + got(self.name), "unique and not of IMMEDIATE type with at least one OPCODE type field", got(seq(fnames(self.non_slice_fields()))), has("the following IMMEDIATE type fields " + got(seq(fnames(self.fields_of_type(InstructionFieldType.IMMEDIATE)))))))
        check(not empty(self.fields_of_type(InstructionFieldType.OPCODE   )),               message=fxmby("non-slice fields"                                 " of InstructionFormat " + got(self.name), "unique and not of IMMEDIATE type with at least one OPCODE type field", got(seq(fnames(self.non_slice_fields()))), has("no OPCODE type fields")                                                                                       ))
        for field, (slices, bits, overlapping, missing) in self.immediate_infos().items():
            check(empty(overlapping),                                                       message=fxmby("sliced IMMEDIATE type field " + got(field.name) + " in InstructionFormat " + got(self.name), "composed of contiguous non-overlapping slices",                        got(seq(slices)),                          "overlapping at bits " + got(seq(overlapping))                                                                     ))
            check(empty(missing    ),                                                       message=fxmby("sliced IMMEDIATE type field " + got(field.name) + " in InstructionFormat " + got(self.name), "composed of contiguous non-overlapping slices",                        got(seq(slices)),                          "missing bits "        + got(seq(missing    ))                                                                     ))
        check(   single(self.fields_of_type(InstructionFieldType.OPCODE   )), warning=True, message=fxmby("non-slice fields"                                 " of InstructionFormat " + got(self.name), have("exactly one OPCODE type field"),                                  got(seq(fnames(self.non_slice_fields()))), has(got(len(self.fields_of_type(InstructionFieldType.OPCODE))) + " OPCODE type fields")                            ))
        for field, (slices, bits, overlapping, missing) in self.immediate_infos().items():
            check(min(bits) == 0,                                             warning=True, message=fxmby("sliced IMMEDIATE type field " + got(field.name) + " in InstructionFormat " + got(self.name), "composed of slices that start at bit 0",                               got(seq(slices)),                          none("start at bit "   + got(min(bits)))                                                                           ))

    def underlying_fields(self, separated: bool = False) -> tuple[InstructionField, ...] | tuple[tuple[InstructionField, ...], tuple[InstructionField, ...]]:
        fields     = []
        immediates = {}
        for field in self.fields:
            if type(field) is InstructionField:
                fields.append(field)
            if type(field) is InstructionFieldSpecialization:
                fields.append(field.field)
            if type(field) is tuple:
                immediates.setdefault(field[0], None)
        if separated:
            return tuple(fields), tuple(immediates.keys())
        else:
            return tuple(fields + list(immediates.keys()))

    def immediate_infos(self) -> dict[InstructionField, tuple[tuple[tuple[int, int], ...],tuple[int, ...], tuple[int, ...], tuple[int, ...]]]:
        field_slices = dict()
        field_bits   = dict()
        result       = dict()
        for field in self.fields:
            if type(field) is tuple:
                immediate_field, start, end = field
                field_slices.setdefault(immediate_field, []).append(     (start, end    ))
                field_bits  .setdefault(immediate_field, []).extend(range(start, end + 1))

        for field in field_slices.keys():
            slices           = field_slices[field]
            bits             = field_bits  [field]
            overlapping_bits = set(bit for bit in bits if bits.count(bit) > 1)
            missing_bits     = set(range(min(bits), max(bits) + 1)) - set(bits)
            result[field]    = (tuple(slices), tuple(bits), tuple(sorted(overlapping_bits)), tuple(sorted(missing_bits)))

        return result

    def field_width (self, field: InstructionField | Jam | Slice) -> int:
        if type(field) is InstructionField:
            return field.width
        if type(field) is InstructionFieldSpecialization:
            return field.field.width
        if type(field) is tuple:
            return field[2] - field[1] + 1

    def field_offset(self, field: InstructionField | Jam | Slice) -> int:
        offset = 0
        for f in self.fields:
            if f is field:
                return offset
            offset += self.field_width(f)

    def instruction_width(self) -> int:
        return sum(self.field_width(field) for field in self.fields)

    def encoding(self) -> tuple[int, int]:
        val  = 0
        mask = 0
        for field in self.fields:
            if type(field) is InstructionField and field.is_fixed():
                val  |= field.value        << self.field_offset(field)
                mask |= field.mask()       << self.field_offset(field)
            if type(field) is InstructionField and field.is_specializable():
                mask |= field.mask()       << self.field_offset(field)
            if type(field) is InstructionFieldSpecialization:
                val  |= field.value        << self.field_offset(field)
                mask |= field.field.mask() << self.field_offset(field)
        return (val, mask)

    def non_slice_fields    (self                            ) -> tuple[InstructionField, ...]: return tuple(field for field in self.underlying_fields(separated=True)[0]                              )
    def fields_of_type      (self, type: InstructionFieldType) -> tuple[InstructionField, ...]: return tuple(field for field in self.underlying_fields(separated=True)[0] if field.type is type        )
    def specializable_fields(self                            ) -> tuple[InstructionField, ...]: return tuple(field for field in self.underlying_fields(separated=True)[0] if field.is_specializable()  )
    def jams                (self                            ) -> tuple[Jam,              ...]: return tuple(field for field in self.fields if type(field) is InstructionFieldSpecialization           )
    def non_slice_arguments (self                            ) -> tuple[InstructionField, ...]: return tuple(field for field in self.fields if type(field) is InstructionField and not field.is_fixed())
    def arguments           (self                            ) -> tuple[InstructionField, ...]: return self.non_slice_arguments() + tuple(field for field in self.immediate_infos())

    def symbol_name(self) -> str: return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(), "INST_FMT_" + self.symbol_name())

    # Potential helpers: total_width(), opcode_field(), normalized_fields, iter_segments(), has_opcode(), immediate_coverage(), has_overlapping_slices(), has_contiguous_slices(), duplicates(), contains_field(), field_sources()

@validated
@dataclass(frozen=True)
class Instruction:
    name:   Identifier
    format: InstructionFormat
    specs:  tuple[Specialization, ...]
    desc:   Description | None = None

    def __post_init__(self) -> None:
        check(same_elements(self.specialized_fields(), self.format.specializable_fields()), message=fxmby("specializations " "of Instruction " + got(self.name), "same as specializable fields of InstructionFormat " + got(self.format.name), got(seq(fnames(self.specialized_fields()))), "not same as " + got(seq(fnames(self.format.specializable_fields())))))
        check(self.has_desc(),                                                warning=True, message=fxmby("description "     "of Instruction " + got(self.name), "present",                                                                    got(self.desc),                              "None"                                                               ))

    def encoding(self) -> tuple[int, int]:
        val, mask = self.format.encoding()
        for spec in self.specs:
            val |= spec.value << self.format.field_offset(spec.field)
        return (val, mask)

    def encoding_overlaps(self, other: Instruction) -> bool:
        sval, smask = self .encoding()
        oval, omask = other.encoding()
        return (sval & smask & omask) == (oval & omask & smask)

    def specialized_fields(self) -> tuple[InstructionField, ...]: return tuple(spec.field for spec  in self.specs                                             )
    def arguments         (self) -> tuple[InstructionField, ...]: return tuple(field      for field in self.format.arguments() if not field.is_specializable())

    def has_desc(self) -> bool: return self.desc is not None

    def symbol_name(self) -> str: return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(), "OP_" + self.symbol_name(), "INST_" + self.symbol_name())

    # Potential helpers: opcode, spec_fields, spec_by_fields, specialization_for_field, decode_key_fields, decode_key_values, decode_key(), effective_desc()

@validated
@dataclass(frozen=True)
class GenerationHints:
    emit_macro: Identifier

    def __post_init__(self) -> None: pass

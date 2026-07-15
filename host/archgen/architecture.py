import importlib
import re

from dataclasses             import dataclass, KW_ONLY
from enum                    import Enum
from types                   import ModuleType
from typing                  import final

from architecture_validators import validate_index,              validate_index_entry
from architecture_validators import validate_instruction_field,  validate_instruction_field_specialization
from architecture_validators import validate_instruction_format, validate_instruction
from architecture_validators import validate_architecture,       validate_architecture_module
from validator               import validate_dataclass,          validate_function,                        Constraint
from exceptions              import InternalException

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
    "Architecture",
]

# Constraints

type Identifier      = Constraint("Identifier",      str,                               lambda x: re.fullmatch(r"[a-z][a-z0-9_]*", x) is not None       ).annot() # type: ignore
type UpperIdentifier = Constraint("UpperIdentifier", str,                               lambda x: re.fullmatch(r"[A-Z][A-Z0-9_]*", x) is not None       ).annot() # type: ignore
type Description     = Constraint("Description",     str,                               lambda x: bool(x.strip())                                       ).annot() # type: ignore
type Width           = Constraint("Width",           int,                               lambda x: x >  0                                                ).annot() # type: ignore
type Value           = Constraint("Value",           int,                               lambda x: x >= 0                                                ).annot() # type: ignore
type Jam             = Constraint("Jam",             InstructionFieldSpecialization,    lambda x: x.is_jam           ()                                 ).annot() # type: ignore
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

@final
@dataclass(frozen=True)
class Index:
    name:  Identifier
    width: Width

    def __post_init__(self) -> None: validate_dataclass(self); validate_index(self)

    def count    (self            ) -> int:                                           return 1 << self.width
    def max_value(self            ) -> int:                                           return self.count() - 1
    def mask     (self            ) -> int:                                           return self.max_value()
    def fits     (self, value: int) -> bool: validate_function(Index.fits, locals()); return 0 <= value <= self.max_value()

    def symbol_name(self) -> str: return "INDEX_" + self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(),)

@final
@dataclass(frozen=True)
class IndexEntry:
    name:  Identifier
    value: Value
    index: Index
    alias: Identifier  | None = None
    _:     KW_ONLY
    desc:  Description | None = None

    def __post_init__(self) -> None: validate_dataclass(self); validate_index_entry(self)

    def has_alias(self) -> bool: return self.alias is not None
    def has_desc (self) -> bool: return self.desc  is not None

    def symbol_name    (self) -> str: return self.name      .upper()
    def alias_name     (self) -> str: return self.alias     .upper() if self.has_alias() else self.symbol_name()
    def qualified_name (self) -> str: return self.index.name.upper() + "." + self.symbol_name()
    def qualified_alias(self) -> str: return self.index.name.upper() + "." + self.alias_name ()

    def projected_names(self) -> tuple[str, ...]:
        result      = [self.symbol_name(), self.index.name.upper() + "_" + self.symbol_name(), self.index.symbol_name() + "_" + self.symbol_name()]
        if self.has_alias():
            result += [self.alias_name (), self.index.name.upper() + "_" + self.alias_name (), self.index.symbol_name() + "_" + self.alias_name ()]
        return tuple(result)

@final
@dataclass(frozen=True)
class InstructionField:
    name:  Identifier
    width: Width
    type:  InstructionFieldType
    value: Value | Index | ImmediateType | None = None

    def __post_init__(self) -> None: validate_dataclass(self); validate_instruction_field(self)

    def count    (self            ) -> int:                                                      return 1 << self.width
    def max_value(self            ) -> int:                                                      return self.count() - 1
    def mask     (self            ) -> int:                                                      return self.max_value()
    def fits     (self, value: int) -> bool: validate_function(InstructionField.fits, locals()); return 0 <= value <= self.max_value()

    def is_fixed    (self) -> bool: return self.type is InstructionFieldType.FIXED
    def is_opcode   (self) -> bool: return self.type is InstructionFieldType.OPCODE
    def is_modifier (self) -> bool: return self.type is InstructionFieldType.MODIFIER
    def is_index    (self) -> bool: return self.type is InstructionFieldType.INDEX
    def is_immediate(self) -> bool: return self.type is InstructionFieldType.IMMEDIATE

    def is_specializable(self) -> bool: return self.is_opcode() or self.is_modifier()
    def is_jamable      (self) -> bool: return self.is_index ()

    def symbol_name(self) -> str: return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        result = [self.symbol_name(), self.symbol_name() + "_MASK", self.symbol_name() + "_SHIFT"]
        if self.is_index():
            result.append(self.value.symbol_name() + "_" + self.symbol_name()           )
            result.append(self.value.symbol_name() + "_" + self.symbol_name() + "_MASK" )
            result.append(self.value.symbol_name() + "_" + self.symbol_name() + "_SHIFT")
            result.append(self.value.name.upper () + "_" + self.symbol_name()           )
            result.append(self.value.name.upper () + "_" + self.symbol_name() + "_MASK" )
            result.append(self.value.name.upper () + "_" + self.symbol_name() + "_SHIFT")
        return tuple(result)

@final
@dataclass(frozen=True)
class InstructionFieldSpecialization:
    name:  Identifier
    value: Value
    field: InstructionField
    _:     KW_ONLY
    jam:   bool = False

    def __post_init__(self) -> None: validate_dataclass(self); validate_instruction_field_specialization(self)

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

@final
@dataclass(frozen=True)
class InstructionFormat:
    name:   Identifier
    fields: tuple[InstructionField | Jam | Slice, ...]

    def __post_init__(self) -> None: validate_dataclass(self); validate_instruction_format(self)

    def immediate_infos(self) -> dict[InstructionField, tuple[tuple[tuple[int, int], ...], tuple[int, ...], tuple[int, ...], tuple[int, ...]]]:
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

    def field_ranges(self) -> dict[InstructionField | Jam | Slice, tuple[int, int]]:
        result = dict()
        pos    = 0
        for field in self.fields:
            if   type(field) is InstructionField:               width = field.width
            elif type(field) is InstructionFieldSpecialization: width = field.field.width
            elif type(field) is tuple:                          width = field[2] - field[1] + 1
            else: raise InternalException("Unexpected field type in InstructionFormat", format=self, field=field, type=type(field))
            result[field] = (pos, width)
            pos += width
        return result

    def encoding(self) -> tuple[int, int]:
        val  = 0
        mask = 0
        for field, (pos, width) in self.field_ranges().items():
            if type(field) is InstructionField and field.is_fixed        (): val |= field.value << pos; mask |= field      .mask() << pos
            if type(field) is InstructionField and field.is_specializable():                            mask |= field      .mask() << pos
            if type(field) is InstructionFieldSpecialization:                val |= field.value << pos; mask |= field.field.mask() << pos
        return (val, mask)

    def format_width         (self) -> int:                          return sum(width for pos, width in self.field_ranges().values()                                   )
    def plain_fields         (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.fields if type(field) is InstructionField              )
    def jams                 (self) -> tuple[Jam,              ...]: return tuple(field       for field in self.fields if type(field) is InstructionFieldSpecialization)
    def jammed_fields        (self) -> tuple[InstructionField, ...]: return tuple(field.field for field in self.jams           ()                                      )
    def immediate_fields     (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.immediate_infos()                                      )
    def fixed_fields         (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.plain_fields() if field.is_fixed        ()             )
    def opcode_fields        (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.plain_fields() if field.is_opcode       ()             )
    def modifier_fields      (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.plain_fields() if field.is_modifier     ()             )
    def index_fields         (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.plain_fields() if field.is_index        ()             )
    def specializable_fields (self) -> tuple[InstructionField, ...]: return tuple(field       for field in self.plain_fields() if field.is_specializable()             )
    def underlying_fields    (self) -> tuple[InstructionField, ...]: return tuple(self.plain_fields        () + self.jammed_fields        () + self.immediate_fields() )
    def instruction_arguments(self) -> tuple[InstructionField, ...]: return tuple(self.index_fields        () + self.immediate_fields     ()                           )
    def arguments            (self) -> tuple[InstructionField, ...]: return tuple(self.specializable_fields() + self.instruction_arguments()                           )

    def symbol_name(self) -> str: return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(), "INST_FMT_" + self.symbol_name())

@final
@dataclass(frozen=True)
class Instruction:
    name:   Identifier
    format: InstructionFormat
    specs:  tuple[Specialization, ...]
    desc:   Description | None = None

    def __post_init__(self) -> None: validate_dataclass(self); validate_instruction(self)

    def encoding(self) -> tuple[int, int]:
        val, mask = self.format.encoding    ()
        ranges    = self.format.field_ranges()
        for spec in self.specs:
            val |= spec.value << ranges[spec.field][0]
        return (val, mask)

    def specialized_fields(self) -> tuple[InstructionField, ...]: return tuple(spec.field for spec in self.specs)
    def arguments         (self) -> tuple[InstructionField, ...]: return self.format.instruction_arguments()

    def has_desc(self) -> bool: return self.desc is not None

    def symbol_name(self) -> str: return self.name.upper()

    def projected_names(self) -> tuple[str, ...]:
        return (self.symbol_name(), "OP_" + self.symbol_name(), "INST_" + self.symbol_name())

    # Potential helpers: opcode, spec_by_fields, specialization_for_field, decode_key_fields, decode_key_values, decode_key(), effective_desc()

@final
@dataclass(frozen=True)
class Architecture:
    name:            UpperIdentifier
    instr_width:     Width
    indexes:         tuple[Index,             ...]
    index_entries:   tuple[IndexEntry,        ...]
    instr_fields:    tuple[InstructionField,  ...]
    jams:            tuple[Jam,               ...]
    specializations: tuple[Specialization,    ...]
    instr_formats:   tuple[InstructionFormat, ...]
    instructions:    tuple[Instruction,       ...]

    def __post_init__(self) -> None: validate_dataclass(self); validate_architecture(self)

    def fixed_fields        (self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.type is InstructionFieldType.FIXED         )
    def opcode_fields       (self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.type is InstructionFieldType.OPCODE        )
    def modifier_fields     (self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.type is InstructionFieldType.MODIFIER      )
    def index_fields        (self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.type is InstructionFieldType.INDEX         )
    def immediate_fields    (self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.type is InstructionFieldType.IMMEDIATE     )
    def specializable_fields(self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.is_specializable()                         )
    def jamable_fields      (self) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.is_jamable      ()                         )
    def plain_fields        (self) -> tuple[InstructionField, ...]: return tuple(self.fixed_fields() + self.opcode_fields() + self.modifier_fields() + self.index_fields())

    def definitions(self) -> tuple[Index | IndexEntry | InstructionField | Jam | Specialization | InstructionFormat | Instruction, ...]:
        return self.indexes + self.index_entries + self.instr_fields + self.jams + self.specializations + self.instr_formats + self.instructions

    def index_entry_aliases(self) -> tuple[str, ...]: return tuple(x.alias_name () for x in self.index_entries       if x.has_alias      ())
    def        symbol_names(self) -> tuple[str, ...]: return tuple(x.symbol_name() for x in self.definitions()) + self.index_entry_aliases()
    def     projected_names(self) -> tuple[str, ...]: return tuple(y               for x in self.definitions() for y in x.projected_names())

    # def field_order(self) -> tuple[InstructionField | tuple[InstructionField, ...], ...]:
    #     field_formats  = {field: {fmt for fmt in self.instr_formats if is_in(field, fmt.arguments())} for field in self.instr_fields}
    #     groups         = [[]]
    #     group_formats  = set()
    #     group_type     = self.instr_fields[0].type if len(self.instr_fields) != 0 else None
    #     for field in self.instr_fields:
    #         if field.type is not group_type or not group_formats.isdisjoint(field_formats[field]):
    #             groups.append([])
    #             group_formats = set()
    #             group_type    = field.type
    #         groups[-1].append(field)
    #         group_formats = group_formats | field_formats[field]

    #     return tuple(group[0] if len(group) == 1 else tuple(group) for group in groups if len(group) != 0)

    @staticmethod
    def from_module(module: ModuleType) -> Architecture:
        validate_function(Architecture.from_module, locals())
        validate_architecture_module(module)

        name         = module.ARCH_NAME
        instr_width  = module.ARCH_INSTR_WIDTH
        indexes      = []
        entries      = []
        fields       = []
        jams         = []
        specs        = []
        formats      = []
        instructions = []

        for field in module.__dict__.values():
            if type(field) is Index:                                                        indexes     .append(field)
            if type(field) is IndexEntry:                                                   entries     .append(field)
            if type(field) is InstructionField:                                             fields      .append(field)
            if type(field) is InstructionFieldSpecialization and field.is_jam           (): jams        .append(field)
            if type(field) is InstructionFieldSpecialization and field.is_specialization(): specs       .append(field)
            if type(field) is InstructionFormat:                                            formats     .append(field)
            if type(field) is Instruction:                                                  instructions.append(field)

        return Architecture(
            name,
            instr_width,
            tuple(indexes),
            tuple(entries),
            tuple(fields),
            tuple(jams),
            tuple(specs),
            tuple(formats),
            tuple(instructions),
        )

    @staticmethod
    def from_name(arch_name: str) -> Architecture:
        validate_function(Architecture.from_name, locals())
        module = importlib .import_module(arch_name)
        return Architecture.from_module  (module   )

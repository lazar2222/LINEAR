import importlib

from dataclasses import dataclass
from types       import ModuleType

from checker     import check, check_refs, check_unique_by, check_unreferenced, duplicates, empty, fxmby, got, has, is_in, seq, unique
from definitions import *
from definitions import Jam, Specialization, UpperIdentifier, Width
from validator   import validated

# Exports

__all__ = [
    "Architecture",
]

# Dataclass

@validated
@dataclass(frozen=True)
class Architecture:
    name:                        UpperIdentifier
    instr_width:                 Width
    indexes:                     tuple[Index,                          ...]
    index_entries:               tuple[IndexEntry,                     ...]
    instr_fields:                tuple[InstructionField,               ...]
    jams:                        tuple[Jam,                            ...]
    instr_field_specializations: tuple[Specialization,                 ...]
    instr_formats:               tuple[InstructionFormat,              ...]
    instructions:                tuple[Instruction,                    ...]
    genvars:                     GenerationHints

    def __post_init__(self) -> None:
        check_refs("index "          "reference", "Architecture.indexes",                     self.index_entries,               lambda entry: entry.index,             self.indexes                    )
        check_refs("index "          "reference", "Architecture.indexes",                     self.index_fields(),              lambda field: field.value,             self.indexes                    )
        check_refs("field "          "reference", "Architecture.instr_fields",                self.jams,                        lambda jam:   jam.field,               self.instr_fields               )
        check_refs("field "          "reference", "Architecture.instr_fields",                self.instr_field_specializations, lambda spec:  spec.field,              self.instr_fields               )
        check_refs("field "          "reference", "Architecture.instr_fields",                self.instr_formats,               lambda fmt:   fmt.underlying_fields(), self.instr_fields               )
        check_refs("jam "            "reference", "Architecture.jams",                        self.instr_formats,               lambda fmt:   fmt.jams(),              self.jams                       )
        check_refs("format "         "reference", "Architecture.instr_formats",               self.instructions,                lambda instr: instr.format,            self.instr_formats              )
        check_refs("specialization " "reference", "Architecture.instr_field_specializations", self.instructions,                lambda instr: instr.specs,             self.instr_field_specializations)

        for fmt in self.instr_formats:
            check(fmt.instruction_width() == self.instr_width, message=fxmby("width of InstructionFormat " + got(fmt.name), "same as Architecture.instr_width", got(fmt.instruction_width()), "not same as " + got(self.instr_width)))

        check(unique(self.symbol_names()), message=fxmby("architecture symbol names and aliases", "unique", got(seq(self.symbol_names())), has("the following duplicates " + got(seq(duplicates(self.symbol_names()))))))

        for first, second in tuple((first, second) for index, first in enumerate(self.instructions) for second in self.instructions[index + 1:]):
            check(not first.encoding_overlaps(second), message=fxmby("instructions " + got(first.name) + " and " + got(second.name), "uniquely decodable by encoding and mask", got(hex(first.encoding()[0]) + " / " + hex(first.encoding()[1])) + " and " + got(hex(second.encoding()[0]) + " / " + hex(second.encoding()[1])), "overlapping under common mask " + got(hex(first.encoding()[1] & second.encoding()[1]))))

        check_unique_by("index entry "                      "values", "index", self.index_entries,               lambda entry: entry.index, lambda entry: entry.value             )
        check_unique_by("instruction field specialization " "values", "field", self.instr_field_specializations, lambda spec:  spec.field,  lambda spec:  spec.value, warning=True)

        check(unique(self.projected_names()), warning=True, message=fxmby("architecture projected names", "unique", got(seq(self.projected_names())), has("the following duplicates " + got(seq(duplicates(self.projected_names()))))))

        check_unreferenced("field type",     "Architecture.instr_fields",                                               "Architecture.instr_fields",                self.instr_fields,                lambda field: field.type,              InstructionFieldType,             warning=True)
        check_unreferenced("index",          "Architecture.index_entries and Architecture.index_fields",                "Architecture.index_entries",               self.index_entries,               lambda entry: entry.index,             self.indexes,                     warning=True)
        check_unreferenced("index",          "Architecture.index_entries and Architecture.index_fields",                "Architecture.index_fields",                self.index_fields(),              lambda field: field.value,             self.indexes,                     warning=True)
        check_unreferenced("field",          "Architecture.instr_formats",                                              "Architecture.instr_formats",               self.instr_formats,               lambda fmt:   fmt.underlying_fields(), self.plain_fields(),              warning=True)
        check_unreferenced("field",          "Architecture.instr_formats and Architecture.instr_field_specializations", "Architecture.instr_formats",               self.instr_formats,               lambda fmt:   fmt.underlying_fields(), self.specializable_fields(),      warning=True)
        check_unreferenced("field",          "Architecture.instr_formats and Architecture.jams",                        "Architecture.instr_formats",               self.instr_formats,               lambda fmt:   fmt.underlying_fields(), self.jamable_fields(),            warning=True)
        check_unreferenced("field",          "Architecture.instr_formats and Architecture.instr_field_specializations", "Architecture.instr_field_specializations", self.instr_field_specializations, lambda spec:  spec.field,              self.specializable_fields(),      warning=True)
        check_unreferenced("field",          "Architecture.instr_formats and Architecture.jams",                        "Architecture.jams",                        self.jams,                        lambda jam:   jam.field,               self.jamable_fields(),            warning=True)
        check_unreferenced("jam",            "Architecture.instr_formats",                                              "Architecture.instr_formats",               self.instr_formats,               lambda fmt:   fmt.jams(),              self.jams,                        warning=True)
        check_unreferenced("specialization", "Architecture.instructions",                                               "Architecture.instructions",                self.instructions,                lambda instr: instr.specs,             self.instr_field_specializations, warning=True)
        check_unreferenced("format",         "Architecture.instructions",                                               "Architecture.instructions",                self.instructions,                lambda instr: instr.format,            self.instr_formats,               warning=True)

        check(not empty(self.indexes                    ), warning=True, message=fxmby("Architecture.indexes",                     "a non-empty tuple", got(self.indexes                    ), "a tuple with " + got(len(self.indexes                    )) + " elements"))
        check(not empty(self.index_entries              ), warning=True, message=fxmby("Architecture.index_entries",               "a non-empty tuple", got(self.index_entries              ), "a tuple with " + got(len(self.index_entries              )) + " elements"))
        check(not empty(self.instr_fields               ), warning=True, message=fxmby("Architecture.instr_fields",                "a non-empty tuple", got(self.instr_fields               ), "a tuple with " + got(len(self.instr_fields               )) + " elements"))
        check(not empty(self.jams                       ), warning=True, message=fxmby("Architecture.jams",                        "a non-empty tuple", got(self.jams                       ), "a tuple with " + got(len(self.jams                       )) + " elements"))
        check(not empty(self.instr_field_specializations), warning=True, message=fxmby("Architecture.instr_field_specializations", "a non-empty tuple", got(self.instr_field_specializations), "a tuple with " + got(len(self.instr_field_specializations)) + " elements"))
        check(not empty(self.instr_formats              ), warning=True, message=fxmby("Architecture.instr_formats",               "a non-empty tuple", got(self.instr_formats              ), "a tuple with " + got(len(self.instr_formats              )) + " elements"))
        check(not empty(self.instructions               ), warning=True, message=fxmby("Architecture.instructions",                "a non-empty tuple", got(self.instructions               ), "a tuple with " + got(len(self.instructions               )) + " elements"))

    def instr_fields_of_type(self, type: InstructionFieldType) -> tuple[InstructionField, ...]: return tuple(field for field in self.instr_fields if field.type is type)
    def fixed_fields        (self                            ) -> tuple[InstructionField, ...]: return self.instr_fields_of_type(InstructionFieldType.FIXED    )
    def opcode_fields       (self                            ) -> tuple[InstructionField, ...]: return self.instr_fields_of_type(InstructionFieldType.OPCODE   )
    def modifier_fields     (self                            ) -> tuple[InstructionField, ...]: return self.instr_fields_of_type(InstructionFieldType.MODIFIER )
    def index_fields        (self                            ) -> tuple[InstructionField, ...]: return self.instr_fields_of_type(InstructionFieldType.INDEX    )
    def immediate_fields    (self                            ) -> tuple[InstructionField, ...]: return self.instr_fields_of_type(InstructionFieldType.IMMEDIATE)
    def plain_fields        (self                            ) -> tuple[InstructionField, ...]: return self.fixed_fields()  + self.immediate_fields()
    def specializable_fields(self                            ) -> tuple[InstructionField, ...]: return self.opcode_fields() + self.modifier_fields()
    def jamable_fields      (self                            ) -> tuple[InstructionField, ...]: return self.index_fields()

    def field_order(self) -> tuple[InstructionField | tuple[InstructionField, ...], ...]:
        field_formats  = {field: {fmt for fmt in self.instr_formats if is_in(field, fmt.arguments())} for field in self.instr_fields}
        groups         = [[]]
        group_formats  = set()
        group_type     = self.instr_fields[0].type if len(self.instr_fields) != 0 else None
        for field in self.instr_fields:
            if field.type is not group_type or not group_formats.isdisjoint(field_formats[field]):
                groups.append([])
                group_formats = set()
                group_type    = field.type
            groups[-1].append(field)
            group_formats = group_formats | field_formats[field]

        return tuple(group[0] if len(group) == 1 else tuple(group) for group in groups if len(group) != 0)

    def collection(self) -> tuple[Index | IndexEntry | InstructionField | Jam | InstructionFieldSpecialization | InstructionFormat | Instruction, ...]:
        return self.indexes + self.index_entries + self.instr_fields + self.jams + self.instr_field_specializations + self.instr_formats + self.instructions

    def    symbol_names(self) -> tuple[str, ...]: return tuple(x.symbol_name() for x in self.collection()) + tuple(entry.alias_name() for entry in self.index_entries if entry.has_alias())
    def projected_names(self) -> tuple[str, ...]: return tuple(y               for x in self.collection() for y in x.projected_names())

    @classmethod
    def from_module(cls, module: ModuleType) -> Architecture:
        check("ARCH_NAME"        in module.__dict__, message=fxmby("ARCH_NAME",        "defined in the architecture definition module", got(module.__name__), "missing ARCH_NAME"       ))
        check("ARCH_INSTR_WIDTH" in module.__dict__, message=fxmby("ARCH_INSTR_WIDTH", "defined in the architecture definition module", got(module.__name__), "missing ARCH_INSTR_WIDTH"))
        check("GENVARS"          in module.__dict__, message=fxmby("GENVARS",          "defined in the architecture definition module", got(module.__name__), "missing GENVARS"         ))

        arch_name                        = module.ARCH_NAME
        arch_instr_width                 = module.ARCH_INSTR_WIDTH
        arch_indexes                     = []
        arch_index_entries               = []
        arch_instr_fields                = []
        arch_jams                        = []
        arch_instr_field_specializations = []
        arch_instr_formats               = []
        arch_instructions                = []
        arch_genvars                     = module.GENVARS

        for symbol_name, field in module.__dict__.items():
            if type(field) is Index:
                check(symbol_name == field.symbol_name(), message=fxmby("symbol name for index "                            + got(field.name), "in the format of "        "INDEX_<NAME>", got(symbol_name), "not same as canonical symbol name " + got(field.symbol_name())))
                arch_indexes                        .append(field)
            if type(field) is IndexEntry:
                check(symbol_name == field.symbol_name(), message=fxmby("symbol name for index entry "                      + got(field.name), "in the format of "              "<NAME>", got(symbol_name), "not same as canonical symbol name " + got(field.symbol_name())))
                arch_index_entries                  .append(field)
            if type(field) is InstructionField:
                check(symbol_name == field.symbol_name(), message=fxmby("symbol name for instruction field "                + got(field.name), "in the format of "              "<NAME>", got(symbol_name), "not same as canonical symbol name " + got(field.symbol_name())))
                arch_instr_fields                   .append(field)
            if type(field) is InstructionFieldSpecialization:
                check(symbol_name == field.symbol_name(), message=fxmby("symbol name for instruction field specialization " + got(field.name), "in the format of " "<FIELD_NAME>_<NAME>", got(symbol_name), "not same as canonical symbol name " + got(field.symbol_name())))
                if field.is_jam():
                    arch_jams                       .append(field)
                else:
                    arch_instr_field_specializations.append(field)
            if type(field) is InstructionFormat:
                check(symbol_name == field.symbol_name(), message=fxmby("symbol name for instruction format "               + got(field.name), "in the format of "              "<NAME>", got(symbol_name), "not same as canonical symbol name " + got(field.symbol_name())))
                arch_instr_formats                  .append(field)
            if type(field) is Instruction:
                check(symbol_name == field.symbol_name(), message=fxmby("symbol name for instruction "                      + got(field.name), "in the format of "              "<NAME>", got(symbol_name), "not same as canonical symbol name " + got(field.symbol_name())))
                arch_instructions                   .append(field)

        return cls(
            arch_name,
            arch_instr_width,
            tuple(arch_indexes),
            tuple(arch_index_entries),
            tuple(arch_instr_fields),
            tuple(arch_jams),
            tuple(arch_instr_field_specializations),
            tuple(arch_instr_formats),
            tuple(arch_instructions),
            arch_genvars,
        )

    @classmethod
    def from_name(cls, arch_name: str) -> Architecture:
        module = importlib.import_module(arch_name)
        return cls.from_module(module)

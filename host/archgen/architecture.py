import importlib

from dataclasses import dataclass
from types       import ModuleType

from definitions import *
from definitions import UpperIdentifier, Width
from validator   import check, validated

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
    indexes:                     tuple[Index, ...]
    instr_fields:                tuple[InstructionField, ...]
    instr_field_specializations: tuple[InstructionFieldSpecialization, ...]
    instr_formats:               tuple[InstructionFormat, ...]
    instructions:                tuple[Instruction, ...]
    index_entries:               tuple[IndexEntry, ...]
    genvars:                     GenerationHints

    # TODO(__post_init__ checks): Architecture-level invariants
    # TODO: warn for any empty collections
    # TODO: uniqueness checks:
    # TODO: check all canonical names are unique (including aliases where applicable)
    # TODO: check all instruction encodings are unique
    # TODO: check all index entries are unique
    # TODO: warn on duplicate specialization values
    # TODO: referential integrity checks:
    # TODO: index type fields reference valid indexes
    # TODO: instruction formats reference valid fields/specializations
    # TODO: instruction field specializations reference valid fields
    # TODO: instructions reference valid format and specializations
    # TODO: index entries reference valid indexes
    # TODO: warn on unreferenced architecture objects (indexes, fields, specializations, formats)
    # TODO: other checks:
    # TODO: check instruction format total widths match architecture instruction width
    # TODO: warn on projected name collisions


    def __post_init__(self) -> None:
        pass
        check(len(self.indexes                    ) > 0, warning=True, message=f"Architecture.indexes should not be empty, got \"{self.indexes}\", which has a length of \"{len(self.indexes)}\"")
        check(len(self.instr_fields               ) > 0, warning=True, message=f"Architecture.instr_fields should not be empty, got \"{self.instr_fields}\", which has a length of \"{len(self.instr_fields)}\"")
        check(len(self.instr_field_specializations) > 0, warning=True, message=f"Architecture.instr_field_specializations should not be empty, got \"{self.instr_field_specializations}\", which has a length of \"{len(self.instr_field_specializations)}\"")
        check(len(self.instr_formats              ) > 0, warning=True, message=f"Architecture.instr_formats should not be empty, got \"{self.instr_formats}\", which has a length of \"{len(self.instr_formats)}\"")
        check(len(self.instructions               ) > 0, warning=True, message=f"Architecture.instructions should not be empty, got \"{self.instructions}\", which has a length of \"{len(self.instructions)}\"")
        check(len(self.index_entries              ) > 0, warning=True, message=f"Architecture.index_entries should not be empty, got \"{self.index_entries}\", which has a length of \"{len(self.index_entries)}\"")


    @classmethod
    def from_module(cls, module: ModuleType) -> Architecture:
        check("ARCH_NAME"        in module.__dict__, message=f"ARCH_NAME must be defined in the architecture definition module, "
            f"got \"{module.__name__}\", which does not contain ARCH_NAME")
        check("ARCH_INSTR_WIDTH" in module.__dict__, message=f"ARCH_INSTR_WIDTH must be defined in the architecture definition module, "
            f"got \"{module.__name__}\", which does not contain ARCH_INSTR_WIDTH")
        check("GENVARS"          in module.__dict__, message=f"GENVARS must be defined in the architecture definition module, "
            f"got \"{module.__name__}\", which does not contain GENVARS")

        arch_name                        = module.ARCH_NAME
        arch_instr_width                 = module.ARCH_INSTR_WIDTH
        arch_indexes                     = []
        arch_instr_fields                = []
        arch_instr_field_specializations = []
        arch_instr_formats               = []
        arch_instructions                = []
        arch_index_entries               = []
        arch_genvars                     = module.GENVARS

        for symbol_name, field in module.__dict__.items():
            if   type(field) is Index:
                check(symbol_name == field.symbol_name(), message=
                    f"symbol name for index \"{field.name}\" must be in the format of INDEX_<NAME>, got \"{symbol_name}\", "
                    f"which does not match its canonical symbol name \"{field.symbol_name()}\"")
                arch_indexes.append(field)
            elif type(field) is InstructionField:
                check(symbol_name == field.symbol_name(), message=
                    f"symbol name for instruction field \"{field.name}\" must be in the format of <NAME>, got \"{symbol_name}\", "
                    f"which does not match its canonical symbol name \"{field.symbol_name()}\"")
                arch_instr_fields.append(field)
            elif type(field) is InstructionFieldSpecialization:
                check(symbol_name == field.symbol_name(), message=
                    f"symbol name for instruction field specialization \"{field.name}\" must be in the format of <FIELD_NAME>_<NAME>, got \"{symbol_name}\", "
                    f"which does not match its canonical symbol name \"{field.symbol_name()}\"")
                arch_instr_field_specializations.append(field)
            elif type(field) is InstructionFormat:
                check(symbol_name == field.symbol_name(), message=
                    f"symbol name for instruction format \"{field.name}\" must be in the format of <NAME>, got \"{symbol_name}\", "
                    f"which does not match its canonical symbol name \"{field.symbol_name()}\"")
                arch_instr_formats.append(field)
            elif type(field) is Instruction:
                check(symbol_name == field.symbol_name(), message=
                    f"symbol name for instruction \"{field.name}\" must be in the format of <NAME>, got \"{symbol_name}\", "
                    f"which does not match its canonical symbol name \"{field.symbol_name()}\"")
                arch_instructions.append(field)
            elif type(field) is IndexEntry:
                check(symbol_name == field.symbol_name(), message=
                    f"symbol name for index entry \"{field.name}\" must be in the format of <NAME>, got \"{symbol_name}\", "
                    f"which does not match its canonical symbol name \"{field.symbol_name()}\"")
                arch_index_entries.append(field)

        return cls(
            arch_name,
            arch_instr_width,
            tuple(arch_indexes),
            tuple(arch_instr_fields),
            tuple(arch_instr_field_specializations),
            tuple(arch_instr_formats),
            tuple(arch_instructions),
            tuple(arch_index_entries),
            arch_genvars
        )

    @classmethod
    def from_name(cls, arch_name: str) -> Architecture:
        module = importlib.import_module(arch_name)
        return cls.from_module(module)

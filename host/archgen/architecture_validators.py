from types                import ModuleType
from typing               import TYPE_CHECKING

import diagnostics

from architecture_helpers import instruction_encoding_overlaps
from checker              import check, check_refs, check_unique_by, check_unreferenced
from util                 import empty, same_elements, single, unique
from exceptions           import InternalException

if TYPE_CHECKING:
    from architecture     import Architecture, Index, IndexEntry, Instruction, InstructionField, InstructionFieldSpecialization, InstructionFormat

# Exports

__all__ = []

# Validators

def validate_index                           (index:          Index                         ) -> None: pass

def validate_index_entry                     (entry:          IndexEntry                    ) -> None:
    check(entry.index.fits(entry.value), diagnostics.value_not_representable(entry, entry.index)              )
    check(entry.alias != entry.name,     diagnostics.alias_name_collision   (entry             )              )
    check(entry.has_alias(),             diagnostics.optional_field_missing (entry, "alias"    ), warning=True)
    check(entry.has_desc (),             diagnostics.optional_field_missing (entry, "desc"     ), warning=True)

def validate_instruction_field               (field:          InstructionField              ) -> None:
    from architecture import ImmediateType, Index

    if   field.is_fixed        ():
        check(type(field.value) is int,           diagnostics.instruction_field_value_invalid(field, int          ))
        check(field.fits(field.value),            diagnostics.value_not_representable        (field, field        ))
    elif field.is_specializable(): # OPCODE or MODIFIER
        check(     field.value  is None,          diagnostics.instruction_field_value_invalid(field, None         ))
    elif field.is_index        ():
        check(type(field.value) is Index,         diagnostics.instruction_field_value_invalid(field, Index        ))
        check(field.width == field.value.width,   diagnostics.field_width_mismatch           (field               ))
    elif field.is_immediate    ():
        check(type(field.value) is ImmediateType, diagnostics.instruction_field_value_invalid(field, ImmediateType))
    else:
        raise InternalException("Unexpected InstructionFieldType in InstructionField", field=field, type=field.type)

def validate_instruction_field_specialization(specialization: InstructionFieldSpecialization) -> None:
    check(specialization.is_jam           (), specialization.field.is_jamable      (), diagnostics.specialization_field_invalid(specialization                      ))
    check(specialization.is_specialization(), specialization.field.is_specializable(), diagnostics.specialization_field_invalid(specialization                      ))
    check(specialization.field.fits(specialization.value),                             diagnostics.value_not_representable     (specialization, specialization.field))

def validate_instruction_format              (format:         InstructionFormat             ) -> None:
    check(    empty([field for field in format.plain_fields() if field.is_immediate()]), diagnostics.plain_field_type_invalid       (format                            )              )
    check(   unique(format.underlying_fields()),                                         diagnostics.format_field_collision         (format                            )              )
    check(not empty(format.opcode_fields    ()),                                         diagnostics.opcode_field_missing           (format                            )              )
    for field, (slices, bits, overlapping, missing) in format.immediate_infos().items():
        check(empty(overlapping               ),                                         diagnostics.immediate_slices_overlap       (format, field, slices, overlapping)              )
        check(empty(missing                   ),                                         diagnostics.immediate_slices_not_contiguous(format, field, slices, missing    )              )
    check(   single(format.opcode_fields    ()),                                         diagnostics.opcode_field_count_invalid     (format                            ), warning=True)
    for field, (slices, bits, overlapping, missing) in format.immediate_infos().items():
        check(  min(bits                      ) == 0,                                    diagnostics.immediate_slices_offset        (format, field, slices, min(bits)  ), warning=True)

def validate_instruction                     (instruction:    Instruction                   ) -> None:
    check(same_elements(instruction.specialized_fields(), instruction.format.specializable_fields()), diagnostics.instruction_specializations_mismatch(instruction        )              )
    check(instruction.has_desc(),                                                                     diagnostics.optional_field_missing              (instruction, "desc"), warning=True)

def validate_architecture                    (architecture:   Architecture                  ) -> None:
    from architecture import InstructionFieldType

    check_refs(architecture.index_entries,   lambda entry: entry.index,            architecture, "indexes"             )
    check_refs(architecture.index_fields(),  lambda field: field.value,            architecture, "indexes"             )
    check_refs(architecture.jams,            lambda jam:   jam.field,              architecture, "jamable_fields"      )
    check_refs(architecture.specializations, lambda spec:  spec.field,             architecture, "specializable_fields")
    check_refs(architecture.instr_formats,   lambda fmt:   fmt.plain_fields    (), architecture, "plain_fields"        )
    check_refs(architecture.instr_formats,   lambda fmt:   fmt.immediate_fields(), architecture, "immediate_fields"    )
    check_refs(architecture.instr_formats,   lambda fmt:   fmt.jams            (), architecture, "jams"                )
    check_refs(architecture.instructions,    lambda instr: instr.specs,            architecture, "specializations"     )
    check_refs(architecture.instructions,    lambda instr: instr.format,           architecture, "instr_formats"       )

    for fmt in architecture.instr_formats:
        check(fmt.format_width() == architecture.instr_width,   diagnostics.format_width_mismatch         (fmt, architecture.instr_width )              )

    check(unique(architecture.symbol_names()),                  diagnostics.symbol_name_collision         (architecture.symbol_names()   )              )

    for first, second in tuple((first, second) for index, first in enumerate(architecture.instructions) for second in architecture.instructions[index + 1:]):
        check(not instruction_encoding_overlaps(first, second), diagnostics.instruction_encoding_collision(first, second                 )              )

    check_unique_by(architecture.index_entries,   "index", "value",             )
    check_unique_by(architecture.specializations, "field", "value", warning=True)

    check(unique(architecture.projected_names()),               diagnostics.projected_name_collision      (architecture.projected_names()), warning=True)

    check_unreferenced(architecture, "instr_fields",    lambda field: field.type,             InstructionFieldType,                warning=True)
    check_unreferenced(architecture, "index_entries",   lambda entry: entry.index,            architecture.indexes,                warning=True)
    check_unreferenced(architecture, "index_fields",    lambda field: field.value,            architecture.indexes,                warning=True)
    check_unreferenced(architecture, "jams",            lambda jam:   jam.field,              architecture.jamable_fields      (), warning=True)
    check_unreferenced(architecture, "specializations", lambda spec:  spec.field,             architecture.specializable_fields(), warning=True)
    check_unreferenced(architecture, "instr_formats",   lambda fmt:   fmt.plain_fields    (), architecture.plain_fields        (), warning=True)
    check_unreferenced(architecture, "instr_formats",   lambda fmt:   fmt.immediate_fields(), architecture.immediate_fields    (), warning=True)
    check_unreferenced(architecture, "instr_formats",   lambda fmt:   fmt.jams            (), architecture.jams,                   warning=True)
    check_unreferenced(architecture, "instructions",    lambda instr: instr.specs,            architecture.specializations,        warning=True)
    check_unreferenced(architecture, "instructions",    lambda instr: instr.format,           architecture.instr_formats,          warning=True)

    check(not empty(architecture.indexes        ), diagnostics.collection_empty("indexes"        ), warning=True)
    check(not empty(architecture.index_entries  ), diagnostics.collection_empty("index_entries"  ), warning=True)
    check(not empty(architecture.instr_fields   ), diagnostics.collection_empty("instr_fields"   ), warning=True)
    check(not empty(architecture.jams           ), diagnostics.collection_empty("jams"           ), warning=True)
    check(not empty(architecture.specializations), diagnostics.collection_empty("specializations"), warning=True)
    check(not empty(architecture.instr_formats  ), diagnostics.collection_empty("instr_formats"  ), warning=True)
    check(not empty(architecture.instructions   ), diagnostics.collection_empty("instructions"   ), warning=True)

def validate_architecture_module             (module:         ModuleType                    ) -> None:
    from architecture import Index, IndexEntry, Instruction, InstructionField, InstructionFieldSpecialization, InstructionFormat

    check("ARCH_NAME"        in module.__dict__, diagnostics.architecture_field_missing(module, "ARCH_NAME"       ))
    check("ARCH_INSTR_WIDTH" in module.__dict__, diagnostics.architecture_field_missing(module, "ARCH_INSTR_WIDTH"))

    for symbol_name, field in module.__dict__.items():
        if type(field) is Index:                          check(symbol_name == field.symbol_name(), diagnostics.symbol_name_invalid(field, symbol_name,        "INDEX_<NAME>"))
        if type(field) is IndexEntry:                     check(symbol_name == field.symbol_name(), diagnostics.symbol_name_invalid(field, symbol_name,              "<NAME>"))
        if type(field) is InstructionField:               check(symbol_name == field.symbol_name(), diagnostics.symbol_name_invalid(field, symbol_name,              "<NAME>"))
        if type(field) is InstructionFieldSpecialization: check(symbol_name == field.symbol_name(), diagnostics.symbol_name_invalid(field, symbol_name, "<FIELD_NAME>_<NAME>"))
        if type(field) is InstructionFormat:              check(symbol_name == field.symbol_name(), diagnostics.symbol_name_invalid(field, symbol_name,              "<NAME>"))
        if type(field) is Instruction:                    check(symbol_name == field.symbol_name(), diagnostics.symbol_name_invalid(field, symbol_name,              "<NAME>"))

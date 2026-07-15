from types            import ModuleType
from typing           import TYPE_CHECKING, Any

from diagnostic       import Diagnostic, DiagnosticKind
from util             import cname, duplicates, expected_name, fname, nseq, seq, tname

if TYPE_CHECKING:
    from architecture import Instruction, InstructionField, InstructionFieldSpecialization, InstructionFormat
    from validator    import Constraint

# Exports

__all__ = []

# Diagnostic factories

def value_type_invalid                  (scope: str, value: Any, expected_type: Any                                                                           ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "value_type_invalid",
        "Value has an invalid type",
        f"{scope} = {value!r}",
        f"expected type = {expected_name(expected_type)}",
        f"actual type = {"None" if value is None else tname(value)}",
    )

def value_constraint_invalid            (scope: str, value: Any, constraint:    Constraint                                                                    ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "value_constraint_invalid",
        "Value does not satisfy constraint",
        f"{scope} = {value!r}",
        f"constraint = {fname(constraint)}",
    )

def value_length_invalid                (scope: str, value: Any, length:        int                                                                           ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "value_length_invalid",
        "Value has an invalid length",
        f"{scope} = {value!r}",
        f"expected length = {length}",
        f"actual length = {len(value)}",
    )

def reference_invalid                   (src: Any, ref: Any,                      coll: str                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "reference_invalid",
        "Symbol's reference is not present in the collection",
        f"symbol = {   tname(src)} {fname(src)}",
        f"reference = {tname(ref)} {fname(ref)}",
        f"collection = {coll}",
    )

def symbol_unreferenced                 (sym: Any,                                coll: str                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "symbol_unreferenced",
        "Symbol is not referenced by any object in the collection",
        f"symbol = {tname(sym)} {fname(sym)}",
        f"collection = {coll}",
    )

def value_for_key_collision             (key: str, kv:  Any, val: str, vals: Any, coll: Any                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "value_for_key_collision",
        "Values for key are not unique",
        f"key field = {  tname(coll[0])}.{key       }",
        f"key value = {  tname(kv     )} {fname(kv) }",
        f"value field = {tname(coll[0])}.{val       }",
        f"value type = { tname(vals[0])}",
        f"duplicate values = {nseq(duplicates(vals))}",
    )

def value_not_representable             (src: Any, tgt: Any                                                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "value_not_representable",
        "Source value is not representable in the target width",
        f"value of {tname(src)} {fname(src)} = {src.value}",
        f"width of {tname(tgt)} {fname(tgt)} = {tgt.width} bits (max {tgt.max_value()})",
    )

def optional_field_missing              (obj: Any, fld: str                                                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "optional_field_missing",
        "Optional field is missing",
        f"{fld} of {tname(obj)} {fname(obj)} = {getattr(obj, fld)}",
    )

def alias_name_collision                (obj: Any                                                                                                             ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "alias_name_collision",
        "Object alias is the same as its name",
        f"name of { tname(obj)} {fname(obj)} = {obj.name }",
        f"alias of {tname(obj)} {fname(obj)} = {obj.alias}",
    )

def collection_empty                    (          name: str                                                                                                  ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "collection_empty",
        "Collection is empty",
        f"collection = {name}",
    )

def symbol_name_invalid                 (sym: Any, name: str, template: str                                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "symbol_name_invalid",
        "Symbol name does not match the expected template",
        f"symbol = {tname(sym)} {fname(sym)}",
        f"expected template = {template}",
        f"canonical symbol name = {sym.symbol_name()}",
        f"actual symbol name = {name}",
    )

def architecture_field_missing          (module: ModuleType,  field:    str                                                                                   ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "architecture_field_missing",
        "Architecture module is missing a required field",
        f"module = {cname(module)}",
        f"missing field = {field}",
    )

def symbol_name_collision               (names: tuple[str, ...]                                                                                               ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "symbol_name_collision",
        "Architecture symbol names and aliases are not unique",
        f"duplicate names = {seq(duplicates(names))}",
    )

def projected_name_collision            (names: tuple[str, ...]                                                                                               ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "projected_name_collision",
        "Architecture projected names are not unique",
        f"duplicate projected names = {seq(duplicates(names))}",
    )

def instruction_field_value_invalid     (field: InstructionField, expected_type: Any                                                                          ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "instruction_field_value_invalid",
        "Instruction field value is invalid",
        f"value of {tname(field)} {fname(field)} = {field.value!r}",
        f"field type = {field.type.value.upper()}",
        f"expected value type = {expected_name(expected_type)}",
        f"actual value type = {"None" if field.value is None else tname(field.value)}",
    )

def field_width_mismatch                (field: InstructionField                                                                                              ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "field_width_mismatch",
        "Instruction field width does not match the width of the index it references",
        f"width of {tname(field      )} {fname(field      )} = {field.      width}",
        f"width of {tname(field.value)} {fname(field.value)} = {field.value.width}",
    )

def specialization_field_invalid        (specialization: InstructionFieldSpecialization                                                                       ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "specialization_field_invalid",
        "Instruction field specialization targets a field of invalid type",
        f"kind of {             tname(specialization      )} {fname(specialization      )} = {"jam" if specialization.is_jam() else "specialization"    }",
        f"expected field type = {                                                           "INDEX" if specialization.is_jam() else "OPCODE or MODIFIER"}",
        f"actual field type of {tname(specialization.field)} {fname(specialization.field)} = {specialization.field.type.value.upper()                   }",
    )

def format_width_mismatch               (format: InstructionFormat, width: int                                                                                ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "format_width_mismatch",
        "Instruction format width does not match architecture instruction width",
        f"width of {tname(format)} {fname(format)} = {format.format_width()}",
        f"Architecture.instr_width = {width}",
    )

def format_field_collision              (format: InstructionFormat                                                                                            ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "format_field_collision",
        "Instruction format fields are not unique",
        f"duplicate fields of {tname(format)} {fname(format)} = {nseq(duplicates(format.underlying_fields()))}",
    )

def plain_field_type_invalid            (format: InstructionFormat                                                                                            ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "plain_field_type_invalid",
        "Plain instruction format fields include immediate fields",
        f"plain immediate fields of {tname(format)} {fname(format)} = {nseq(tuple(field for field in format.plain_fields() if field.is_immediate()))}",
    )

def opcode_field_missing                (format: InstructionFormat                                                                                            ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "opcode_field_missing",
        "Instruction format has no opcode field",
        f"fields of {tname(format)} {fname(format)} = {nseq(format.underlying_fields())}",
    )

def opcode_field_count_invalid          (format: InstructionFormat                                                                                            ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "opcode_field_count_invalid",
        "Instruction format does not have exactly one opcode field",
        f"opcode fields of {tname(format)} {fname(format)} = {nseq(format.opcode_fields())}",
    )

def immediate_slices_overlap            (format: InstructionFormat, field: InstructionField, slices: tuple[tuple[int, int], ...], overlapping: tuple[int, ...]) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "immediate_slices_overlap",
        "Immediate field slices overlap",
        f"sliced IMMEDIATE {tname(field)} {fname(field)} in {tname(format)} {fname(format)}",
        f"slices = {          seq(slices     )}",
        f"overlapping bits = {seq(overlapping)}",
    )

def immediate_slices_not_contiguous     (format: InstructionFormat, field: InstructionField, slices: tuple[tuple[int, int], ...], missing:     tuple[int, ...]) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "immediate_slices_not_contiguous",
        "Immediate field slices are not contiguous",
        f"sliced IMMEDIATE {tname(field)} {fname(field)} in {tname(format)} {fname(format)}",
        f"slices = {      seq(slices )}",
        f"missing bits = {seq(missing)}",
    )

def immediate_slices_offset             (format: InstructionFormat, field: InstructionField, slices: tuple[tuple[int, int], ...], offset:            int      ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "immediate_slices_offset",
        "Immediate field slices do not start at bit 0",
        f"sliced IMMEDIATE {tname(field)} {fname(field)} in {tname(format)} {fname(format)}",
        f"slices = {seq(slices)}",
        f"first bit = {offset}",
    )

def instruction_specializations_mismatch(instruction: Instruction                                                                                             ) -> Diagnostic:
    return Diagnostic.create(DiagnosticKind.VALIDATION, "instruction_specializations_mismatch",
        "Instruction specializations do not match format specializable fields",
        f"specialized fields of {  tname(instruction       )} {fname(instruction       )} = {nseq(instruction.         specialized_fields())}",
        f"specializable fields of {tname(instruction.format)} {fname(instruction.format)} = {nseq(instruction.format.specializable_fields())}",
    )

def instruction_encoding_collision      (a: Instruction, b: Instruction                                                                                       ) -> Diagnostic:
    val_a, mask_a = a.encoding()
    val_b, mask_b = b.encoding()
    common_mask   = mask_a & mask_b
    return Diagnostic.create(DiagnosticKind.VALIDATION, "instruction_encoding_collision",
        "Instruction encodings overlap under their common mask",
        f"encoding of {tname(a)} {fname(a)} = {hex(val_a)} / {hex(mask_a)}",
        f"encoding of {tname(b)} {fname(b)} = {hex(val_b)} / {hex(mask_b)}",
        f"common mask = {hex(common_mask)}",
    )

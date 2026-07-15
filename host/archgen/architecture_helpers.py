from typing           import TYPE_CHECKING

if TYPE_CHECKING:
    from architecture import Instruction

# Exports

__all__ = []

# Instruction helpers

def instruction_encoding_overlaps(a: Instruction, b: Instruction) -> bool:
    val_a, mask_a = a.encoding()
    val_b, mask_b = b.encoding()
    common_mask = mask_a & mask_b
    return (val_a & common_mask) == (val_b & common_mask)

#pragma once

#ifdef LE_ENABLE_VALIDATION
#include <assert.h>
#define LE__VALIDATE_IMM(value, min, max, lo_bits) ( \
    assert((value) >= (min) && (value) <= (max)    && "Immediate out of range") , \
    assert(((value) & ((1 << (lo_bits)) - 1)) == 0 && "Immediate not aligned")  )
#define LE__MASK_SHIFT(value, mask, shift) ( \
    assert(((value) & ~(mask)) == 0 && "Value exceeds mask") , \
    (((value) & (mask)) << (shift))                          )
#else
#define LE__VALIDATE_IMM(value, min, max, lo_bits) ((void)0)
#define LE__MASK_SHIFT(value, mask, shift) (((value) & (mask)) << (shift))
#endif
#define LE__PICK_RANGE(value, end, start) (((value) >> (start)) & ((1 << ((end) - (start) + 1)) - 1))

#define LE__INST_FMT_R(opcode, funct3, funct7, rd, rs1, rs2) ( \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX, LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,            LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(funct3,            LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,               LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(rs2,               LE__RS2_MASK,           LE__RS2_SHIFT          ) | \
    LE__MASK_SHIFT(funct7,            LE__FUNCT7_MASK,        LE__FUNCT7_SHIFT       ) )

#define LE__INST_FMT_I(opcode, funct3, rd, rs1, imm) ( \
    LE__VALIDATE_IMM(imm, -0x800, 0x7FF, 0                                                    ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,          LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                     LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                         LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(funct3,                     LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,                        LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 11, 0), 0xFFF,                  20                     ) )

#define LE__INST_FMT_H(opcode, funct3, funct7, rd, rs1, zimm) ( \
    LE__VALIDATE_IMM(zimm, 0x0, 0x1F, 0                                                       ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,          LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                     LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                         LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(funct3,                     LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,                        LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(zimm, 4, 0), 0x1F,                   20                     ) | \
    LE__MASK_SHIFT(funct7,                     LE__FUNCT7_MASK,        LE__FUNCT7_SHIFT       ) )

#define LE__INST_FMT_Y(opcode, funct3, sys) ( \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX, LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,            LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(LE__RD_ZERO,       LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(funct3,            LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(LE__RS1_ZERO,      LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(sys,               LE__SYS_MASK,           LE__SYS_SHIFT          ) )

#define LE__INST_FMT_C(opcode, funct3, rd, rs1, csr) ( \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX, LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,            LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(funct3,            LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,               LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(csr,               LE__CSR_MASK,           LE__CSR_SHIFT          ) )

#define LE__INST_FMT_D(opcode, funct3, rd, zimm, csr) ( \
    LE__VALIDATE_IMM(zimm, 0x0, 0x1F, 0                                                       ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,          LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                     LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                         LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(funct3,                     LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(zimm, 4, 0), 0x1F,                   15                     ) | \
    LE__MASK_SHIFT(csr,                        LE__CSR_MASK,           LE__CSR_SHIFT          ) )

#define LE__INST_FMT_N(opcode, funct3, funct7, cmp, rs1, rs2) ( \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX, LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,            LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(cmp,               LE__CMP_MASK,           LE__CMP_SHIFT          ) | \
    LE__MASK_SHIFT(funct3,            LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,               LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(rs2,               LE__RS2_MASK,           LE__RS2_SHIFT          ) | \
    LE__MASK_SHIFT(funct7,            LE__FUNCT7_MASK,        LE__FUNCT7_SHIFT       ) )

#define LE__INST_FMT_M(opcode, funct3, cmp, rs1, imm) ( \
    LE__VALIDATE_IMM(imm, -0x800, 0x7FF, 0                                                    ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,          LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                     LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(cmp,                        LE__CMP_MASK,           LE__CMP_SHIFT          ) | \
    LE__MASK_SHIFT(funct3,                     LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,                        LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 11, 0), 0xFFF,                  20                     ) )

#define LE__INST_FMT_S(opcode, funct3, rs1, rs2, imm) ( \
    LE__VALIDATE_IMM(imm, -0x800, 0x7FF, 0                                                    ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,          LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                     LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 4, 0),  0x1F,                   7                      ) | \
    LE__MASK_SHIFT(funct3,                     LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,                        LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(rs2,                        LE__RS2_MASK,           LE__RS2_SHIFT          ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 11, 5), 0x7F,                   25                     ) )

#define LE__INST_FMT_B(opcode, funct3, rs1, rs2, imm) ( \
    LE__VALIDATE_IMM(imm, -0x1000, 0xFFE, 1                                                    ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,           LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                      LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 11, 11), 0x1,                    7                      ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 4, 1),   0xF,                    8                      ) | \
    LE__MASK_SHIFT(funct3,                      LE__FUNCT3_MASK,        LE__FUNCT3_SHIFT       ) | \
    LE__MASK_SHIFT(rs1,                         LE__RS1_MASK,           LE__RS1_SHIFT          ) | \
    LE__MASK_SHIFT(rs2,                         LE__RS2_MASK,           LE__RS2_SHIFT          ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 10, 5),  0x3F,                   25                     ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 12, 12), 0x1,                    31                     ) )

#define LE__INST_FMT_U(opcode, rd, imm) ( \
    LE__VALIDATE_IMM(imm, -0x80000000, 0x7FFFF000, 12                                               ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,                LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                           LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                               LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 31, 12),      0xFFFFF,                12                     ) )

#define LE__INST_FMT_J(opcode, rd, imm) ( \
    LE__VALIDATE_IMM(imm, -0x100000, 0xFFFFE, 1                                                ) , \
    LE__MASK_SHIFT(LE__OPCODE_PREFIX,           LE__OPCODE_PREFIX_MASK, LE__OPCODE_PREFIX_SHIFT) | \
    LE__MASK_SHIFT(opcode,                      LE__OPCODE_MASK,        LE__OPCODE_SHIFT       ) | \
    LE__MASK_SHIFT(rd,                          LE__RD_MASK,            LE__RD_SHIFT           ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 19, 12), 0xFF,                   12                     ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 11, 11), 0x1,                    20                     ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 10, 1),  0x3FF,                  21                     ) | \
    LE__MASK_SHIFT(LE__PICK_RANGE(imm, 20, 20), 0x1,                    31                     ) )

#define LE__OPCODE_PREFIX_SHIFT    0
#define LE__OPCODE_PREFIX_MASK     0b11
#define LE__OPCODE_PREFIX          0b11

#define LE__OPCODE_SHIFT           2
#define LE__OPCODE_MASK            0b11111
#define LE__OPCODE_LOAD            0b00000
#define LE__OPCODE_MISC_MEM        0b00011
#define LE__OPCODE_OP_IMM          0b00100
#define LE__OPCODE_AUIPC           0b00101
#define LE__OPCODE_STORE           0b01000
#define LE__OPCODE_OP              0b01100
#define LE__OPCODE_LUI             0b01101
#define LE__OPCODE_BRANCH          0b11000
#define LE__OPCODE_JALR            0b11001
#define LE__OPCODE_JAL             0b11011
#define LE__OPCODE_SYSTEM          0b11100

#define LE__FUNCT3_SHIFT           12
#define LE__FUNCT3_MASK            0b111
#define LE__FUNCT3_JALR            0b000
#define LE__FUNCT3_BEQ             0b000
#define LE__FUNCT3_BNE             0b001
#define LE__FUNCT3_CC              0b010
#define LE__FUNCT3_CCI             0b011
#define LE__FUNCT3_BLT             0b100
#define LE__FUNCT3_BGE             0b101
#define LE__FUNCT3_BLTU            0b110
#define LE__FUNCT3_BGEU            0b111
#define LE__FUNCT3_B               0b000
#define LE__FUNCT3_H               0b001
#define LE__FUNCT3_W               0b010
#define LE__FUNCT3_BU              0b100
#define LE__FUNCT3_HU              0b101
#define LE__FUNCT3_ADD             0b000
#define LE__FUNCT3_SLT             0b010
#define LE__FUNCT3_SLTU            0b011
#define LE__FUNCT3_XOR             0b100
#define LE__FUNCT3_OR              0b110
#define LE__FUNCT3_AND             0b111
#define LE__FUNCT3_SL              0b001
#define LE__FUNCT3_SR              0b101
#define LE__FUNCT3_MUL             0b000
#define LE__FUNCT3_MULH            0b001
#define LE__FUNCT3_MULHSU          0b010
#define LE__FUNCT3_MULHU           0b011
#define LE__FUNCT3_DIV             0b100
#define LE__FUNCT3_DIVU            0b101
#define LE__FUNCT3_REM             0b110
#define LE__FUNCT3_REMU            0b111
#define LE__FUNCT3_FENCE           0b000
#define LE__FUNCT3_PRIV            0b000
#define LE__FUNCT3_CSRRW           0b001
#define LE__FUNCT3_CSRRS           0b010
#define LE__FUNCT3_CSRRC           0b011
#define LE__FUNCT3_CSRRWI          0b101
#define LE__FUNCT3_CSRRSI          0b110
#define LE__FUNCT3_CSRRCI          0b111

#define LE__FUNCT7_SHIFT           25
#define LE__FUNCT7_MASK            0b1111111
#define LE__FUNCT7_NORM            0b0000000
#define LE__FUNCT7_ADD             0b0000000
#define LE__FUNCT7_SUB             0b0100000
#define LE__FUNCT7_LOGIC           0b0000000
#define LE__FUNCT7_ARITH           0b0100000
#define LE__FUNCT7_M               0b0000001

#define LE__CMP_SHIFT              7
#define LE__CMP_MASK               0b11111
#define LE__CMP_EQ                 0b00000
#define LE__CMP_NE                 0b00001
#define LE__CMP_LT                 0b00100
#define LE__CMP_GE                 0b00101
#define LE__CMP_LTU                0b00110
#define LE__CMP_GEU                0b00111

#define LE__SYS_SHIFT              20
#define LE__SYS_MASK               0b111111111111
#define LE__SYS_FENCE              0b000000000000
#define LE__SYS_ECALL              0b000000000000
#define LE__SYS_EBREAK             0b000000000001
#define LE__SYS_HALT               0b000000001010
#define LE__SYS_CCC                0b000000010000

#define LE__RD_SHIFT               7
#define LE__RD_MASK                0b11111
#define LE__RD_ZERO                0b00000

#define LE__RS1_SHIFT              15
#define LE__RS1_MASK               0b11111
#define LE__RS1_ZERO               0b00000

#define LE__RS2_SHIFT              20
#define LE__RS2_MASK               0b11111

#define LE__CSR_SHIFT              20
#define LE__CSR_MASK               0b111111111111

#define LE__REG_X0     0
#define LE__REG_X1     1
#define LE__REG_X2     2
#define LE__REG_X3     3
#define LE__REG_X4     4
#define LE__REG_X5     5
#define LE__REG_X6     6
#define LE__REG_X7     7
#define LE__REG_X8     8
#define LE__REG_X9     9
#define LE__REG_X10    10
#define LE__REG_X11    11
#define LE__REG_X12    12
#define LE__REG_X13    13
#define LE__REG_X14    14
#define LE__REG_X15    15
#define LE__REG_X16    16
#define LE__REG_X17    17
#define LE__REG_X18    18
#define LE__REG_X19    19
#define LE__REG_X20    20
#define LE__REG_X21    21
#define LE__REG_X22    22
#define LE__REG_X23    23
#define LE__REG_X24    24
#define LE__REG_X25    25
#define LE__REG_X26    26
#define LE__REG_X27    27
#define LE__REG_X28    28
#define LE__REG_X29    29
#define LE__REG_X30    30
#define LE__REG_X31    31

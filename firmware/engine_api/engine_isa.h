#ifndef __ENGINE_ISA_H
#define __ENGINE_ISA_H

#define __LE_MASK_SHIFT(value, mask, shift) (((value) & (mask)) << (shift))
#define __LE_PICK_RANGE(value, end, start) (((value) >> (start)) & ((1 << ((end) - (start) + 1)) - 1))

#define __LE_INST_R(opcode, funct3, funct7, rd, rs1, rs2) ( \
    __LE_MASK_SHIFT(__LE_OPCODE_PREFIX,           __LE_OPCODE_PREFIX_MASK, __LE_OPCODE_PREFIX_SHIFT) | \
    __LE_MASK_SHIFT(opcode,                       __LE_OPCODE_MASK,        __LE_OPCODE_SHIFT       ) | \
    __LE_MASK_SHIFT(rd,                           __LE_REG_MASK,           __LE_RD_SHIFT           ) | \
    __LE_MASK_SHIFT(funct3,                       __LE_FUNCT3_MASK,        __LE_FUNCT3_SHIFT       ) | \
    __LE_MASK_SHIFT(rs1,                          __LE_REG_MASK,           __LE_RS1_SHIFT          ) | \
    __LE_MASK_SHIFT(rs2,                          __LE_REG_MASK,           __LE_RS2_SHIFT          ) | \
    __LE_MASK_SHIFT(funct7,                       __LE_FUNCT7_MASK,        __LE_FUNCT7_SHIFT       ) )

#define __LE_INST_I(opcode, funct3, rd, rs1, imm) ( \
    __LE_MASK_SHIFT(__LE_OPCODE_PREFIX,           __LE_OPCODE_PREFIX_MASK, __LE_OPCODE_PREFIX_SHIFT) | \
    __LE_MASK_SHIFT(opcode,                       __LE_OPCODE_MASK,        __LE_OPCODE_SHIFT       ) | \
    __LE_MASK_SHIFT(rd,                           __LE_REG_MASK,           __LE_RD_SHIFT           ) | \
    __LE_MASK_SHIFT(funct3,                       __LE_FUNCT3_MASK,        __LE_FUNCT3_SHIFT       ) | \
    __LE_MASK_SHIFT(rs1,                          __LE_REG_MASK,           __LE_RS1_SHIFT          ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 11,  0), 0xFFF,                   20                      ) )

#define __LE_INST_S(opcode, funct3, rs1, rs2, imm) ( \
    __LE_MASK_SHIFT(__LE_OPCODE_PREFIX,           __LE_OPCODE_PREFIX_MASK, __LE_OPCODE_PREFIX_SHIFT) | \
    __LE_MASK_SHIFT(opcode,                       __LE_OPCODE_MASK,        __LE_OPCODE_SHIFT       ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm,  4,  0), 0x1F,                    7                       ) | \
    __LE_MASK_SHIFT(funct3,                       __LE_FUNCT3_MASK,        __LE_FUNCT3_SHIFT       ) | \
    __LE_MASK_SHIFT(rs1,                          __LE_REG_MASK,           __LE_RS1_SHIFT          ) | \
    __LE_MASK_SHIFT(rs2,                          __LE_REG_MASK,           __LE_RS2_SHIFT          ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 11,  5), 0x7F,                    25                      ) )

#define __LE_INST_U(opcode, rd, imm) ( \
    __LE_MASK_SHIFT(__LE_OPCODE_PREFIX,           __LE_OPCODE_PREFIX_MASK, __LE_OPCODE_PREFIX_SHIFT) | \
    __LE_MASK_SHIFT(opcode,                       __LE_OPCODE_MASK,        __LE_OPCODE_SHIFT       ) | \
    __LE_MASK_SHIFT(rd,                           __LE_REG_MASK,           __LE_RD_SHIFT           ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 31, 12), 0xFFFFF,                 12                      ) )

#define __LE_INST_J(opcode, rd, imm) ( \
    __LE_MASK_SHIFT(__LE_OPCODE_PREFIX,           __LE_OPCODE_PREFIX_MASK, __LE_OPCODE_PREFIX_SHIFT) | \
    __LE_MASK_SHIFT(opcode,                       __LE_OPCODE_MASK,        __LE_OPCODE_SHIFT       ) | \
    __LE_MASK_SHIFT(rd,                           __LE_REG_MASK,           __LE_RD_SHIFT           ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 19, 12), 0xFF,                    31                      ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 11, 11), 0x1,                     20                      ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 10,  1), 0x3FF,                   21                      ) | \
    __LE_MASK_SHIFT(__LE_PICK_RANGE(imm, 20, 20), 0x1,                     12                      ) )

#define __LE_X0     0
#define __LE_X1     1
#define __LE_X2     2
#define __LE_X3     3
#define __LE_X4     4
#define __LE_X5     5
#define __LE_X6     6
#define __LE_X7     7
#define __LE_X8     8
#define __LE_X9     9
#define __LE_X10    10
#define __LE_X11    11
#define __LE_X12    12
#define __LE_X13    13
#define __LE_X14    14
#define __LE_X15    15
#define __LE_X16    16
#define __LE_X17    17
#define __LE_X18    18
#define __LE_X19    19
#define __LE_X20    20
#define __LE_X21    21
#define __LE_X22    22
#define __LE_X23    23
#define __LE_X24    24
#define __LE_X25    25
#define __LE_X26    26
#define __LE_X27    27
#define __LE_X28    28
#define __LE_X29    29
#define __LE_X30    30
#define __LE_X31    31

#define __LE_OPCODE_PREFIX_SHIFT    0
#define __LE_OPCODE_PREFIX_MASK     0b11
#define __LE_OPCODE_PREFIX          0b00

#define __LE_OPCODE_SHIFT           2
#define __LE_OPCODE_MASK            0b11111
#define __LE_OPCODE_LOAD            0b00000
#define __LE_OPCODE_OPIMM           0b00100
#define __LE_OPCODE_AUIPC           0b00101
#define __LE_OPCODE_STORE           0b01000
#define __LE_OPCODE_OP              0b01100
#define __LE_OPCODE_LUI             0b01101
#define __LE_OPCODE_BRANCH          0b11000
#define __LE_OPCODE_JALR            0b11001
#define __LE_OPCODE_JAL             0b11011
#define __LE_OPCODE_SYSTEM          0b11100

#define __LE_FUNCT3_SHIFT           12
#define __LE_FUNCT3_MASK            0b111
#define __LE_FUNCT3_JALR            0b000
#define __LE_FUNCT3_BEQ             0b000
#define __LE_FUNCT3_BNE             0b001
#define __LE_FUNCT3_BIM             0b010
#define __LE_FUNCT3_BLT             0b100
#define __LE_FUNCT3_BGE             0b101
#define __LE_FUNCT3_BLTU            0b110
#define __LE_FUNCT3_BGEU            0b111
#define __LE_FUNCT3_LB              0b000
#define __LE_FUNCT3_LH              0b001
#define __LE_FUNCT3_LW              0b010
#define __LE_FUNCT3_LBU             0b100
#define __LE_FUNCT3_LHU             0b101
#define __LE_FUNCT3_SB              0b000
#define __LE_FUNCT3_SH              0b001
#define __LE_FUNCT3_SW              0b010
#define __LE_FUNCT3_ADDI            0b000
#define __LE_FUNCT3_SLTI            0b010
#define __LE_FUNCT3_SLTIU           0b011
#define __LE_FUNCT3_XORI            0b100
#define __LE_FUNCT3_ORI             0b110
#define __LE_FUNCT3_ANDI            0b111
#define __LE_FUNCT3_SLLI            0b001
#define __LE_FUNCT3_SRLI            0b101
#define __LE_FUNCT3_SRAI            0b101
#define __LE_FUNCT3_ADD             0b000
#define __LE_FUNCT3_SUB             0b000
#define __LE_FUNCT3_SLL             0b001
#define __LE_FUNCT3_SLT             0b010
#define __LE_FUNCT3_SLTU            0b011
#define __LE_FUNCT3_XOR             0b100
#define __LE_FUNCT3_SRL             0b101
#define __LE_FUNCT3_SRA             0b101
#define __LE_FUNCT3_OR              0b110
#define __LE_FUNCT3_AND             0b111
#define __LE_FUNCT3_MUL             0b000
#define __LE_FUNCT3_DIV             0b100
#define __LE_FUNCT3_MMR             0b001
#define __LE_FUNCT3_PRIV            0b000

#define __LE_FUNCT7_SHIFT           25
#define __LE_FUNCT7_MASK            0b1111111
#define __LE_FUNCT7_SLLI            0b0000000
#define __LE_FUNCT7_SRLI            0b0000000
#define __LE_FUNCT7_SRAI            0b0100000
#define __LE_FUNCT7_ADD             0b0000000
#define __LE_FUNCT7_SUB             0b0100000
#define __LE_FUNCT7_SLL             0b0000000
#define __LE_FUNCT7_SLT             0b0000000
#define __LE_FUNCT7_SLTU            0b0000000
#define __LE_FUNCT7_XOR             0b0000000
#define __LE_FUNCT7_SRL             0b0000000
#define __LE_FUNCT7_SRA             0b0100000
#define __LE_FUNCT7_OR              0b0000000
#define __LE_FUNCT7_AND             0b0000000
#define __LE_FUNCT7_MUL             0b0000001
#define __LE_FUNCT7_DIV             0b0000001
#define __LE_FUNCT7_MMR             0b0000001

#define __LE_RD_SHIFT               7
#define __LE_RS1_SHIFT              15
#define __LE_RS2_SHIFT              20
#define __LE_REG_MASK               0b11111

#define __LE_RD_PRIV                0b00000

#define __LE_RS1_PRIV               0b00000

#define __LE_RS2_BEQ                0b00000
#define __LE_RS2_BNE                0b00001
#define __LE_RS2_BLT                0b00100
#define __LE_RS2_BGE                0b00101
#define __LE_RS2_BLTU               0b00110
#define __LE_RS2_BGEU               0b00111

#define __LE_IMM_HALT               0x0
#define __LE_IMM_CCC                0x1
// TODO cache control instructions

#endif /* __ENGINE_ISA_H */

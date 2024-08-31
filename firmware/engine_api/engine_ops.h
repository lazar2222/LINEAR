#ifndef __ENGINE_OPS_H
#define __ENGINE_OPS_H

#include "engine_isa.h"

// Register definitions
#define LE_ZERO LE_X0   // Hard-wired zero
#define LE_RA   LE_X1   // Return address
#define LE_SP   LE_X2   // Stack pointer
#define LE_GP   LE_X3   // Global pointer
#define LE_TP   LE_X4   // Thread pointer (Thread index)
#define LE_FP   LE_X8   // Frame pointer
#define LE_R0   LE_X5   // General purpose registers R0-R9
#define LE_R1   LE_X6
#define LE_R2   LE_X7
#define LE_R3   LE_X9
#define LE_R4   LE_X10
#define LE_R5   LE_X11
#define LE_R6   LE_X12
#define LE_R7   LE_X13
#define LE_R8   LE_X14
#define LE_R9   LE_X15
#define LE_S0   LE_X16  // Shared registers S0-S15
#define LE_S1   LE_X17
#define LE_S2   LE_X18
#define LE_S3   LE_X19
#define LE_S4   LE_X20
#define LE_S5   LE_X21
#define LE_S6   LE_X22
#define LE_S7   LE_X23
#define LE_S8   LE_X24
#define LE_S9   LE_X25
#define LE_S10  LE_X26
#define LE_S11  LE_X27
#define LE_S12  LE_X28
#define LE_S13  LE_X29
#define LE_S14  LE_X30
#define LE_S15  LE_X31

// Instruction definitions
#define LE_LUI      (rd,           imm) EMIT(LE_OP_LUI   (rd,           imm))   // R[rd] = imm & 0xFFFFF000
#define LE_AUIPC    (rd,           imm) EMIT(LE_OP_AUIPC (rd,           imm))   // R[rd] = PC + (imm & 0xFFFFF000)
#define LE_JAL      (rd,           imm) EMIT(LE_OP_JAL   (rd,           imm))   // R[rd] = PC + 4; PC += signext(imm & 0x1FFFFE)
#define LE_JALR     (rd, rs1,      imm) EMIT(LE_OP_JALR  (rd, rs1,      imm))   // R[rd] = PC + 4; PC = (R[rs1] + signext(imm & 0xFFF)) & ~1

#define LE_BEQ      (    rs1, rs2     ) EMIT(LE_OP_BEQ   (    rs1, rs2     ))   // CC = R[rs1] == R[rs2]
#define LE_BNE      (    rs1, rs2     ) EMIT(LE_OP_BNE   (    rs1, rs2     ))   // CC = R[rs1] != R[rs2]
#define LE_BLT      (    rs1, rs2     ) EMIT(LE_OP_BLT   (    rs1, rs2     ))   // CC = R[rs1] < R[rs2]     (signed)
#define LE_BLTU     (    rs1, rs2     ) EMIT(LE_OP_BLTU  (    rs1, rs2     ))   // CC = R[rs1] < R[rs2]     (unsigned)
#define LE_BGE      (    rs1, rs2     ) EMIT(LE_OP_BGE   (    rs1, rs2     ))   // CC = R[rs1] >= R[rs2]    (signed)
#define LE_BGEU     (    rs1, rs2     ) EMIT(LE_OP_BGEU  (    rs1, rs2     ))   // CC = R[rs1] >= R[rs2]    (unsigned)

#define LE_BEQI     (    rs1,      imm) EMIT(LE_OP_BEQI  (    rs1,      imm))   // CC = R[rs1] == signext(imm & 0xFFF)
#define LE_BNEI     (    rs1,      imm) EMIT(LE_OP_BNEI  (    rs1,      imm))   // CC = R[rs1] != signext(imm & 0xFFF)
#define LE_BLTI     (    rs1,      imm) EMIT(LE_OP_BLTI  (    rs1,      imm))   // CC = R[rs1] < signext(imm & 0xFFF)   (signed)
#define LE_BLTUI    (    rs1,      imm) EMIT(LE_OP_BLTUI (    rs1,      imm))   // CC = R[rs1] < signext(imm & 0xFFF)   (unsigned)
#define LE_BGEI     (    rs1,      imm) EMIT(LE_OP_BGEI  (    rs1,      imm))   // CC = R[rs1] >= signext(imm & 0xFFF)  (signed)
#define LE_BGEUI    (    rs1,      imm) EMIT(LE_OP_BGEUI (    rs1,      imm))   // CC = R[rs1] >= signext(imm & 0xFFF)  (unsigned)

#define LE_LB       (rd, rs1,      imm) EMIT(LE_OP_LB    (rd, rs1,      imm))   // R[rd] = signext(MEM[R[rs1] + signext(imm & 0xFFF)] & 0xFF)
#define LE_LBU      (rd, rs1,      imm) EMIT(LE_OP_LBU   (rd, rs1,      imm))   // R[rd] = zeroext(MEM[R[rs1] + signext(imm & 0xFFF)] & 0xFF)
#define LE_LH       (rd, rs1,      imm) EMIT(LE_OP_LH    (rd, rs1,      imm))   // R[rd] = signext(MEM[R[rs1] + signext(imm & 0xFFF)] & 0xFFFF)
#define LE_LHU      (rd, rs1,      imm) EMIT(LE_OP_LHU   (rd, rs1,      imm))   // R[rd] = zeroext(MEM[R[rs1] + signext(imm & 0xFFF)] & 0xFFFF)
#define LE_LW       (rd, rs1,      imm) EMIT(LE_OP_LW    (rd, rs1,      imm))   // R[rd] = MEM[R[rs1] + signext(imm & 0xFFF)]

#define LE_SB       (    rs1, rs2, imm) EMIT(LE_OP_SB    (    rs1, rs2, imm))   // MEM[R[rs1] + signext(imm & 0xFFF)] = R[rs2] & 0xFF
#define LE_SH       (    rs1, rs2, imm) EMIT(LE_OP_SH    (    rs1, rs2, imm))   // MEM[R[rs1] + signext(imm & 0xFFF)] = R[rs2] & 0xFFFF
#define LE_SW       (    rs1, rs2, imm) EMIT(LE_OP_SW    (    rs1, rs2, imm))   // MEM[R[rs1] + signext(imm & 0xFFF)] = R[rs2]

#define LE_ADDI     (rd, rs1,      imm) EMIT(LE_OP_ADDI  (rd, rs1,      imm))   // R[rd] = R[rs1] + signext(imm & 0xFFF)
#define LE_SLTI     (rd, rs1,      imm) EMIT(LE_OP_SLTI  (rd, rs1,      imm))   // R[rd] = (R[rs1] < signext(imm & 0xFFF)) ? 1 : 0  (signed)
#define LE_SLTIU    (rd, rs1,      imm) EMIT(LE_OP_SLTIU (rd, rs1,      imm))   // R[rd] = (R[rs1] < signext(imm & 0xFFF)) ? 1 : 0  (unsigned)
#define LE_ANDI     (rd, rs1,      imm) EMIT(LE_OP_ANDI  (rd, rs1,      imm))   // R[rd] = R[rs1] & signext(imm & 0xFFF)
#define LE_ORI      (rd, rs1,      imm) EMIT(LE_OP_ORI   (rd, rs1,      imm))   // R[rd] = R[rs1] | signext(imm & 0xFFF)
#define LE_XORI     (rd, rs1,      imm) EMIT(LE_OP_XORI  (rd, rs1,      imm))   // R[rd] = R[rs1] ^ signext(imm & 0xFFF)
#define LE_SLLI     (rd, rs1,      imm) EMIT(LE_OP_SLLI  (rd, rs1,      imm))   // R[rd] = R[rs1] << (imm & 0x1F)   (logical)
#define LE_SRLI     (rd, rs1,      imm) EMIT(LE_OP_SRLI  (rd, rs1,      imm))   // R[rd] = R[rs1] >> (imm & 0x1F)   (logical)
#define LE_SRAI     (rd, rs1,      imm) EMIT(LE_OP_SRAI  (rd, rs1,      imm))   // R[rd] = R[rs1] >> (imm & 0x1F)   (arithmetic)

#define LE_ADD      (rd, rs1, rs2     ) EMIT(LE_OP_ADD   (rd, rs1, rs2     ))   // R[rd] = R[rs1] + R[rs2]
#define LE_SUB      (rd, rs1, rs2     ) EMIT(LE_OP_SUB   (rd, rs1, rs2     ))   // R[rd] = R[rs1] - R[rs2]
#define LE_SLT      (rd, rs1, rs2     ) EMIT(LE_OP_SLT   (rd, rs1, rs2     ))   // R[rd] = (R[rs1] < R[rs2]) ? 1 : 0    (signed)
#define LE_SLTU     (rd, rs1, rs2     ) EMIT(LE_OP_SLTU  (rd, rs1, rs2     ))   // R[rd] = (R[rs1] < R[rs2]) ? 1 : 0    (unsigned)
#define LE_AND      (rd, rs1, rs2     ) EMIT(LE_OP_AND   (rd, rs1, rs2     ))   // R[rd] = R[rs1] & R[rs2]
#define LE_OR       (rd, rs1, rs2     ) EMIT(LE_OP_OR    (rd, rs1, rs2     ))   // R[rd] = R[rs1] | R[rs2]
#define LE_XOR      (rd, rs1, rs2     ) EMIT(LE_OP_XOR   (rd, rs1, rs2     ))   // R[rd] = R[rs1] ^ R[rs2]
#define LE_SLL      (rd, rs1, rs2     ) EMIT(LE_OP_SLL   (rd, rs1, rs2     ))   // R[rd] = R[rs1] << (R[rs2] & 0x1F)    (logical)
#define LE_SRL      (rd, rs1, rs2     ) EMIT(LE_OP_SRL   (rd, rs1, rs2     ))   // R[rd] = R[rs1] >> (R[rs2] & 0x1F)    (logical)
#define LE_SRA      (rd, rs1, rs2     ) EMIT(LE_OP_SRA   (rd, rs1, rs2     ))   // R[rd] = R[rs1] >> (R[rs2] & 0x1F)    (arithmetic)

#define LE_MUL      (rd, rs1, rs2     ) EMIT(LE_OP_MUL   (rd, rs1, rs2     ))   // R[rd] = (R[rs1] * R[rs2]) & 0xFFFFFFFF; TR = (R[rs1] * R[rs2]) >> 32
#define LE_DIV      (rd, rs1, rs2     ) EMIT(LE_OP_DIV   (rd, rs1, rs2     ))   // R[rd] = R[rs1] / R[rs2]; TR = R[rs1] % R[rs2]
#define LE_MMR      (rd,              ) EMIT(LE_OP_MMR   (rd,              ))   // R[rd] = TR
#define LE_HALT     (                 ) EMIT(LE_OP_HALT  (                 ))   // End the kernel
#define LE_CCC      (                 ) EMIT(LE_OP_CCC   (                 ))   // CC = 1

#define LE_OP_LUI   (rd,           imm) __LE_INST_U(__LE_OPCODE_LUI,                                        rd,                     imm)
#define LE_OP_AUIPC (rd,           imm) __LE_INST_U(__LE_OPCODE_AUIPC,                                      rd,                     imm)
#define LE_OP_JAL   (rd,           imm) __LE_INST_J(__LE_OPCODE_JAL,                                        rd,                     imm)
#define LE_OP_JALR  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_JALR,   __LE_FUNCT3_JALR,                   rd, rs1,                imm)

#define LE_OP_BEQ   (    rs1, rs2     ) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BEQ,                        rs1, rs2,             0)
#define LE_OP_BNE   (    rs1, rs2     ) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BNE,                        rs1, rs2,             0)
#define LE_OP_BLT   (    rs1, rs2     ) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BLT,                        rs1, rs2,             0)
#define LE_OP_BLTU  (    rs1, rs2     ) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BLTU,                       rs1, rs2,             0)
#define LE_OP_BGE   (    rs1, rs2     ) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BGE,                        rs1, rs2,             0)
#define LE_OP_BGEU  (    rs1, rs2     ) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BGEU,                       rs1, rs2,             0)

#define LE_OP_BEQI  (    rs1,      imm) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BIM,                        rs1, __LE_RS2_BEQ,  imm)
#define LE_OP_BNEI  (    rs1,      imm) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BIM,                        rs1, __LE_RS2_BNE,  imm)
#define LE_OP_BLTI  (    rs1,      imm) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BIM,                        rs1, __LE_RS2_BLT,  imm)
#define LE_OP_BLTUI (    rs1,      imm) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BIM,                        rs1, __LE_RS2_BLTU, imm)
#define LE_OP_BGEI  (    rs1,      imm) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BIM,                        rs1, __LE_RS2_BGE,  imm)
#define LE_OP_BGEUI (    rs1,      imm) __LE_INST_I(__LE_OPCODE_BRANCH, __LE_FUNCT3_BIM,                        rs1, __LE_RS2_BGEU, imm)

#define LE_OP_LB    (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LB,                     rd, rs1,                imm)
#define LE_OP_LBU   (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LBU,                    rd, rs1,                imm)
#define LE_OP_LH    (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LH,                     rd, rs1,                imm)
#define LE_OP_LHU   (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LHU,                    rd, rs1,                imm)
#define LE_OP_LW    (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LW,                     rd, rs1,                imm)

#define LE_OP_SB    (    rs1, rs2, imm) __LE_INST_S(__LE_OPCODE_STORE,  __LE_FUNCT3_SB,                         rs1, rs2,           imm)
#define LE_OP_SH    (    rs1, rs2, imm) __LE_INST_S(__LE_OPCODE_STORE,  __LE_FUNCT3_SH,                         rs1, rs2,           imm)
#define LE_OP_SW    (    rs1, rs2, imm) __LE_INST_S(__LE_OPCODE_STORE,  __LE_FUNCT3_SW,                         rs1, rs2,           imm)

#define LE_OP_ADDI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_ADDI,                   rd, rs1,                imm)
#define LE_OP_SLTI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SLTI,                   rd, rs1,                imm)
#define LE_OP_SLTIU (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SLTIU,                  rd, rs1,                imm)
#define LE_OP_ANDI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_ANDI,                   rd, rs1,                imm)
#define LE_OP_ORI   (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_ORI,                    rd, rs1,                imm)
#define LE_OP_XORI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_XORI,                   rd, rs1,                imm)
#define LE_OP_SLLI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SLLI,                   rd, rs1,                imm)
#define LE_OP_SRLI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SRLI,                   rd, rs1,                imm)
#define LE_OP_SRAI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SRAI,                   rd, rs1,                imm)

#define LE_OP_ADD   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_ADD,  __LE_FUNCT7_ADD,  rd, rs1, rs2               )
#define LE_OP_SUB   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SUB,  __LE_FUNCT7_SUB,  rd, rs1, rs2               )
#define LE_OP_SLT   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SLT,  __LE_FUNCT7_SLT,  rd, rs1, rs2               )
#define LE_OP_SLTU  (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SLTU, __LE_FUNCT7_SLTU, rd, rs1, rs2               )
#define LE_OP_AND   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_AND,  __LE_FUNCT7_AND,  rd, rs1, rs2               )
#define LE_OP_OR    (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_OR,   __LE_FUNCT7_OR,   rd, rs1, rs2               )
#define LE_OP_XOR   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_XOR,  __LE_FUNCT7_XOR,  rd, rs1, rs2               )
#define LE_OP_SLL   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SLL,  __LE_FUNCT7_SLL,  rd, rs1, rs2               )
#define LE_OP_SRL   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SRL,  __LE_FUNCT7_SRL,  rd, rs1, rs2               )
#define LE_OP_SRA   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SRA,  __LE_FUNCT7_SRA,  rd, rs1, rs2               )

#define LE_OP_MUL   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_MUL,  __LE_FUNCT7_MUL,  rd, rs1, rs2               )
#define LE_OP_DIV   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_DIV,  __LE_FUNCT7_DIV,  rd, rs1, rs2               )
#define LE_OP_MMR   (rd               ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_MMR,  __LE_FUNCT7_MMR,  rd,   0,   0               )

#define LE_OP_HALT  (                 ) __LE_INST_I(__LE_OPCODE_SYSTEM, __LE_FUNCT3_PRIV, __LE_RD_PRIV, __LE_RS1_PRIV, __LE_IMM_HALT)
#define LE_OP_CCC   (                 ) __LE_INST_I(__LE_OPCODE_SYSTEM, __LE_FUNCT3_PRIV, __LE_RD_PRIV, __LE_RS1_PRIV, __LE_IMM_CCC)

#endif /* __ENGINE_OPS_H */

#pragma once

#include "le_isa.h"

#define LE__OP_LUI(    rd,           imm      ) LE__INST_FMT_U(LE__OPCODE_LUI,                                                         rd,           imm      )

#define LE__OP_AUIPC(  rd,           imm      ) LE__INST_FMT_U(LE__OPCODE_AUIPC,                                                       rd,           imm      )

#define LE__OP_JAL(    rd,           imm      ) LE__INST_FMT_J(LE__OPCODE_JAL,                                                         rd,           imm      )

#define LE__OP_JALR(   rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_JALR,     LE__FUNCT3_JALR,                                   rd, rs1,      imm      )

#define LE__OP_BEQ(        rs1, rs2, imm      ) LE__INST_FMT_B(LE__OPCODE_BRANCH,   LE__FUNCT3_BEQ,                                        rs1, rs2, imm      )
#define LE__OP_BNE(        rs1, rs2, imm      ) LE__INST_FMT_B(LE__OPCODE_BRANCH,   LE__FUNCT3_BNE,                                        rs1, rs2, imm      )
#define LE__OP_BLT(        rs1, rs2, imm      ) LE__INST_FMT_B(LE__OPCODE_BRANCH,   LE__FUNCT3_BLT,                                        rs1, rs2, imm      )
#define LE__OP_BGE(        rs1, rs2, imm      ) LE__INST_FMT_B(LE__OPCODE_BRANCH,   LE__FUNCT3_BGE,                                        rs1, rs2, imm      )
#define LE__OP_BLTU(       rs1, rs2, imm      ) LE__INST_FMT_B(LE__OPCODE_BRANCH,   LE__FUNCT3_BLTU,                                       rs1, rs2, imm      )
#define LE__OP_BGEU(       rs1, rs2, imm      ) LE__INST_FMT_B(LE__OPCODE_BRANCH,   LE__FUNCT3_BGEU,                                       rs1, rs2, imm      )

#define LE__OP_LB(     rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_LOAD,     LE__FUNCT3_B,                                      rd, rs1,      imm      )
#define LE__OP_LH(     rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_LOAD,     LE__FUNCT3_H,                                      rd, rs1,      imm      )
#define LE__OP_LW(     rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_LOAD,     LE__FUNCT3_W,                                      rd, rs1,      imm      )
#define LE__OP_LBU(    rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_LOAD,     LE__FUNCT3_BU,                                     rd, rs1,      imm      )
#define LE__OP_LHU(    rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_LOAD,     LE__FUNCT3_HU,                                     rd, rs1,      imm      )

#define LE__OP_SB(         rs1, rs2, imm      ) LE__INST_FMT_S(LE__OPCODE_STORE,    LE__FUNCT3_B,                                          rs1, rs2, imm      )
#define LE__OP_SH(         rs1, rs2, imm      ) LE__INST_FMT_S(LE__OPCODE_STORE,    LE__FUNCT3_H,                                          rs1, rs2, imm      )
#define LE__OP_SW(         rs1, rs2, imm      ) LE__INST_FMT_S(LE__OPCODE_STORE,    LE__FUNCT3_W,                                          rs1, rs2, imm      )

#define LE__OP_ADDI(   rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_OP_IMM,   LE__FUNCT3_ADD,                                    rd, rs1,      imm      )
#define LE__OP_SLTI(   rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_OP_IMM,   LE__FUNCT3_SLT,                                    rd, rs1,      imm      )
#define LE__OP_SLTIU(  rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_OP_IMM,   LE__FUNCT3_SLTU,                                   rd, rs1,      imm      )
#define LE__OP_XORI(   rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_OP_IMM,   LE__FUNCT3_XOR,                                    rd, rs1,      imm      )
#define LE__OP_ORI(    rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_OP_IMM,   LE__FUNCT3_OR,                                     rd, rs1,      imm      )
#define LE__OP_ANDI(   rd, rs1,      imm      ) LE__INST_FMT_I(LE__OPCODE_OP_IMM,   LE__FUNCT3_AND,                                    rd, rs1,      imm      )
#define LE__OP_SLLI(   rd, rs1,      zimm     ) LE__INST_FMT_H(LE__OPCODE_OP_IMM,   LE__FUNCT3_SL,     LE__FUNCT7_LOGIC,               rd, rs1,      zimm     )
#define LE__OP_SRLI(   rd, rs1,      zimm     ) LE__INST_FMT_H(LE__OPCODE_OP_IMM,   LE__FUNCT3_SR,     LE__FUNCT7_LOGIC,               rd, rs1,      zimm     )
#define LE__OP_SRAI(   rd, rs1,      zimm     ) LE__INST_FMT_H(LE__OPCODE_OP_IMM,   LE__FUNCT3_SR,     LE__FUNCT7_ARITH,               rd, rs1,      zimm     )

#define LE__OP_ADD(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_ADD,    LE__FUNCT7_ADD,                 rd, rs1, rs2           )
#define LE__OP_SUB(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_ADD,    LE__FUNCT7_SUB,                 rd, rs1, rs2           )
#define LE__OP_SLT(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_SLT,    LE__FUNCT7_NORM,                rd, rs1, rs2           )
#define LE__OP_SLTU(   rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_SLTU,   LE__FUNCT7_NORM,                rd, rs1, rs2           )
#define LE__OP_XOR(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_XOR,    LE__FUNCT7_NORM,                rd, rs1, rs2           )
#define LE__OP_OR(     rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_OR,     LE__FUNCT7_NORM,                rd, rs1, rs2           )
#define LE__OP_AND(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_AND,    LE__FUNCT7_NORM,                rd, rs1, rs2           )
#define LE__OP_SLL(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_SL,     LE__FUNCT7_LOGIC,               rd, rs1, rs2           )
#define LE__OP_SRL(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_SR,     LE__FUNCT7_LOGIC,               rd, rs1, rs2           )
#define LE__OP_SRA(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_SR,     LE__FUNCT7_ARITH,               rd, rs1, rs2           )

#define LE__OP_FENCE(                         ) LE__INST_FMT_Y(LE__OPCODE_MISC_MEM, LE__FUNCT3_FENCE,                    LE__SYS_FENCE                        )

#define LE__OP_ECALL(                         ) LE__INST_FMT_Y(LE__OPCODE_SYSTEM,   LE__FUNCT3_PRIV,                     LE__SYS_ECALL                        )
#define LE__OP_EBREAK(                        ) LE__INST_FMT_Y(LE__OPCODE_SYSTEM,   LE__FUNCT3_PRIV,                     LE__SYS_EBREAK                       )

#define LE__OP_MUL(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_MUL,    LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_MULH(   rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_MULH,   LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_MULHSU( rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_MULHSU, LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_MULHU(  rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_MULHU,  LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_DIV(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_DIV,    LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_DIVU(   rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_DIVU,   LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_REM(    rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_REM,    LE__FUNCT7_M,                   rd, rs1, rs2           )
#define LE__OP_REMU(   rd, rs1, rs2           ) LE__INST_FMT_R(LE__OPCODE_OP,       LE__FUNCT3_REMU,   LE__FUNCT7_M,                   rd, rs1, rs2           )

#define LE__OP_CSRRW(  rd, rs1,            csr) LE__INST_FMT_C(LE__OPCODE_SYSTEM,   LE__FUNCT3_CSRRW,                                  rd, rs1,            csr)
#define LE__OP_CSRRS(  rd, rs1,            csr) LE__INST_FMT_C(LE__OPCODE_SYSTEM,   LE__FUNCT3_CSRRS,                                  rd, rs1,            csr)
#define LE__OP_CSRRC(  rd, rs1,            csr) LE__INST_FMT_C(LE__OPCODE_SYSTEM,   LE__FUNCT3_CSRRC,                                  rd, rs1,            csr)
#define LE__OP_CSRRWI( rd,           zimm, csr) LE__INST_FMT_D(LE__OPCODE_SYSTEM,   LE__FUNCT3_CSRRWI,                                 rd,           zimm, csr)
#define LE__OP_CSRRSI( rd,           zimm, csr) LE__INST_FMT_D(LE__OPCODE_SYSTEM,   LE__FUNCT3_CSRRSI,                                 rd,           zimm, csr)
#define LE__OP_CSRRCI( rd,           zimm, csr) LE__INST_FMT_D(LE__OPCODE_SYSTEM,   LE__FUNCT3_CSRRCI,                                 rd,           zimm, csr)

#define LE__OP_CCEQ(       rs1, rs2           ) LE__INST_FMT_N(LE__OPCODE_BRANCH,   LE__FUNCT3_CC,     LE__FUNCT7_NORM,  LE__CMP_EQ,       rs1, rs2           )
#define LE__OP_CCNE(       rs1, rs2           ) LE__INST_FMT_N(LE__OPCODE_BRANCH,   LE__FUNCT3_CC,     LE__FUNCT7_NORM,  LE__CMP_NE,       rs1, rs2           )
#define LE__OP_CCLT(       rs1, rs2           ) LE__INST_FMT_N(LE__OPCODE_BRANCH,   LE__FUNCT3_CC,     LE__FUNCT7_NORM,  LE__CMP_LT,       rs1, rs2           )
#define LE__OP_CCGE(       rs1, rs2           ) LE__INST_FMT_N(LE__OPCODE_BRANCH,   LE__FUNCT3_CC,     LE__FUNCT7_NORM,  LE__CMP_GE,       rs1, rs2           )
#define LE__OP_CCLTU(      rs1, rs2           ) LE__INST_FMT_N(LE__OPCODE_BRANCH,   LE__FUNCT3_CC,     LE__FUNCT7_NORM,  LE__CMP_LTU,      rs1, rs2           )
#define LE__OP_CCGEU(      rs1, rs2           ) LE__INST_FMT_N(LE__OPCODE_BRANCH,   LE__FUNCT3_CC,     LE__FUNCT7_NORM,  LE__CMP_GEU,      rs1, rs2           )
#define LE__OP_CCEQI(      rs1,      imm      ) LE__INST_FMT_M(LE__OPCODE_BRANCH,   LE__FUNCT3_CCI,                      LE__CMP_EQ,       rs1,      imm      )
#define LE__OP_CCNEI(      rs1,      imm      ) LE__INST_FMT_M(LE__OPCODE_BRANCH,   LE__FUNCT3_CCI,                      LE__CMP_NE,       rs1,      imm      )
#define LE__OP_CCLTI(      rs1,      imm      ) LE__INST_FMT_M(LE__OPCODE_BRANCH,   LE__FUNCT3_CCI,                      LE__CMP_LT,       rs1,      imm      )
#define LE__OP_CCGEI(      rs1,      imm      ) LE__INST_FMT_M(LE__OPCODE_BRANCH,   LE__FUNCT3_CCI,                      LE__CMP_GE,       rs1,      imm      )
#define LE__OP_CCLTUI(     rs1,      imm      ) LE__INST_FMT_M(LE__OPCODE_BRANCH,   LE__FUNCT3_CCI,                      LE__CMP_LTU,      rs1,      imm      )
#define LE__OP_CCGEUI(     rs1,      imm      ) LE__INST_FMT_M(LE__OPCODE_BRANCH,   LE__FUNCT3_CCI,                      LE__CMP_GEU,      rs1,      imm      )

#define LE__OP_CCC(                           ) LE__INST_FMT_Y(LE__OPCODE_SYSTEM,   LE__FUNCT3_PRIV,                     LE__SYS_CCC                          )
#define LE__OP_HALT(                          ) LE__INST_FMT_Y(LE__OPCODE_SYSTEM,   LE__FUNCT3_PRIV,                     LE__SYS_HALT                         )

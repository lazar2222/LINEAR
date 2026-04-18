#pragma once

#include "le_ops.h"

#define LE_LUI(    rd,           imm      ) EMIT(LE__OP_LUI(    rd,           imm      )) // R[rd] = imm & 0xFFFFF000

#define LE_AUIPC(  rd,           imm      ) EMIT(LE__OP_AUIPC(  rd,           imm      )) // R[rd] = PC + (imm & 0xFFFFF000)

#define LE_JAL(    rd,           imm      ) EMIT(LE__OP_JAL(    rd,           imm      )) // R[rd] = PC + 4; PC += signext(imm & 0x1FFFFE)

#define LE_JALR(   rd, rs1,      imm      ) EMIT(LE__OP_JALR(   rd, rs1,      imm      )) // R[rd] = PC + 4; PC = (R[rs1] + signext(imm & 0xFFF)) & ~1

#define LE_BEQ(        rs1, rs2, imm      ) EMIT(LE__OP_BEQ(        rs1, rs2, imm      )) // PC += (R[rs1] == R[rs2]) ? signext(imm & 0x1FFE) : 4
#define LE_BNE(        rs1, rs2, imm      ) EMIT(LE__OP_BNE(        rs1, rs2, imm      )) // PC += (R[rs1] != R[rs2]) ? signext(imm & 0x1FFE) : 4
#define LE_BLT(        rs1, rs2, imm      ) EMIT(LE__OP_BLT(        rs1, rs2, imm      )) // PC += (R[rs1] <  R[rs2]) ? signext(imm & 0x1FFE) : 4 (signed)
#define LE_BGE(        rs1, rs2, imm      ) EMIT(LE__OP_BGE(        rs1, rs2, imm      )) // PC += (R[rs1] >= R[rs2]) ? signext(imm & 0x1FFE) : 4 (signed)
#define LE_BLTU(       rs1, rs2, imm      ) EMIT(LE__OP_BLTU(       rs1, rs2, imm      )) // PC += (R[rs1] <  R[rs2]) ? signext(imm & 0x1FFE) : 4 (unsigned)
#define LE_BGEU(       rs1, rs2, imm      ) EMIT(LE__OP_BGEU(       rs1, rs2, imm      )) // PC += (R[rs1] >= R[rs2]) ? signext(imm & 0x1FFE) : 4 (unsigned)

#define LE_LB(     rd, rs1,      imm      ) EMIT(LE__OP_LB(     rd, rs1,      imm      )) // R[rd] = signext(M[R[rs1] + signext(imm & 0xFFF)] & 0xFF)
#define LE_LH(     rd, rs1,      imm      ) EMIT(LE__OP_LH(     rd, rs1,      imm      )) // R[rd] = signext(M[R[rs1] + signext(imm & 0xFFF)] & 0xFFFF)
#define LE_LW(     rd, rs1,      imm      ) EMIT(LE__OP_LW(     rd, rs1,      imm      )) // R[rd] = M[R[rs1] + signext(imm & 0xFFF)]
#define LE_LBU(    rd, rs1,      imm      ) EMIT(LE__OP_LBU(    rd, rs1,      imm      )) // R[rd] = M[R[rs1] + signext(imm & 0xFFF)] & 0xFF
#define LE_LHU(    rd, rs1,      imm      ) EMIT(LE__OP_LHU(    rd, rs1,      imm      )) // R[rd] = M[R[rs1] + signext(imm & 0xFFF)] & 0xFFFF

#define LE_SB(         rs1, rs2, imm      ) EMIT(LE__OP_SB(         rs1, rs2, imm      )) // M[R[rs1] + signext(imm & 0xFFF)] = R[rs2] & 0xFF
#define LE_SH(         rs1, rs2, imm      ) EMIT(LE__OP_SH(         rs1, rs2, imm      )) // M[R[rs1] + signext(imm & 0xFFF)] = R[rs2] & 0xFFFF
#define LE_SW(         rs1, rs2, imm      ) EMIT(LE__OP_SW(         rs1, rs2, imm      )) // M[R[rs1] + signext(imm & 0xFFF)] = R[rs2]

#define LE_ADDI(   rd, rs1,      imm      ) EMIT(LE__OP_ADDI(   rd, rs1,      imm      )) // R[rd] = R[rs1] + signext(imm & 0xFFF)
#define LE_SLTI(   rd, rs1,      imm      ) EMIT(LE__OP_SLTI(   rd, rs1,      imm      )) // R[rd] = (R[rs1] < signext(imm & 0xFFF)) ? 1 : 0 (signed)
#define LE_SLTIU(  rd, rs1,      imm      ) EMIT(LE__OP_SLTIU(  rd, rs1,      imm      )) // R[rd] = (R[rs1] < signext(imm & 0xFFF)) ? 1 : 0 (unsigned)
#define LE_XORI(   rd, rs1,      imm      ) EMIT(LE__OP_XORI(   rd, rs1,      imm      )) // R[rd] = R[rs1] ^ signext(imm & 0xFFF)
#define LE_ORI(    rd, rs1,      imm      ) EMIT(LE__OP_ORI(    rd, rs1,      imm      )) // R[rd] = R[rs1] | signext(imm & 0xFFF)
#define LE_ANDI(   rd, rs1,      imm      ) EMIT(LE__OP_ANDI(   rd, rs1,      imm      )) // R[rd] = R[rs1] & signext(imm & 0xFFF)
#define LE_SLLI(   rd, rs1,      zimm     ) EMIT(LE__OP_SLLI(   rd, rs1,      zimm     )) // R[rd] = R[rs1] << (zimm & 0x1F) (logical)
#define LE_SRLI(   rd, rs1,      zimm     ) EMIT(LE__OP_SRLI(   rd, rs1,      zimm     )) // R[rd] = R[rs1] >> (zimm & 0x1F) (logical)
#define LE_SRAI(   rd, rs1,      zimm     ) EMIT(LE__OP_SRAI(   rd, rs1,      zimm     )) // R[rd] = R[rs1] >> (zimm & 0x1F) (arithmetic)

#define LE_ADD(    rd, rs1, rs2           ) EMIT(LE__OP_ADD(    rd, rs1, rs2           )) // R[rd] = R[rs1] + R[rs2]
#define LE_SUB(    rd, rs1, rs2           ) EMIT(LE__OP_SUB(    rd, rs1, rs2           )) // R[rd] = R[rs1] - R[rs2]
#define LE_SLT(    rd, rs1, rs2           ) EMIT(LE__OP_SLT(    rd, rs1, rs2           )) // R[rd] = (R[rs1] < R[rs2]) ? 1 : 0 (signed)
#define LE_SLTU(   rd, rs1, rs2           ) EMIT(LE__OP_SLTU(   rd, rs1, rs2           )) // R[rd] = (R[rs1] < R[rs2]) ? 1 : 0 (unsigned)
#define LE_XOR(    rd, rs1, rs2           ) EMIT(LE__OP_XOR(    rd, rs1, rs2           )) // R[rd] = R[rs1] ^ R[rs2]
#define LE_OR(     rd, rs1, rs2           ) EMIT(LE__OP_OR(     rd, rs1, rs2           )) // R[rd] = R[rs1] | R[rs2]
#define LE_AND(    rd, rs1, rs2           ) EMIT(LE__OP_AND(    rd, rs1, rs2           )) // R[rd] = R[rs1] & R[rs2]
#define LE_SLL(    rd, rs1, rs2           ) EMIT(LE__OP_SLL(    rd, rs1, rs2           )) // R[rd] = R[rs1] << (R[rs2] & 0x1F) (logical)
#define LE_SRL(    rd, rs1, rs2           ) EMIT(LE__OP_SRL(    rd, rs1, rs2           )) // R[rd] = R[rs1] >> (R[rs2] & 0x1F) (logical)
#define LE_SRA(    rd, rs1, rs2           ) EMIT(LE__OP_SRA(    rd, rs1, rs2           )) // R[rd] = R[rs1] >> (R[rs2] & 0x1F) (arithmetic)

#define LE_FENCE(                         ) EMIT(LE__OP_FENCE(                         )) // Fence

#define LE_ECALL(                         ) EMIT(LE__OP_ECALL(                         )) // Environment call
#define LE_EBREAK(                        ) EMIT(LE__OP_EBREAK(                        )) // Environment break

#define LE_MUL(    rd, rs1, rs2           ) EMIT(LE__OP_MUL(    rd, rs1, rs2           )) // R[rd] = (R[rs1] * R[rs2]) & 0xFFFFFFFF
#define LE_MULH(   rd, rs1, rs2           ) EMIT(LE__OP_MULH(   rd, rs1, rs2           )) // R[rd] = ((R[rs1] * R[rs2]) >> 32) & 0xFFFFFFFF (signed, signed)
#define LE_MULHSU( rd, rs1, rs2           ) EMIT(LE__OP_MULHSU( rd, rs1, rs2           )) // R[rd] = ((R[rs1] * R[rs2]) >> 32) & 0xFFFFFFFF (signed, unsigned)
#define LE_MULHU(  rd, rs1, rs2           ) EMIT(LE__OP_MULHU(  rd, rs1, rs2           )) // R[rd] = ((R[rs1] * R[rs2]) >> 32) & 0xFFFFFFFF (unsigned, unsigned)
#define LE_DIV(    rd, rs1, rs2           ) EMIT(LE__OP_DIV(    rd, rs1, rs2           )) // R[rd] = R[rs1] / R[rs2] (signed)
#define LE_DIVU(   rd, rs1, rs2           ) EMIT(LE__OP_DIVU(   rd, rs1, rs2           )) // R[rd] = R[rs1] / R[rs2] (unsigned)
#define LE_REM(    rd, rs1, rs2           ) EMIT(LE__OP_REM(    rd, rs1, rs2           )) // R[rd] = R[rs1] % R[rs2] (signed)
#define LE_REMU(   rd, rs1, rs2           ) EMIT(LE__OP_REMU(   rd, rs1, rs2           )) // R[rd] = R[rs1] % R[rs2] (unsigned)

#define LE_CSRRW(  rd, rs1,            csr) EMIT(LE__OP_CSRRW(  rd, rs1,            csr)) // R[rd] = CSR[csr]; CSR[csr] = R[rs1]
#define LE_CSRRS(  rd, rs1,            csr) EMIT(LE__OP_CSRRS(  rd, rs1,            csr)) // R[rd] = CSR[csr]; CSR[csr] |= R[rs1]
#define LE_CSRRC(  rd, rs1,            csr) EMIT(LE__OP_CSRRC(  rd, rs1,            csr)) // R[rd] = CSR[csr]; CSR[csr] &= ~R[rs1]
#define LE_CSRRWI( rd,           zimm, csr) EMIT(LE__OP_CSRRWI( rd,           zimm, csr)) // R[rd] = CSR[csr]; CSR[csr] = (zimm & 0x1F)
#define LE_CSRRSI( rd,           zimm, csr) EMIT(LE__OP_CSRRSI( rd,           zimm, csr)) // R[rd] = CSR[csr]; CSR[csr] |= (zimm & 0x1F)
#define LE_CSRRCI( rd,           zimm, csr) EMIT(LE__OP_CSRRCI( rd,           zimm, csr)) // R[rd] = CSR[csr]; CSR[csr] &= ~(zimm & 0x1F)

#define LE_CCEQ(       rs1, rs2           ) EMIT(LE__OP_CCEQ(       rs1, rs2           )) // CC = (R[rs1] == R[rs2])
#define LE_CCNE(       rs1, rs2           ) EMIT(LE__OP_CCNE(       rs1, rs2           )) // CC = (R[rs1] != R[rs2])
#define LE_CCLT(       rs1, rs2           ) EMIT(LE__OP_CCLT(       rs1, rs2           )) // CC = (R[rs1] <  R[rs2]) (signed)
#define LE_CCGE(       rs1, rs2           ) EMIT(LE__OP_CCGE(       rs1, rs2           )) // CC = (R[rs1] >= R[rs2]) (signed)
#define LE_CCLTU(      rs1, rs2           ) EMIT(LE__OP_CCLTU(      rs1, rs2           )) // CC = (R[rs1] <  R[rs2]) (unsigned)
#define LE_CCGEU(      rs1, rs2           ) EMIT(LE__OP_CCGEU(      rs1, rs2           )) // CC = (R[rs1] >= R[rs2]) (unsigned)
#define LE_CCEQI(      rs1,      imm      ) EMIT(LE__OP_CCEQI(      rs1,      imm      )) // CC = (R[rs1] == signext(imm & 0xFFF))
#define LE_CCNEI(      rs1,      imm      ) EMIT(LE__OP_CCNEI(      rs1,      imm      )) // CC = (R[rs1] != signext(imm & 0xFFF))
#define LE_CCLTI(      rs1,      imm      ) EMIT(LE__OP_CCLTI(      rs1,      imm      )) // CC = (R[rs1] <  signext(imm & 0xFFF)) (signed)
#define LE_CCGEI(      rs1,      imm      ) EMIT(LE__OP_CCGEI(      rs1,      imm      )) // CC = (R[rs1] >= signext(imm & 0xFFF)) (signed)
#define LE_CCLTUI(     rs1,      imm      ) EMIT(LE__OP_CCLTUI(     rs1,      imm      )) // CC = (R[rs1] <  signext(imm & 0xFFF)) (unsigned)
#define LE_CCGEUI(     rs1,      imm      ) EMIT(LE__OP_CCGEUI(     rs1,      imm      )) // CC = (R[rs1] >= signext(imm & 0xFFF)) (unsigned)

#define LE_CCC(                           ) EMIT(LE__OP_CCC(                           )) // CC = 1
#define LE_HALT(                          ) EMIT(LE__OP_HALT(                          )) // End the kernel

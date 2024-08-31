#ifndef __ENGINE_OPS_H
#define __ENGINE_OPS_H

#include "engine_isa.h"

#define LE_ZERO 0           // Hard-wired zero
#define LE_RA   1           // Return address
#define LE_SP   2           // Stack pointer
#define LE_GP   3           // Global pointer
#define LE_TP   4           // Thread pointer (thread index)
#define LE_FP   8           // Frame pointer
#define LE_S(x) (16 + (x))  // S0 - S15: Shared registers

#define LE_LUI      (rd,           imm) EMIT(LE_OP_LUI   (rd,           imm))
#define LE_AUIPC    (rd,           imm) EMIT(LE_OP_AUIPC (rd,           imm))
#define LE_JAL      (rd,           imm) EMIT(LE_OP_JAL   (rd,           imm))
#define LE_JALR     (rd, rs1,      imm) EMIT(LE_OP_JALR  (rd, rs1,      imm))

#define LE_BEQ      (    rs1, rs2, imm) EMIT(LE_OP_BEQ   (    rs1, rs2, imm))
#define LE_BNE      (    rs1, rs2, imm) EMIT(LE_OP_BNE   (    rs1, rs2, imm))
#define LE_BLT      (    rs1, rs2, imm) EMIT(LE_OP_BLT   (    rs1, rs2, imm))
#define LE_BLTU     (    rs1, rs2, imm) EMIT(LE_OP_BLTU  (    rs1, rs2, imm))
#define LE_BGE      (    rs1, rs2, imm) EMIT(LE_OP_BGE   (    rs1, rs2, imm))
#define LE_BGEU     (    rs1, rs2, imm) EMIT(LE_OP_BGEU  (    rs1, rs2, imm))

#define LE_LB       (rd, rs1,      imm) EMIT(LE_OP_LB    (rd, rs1,      imm))
#define LE_LBU      (rd, rs1,      imm) EMIT(LE_OP_LBU   (rd, rs1,      imm))
#define LE_LH       (rd, rs1,      imm) EMIT(LE_OP_LH    (rd, rs1,      imm))
#define LE_LHU      (rd, rs1,      imm) EMIT(LE_OP_LHU   (rd, rs1,      imm))
#define LE_LW       (rd, rs1,      imm) EMIT(LE_OP_LW    (rd, rs1,      imm))

#define LE_SB       (    rs1, rs2, imm) EMIT(LE_OP_SB    (    rs1, rs2, imm))
#define LE_SH       (    rs1, rs2, imm) EMIT(LE_OP_SH    (    rs1, rs2, imm))
#define LE_SW       (    rs1, rs2, imm) EMIT(LE_OP_SW    (    rs1, rs2, imm))

#define LE_ADDI     (rd, rs1,      imm) EMIT(LE_OP_ADDI  (rd, rs1,      imm))
#define LE_SLTI     (rd, rs1,      imm) EMIT(LE_OP_SLTI  (rd, rs1,      imm))
#define LE_SLTIU    (rd, rs1,      imm) EMIT(LE_OP_SLTIU (rd, rs1,      imm))
#define LE_ANDI     (rd, rs1,      imm) EMIT(LE_OP_ANDI  (rd, rs1,      imm))
#define LE_ORI      (rd, rs1,      imm) EMIT(LE_OP_ORI   (rd, rs1,      imm))
#define LE_XORI     (rd, rs1,      imm) EMIT(LE_OP_XORI  (rd, rs1,      imm))
#define LE_SLLI     (rd, rs1,      imm) EMIT(LE_OP_SLLI  (rd, rs1,      imm))
#define LE_SRLI     (rd, rs1,      imm) EMIT(LE_OP_SRLI  (rd, rs1,      imm))
#define LE_SRAI     (rd, rs1,      imm) EMIT(LE_OP_SRAI  (rd, rs1,      imm))

#define LE_ADD      (rd, rs1, rs2     ) EMIT(LE_OP_ADD   (rd, rs1, rs2     ))
#define LE_SUB      (rd, rs1, rs2     ) EMIT(LE_OP_SUB   (rd, rs1, rs2     ))
#define LE_SLT      (rd, rs1, rs2     ) EMIT(LE_OP_SLT   (rd, rs1, rs2     ))
#define LE_SLTU     (rd, rs1, rs2     ) EMIT(LE_OP_SLTU  (rd, rs1, rs2     ))
#define LE_AND      (rd, rs1, rs2     ) EMIT(LE_OP_AND   (rd, rs1, rs2     ))
#define LE_OR       (rd, rs1, rs2     ) EMIT(LE_OP_OR    (rd, rs1, rs2     ))
#define LE_XOR      (rd, rs1, rs2     ) EMIT(LE_OP_XOR   (rd, rs1, rs2     ))
#define LE_SLL      (rd, rs1, rs2     ) EMIT(LE_OP_SLL   (rd, rs1, rs2     ))
#define LE_SRL      (rd, rs1, rs2     ) EMIT(LE_OP_SRL   (rd, rs1, rs2     ))
#define LE_SRA      (rd, rs1, rs2     ) EMIT(LE_OP_SRA   (rd, rs1, rs2     ))

#define LE_MUL      (rd, rs1, rs2     ) EMIT(LE_OP_MUL   (rd, rs1, rs2     ))
#define LE_MULH     (rd, rs1, rs2     ) EMIT(LE_OP_MULH  (rd, rs1, rs2     ))
#define LE_DIV      (rd, rs1, rs2     ) EMIT(LE_OP_DIV   (rd, rs1, rs2     ))
#define LE_REM      (rd, rs1, rs2     ) EMIT(LE_OP_REM   (rd, rs1, rs2     ))
#define LE_HALT     (                 ) EMIT(LE_OP_HALT  (                 ))
#define LE_CCC      (                 ) EMIT(LE_OP_CCC   (                 ))

#define LE_OP_LUI   (rd,           imm) __LE_INST_U(__LE_OPCODE_LUI,                       rd,           imm)
#define LE_OP_AUIPC (rd,           imm) __LE_INST_U(__LE_OPCODE_AUIPC,                     rd,           imm)
#define LE_OP_JAL   (rd,           imm) __LE_INST_J(__LE_OPCODE_JAL,                       rd,           imm)
#define LE_OP_JALR  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_JALR,   __LE_FUNCT3_JALR,  rd, rs1,      imm)

#define LE_OP_BEQ   (    rs1, rs2, imm) __LE_INST_B(__LE_OPCODE_BRANCH, __LE_FUNCT3_BEQ,       rs1, rs2, imm)
#define LE_OP_BNE   (    rs1, rs2, imm) __LE_INST_B(__LE_OPCODE_BRANCH, __LE_FUNCT3_BNE,       rs1, rs2, imm)
#define LE_OP_BLT   (    rs1, rs2, imm) __LE_INST_B(__LE_OPCODE_BRANCH, __LE_FUNCT3_BLT,       rs1, rs2, imm)
#define LE_OP_BLTU  (    rs1, rs2, imm) __LE_INST_B(__LE_OPCODE_BRANCH, __LE_FUNCT3_BLTU,      rs1, rs2, imm)
#define LE_OP_BGE   (    rs1, rs2, imm) __LE_INST_B(__LE_OPCODE_BRANCH, __LE_FUNCT3_BGE,       rs1, rs2, imm)
#define LE_OP_BGEU  (    rs1, rs2, imm) __LE_INST_B(__LE_OPCODE_BRANCH, __LE_FUNCT3_BGEU,      rs1, rs2, imm)

#define LE_OP_LB    (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LB,    rd, rs1,      imm)
#define LE_OP_LBU   (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LBU,   rd, rs1,      imm)
#define LE_OP_LH    (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LH,    rd, rs1,      imm)
#define LE_OP_LHU   (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LHU,   rd, rs1,      imm)
#define LE_OP_LW    (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_LOAD,   __LE_FUNCT3_LW,    rd, rs1,      imm)

#define LE_OP_SB    (    rs1, rs2, imm) __LE_INST_S(__LE_OPCODE_STORE,  __LE_FUNCT3_SB,        rs1, rs2, imm)
#define LE_OP_SH    (    rs1, rs2, imm) __LE_INST_S(__LE_OPCODE_STORE,  __LE_FUNCT3_SH,        rs1, rs2, imm)
#define LE_OP_SW    (    rs1, rs2, imm) __LE_INST_S(__LE_OPCODE_STORE,  __LE_FUNCT3_SW,        rs1, rs2, imm)

#define LE_OP_ADDI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_ADDI,  rd, rs1,      imm)
#define LE_OP_SLTI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SLTI,  rd, rs1,      imm)
#define LE_OP_SLTIU (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SLTIU, rd, rs1,      imm)
#define LE_OP_ANDI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_ANDI,  rd, rs1,      imm)
#define LE_OP_ORI   (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_ORI,   rd, rs1,      imm)
#define LE_OP_XORI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_XORI,  rd, rs1,      imm)
#define LE_OP_SLLI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SLLI,  rd, rs1,      imm)
#define LE_OP_SRLI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SRLI,  rd, rs1,      imm)
#define LE_OP_SRAI  (rd, rs1,      imm) __LE_INST_I(__LE_OPCODE_OPIMM,  __LE_FUNCT3_SRAI,  rd, rs1,      imm)

#define LE_OP_ADD   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_ADD,   rd, rs1, rs2     )
#define LE_OP_SUB   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SUB,   rd, rs1, rs2     )
#define LE_OP_SLT   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SLT,   rd, rs1, rs2     )
#define LE_OP_SLTU  (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SLTU,  rd, rs1, rs2     )
#define LE_OP_AND   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_AND,   rd, rs1, rs2     )
#define LE_OP_OR    (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_OR,    rd, rs1, rs2     )
#define LE_OP_XOR   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_XOR,   rd, rs1, rs2     )
#define LE_OP_SLL   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SLL,   rd, rs1, rs2     )
#define LE_OP_SRL   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SRL,   rd, rs1, rs2     )
#define LE_OP_SRA   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_SRA,   rd, rs1, rs2     )

#define LE_OP_MUL   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_MUL,   rd, rs1, rs2     )
#define LE_OP_MULH  (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_MULH,  rd, rs1, rs2     )
#define LE_OP_DIV   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_DIV,   rd, rs1, rs2     )
#define LE_OP_REM   (rd, rs1, rs2     ) __LE_INST_R(__LE_OPCODE_OP,     __LE_FUNCT3_REM,   rd, rs1, rs2     )

#define LE_OP_HALT  (                 ) __LE_INST_I(__LE_OPCODE_SYSTEM, __LE_FUNCT3_PRIV,  __LE_RD_PRIV, __LE_RS1_PRIV, __LE_IMM_HALT)
#define LE_OP_CCC   (                 ) __LE_INST_I(__LE_OPCODE_SYSTEM, __LE_FUNCT3_PRIV,  __LE_RD_PRIV, __LE_RS1_PRIV, __LE_IMM_CCC)

#endif /* __ENGINE_OPS_H */

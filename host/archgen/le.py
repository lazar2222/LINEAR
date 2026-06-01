from definitions import *

# Architecture definition
# Base:       RV32I
# Extensions: M, Zicsr, Zicc, Ziwarp, Zxlinear
ARCH_NAME        = "LE"
ARCH_INSTR_WIDTH = 32

# Indexes
INDEX_REG = Index("reg",  5)
INDEX_CSR = Index("csr", 12)

# Instruction Fields
OPCODE_PREFIX = InstructionField("opcode_prefix",  2, InstructionFieldType.FIXED,     0b11                     )
OPCODE        = InstructionField("opcode",         5, InstructionFieldType.OPCODE                              )
FUNCT3        = InstructionField("funct3",         3, InstructionFieldType.MODIFIER                            )
FUNCT7        = InstructionField("funct7",         7, InstructionFieldType.MODIFIER                            )
CMP           = InstructionField("cmp",            5, InstructionFieldType.MODIFIER                            )
SYS           = InstructionField("sys",           12, InstructionFieldType.MODIFIER                            )
RD0           = InstructionField("rd0",            5, InstructionFieldType.INDEX,     INDEX_REG                )
RS1           = InstructionField("rs1",            5, InstructionFieldType.INDEX,     INDEX_REG                )
RS2           = InstructionField("rs2",            5, InstructionFieldType.INDEX,     INDEX_REG                )
SIMM          = InstructionField("simm",          32, InstructionFieldType.IMMEDIATE, ImmediateType.SIGN_EXTEND)
ZIMM          = InstructionField("zimm",          32, InstructionFieldType.IMMEDIATE, ImmediateType.ZERO_EXTEND)
CSR           = InstructionField("csr",           12, InstructionFieldType.INDEX,     INDEX_CSR                )

# Jams
RD0_ZERO = InstructionFieldSpecialization("zero", 0, RD0, jam=True) # For Y format that repurposes rd0 but fixes it to zero
RS1_ZERO = InstructionFieldSpecialization("zero", 0, RS1, jam=True) # For Y format that repurposes rs1 but fixes it to zero

# Instruction Formats       0              2       7               8             12      15            20              21  25             31            32
R = InstructionFormat("r", (OPCODE_PREFIX, OPCODE, RD0,                          FUNCT3, RS1,          RS2,                FUNCT7                       )) # Register
I = InstructionFormat("i", (OPCODE_PREFIX, OPCODE, RD0,                          FUNCT3, RS1,          (SIMM, 0, 11)                                    )) # Immediate
H = InstructionFormat("h", (OPCODE_PREFIX, OPCODE, RD0,                          FUNCT3, RS1,          (ZIMM, 0,  4),      FUNCT7                       )) # Immediate shift          (I specialization for immediate shifts)
Y = InstructionFormat("y", (OPCODE_PREFIX, OPCODE, RD0_ZERO,                     FUNCT3, RS1_ZERO,     SYS                                              )) # System                   (I specialization for system instructions, e.g., ECALL, EBREAK)
C = InstructionFormat("c", (OPCODE_PREFIX, OPCODE, RD0,                          FUNCT3, RS1,          CSR                                              )) # CSR                      (I specialization for CSR instructions)
D = InstructionFormat("d", (OPCODE_PREFIX, OPCODE, RD0,                          FUNCT3, (ZIMM, 0, 4), CSR                                              )) # CSR immediate            (I specialization for CSR instructions with immediate)
N = InstructionFormat("n", (OPCODE_PREFIX, OPCODE, CMP,                          FUNCT3, RS1,          RS2,                FUNCT7                       )) # Condition code register  (For Zicc)
M = InstructionFormat("m", (OPCODE_PREFIX, OPCODE, CMP,                          FUNCT3, RS1,          (SIMM, 0, 11)                                    )) # Condition code immediate (For Zicc with immediate)
S = InstructionFormat("s", (OPCODE_PREFIX, OPCODE, (SIMM,  0,  4),               FUNCT3, RS1,          RS2,                (SIMM, 5, 11)                )) # Store
B = InstructionFormat("b", (OPCODE_PREFIX, OPCODE, (SIMM, 11, 11), (SIMM, 1, 4), FUNCT3, RS1,          RS2,                (SIMM, 5, 10), (SIMM, 12, 12))) # Branch
U = InstructionFormat("u", (OPCODE_PREFIX, OPCODE, RD0,                          (SIMM, 12, 31)                                                         )) # Upper immediate
J = InstructionFormat("j", (OPCODE_PREFIX, OPCODE, RD0,                          (SIMM, 12, 19),       (SIMM, 11, 11), (SIMM, 1, 10),     (SIMM, 20, 20))) # Jump

# Opcodes
OPCODE_LOAD       = InstructionFieldSpecialization("load",       0b00_000, OPCODE) # LB, LH, LW, LBU, LHU
OPCODE_LOAD_FP    = InstructionFieldSpecialization("load_fp",    0b00_001, OPCODE)
OPCODE_CUSTOM_0   = InstructionFieldSpecialization("custom_0",   0b00_010, OPCODE)
OPCODE_MISC_MEM   = InstructionFieldSpecialization("misc_mem",   0b00_011, OPCODE) # FENCE
OPCODE_OP_IMM     = InstructionFieldSpecialization("op_imm",     0b00_100, OPCODE) # ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
OPCODE_AUIPC      = InstructionFieldSpecialization("auipc",      0b00_101, OPCODE) # AUIPC
OPCODE_OP_IMM_32  = InstructionFieldSpecialization("op_imm_32",  0b00_110, OPCODE)
OPCODE_RESERVED_0 = InstructionFieldSpecialization("reserved_0", 0b00_111, OPCODE)
OPCODE_STORE      = InstructionFieldSpecialization("store",      0b01_000, OPCODE) # SB, SH, SW
OPCODE_STORE_FP   = InstructionFieldSpecialization("store_fp",   0b01_001, OPCODE)
OPCODE_CUSTOM_1   = InstructionFieldSpecialization("custom_1",   0b01_010, OPCODE)
OPCODE_AMO        = InstructionFieldSpecialization("amo",        0b01_011, OPCODE)
OPCODE_OP         = InstructionFieldSpecialization("op",         0b01_100, OPCODE) # ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND, (M) MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
OPCODE_LUI        = InstructionFieldSpecialization("lui",        0b01_101, OPCODE) # LUI
OPCODE_OP_32      = InstructionFieldSpecialization("op_32",      0b01_110, OPCODE)
OPCODE_RESERVED_1 = InstructionFieldSpecialization("reserved_1", 0b01_111, OPCODE)
OPCODE_MADD       = InstructionFieldSpecialization("madd",       0b10_000, OPCODE)
OPCODE_MSUB       = InstructionFieldSpecialization("msub",       0b10_001, OPCODE)
OPCODE_NMSUB      = InstructionFieldSpecialization("nmsub",      0b10_010, OPCODE)
OPCODE_NMADD      = InstructionFieldSpecialization("nmadd",      0b10_011, OPCODE)
OPCODE_OP_FP      = InstructionFieldSpecialization("op_fp",      0b10_100, OPCODE)
OPCODE_OP_V       = InstructionFieldSpecialization("op_v",       0b10_101, OPCODE)
OPCODE_CUSTOM_2   = InstructionFieldSpecialization("custom_2",   0b10_110, OPCODE)
OPCODE_RESERVED_2 = InstructionFieldSpecialization("reserved_2", 0b10_111, OPCODE)
OPCODE_BRANCH     = InstructionFieldSpecialization("branch",     0b11_000, OPCODE) # BEQ, BNE, BLT, BGE, BLTU, BGEU, (Zicc) CCEQ, CCNE, CCLT, CCGE, CCLTU, CCGEU, CCEQI, CCNEI, CCLTI, CCGEI, CCLTUI, CCGEUI
OPCODE_JALR       = InstructionFieldSpecialization("jalr",       0b11_001, OPCODE) # JALR
OPCODE_RESERVED_4 = InstructionFieldSpecialization("reserved_4", 0b11_010, OPCODE)
OPCODE_JAL        = InstructionFieldSpecialization("jal",        0b11_011, OPCODE) # JAL
OPCODE_SYSTEM     = InstructionFieldSpecialization("system",     0b11_100, OPCODE) # ECALL, EBREAK, (Zicsr) CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI, (Zicc) CCC, (Ziwarp) HALT
OPCODE_OP_VE      = InstructionFieldSpecialization("op_ve",      0b11_101, OPCODE)
OPCODE_CUSTOM_3   = InstructionFieldSpecialization("custom_3",   0b11_110, OPCODE)
OPCODE_RESERVED_3 = InstructionFieldSpecialization("reserved_3", 0b11_111, OPCODE)

# Instruction Modifiers (RV32I unless noted otherwise)
## FUNCT3
### OPCODE JALR
FUNCT3_JALR   = InstructionFieldSpecialization("jalr",   0b000, FUNCT3)
### OPCODE BRANCH
FUNCT3_BEQ    = InstructionFieldSpecialization("beq",    0b000, FUNCT3)
FUNCT3_BNE    = InstructionFieldSpecialization("bne",    0b001, FUNCT3)
FUNCT3_CC     = InstructionFieldSpecialization("cc",     0b010, FUNCT3) # Multiple instructions ((Zicc) CCEQ, CCNE, CCLT, CCGE, CCLTU, CCGEU)
FUNCT3_CCI    = InstructionFieldSpecialization("cci",    0b011, FUNCT3) # Multiple instructions ((Zicc) CCEQI, CCNEI, CCLTI, CCGEI, CCLTUI, CCGEUI)
FUNCT3_BLT    = InstructionFieldSpecialization("blt",    0b100, FUNCT3)
FUNCT3_BGE    = InstructionFieldSpecialization("bge",    0b101, FUNCT3)
FUNCT3_BLTU   = InstructionFieldSpecialization("bltu",   0b110, FUNCT3)
FUNCT3_BGEU   = InstructionFieldSpecialization("bgeu",   0b111, FUNCT3)
### OPCODE LOAD/STORE
FUNCT3_B      = InstructionFieldSpecialization("b",      0b000, FUNCT3) # Multiple instructions (LB, SB)
FUNCT3_H      = InstructionFieldSpecialization("h",      0b001, FUNCT3) # Multiple instructions (LH, SH)
FUNCT3_W      = InstructionFieldSpecialization("w",      0b010, FUNCT3) # Multiple instructions (LW, SW)
FUNCT3_BU     = InstructionFieldSpecialization("bu",     0b100, FUNCT3) # Multiple instructions (LBU)
FUNCT3_HU     = InstructionFieldSpecialization("hu",     0b101, FUNCT3) # Multiple instructions (LHU)
### OPCODE OP/OP_IMM
FUNCT3_ADD    = InstructionFieldSpecialization("add",    0b000, FUNCT3) # Multiple instructions (ADD, SUB, ADDI)
FUNCT3_SLT    = InstructionFieldSpecialization("slt",    0b010, FUNCT3) # Multiple instructions (SLT, SLTI)
FUNCT3_SLTU   = InstructionFieldSpecialization("sltu",   0b011, FUNCT3) # Multiple instructions (SLTU, SLTIU)
FUNCT3_XOR    = InstructionFieldSpecialization("xor",    0b100, FUNCT3) # Multiple instructions (XOR, XORI)
FUNCT3_OR     = InstructionFieldSpecialization("or",     0b110, FUNCT3) # Multiple instructions (OR, ORI)
FUNCT3_AND    = InstructionFieldSpecialization("and",    0b111, FUNCT3) # Multiple instructions (AND, ANDI)
FUNCT3_SL     = InstructionFieldSpecialization("sl",     0b001, FUNCT3) # Multiple instructions (SLL, SLLI)
FUNCT3_SR     = InstructionFieldSpecialization("sr",     0b101, FUNCT3) # Multiple instructions (SRL, SRLI, SRA, SRAI)
FUNCT3_MUL    = InstructionFieldSpecialization("mul",    0b000, FUNCT3) # For M
FUNCT3_MULH   = InstructionFieldSpecialization("mulh",   0b001, FUNCT3) # For M
FUNCT3_MULHSU = InstructionFieldSpecialization("mulhsu", 0b010, FUNCT3) # For M
FUNCT3_MULHU  = InstructionFieldSpecialization("mulhu",  0b011, FUNCT3) # For M
FUNCT3_DIV    = InstructionFieldSpecialization("div",    0b100, FUNCT3) # For M
FUNCT3_DIVU   = InstructionFieldSpecialization("divu",   0b101, FUNCT3) # For M
FUNCT3_REM    = InstructionFieldSpecialization("rem",    0b110, FUNCT3) # For M
FUNCT3_REMU   = InstructionFieldSpecialization("remu",   0b111, FUNCT3) # For M
### OPCODE MISC_MEM
FUNCT3_FENCE  = InstructionFieldSpecialization("fence",  0b000, FUNCT3)
### OPCODE SYSTEM
FUNCT3_PRIV   = InstructionFieldSpecialization("priv",   0b000, FUNCT3) # Multiple instructions (ECALL, EBREAK, (Zicc) CCC, (Ziwarp) HALT)
FUNCT3_CSRRW  = InstructionFieldSpecialization("csrrw",  0b001, FUNCT3)
FUNCT3_CSRRS  = InstructionFieldSpecialization("csrrs",  0b010, FUNCT3)
FUNCT3_CSRRC  = InstructionFieldSpecialization("csrrc",  0b011, FUNCT3)
FUNCT3_CSRRWI = InstructionFieldSpecialization("csrrwi", 0b101, FUNCT3)
FUNCT3_CSRRSI = InstructionFieldSpecialization("csrrsi", 0b110, FUNCT3)
FUNCT3_CSRRCI = InstructionFieldSpecialization("csrrci", 0b111, FUNCT3)

## FUNCT7
### OPCODE OP/OP_IMM/BRANCH
FUNCT7_NORM   = InstructionFieldSpecialization("norm",   0b0000000, FUNCT7) # Multiple instructions (SLT, SLTU, XOR, OR, AND, (Zicc) CCEQ, CCNE, CCLT, CCGE, CCLTU, CCGEU)
FUNCT7_ADD    = InstructionFieldSpecialization("add",    0b0000000, FUNCT7)
FUNCT7_SUB    = InstructionFieldSpecialization("sub",    0b0100000, FUNCT7)
FUNCT7_LOGIC  = InstructionFieldSpecialization("logic",  0b0000000, FUNCT7) # Multiple instructions (SRL, SLL, SLLI, SRLI)
FUNCT7_ARITH  = InstructionFieldSpecialization("arith",  0b0100000, FUNCT7) # Multiple instructions (SRA, SRAI)
FUNCT7_M      = InstructionFieldSpecialization("m",      0b0000001, FUNCT7) # Multiple instructions ((M) MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU)

## CMP
### OPCODE BRANCH
CMP_EQ        = InstructionFieldSpecialization("eq",     0b00000, CMP) # Multiple instructions ((Zicc) CCEQ, CCEQI)
CMP_NE        = InstructionFieldSpecialization("ne",     0b00001, CMP) # Multiple instructions ((Zicc) CCNE, CCNEI)
CMP_LT        = InstructionFieldSpecialization("lt",     0b00100, CMP) # Multiple instructions ((Zicc) CCLT, CCLTI)
CMP_GE        = InstructionFieldSpecialization("ge",     0b00101, CMP) # Multiple instructions ((Zicc) CCGE, CCGEI)
CMP_LTU       = InstructionFieldSpecialization("ltu",    0b00110, CMP) # Multiple instructions ((Zicc) CCLTU, CCLTUI)
CMP_GEU       = InstructionFieldSpecialization("geu",    0b00111, CMP) # Multiple instructions ((Zicc) CCGEU, CCGEUI)

## SYS
### OPCODE MISC_MEM
SYS_FENCE     = InstructionFieldSpecialization("fence",  0b0000_0000_0000, SYS)
### OPCODE SYSTEM
SYS_ECALL     = InstructionFieldSpecialization("ecall",  0b0000_0000_0000, SYS)
SYS_EBREAK    = InstructionFieldSpecialization("ebreak", 0b0000_0000_0001, SYS)
SYS_HALT      = InstructionFieldSpecialization("halt",   0b0000_0000_1010, SYS) # For Ziwarp
SYS_CCC       = InstructionFieldSpecialization("ccc",    0b0000_0001_0000, SYS) # For Zicc

# Instructions
## RV32I
LUI    = Instruction("lui",    U, (OPCODE_LUI,                                          ), "R[rd] =  0 + (simm & 0xFFFF_F000)"                                     )
AUIPC  = Instruction("auipc",  U, (OPCODE_AUIPC,                                        ), "R[rd] = PC + (simm & 0xFFFF_F000)"                                     )
JAL    = Instruction("jal",    J, (OPCODE_JAL,                                          ), "R[rd] = PC + 4; PC += (     0 + signext(simm & 0x001F_FFFE)) & ~1"     )
JALR   = Instruction("jalr",   I, (OPCODE_JALR,              FUNCT3_JALR                ), "R[rd] = PC + 4; PC  = (R[rs1] + signext(simm & 0x0000_0FFF)) & ~1"     )
BEQ    = Instruction("beq",    B, (OPCODE_BRANCH,            FUNCT3_BEQ                 ), "PC += (R[rs1] == R[rs2]) ? signext(simm & 0x0000_1FFE) : 4"            )
BNE    = Instruction("bne",    B, (OPCODE_BRANCH,            FUNCT3_BNE                 ), "PC += (R[rs1] != R[rs2]) ? signext(simm & 0x0000_1FFE) : 4"            )
BLT    = Instruction("blt",    B, (OPCODE_BRANCH,            FUNCT3_BLT                 ), "PC += (R[rs1] <  R[rs2]) ? signext(simm & 0x0000_1FFE) : 4 (signed)"   )
BGE    = Instruction("bge",    B, (OPCODE_BRANCH,            FUNCT3_BGE                 ), "PC += (R[rs1] >= R[rs2]) ? signext(simm & 0x0000_1FFE) : 4 (signed)"   )
BLTU   = Instruction("bltu",   B, (OPCODE_BRANCH,            FUNCT3_BLTU                ), "PC += (R[rs1] <  R[rs2]) ? signext(simm & 0x0000_1FFE) : 4 (unsigned)" )
BGEU   = Instruction("bgeu",   B, (OPCODE_BRANCH,            FUNCT3_BGEU                ), "PC += (R[rs1] >= R[rs2]) ? signext(simm & 0x0000_1FFE) : 4 (unsigned)" )
LB     = Instruction("lb",     I, (OPCODE_LOAD,              FUNCT3_B                   ), "R[rd] = signext(M[R[rs1] + signext(simm & 0x0000_0FFF)] & 0x0000_00FF)")
LH     = Instruction("lh",     I, (OPCODE_LOAD,              FUNCT3_H                   ), "R[rd] = signext(M[R[rs1] + signext(simm & 0x0000_0FFF)] & 0x0000_FFFF)")
LW     = Instruction("lw",     I, (OPCODE_LOAD,              FUNCT3_W                   ), "R[rd] = signext(M[R[rs1] + signext(simm & 0x0000_0FFF)] & 0xFFFF_FFFF)")
LBU    = Instruction("lbu",    I, (OPCODE_LOAD,              FUNCT3_BU                  ), "R[rd] = zeroext(M[R[rs1] + signext(simm & 0x0000_0FFF)] & 0x0000_00FF)")
LHU    = Instruction("lhu",    I, (OPCODE_LOAD,              FUNCT3_HU                  ), "R[rd] = zeroext(M[R[rs1] + signext(simm & 0x0000_0FFF)] & 0x0000_FFFF)")
SB     = Instruction("sb",     S, (OPCODE_STORE,             FUNCT3_B                   ), "M[R[rs1] + signext(simm & 0x0000_0FFF)] = R[rs2] & 0x0000_00FF"        )
SH     = Instruction("sh",     S, (OPCODE_STORE,             FUNCT3_H                   ), "M[R[rs1] + signext(simm & 0x0000_0FFF)] = R[rs2] & 0x0000_FFFF"        )
SW     = Instruction("sw",     S, (OPCODE_STORE,             FUNCT3_W                   ), "M[R[rs1] + signext(simm & 0x0000_0FFF)] = R[rs2] & 0xFFFF_FFFF"        )
ADDI   = Instruction("addi",   I, (OPCODE_OP_IMM,            FUNCT3_ADD                 ), "R[rd] = (R[rs1] +  signext(simm & 0x0000_0FFF))"                       )
SLTI   = Instruction("slti",   I, (OPCODE_OP_IMM,            FUNCT3_SLT                 ), "R[rd] = (R[rs1] <  signext(simm & 0x0000_0FFF)) ? 1 : 0 (signed)"      )
SLTIU  = Instruction("sltiu",  I, (OPCODE_OP_IMM,            FUNCT3_SLTU                ), "R[rd] = (R[rs1] <  signext(simm & 0x0000_0FFF)) ? 1 : 0 (unsigned)"    )
XORI   = Instruction("xori",   I, (OPCODE_OP_IMM,            FUNCT3_XOR                 ), "R[rd] = (R[rs1] ^  signext(simm & 0x0000_0FFF))"                       )
ORI    = Instruction("ori",    I, (OPCODE_OP_IMM,            FUNCT3_OR                  ), "R[rd] = (R[rs1] |  signext(simm & 0x0000_0FFF))"                       )
ANDI   = Instruction("andi",   I, (OPCODE_OP_IMM,            FUNCT3_AND                 ), "R[rd] = (R[rs1] &  signext(simm & 0x0000_0FFF))"                       )
SLLI   = Instruction("slli",   H, (OPCODE_OP_IMM,            FUNCT3_SL,     FUNCT7_LOGIC), "R[rd] = (R[rs1] << zeroext(zimm & 0x0000_001F)) (logical)"             )
SRLI   = Instruction("srli",   H, (OPCODE_OP_IMM,            FUNCT3_SR,     FUNCT7_LOGIC), "R[rd] = (R[rs1] >> zeroext(zimm & 0x0000_001F)) (logical)"             )
SRAI   = Instruction("srai",   H, (OPCODE_OP_IMM,            FUNCT3_SR,     FUNCT7_ARITH), "R[rd] = (R[rs1] >> zeroext(zimm & 0x0000_001F)) (arithmetic)"          )
ADD    = Instruction("add",    R, (OPCODE_OP,                FUNCT3_ADD,    FUNCT7_ADD  ), "R[rd] = (R[rs1] +  (R[rs2] & 0xFFFF_FFFF))"                            )
SUB    = Instruction("sub",    R, (OPCODE_OP,                FUNCT3_ADD,    FUNCT7_SUB  ), "R[rd] = (R[rs1] -  (R[rs2] & 0xFFFF_FFFF))"                            )
SLT    = Instruction("slt",    R, (OPCODE_OP,                FUNCT3_SLT,    FUNCT7_NORM ), "R[rd] = (R[rs1] <  (R[rs2] & 0xFFFF_FFFF)) ? 1 : 0 (signed)"           )
SLTU   = Instruction("sltu",   R, (OPCODE_OP,                FUNCT3_SLTU,   FUNCT7_NORM ), "R[rd] = (R[rs1] <  (R[rs2] & 0xFFFF_FFFF)) ? 1 : 0 (unsigned)"         )
XOR    = Instruction("xor",    R, (OPCODE_OP,                FUNCT3_XOR,    FUNCT7_NORM ), "R[rd] = (R[rs1] ^  (R[rs2] & 0xFFFF_FFFF))"                            )
OR     = Instruction("or",     R, (OPCODE_OP,                FUNCT3_OR,     FUNCT7_NORM ), "R[rd] = (R[rs1] |  (R[rs2] & 0xFFFF_FFFF))"                            )
AND    = Instruction("and",    R, (OPCODE_OP,                FUNCT3_AND,    FUNCT7_NORM ), "R[rd] = (R[rs1] &  (R[rs2] & 0xFFFF_FFFF))"                            )
SLL    = Instruction("sll",    R, (OPCODE_OP,                FUNCT3_SL,     FUNCT7_LOGIC), "R[rd] = (R[rs1] << (R[rs2] & 0x0000_001F)) (logical)"                  )
SRL    = Instruction("srl",    R, (OPCODE_OP,                FUNCT3_SR,     FUNCT7_LOGIC), "R[rd] = (R[rs1] >> (R[rs2] & 0x0000_001F)) (logical)"                  )
SRA    = Instruction("sra",    R, (OPCODE_OP,                FUNCT3_SR,     FUNCT7_ARITH), "R[rd] = (R[rs1] >> (R[rs2] & 0x0000_001F)) (arithmetic)"               )
FENCE  = Instruction("fence",  Y, (OPCODE_MISC_MEM,          FUNCT3_FENCE,  SYS_FENCE   ), "Fence"                                                                 )
ECALL  = Instruction("ecall",  Y, (OPCODE_SYSTEM,            FUNCT3_PRIV,   SYS_ECALL   ), "Environment call"                                                      )
EBREAK = Instruction("ebreak", Y, (OPCODE_SYSTEM,            FUNCT3_PRIV,   SYS_EBREAK  ), "Environment break"                                                     )
## M
MUL    = Instruction("mul",    R, (OPCODE_OP,                FUNCT3_MUL,    FUNCT7_M    ), "R[rd] = ((R[rs1] * R[rs2]) >>  0) & 0xFFFF_FFFF"                       )
MULH   = Instruction("mulh",   R, (OPCODE_OP,                FUNCT3_MULH,   FUNCT7_M    ), "R[rd] = ((R[rs1] * R[rs2]) >> 32) & 0xFFFF_FFFF (signed, signed)"      )
MULHSU = Instruction("mulhsu", R, (OPCODE_OP,                FUNCT3_MULHSU, FUNCT7_M    ), "R[rd] = ((R[rs1] * R[rs2]) >> 32) & 0xFFFF_FFFF (signed, unsigned)"    )
MULHU  = Instruction("mulhu",  R, (OPCODE_OP,                FUNCT3_MULHU,  FUNCT7_M    ), "R[rd] = ((R[rs1] * R[rs2]) >> 32) & 0xFFFF_FFFF (unsigned, unsigned)"  )
DIV    = Instruction("div",    R, (OPCODE_OP,                FUNCT3_DIV,    FUNCT7_M    ), "R[rd] = ((R[rs1] / R[rs2]) >>  0) & 0xFFFF_FFFF (signed)"              )
DIVU   = Instruction("divu",   R, (OPCODE_OP,                FUNCT3_DIVU,   FUNCT7_M    ), "R[rd] = ((R[rs1] / R[rs2]) >>  0) & 0xFFFF_FFFF (unsigned)"            )
REM    = Instruction("rem",    R, (OPCODE_OP,                FUNCT3_REM,    FUNCT7_M    ), "R[rd] = ((R[rs1] % R[rs2]) >>  0) & 0xFFFF_FFFF (signed)"              )
REMU   = Instruction("remu",   R, (OPCODE_OP,                FUNCT3_REMU,   FUNCT7_M    ), "R[rd] = ((R[rs1] % R[rs2]) >>  0) & 0xFFFF_FFFF (unsigned)"            )
## Zicsr
CSRRW  = Instruction("csrrw",  C, (OPCODE_SYSTEM,            FUNCT3_CSRRW               ), "R[rd] = CSR[csr]; CSR[csr]  =  R[rs1]"                                 )
CSRRS  = Instruction("csrrs",  C, (OPCODE_SYSTEM,            FUNCT3_CSRRS               ), "R[rd] = CSR[csr]; CSR[csr] |=  R[rs1]"                                 )
CSRRC  = Instruction("csrrc",  C, (OPCODE_SYSTEM,            FUNCT3_CSRRC               ), "R[rd] = CSR[csr]; CSR[csr] &= ~R[rs1]"                                 )
CSRRWI = Instruction("csrrwi", D, (OPCODE_SYSTEM,            FUNCT3_CSRRWI              ), "R[rd] = CSR[csr]; CSR[csr]  =  (zimm & 0x0000_001F)"                   )
CSRRSI = Instruction("csrrsi", D, (OPCODE_SYSTEM,            FUNCT3_CSRRSI              ), "R[rd] = CSR[csr]; CSR[csr] |=  (zimm & 0x0000_001F)"                   )
CSRRCI = Instruction("csrrci", D, (OPCODE_SYSTEM,            FUNCT3_CSRRCI              ), "R[rd] = CSR[csr]; CSR[csr] &= ~(zimm & 0x0000_001F)"                   )
## Zicc
CCEQ   = Instruction("cceq",   N, (OPCODE_BRANCH,   CMP_EQ,  FUNCT3_CC,     FUNCT7_NORM ), "CC = (R[rs1] == R[rs2])"                                               )
CCNE   = Instruction("ccne",   N, (OPCODE_BRANCH,   CMP_NE,  FUNCT3_CC,     FUNCT7_NORM ), "CC = (R[rs1] != R[rs2])"                                               )
CCLT   = Instruction("cclt",   N, (OPCODE_BRANCH,   CMP_LT,  FUNCT3_CC,     FUNCT7_NORM ), "CC = (R[rs1] <  R[rs2]) (signed)"                                      )
CCGE   = Instruction("ccge",   N, (OPCODE_BRANCH,   CMP_GE,  FUNCT3_CC,     FUNCT7_NORM ), "CC = (R[rs1] >= R[rs2]) (signed)"                                      )
CCLTU  = Instruction("ccltu",  N, (OPCODE_BRANCH,   CMP_LTU, FUNCT3_CC,     FUNCT7_NORM ), "CC = (R[rs1] <  R[rs2]) (unsigned)"                                    )
CCGEU  = Instruction("ccgeu",  N, (OPCODE_BRANCH,   CMP_GEU, FUNCT3_CC,     FUNCT7_NORM ), "CC = (R[rs1] >= R[rs2]) (unsigned)"                                    )
CCEQI  = Instruction("cceqi",  M, (OPCODE_BRANCH,   CMP_EQ,  FUNCT3_CCI                 ), "CC = (R[rs1] == signext(simm & 0x0000_0FFF))"                          )
CCNEI  = Instruction("ccnei",  M, (OPCODE_BRANCH,   CMP_NE,  FUNCT3_CCI                 ), "CC = (R[rs1] != signext(simm & 0x0000_0FFF))"                          )
CCLTI  = Instruction("cclti",  M, (OPCODE_BRANCH,   CMP_LT,  FUNCT3_CCI                 ), "CC = (R[rs1] <  signext(simm & 0x0000_0FFF)) (signed)"                 )
CCGEI  = Instruction("ccgei",  M, (OPCODE_BRANCH,   CMP_GE,  FUNCT3_CCI                 ), "CC = (R[rs1] >= signext(simm & 0x0000_0FFF)) (signed)"                 )
CCLTUI = Instruction("ccltui", M, (OPCODE_BRANCH,   CMP_LTU, FUNCT3_CCI                 ), "CC = (R[rs1] <  signext(simm & 0x0000_0FFF)) (unsigned)"               )
CCGEUI = Instruction("ccgeui", M, (OPCODE_BRANCH,   CMP_GEU, FUNCT3_CCI                 ), "CC = (R[rs1] >= signext(simm & 0x0000_0FFF)) (unsigned)"               )
CCC    = Instruction("ccc",    Y, (OPCODE_SYSTEM,            FUNCT3_PRIV,   SYS_CCC     ), "CC = 1"                                                                )
## Ziwarp
HALT   = Instruction("halt",   Y, (OPCODE_SYSTEM,            FUNCT3_PRIV,   SYS_HALT    ), "End the kernel"                                                        )

# General purpose registers (GPRs)
X00 = IndexEntry("x00",  0, INDEX_REG, "zero", desc=     "Hard-wired zero")
X01 = IndexEntry("x01",  1, INDEX_REG, "ra",   desc=      "Return address")
X02 = IndexEntry("x02",  2, INDEX_REG, "sp",   desc=       "Stack pointer")
X03 = IndexEntry("x03",  3, INDEX_REG, "gp",   desc=      "Global pointer")
X04 = IndexEntry("x04",  4, INDEX_REG, "tp",   desc=      "Thread pointer")
X05 = IndexEntry("x05",  5, INDEX_REG, "t0",   desc="Temporary register 0")
X06 = IndexEntry("x06",  6, INDEX_REG, "t1",   desc="Temporary register 1")
X07 = IndexEntry("x07",  7, INDEX_REG, "t2",   desc="Temporary register 2")
X08 = IndexEntry("x08",  8, INDEX_REG, "s0",   desc=    "Saved register 0")
X09 = IndexEntry("x09",  9, INDEX_REG, "s1",   desc=    "Saved register 1")
X10 = IndexEntry("x10", 10, INDEX_REG, "a0",   desc= "Argument register 0")
X11 = IndexEntry("x11", 11, INDEX_REG, "a1",   desc= "Argument register 1")
X12 = IndexEntry("x12", 12, INDEX_REG, "a2",   desc= "Argument register 2")
X13 = IndexEntry("x13", 13, INDEX_REG, "a3",   desc= "Argument register 3")
X14 = IndexEntry("x14", 14, INDEX_REG, "a4",   desc= "Argument register 4")
X15 = IndexEntry("x15", 15, INDEX_REG, "a5",   desc= "Argument register 5")
X16 = IndexEntry("x16", 16, INDEX_REG, "a6",   desc= "Argument register 6")
X17 = IndexEntry("x17", 17, INDEX_REG, "a7",   desc= "Argument register 7")
X18 = IndexEntry("x18", 18, INDEX_REG, "s2",   desc=    "Saved register 2")
X19 = IndexEntry("x19", 19, INDEX_REG, "s3",   desc=    "Saved register 3")
X20 = IndexEntry("x20", 20, INDEX_REG, "s4",   desc=    "Saved register 4")
X21 = IndexEntry("x21", 21, INDEX_REG, "s5",   desc=    "Saved register 5")
X22 = IndexEntry("x22", 22, INDEX_REG, "s6",   desc=    "Saved register 6")
X23 = IndexEntry("x23", 23, INDEX_REG, "s7",   desc=    "Saved register 7")
X24 = IndexEntry("x24", 24, INDEX_REG, "s8",   desc=    "Saved register 8")
X25 = IndexEntry("x25", 25, INDEX_REG, "s9",   desc=    "Saved register 9")
X26 = IndexEntry("x26", 26, INDEX_REG, "t3",   desc="Temporary register 3")
X27 = IndexEntry("x27", 27, INDEX_REG, "t4",   desc="Temporary register 4")
X28 = IndexEntry("x28", 28, INDEX_REG, "r0",   desc="Reduction register 0") # (Zxlinear) lane[i]r0 = lane[i+0]r0 (no change)
X29 = IndexEntry("x29", 29, INDEX_REG, "r1",   desc="Reduction register 1") # (Zxlinear) lane[i]r1 = lane[i+1]r0 (circular shift by 1)
X30 = IndexEntry("x30", 30, INDEX_REG, "r2",   desc="Reduction register 2") # (Zxlinear) lane[i]r2 = lane[i+2]r0 (circular shift by 2)
X31 = IndexEntry("x31", 31, INDEX_REG, "r3",   desc="Reduction register 3") # (Zxlinear) lane[i]r3 = lane[i+3]r0 (circular shift by 3)

# Control and status registers (CSRs)
## Custom read/write
COMPATMODE = IndexEntry("compatmode", 0x800, INDEX_CSR, desc="bit 0: Enable reduction registers; bit 1: Trap on control flow divergence") # Zxlinear
DEBUGMODE  = IndexEntry("debugmode",  0x801, INDEX_CSR, desc="bit 0: Core halt; bit 1: Single step enabled"                             ) # Zxlinear
THREADID   = IndexEntry("threadid",   0x80A, INDEX_CSR, desc="Thread id, base + laneid"                                                 ) # Ziwarp
GRIDID     = IndexEntry("gridid",     0x80B, INDEX_CSR, desc="Grid id, runtime controlled"                                              ) # Ziwarp
CCFLAGS    = IndexEntry("ccflags",    0x810, INDEX_CSR, desc="Condition code flags, one bit per lane"                                   ) # Zicc
## Custom read-only
COREID     = IndexEntry("coreid",     0xCCA, INDEX_CSR, desc="Core id"                                                                  ) # Ziwarp
LANEID     = IndexEntry("laneid",     0xCCB, INDEX_CSR, desc="Lane id"                                                                  ) # Ziwarp
## Standard read-only
CYCLE      = IndexEntry("cycle",      0xC00, INDEX_CSR, desc="Cycle count"                                                              )
TIME       = IndexEntry("time",       0xC01, INDEX_CSR, desc="Time stamp"                                                               )
INSTRET    = IndexEntry("instret",    0xC02, INDEX_CSR, desc="Instruction retired"                                                      )
## Standard read-only high 32 bits
CYCLEH     = IndexEntry("cycleh",     0xC80, INDEX_CSR, desc="High cycle count"                                                         )
TIMEH      = IndexEntry("timeh",      0xC81, INDEX_CSR, desc="High time stamp"                                                          )
INSTRETH   = IndexEntry("instreth",   0xC82, INDEX_CSR, desc="High instruction retired"                                                 )

# Generation hints
GENVARS = GenerationHints(
    emit_macro = "emit",
)

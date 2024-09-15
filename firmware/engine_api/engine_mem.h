#ifndef __ENGINE_MEMORY_H
#define __ENGINE_MEMORY_H

#define LE_SM0_BASE     0x00000000
#define LE_SM1_BASE     0x00080000
#define LE_IMEM_BASE    0x00000000
#define LE_IMEM_SIZE    0x00020000
#define LE_DMEM_BASE    0x00020000
#define LE_DMEM_SIZE    0x00020000
#define LE_PERIPH_BASE  0x00040000
#define LE_PERIPH_SIZE  0x00040000

#define LE_SM_BASE(sm)      ((sm) == 0 ? LE_SM0_BASE : LE_SM1_BASE)
#define LE_SM_IMEM(sm)      LE_SM_BASE(sm) + LE_IMEM_BASE
#define LE_SM_DMEM(sm)      LE_SM_BASE(sm) + LE_DMEM_BASE
#define LE_SM_PERIPH(sm)    LE_SM_BASE(sm) + LE_PERIPH_BASE

#endif /* __ENGINE_MEMORY_H */

#pragma once

#include "le_isa.h"

#define LE_COMPATMODE    0x800    // bit 0: Enable reduction registers; bit 1: Trap on control flow divergence
#define LE_DEBUGMODE     0x801    // bit 0: Core halt, bit 1: Single step enabled
#define LE_THREADID      0x80A    // Thread id, base + laneid
#define LE_GRIDID        0x80B    // Grid id, runtime controlled
#define LE_CCFLAGS       0x810    // Condition code flags, one bit per lane
#define LE_COREID        0xCCA    // Core id
#define LE_LANEID        0xCCB    // Lane id
#define LE_CYCLE         0xC00    // Cycle count
#define LE_TIME          0xC01    // Time stamp
#define LE_INSTRET       0xC02    // Instruction retired
#define LE_CYCLEH        0xC80    // High cycle count
#define LE_TIMEH         0xC81    // High time stamp
#define LE_INSTRETH      0xC82    // High instruction retired

#include "../engine_api/engine_ops.h"
#include "../engine_api/engine_mem.h"

int main() {
	//init my shared register
	LE_ADD(LE_S0, LE_ZERO, LE_ZERO);

	//clear highest bit in thread id
	LE_LUI(LE_R0, 1 << 32);// 10..0
	LE_XORI(LE_R0, LE_R0, ~0);// 01..1
	LE_AND(LE_R0, LE_TP, LE_R0);

	//load image width
	LE_ADDI(LE_R9, LE_ZERO, 640);

	//get pixel position based on thread id
	LE_DIV(LE_R0, LE_R0, LE_R9);
	LE_MMR(LE_R1); //r0 = i, r1 = j

	//get pixel value
	int image_address = LE_SM_PERIPH(0);
	LE_LUI(LE_R2, image_address);
	LE_ADDI(LE_R2, LE_R2, image_address); //r2 = image_address
									
	LE_SLLI(LE_R0, LE_R0, 10);
	LE_ADDI(LE_R0, LE_R0, LE_R1);
	LE_SLLI(LE_R0, LE_R0, 2);

	LE_ADD(LE_R2, LE_R2, LE_R0);
	LE_LW(LE_R2, LE_R2, 0); //r2 = pixel

	//split pixel to rgb(range 0 to 1)
	LE_LUI(LE_R9, 255 << 24);
	LE_LUI(LE_R8, 255 << 24);

	LE_AND(LE_R3, LE_R2, LE_R9);
	LE_DIV(LE_R3, LE_R3, LE_R8);

	LE_SLLI(LE_R2, LE_R2, 8);
	LE_AND(LE_R4, LE_R2, LE_R9);
	LE_DIV(LE_R4, LE_R4, LE_R8);

	LE_SLLI(LE_R2, LE_R2, 8);
	LE_AND(LE_R5, LE_R2, LE_R9);
	LE_DIV(LE_R5, LE_R5, LE_R8); //r3 = r, r4 = g, r5 = b

	//find cmin
	LE_ADD(LE_R2, LE_ZERO, LE_R3);

	LE_BLTU(LE_R4, LE_R2);
	LE_ADD(LE_R2, LE_ZERO, LE_R4);
	LE_CCC();

	LE_BLTU(LE_R5, LE_R2);
	LE_ADD(LE_R2, LE_ZERO, LE_R5);
	LE_CCC();

	LE_SUB(LE_R6, LE_ZERO, LE_R2);

	//find cmax
	LE_ADD(LE_R2, LE_ZERO, LE_R3);

	LE_BLTU(LE_R2, LE_R4);
	LE_ADD(LE_R2, LE_ZERO, LE_R4);
	LE_CCC();

	LE_BLTU(LE_R2, LE_R5);
	LE_ADD(LE_R2, LE_ZERO, LE_R5);
	LE_CCC();

	//calculate delta
	LE_ADD(LE_R6, LE_R6, LE_R2); //- r2 = cmax, r6 = delta

	//calculate hue_index
	LE_BEQ(LE_R2, LE_R3);
	LE_SUB(LE_R7, LE_R4, LE_R5);
	LE_DIV(LE_R7, LE_R7, LE_R6);
	LE_CCC();

	LE_BEQ(LE_R2, LE_R4);
	LE_SUB(LE_R7, LE_R5, LE_R3);
	LE_DIV(LE_R7, LE_R7, LE_R6);
	LE_ADD(LE_R7, LE_R7, 2 << 24);
	LE_CCC();

	LE_BEQ(LE_R2, LE_R5);
	LE_SUB(LE_R7, LE_R3, LE_R5);
	LE_DIV(LE_R7, LE_R7, LE_R6);
	LE_ADD(LE_R7, LE_R7, 4 << 4);
	LE_CCC(); //- r7 = hue_index

	//calculate hsv(h in range 0 to 6, sv in range 0 to 1)
	LE_BLTI(LE_R7, 0);
	LE_ADDI(LE_R7, LE_R7, 6 << 24);
	LE_CCC(); //- r7 = h

	LE_ADD(LE_R8, LE_ZERO, LE_ZERO);
	LE_BNE(LE_R2, LE_ZERO);
	LE_DIV(LE_R8, LE_R6, LE_R2);
	LE_CCC(); //- r8 = s, r2 = v

	//load filter
	int filter_address = LE_SM_DMEM(0);

	LE_LUI(LE_R3, filter_address);

	//calculate cumulative
	LE_LW(LE_R1, LE_R3, 0);
	LE_BGEU(LE_R7, LE_R1);

	LE_LW(LE_R1, LE_R3, 4);
	LE_BGEU(LE_R1, LE_R7);

	LE_LW(LE_R1, LE_R3, 8);
	LE_BGEU(LE_R8, LE_R1);

	LE_LW(LE_R1, LE_R3, 16);
	LE_BGEU(LE_R1, LE_R8);

	LE_LW(LE_R1, LE_R3, 20);
	LE_BGEU(LE_R2, LE_R1);

	LE_LW(LE_R1, LE_R3, 24);
	LE_BGEU(LE_R1, LE_R2);

	LE_ADD(LE_S0, LE_S0, 1);
	LE_CCC();

	LE_LW(LE_R1, LE_R3, 28);
	LE_BGEU(LE_R7, LE_R1);

	LE_LW(LE_R1, LE_R3, 32);
	LE_BGEU(LE_R1, LE_R7);

	LE_LW(LE_R1, LE_R3, 36);
	LE_BGEU(LE_R8, LE_R1);

	LE_LW(LE_R1, LE_R3, 40);
	LE_BGEU(LE_R1, LE_R8);

	LE_LW(LE_R1, LE_R3, 44);
	LE_BGEU(LE_R2, LE_R1);

	LE_LW(LE_R1, LE_R3, 48);
	LE_BGEU(LE_R1, LE_R2);

	LE_ADD(LE_S0, LE_S0, 1);
	LE_CCC(); //- s0 = cumulative

	//reduce cumulative
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	//save cumulative(only smallest thread id in block)
	LE_ANDI(LE_R0, LE_TP, 15);
	LE_BEQI(LE_R0, 0);
	LE_LW(LE_R4, LE_R3, 52);
	LE_ADD(LE_R4, LE_R4, LE_S0);
	LE_SW(LE_R3, LE_R4, 52);
	LE_CCC();
	LE_HALT();

	return 0;
}
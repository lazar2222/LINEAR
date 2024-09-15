#include "../engine_api/engine_ops.h"
#include "../engine_api/engine_mem.h"

int main() {
	//clear highest bit in thread id
	LE_LUI(LE_R0, 1 << 32); //10..0
	LE_XORI(LE_R0, LE_R0, ~0); //01..1
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

	LE_SLLI(LE_R8, LE_R0, 10);
	LE_ADDI(LE_R8, LE_R8, LE_R1);
	LE_SLLI(LE_R8, LE_R8, 2);

	LE_ADD(LE_R2, LE_R2, LE_R8);
	LE_LW(LE_R2, LE_R2, 0);//r2 = pixel

	//CALCULATE FIRST POINT FMAX = 1, NMIN = 0
	//calculate weight
	LE_ADD(LE_R3, LE_ZERO, LE_ZERO);

	LE_BLTU(LE_R2, 100 << 24);

	LE_ADDI(LE_R8, LE_ZERO, -100 << 24);
	LE_DIV(LE_R3, LE_R2, LE_R8);
	LE_CCC(); // r3 = weight

	LE_SRLI(LE_R9, LE_R3, 3);
	LE_SLLI(LE_R0, LE_R0, 21);
	LE_SLLI(LE_R1, LE_R1, 21);
		//neki shift za r0, r1, r3 npr >>3

	LE_MUL(LE_R4, LE_R1, LE_R9);
	LE_MUL(LE_R5, LE_R0, LE_R9); //r4 = x, r5 = y

	LE_ADD(LE_S0, LE_ZERO, LE_R3);
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	LE_ADD(LE_R3, LE_ZERO, LE_S0);//r3 = norm

	LE_ADD(LE_S0, LE_ZERO, LE_R4);
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	LE_ADD(LE_R4, LE_ZERO, LE_S0);//r4 = sumx

	LE_ADD(LE_S0, LE_ZERO, LE_R5);
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	LE_ADD(LE_R5, LE_ZERO, LE_S0);//r5 = sumy

	//CALCULATE SECOND POINT FMAX = 0, NMIN = 1
	//calculate weight
	LE_ADD(LE_R6, LE_ZERO, LE_ZERO);

	LE_BLTU(155 << 24, LE_R2);

	LE_SUB(LE_R6, LE_R2, 155 << 24);
	LE_ADDI(LE_R8, LE_ZERO, 100 << 24);
	LE_DIV(LE_R6, LE_R6, LE_R8);
	LE_CCC(); // r6 = weight

	LE_SRLI(LE_R9, LE_R6, 3);
	//neki shift za r0, r1, r3

	LE_MUL(LE_R7, LE_R1, LE_R9);
	LE_MUL(LE_R8, LE_R0, LE_R9); //r7 = x, r8 = y

	LE_ADD(LE_S0, LE_ZERO, LE_R6);
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	LE_ADD(LE_R6, LE_ZERO, LE_S0);//r6 = norm

	LE_ADD(LE_S0, LE_ZERO, LE_R7);
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	LE_ADD(LE_R7, LE_ZERO, LE_S0);//r7 = sumx

	LE_ADD(LE_S0, LE_ZERO, LE_R8);
	LE_ADD(LE_S0, LE_S0, LE_S8);
	LE_ADD(LE_S0, LE_S0, LE_S4);
	LE_ADD(LE_S0, LE_S0, LE_S2);
	LE_ADD(LE_S0, LE_S0, LE_S1);

	LE_ADD(LE_R8, LE_ZERO, LE_S0);//r8 = sumy

	//write result(only the thread with smallest id in block)
	int result_address = LE_SM_DMEM(0);
	LE_LUI(LE_R9, result_address);

	LE_ANDI(LE_R0, LE_TP, 15);
	LE_BEQI(LE_R0, 0);

	LE_LW(LE_R1, LE_R9, 0);
	LE_ADD(LE_R1, LE_R1, LE_R3);
	LE_SW(LE_R9, LE_R1, 0);

	LE_LW(LE_R1, LE_R9, 4);
	LE_ADD(LE_R1, LE_R1, LE_R4);
	LE_SW(LE_R9, LE_R1, 4);

	LE_LW(LE_R1, LE_R9, 8);
	LE_ADD(LE_R1, LE_R1, LE_R5);
	LE_SW(LE_R9, LE_R1, 8);

	LE_LW(LE_R1, LE_R9, 16);
	LE_ADD(LE_R1, LE_R1, LE_R6);
	LE_SW(LE_R9, LE_R1, 16);

	LE_LW(LE_R1, LE_R9, 20);
	LE_ADD(LE_R1, LE_R1, LE_R7);
	LE_SW(LE_R9, LE_R1, 20);

	LE_LW(LE_R1, LE_R9, 24);
	LE_ADD(LE_R1, LE_R1, LE_R8);
	LE_SW(LE_R9, LE_R1, 24);

	LE_CCC(); 

	return 0;
}
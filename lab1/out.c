#include "stdint.h"


void __nor(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 0, 0, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __and(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {0, 0, 0, 1};
	*out0 = (table[inw] >> 0) & 1;

}

void __nand(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 1, 1, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __xor(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {0, 1, 1, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void calc(const uint8_t in [], uint8_t out []){

	uint8_t temp [9][1];

	temp[0][0] = in[0];
	temp[1][0] = in[1];
	temp[2][0] = in[2];
	temp[3][0] = in[3];
	__and(&temp[0][0], &temp[1][0], &temp[4][0]);
	__nor(&temp[4][0], &temp[2][0], &temp[5][0]);
	__xor(&temp[4][0], &temp[5][0], &temp[6][0]);
	__and(&temp[6][0], &temp[5][0], &temp[8][0]);
	__nand(&temp[8][0], &temp[3][0], &temp[7][0]);

	out[0] = temp[6][0];
	out[1] = temp[7][0];

}

int entry_point(void){

	uint8_t out[2];
	uint8_t in[4] = {1, 1, 1, 1, };

	calc(in, out);

	return 0;
}

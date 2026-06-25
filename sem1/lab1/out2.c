#include "stdint.h"


void __i2_o2_0(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 2, 3, 2};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o1_0(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {0, 0, 1, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __i1_o1_0(const uint8_t *in0, uint8_t *out0){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {0, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __i2_o1_1(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {0, 1, 1, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __i2_o1_2(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 1, 0, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __i1_o1_1(const uint8_t *in0, uint8_t *out0){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {0, 1};
	*out0 = (table[inw] >> 0) & 1;

}

void __i1_o1_2(const uint8_t *in0, uint8_t *out0){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {0, 1};
	*out0 = (table[inw] >> 0) & 1;

}

void __i2_o2_1(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 1, 1, 1};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o2_2(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {3, 3, 3, 3};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o2_3(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 3, 0, 1};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i1_o2_0(const uint8_t *in0, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {3, 1};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o2_4(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {2, 1, 1, 3};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o1_3(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 0, 0, 1};
	*out0 = (table[inw] >> 0) & 1;

}

void __i1_o2_1(const uint8_t *in0, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {1, 1};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i1_o2_2(const uint8_t *in0, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {1, 2};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o1_4(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 1, 1, 0};
	*out0 = (table[inw] >> 0) & 1;

}

void __i1_o1_3(const uint8_t *in0, uint8_t *out0){

	uint8_t inw = (*in0 << 0);
	const uint8_t table[2] = {1, 1};
	*out0 = (table[inw] >> 0) & 1;

}

void __i2_o2_5(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {0, 2, 0, 3};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o2_6(const uint8_t *in0, const uint8_t *in1, uint8_t *out0, uint8_t *out1){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {2, 1, 2, 2};
	*out0 = (table[inw] >> 0) & 1;
	*out1 = (table[inw] >> 1) & 1;

}

void __i2_o1_5(const uint8_t *in0, const uint8_t *in1, uint8_t *out0){

	uint8_t inw = (*in0 << 0) + (*in1 << 1);
	const uint8_t table[4] = {1, 0, 0, 1};
	*out0 = (table[inw] >> 0) & 1;

}

void calc(const uint8_t in [], uint8_t out []){

	uint8_t temp [28][2];

	temp[0][0] = in[0];
	temp[1][0] = in[1];
	temp[2][0] = in[2];
	temp[3][0] = in[3];
	temp[4][0] = in[4];
	__i2_o1_3(&temp[0][0], &temp[1][0], &temp[5][0]);
	__i1_o2_0(&temp[2][0], &temp[6][0], &temp[6][1]);
	__i2_o2_3(&temp[3][0], &temp[4][0], &temp[7][0], &temp[7][1]);
	__i2_o1_5(&temp[6][0], &temp[6][0], &temp[8][0]);
	__i1_o2_1(&temp[1][0], &temp[9][0], &temp[9][1]);
	__i1_o1_3(&temp[2][0], &temp[10][0]);
	__i2_o2_5(&temp[2][0], &temp[6][0], &temp[11][0], &temp[11][1]);
	__i2_o2_3(&temp[2][0], &temp[3][0], &temp[12][0], &temp[12][1]);
	__i2_o1_2(&temp[7][1], &temp[11][1], &temp[13][0]);
	__i2_o2_0(&temp[7][0], &temp[11][1], &temp[14][0], &temp[14][1]);
	__i2_o1_4(&temp[6][1], &temp[8][0], &temp[15][0]);
	__i2_o2_0(&temp[14][0], &temp[7][1], &temp[16][0], &temp[16][1]);
	__i1_o2_1(&temp[14][0], &temp[17][0], &temp[17][1]);
	__i2_o2_4(&temp[6][1], &temp[7][0], &temp[18][0], &temp[18][1]);
	__i2_o2_0(&temp[3][0], &temp[9][0], &temp[19][0], &temp[19][1]);
	__i2_o1_2(&temp[11][0], &temp[19][1], &temp[20][0]);
	__i2_o1_5(&temp[10][0], &temp[10][0], &temp[21][0]);
	__i2_o1_0(&temp[16][1], &temp[5][0], &temp[22][0]);
	__i2_o1_2(&temp[13][0], &temp[6][1], &temp[23][0]);
	__i1_o1_3(&temp[20][0], &temp[24][0]);
	__i1_o2_2(&temp[10][0], &temp[25][0], &temp[25][1]);
	__i1_o1_1(&temp[0][0], &temp[26][0]);
	__i2_o2_1(&temp[14][1], &temp[7][0], &temp[27][0], &temp[27][1]);

	out[0] = temp[25][0];
	out[1] = temp[23][0];
	out[2] = temp[27][0];
	out[3] = temp[24][0];
	out[4] = temp[22][0];
	out[5] = temp[15][0];
	out[6] = temp[21][0];
	out[7] = temp[18][1];
	out[8] = temp[26][0];
	out[9] = temp[12][1];
	out[10] = temp[12][0];
	out[11] = temp[17][0];
	out[12] = temp[2][0];

}

int main(void){

	uint8_t out[13];
	uint8_t in[5] = {0, 0, 0, 0, 1};

	calc(in, out);

	return 0;
}

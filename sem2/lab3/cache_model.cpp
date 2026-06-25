#include <stdint.h>

struct bit_7{
	unsigned char value; // 7 bit
};

struct bit_3{
	unsigned char value; // 3 bit
};

struct bit_2{
	unsigned char value; // 2 bit
};

struct bit_10{
	int16_t value; // 10 bit
};

struct bit_35{
	int64_t value; // 35 bit
};

struct Tag{
	bool operator== (const Tag & other) const{
		return value.value == other.value.value;
	}
	bit_35 value;
}; //35 bit

struct Address{
	Tag tag;
	bit_10 index;
	bit_7 offest;
}; // 52 bit

struct Cache_string{
	bool valid;
	Tag saved_tag;
	unsigned char data;
	bit_3 life_time; // 3 bit
	bool modified;
};

struct Inner_state{
	Cache_string S[8] = {}; //S0 === all zeros
};

enum class Opcode : uint8_t{
	Noop = 0,
	Read,
	Write,
	Snoop
};

struct Input_data{
	Opcode opcode;
	Tag tag;
	unsigned char data;
};

struct Output_data{
	bool valid;
	Tag tag;
	unsigned char data;
};

struct Cache{
	Inner_state states[1024];
};


static unsigned char ddr5[1024] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int current_index = 0;

int64_t merge(Tag tag, int index){
	return tag.value.value + (index << 35);
}

unsigned char memory(Tag tag){
	return ddr5[merge(tag, current_index)%1024];
}

void memory(Tag tag, unsigned char new_data){
	 ddr5[merge(tag, current_index)%1024] = new_data;
}

void state_change(Inner_state & state, const Input_data &input){

	switch (input.opcode)
	{
		case Opcode::Read:
			{
				int hit_n = -1;
				int last_free_n = -1;
				for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
					auto & string = state.S[i];
					if(!string.valid){
						last_free_n = i;
						continue;
					}
					if(!(string.saved_tag == input.tag)){
						continue;
					}
					hit_n = i;
					break;
				}

				if(hit_n != -1){ // if hit
					for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
						auto & string = state.S[i];
						if(i == hit_n){
							string.life_time.value = 0;
						}
						else{
							string.life_time.value++; // Least recently read counter increase
						}
					}
				}
				else if(last_free_n != -1){ // if miss, but cache not full
					auto & free_string = state.S[last_free_n];
					free_string.data = memory(input.tag);
					free_string.life_time.value = 0;
					free_string.saved_tag = input.tag;
					free_string.modified = false;
					free_string.valid = true;

					for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
						auto & string = state.S[i];
						if(i != last_free_n){
							string.life_time.value++; // Least recently read counter increase
						}
					}
				}
				else{// if miss, and have to make free
					int lrr_n = -1;
					int lrr_value = -1;
					for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
						auto & string = state.S[i];
						if(lrr_value < string.life_time.value){
							lrr_n = i;
							lrr_value = string.life_time.value;
						}
					}

					auto & writeback_string = state.S[lrr_n];
					if(writeback_string.modified){
						memory(writeback_string.saved_tag, writeback_string.data);
					}
					writeback_string.data = memory(input.tag);
					writeback_string.life_time.value = 0;
					writeback_string.saved_tag = input.tag;
					writeback_string.modified = false;
					writeback_string.valid = true;

					for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
						auto & string = state.S[i];
						if(i != lrr_n){
							string.life_time.value++; // Least recently read counter increase
						}
					}
				}
			}
			break;
		case Opcode::Write:
			{
				int hit_n = -1;
				for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
					auto & string = state.S[i];
					if(!string.valid){
						continue;
					}
					if(!(string.saved_tag == input.tag)){
						continue;
					}
					hit_n = i;
					break;
				}

				if(hit_n != -1){ // if hit
					auto & hit_string = state.S[hit_n];
					hit_string.data = input.data;
					hit_string.modified = true;
				}
				else{ // if miss
					memory(input.tag, input.data);
				}	
			}
			break;
		case Opcode::Snoop:
			for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
				auto & string = state.S[i];
				if(!string.valid){
					continue;
				}
				if(!(string.saved_tag == input.tag)){
					continue;
				}
				if(string.modified){ //writeback
					memory(input.tag, string.data); 
				}
				string.valid = false; //invalidate
			}
			break;
		default:
			break;
	}
}

Output_data output(const Inner_state & state, const Input_data &input){

	Output_data res = {}; // valid = false

	switch (input.opcode)
	{
		case Opcode::Read:
			for(int i = 0; i < sizeof(state.S)/sizeof(Cache_string); i++){
				auto & string = state.S[i];
				if(!string.valid){
					continue;
				}
				if(!(string.saved_tag == input.tag)){
					continue;
				}
				res.valid = true;
				res.tag = input.tag;
				res.data = string.data;
				break;
			}
			break;
		case Opcode::Write: //do nothing
			break;
		case Opcode::Snoop: //do nothing
			break;
		default:
			break;
	}

	return res;
}

int test_write_to_mem_minimal(){

	//Note: write to memory occures with first instruction since "политика заведения - промах по чтению"
	Input_data input[1] = {
		{
			Opcode::Write, //Opcode
			{{0xBEDA}}, //Tag
			0xf //Data
		}
	};
	Cache cache = {};
	const int index = 112;
	auto & state = cache.states[index];
	current_index = index;
	for(int i = 0; i < sizeof(input)/sizeof(Input_data); i++){
		auto output_data = output(state, input[i]);
		state_change(state, input[i]);
	}
	/*
		S0 -> S0 / {0, 0, 0}
		// Запись по адресу: {tag, index}
	*/
	return 0;
}

int test_free_from_cache(){

	Input_data input[9] = {
		{
			Opcode::Read, //Opcode
			{{0x0DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x1DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x2DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x3DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x4DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x5DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x6DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0x7DED}}, //Tag
			0x0 //Data
		},
		{
			Opcode::Read, //Opcode
			{{0xBEDA}}, //Tag
			0x0 //Data
		}
	};
	//Note: 8 reads for fill of cache and 9th will trigger read with free of one cache string
	Cache cache = {};
	const int index = 112;
	current_index = index;
	auto & state = cache.states[index];
	for(int i = 0; i < sizeof(input)/sizeof(Input_data); i++){
		auto output_data = output(state, input[i]);
		// do stuff with output
		state_change(state, input[i]);
	}
	/*
		Sn : {8x{valid, tag, data, life_time, modified}}
		X : {opcode, tag, data}
		Y : {valid, tag, data}

		Ss -> Sf: {Sf} / {Y}

		S0 -> S1: {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {1, 0x0DED, 0x0, 0, 0}} / {1, 0x0DED, 0x0}
		S1 -> S2: {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {1, 0x1DED, 0x1, 0, 0}, {1, 0x0DED, 0x0, 1, 0}} / {1, 0x1DED, 0x1}
		S2 -> S3: {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {1, 0x2DED, 0x2, 0, 0}, {1, 0x1DED, 0x1, 1, 0}, {1, 0x0DED, 0x0, 2, 0}} / {1, 0x2DED, 0x2}
		S3 -> S4: {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {1, 0x3DED, 0x3, 0, 0}, {1, 0x2DED, 0x2, 1, 0}, {1, 0x1DED, 0x1, 2, 0}, {1, 0x0DED, 0x0, 3, 0}} / {1, 0x3DED, 0x3}
		S4 -> S4: {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {1, 0x4DED, 0x4, 0, 0}, {1, 0x3DED, 0x3, 1, 0}, {1, 0x2DED, 0x2, 2, 0}, {1, 0x1DED, 0x1, 3, 0}, {1, 0x0DED, 0x0, 4, 0}} / {1, 0x4DED, 0x4}
		S5 -> S6: {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}, {1, 0x5DED, 0x5, 0, 0}, {1, 0x4DED, 0x4, 1, 0}, {1, 0x3DED, 0x3, 2, 0}, {1, 0x2DED, 0x2, 3, 0}, {1, 0x1DED, 0x1, 4, 0}, {1, 0x0DED, 0x0, 5, 0}} / {1, 0x5DED, 0x5}
		S6 -> S7: {{0, 0, 0, 0, 0}, {1, 0x6DED, 0x6, 0, 0}, {1, 0x5DED, 0x5, 1, 0}, {1, 0x4DED, 0x4, 2, 0}, {1, 0x3DED, 0x3, 3, 0}, {1, 0x2DED, 0x2, 4, 0}, {1, 0x1DED, 0x1, 5, 0}, {1, 0x0DED, 0x0, 6, 0}} / {1, 0x6DED, 0x6}
		S7 -> S8: {{1, 0x7DED, 0x7, 0, 0}, {1, 0x6DED, 0x6, 1, 0}, {1, 0x5DED, 0x5, 2, 0}, {1, 0x4DED, 0x4, 3, 0}, {1, 0x3DED, 0x3, 4, 0}, {1, 0x2DED, 0x2, 5, 0}, {1, 0x1DED, 0x1, 6, 0}, {1, 0x0DED, 0x0, 7, 0}} / {1, 0x7DED, 0x7}
		S8 -> S9: {{1, 0x7DED, 0x7, 1, 0}, {1, 0x6DED, 0x6, 2, 0}, {1, 0x5DED, 0x5, 3, 0}, {1, 0x4DED, 0x4, 4, 0}, {1, 0x3DED, 0x3, 5, 0}, {1, 0x2DED, 0x2, 6, 0}, {1, 0x1DED, 0x1, 7, 0}, {1, 0xBEDA, 0x8, 0, 0}} / {1, 0xBEDA, 0x8}
	*/
	return 0;
}

/*
		Количество состояний : 2^(8*(1+35+8+3+1)) = 2^384
		Пройдено: 9
		Процент покрытия КА: 9/2^384 ~ 2.28e-113%

		Количество переходов : Количество состояний * Размер входных данных = 2^384 * 2^(2 + 35 + 8) = 2^384 * 2^45 = 2^429
		Пройдено: 10
		Процент покрытия КА: 10/2^429 ~ 7.21e-127%

		Код на c++:
		gcov: 73.53%
*/


int main(){

	test_write_to_mem_minimal();
	test_free_from_cache();
	return 0;
}


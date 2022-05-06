
std::string kernel_code = 
"#define STATE_PARAM	global unsigned char *state\n"
"#define INSTATE_PARAM global unsigned char *in_state\n"
"#define state(x,y) state[x*4+y]\n"
"#define in_state(x,y) in_state[x*4+y]\n"
"#define STATES_PARAM INSTATE_PARAM, STATE_PARAM\n"
"#define ROUNDKEY_PARAM	global  unsigned char *roundkey\n"
"#define SBOX_PARAM global const unsigned char *sbox\n"
"#define RCON_PARAM global unsigned char *rcon\n"
"#define NB_PARAM const unsigned int Nb\n"
"#define NR_PARAM const unsigned int Nr\n"
"#define NK_PARAM const unsigned int Nk\n"
"#define KEY_VALUE global const unsigned char *value\n"
"#define KEY_PARAM NB_PARAM, NR_PARAM, NK_PARAM, KEY_VALUE\n"
"#define DATA_PARAM global unsigned char *plaintext, global unsigned char *cyphertext, global unsigned char *iv, NB_PARAM, NR_PARAM, SBOX_PARAM, ROUNDKEY_PARAM\n"
"void printState(STATE_PARAM, int Nb){\n"
"for(int i =0; i<Nb; i++){\n"
"for(int j =0; j<4; j++)\n"
"printf(\"%#x \", state(j,i));\n"
"printf(\"\\n\");\n"
"}\n"
"}\n"
"void printKey(ROUNDKEY_PARAM, int round){\n"
"for(int i=0; i<4; i++) {\n"
"for(int j=0; j<4; j++)\n"
"printf(\"%#x \", roundkey[(round * 4 * 4) + (j * 4) + i]);\n"
"printf(\"\\n\");\n"
"}\n"
"}\n"
"unsigned int AES_RotWord(unsigned int n)\n"
"{\n"
"return (n>>8) | (n<<24);\n"
"}\n"
"unsigned int AES_SubWord(unsigned int word, SBOX_PARAM)\n"
"{\n"
"return sbox[word>>24]<<24|sbox[(unsigned char)(word>>16)]<<16|sbox[(unsigned char)(word>>8)]<<8|sbox[(unsigned char)word];\n"
"}\n"
"void kernel\n"
"AES_KeyExpansion(KEY_PARAM, ROUNDKEY_PARAM, SBOX_PARAM, RCON_PARAM)\n"
"{\n"
"unsigned char temp[4];\n"
"unsigned char single_temp;\n"
"int i = 0;\n"
"while(i < Nk){\n"
"roundkey[i*4+0] = value[i*4+0];\n"
"roundkey[i*4+1] = value[i*4+1];\n"
"roundkey[i*4+2] = value[i*4+2];\n"
"roundkey[i*4+3] = value[i*4+3];\n"
"i++;\n"
"}\n"
"for(; i < Nb * (Nr+1); i++) {\n"
"temp[0] = roundkey[(i-1)*4];\n"
"temp[1] = roundkey[1+(i-1)*4];\n"
"temp[2] = roundkey[2+(i-1)*4];\n"
"temp[3] = roundkey[3+(i-1)*4];\n"
"if (i%Nk == 0) {\n"
"single_temp = temp[0];\n"
"temp[0] = sbox[temp[1]] ^ rcon[i/Nk];\n"
"temp[1] = sbox[temp[2]];\n"
"temp[2] = sbox[temp[3]];\n"
"temp[3] = sbox[single_temp];\n"
"}\n"
"else if (Nk > 6 && i%Nk == 4){\n"
"temp[0] = sbox[temp[0]];\n"
"temp[1] = sbox[temp[1]];\n"
"temp[2] = sbox[temp[2]];\n"
"temp[3] = sbox[temp[3]];\n"
"}\n"
"roundkey[i*4+0] = roundkey[(i-Nk)*4+0] ^ temp[0];\n"
"roundkey[i*4+1] = roundkey[(i-Nk)*4+1] ^ temp[1];\n"
"roundkey[i*4+2] = roundkey[(i-Nk)*4+2] ^ temp[2];\n"
"roundkey[i*4+3] = roundkey[(i-Nk)*4+3] ^ temp[3];\n"
"}\n"
"}\n"
"void AES_AddRoundKey(STATES_PARAM, ROUNDKEY_PARAM, NB_PARAM,  unsigned int round_number)\n"
"{\n"
"for(int i=0; i<Nb; i++) {\n"
"for(int j=0; j<4; j++) {\n"
"state(i,j) = in_state(i,j) ^ roundkey[(round_number * Nb * 4) + (i * Nb) + j];\n"
"}\n"
"}\n"
"}\n"
"void AES_SubBytes(STATE_PARAM, SBOX_PARAM)\n"
"{\n"
"for(int i=0; i<4; i++) {\n"
"for(int j=0; j<4; j++) {\n"
"state(i,j) = sbox[state(i,j)];\n"
"}\n"
"}\n"
"}\n"
"void AES_ShiftRows(STATE_PARAM)\n"
"{\n"
"unsigned char temp;\n"
"/* Shift each column by coeficient, coeficent = nrow */\n"
"/* No shift on 1st row */\n"
"/* Shift 2nd row 1 byte */\n"
"temp = state(0,1);\n"
"state(0,1) = state(1,1);\n"
"state(1,1) = state(2,1);\n"
"state(2,1) = state(3,1);\n"
"state(3,1) = temp;\n"
"/* Shift 3rd row 2 bytes */\n"
"temp = state(0,2);\n"
"state(0,2) = state(2,2);\n"
"state(2,2) = temp;\n"
"temp = state(1,2);\n"
"state(1,2) = state(3,2);\n"
"state(3,2) = temp;\n"
"/* Shift 4th row 3 bytes (same as 1 byte right shift) */\n"
"temp = state(3,3);\n"
"state(3,3) = state(2,3);\n"
"state(2,3) = state(1,3);\n"
"state(1,3) = state(0,3);\n"
"state(0,3) = temp;\n"
"}\n"
"unsigned char xtime(unsigned char x)\n"
"{\n"
"return ((x<<1) ^ (((x>>7) & 1) * 0x1b));\n"
"}\n"
"void AES_MixColumns(STATE_PARAM)\n"
"{\n"
"unsigned char Tmp, Tm, t;\n"
"for (int i = 0; i < 4; ++i)\n"
"{\n"
"t   = state(i,0);\n"
"Tmp = state(i,0) ^ state(i,1) ^ state(i,2) ^ state(i,3) ;\n"
"Tm  = state(i,0) ^ state(i,1);\n"
"Tm = xtime(Tm);\n"
"state(i,0) ^= Tm ^ Tmp;\n"
"Tm  = state(i,1) ^ state(i,2);\n"
"Tm = xtime(Tm);\n"
"state(i,1) ^= Tm ^ Tmp;\n"
"Tm  = state(i,2) ^ state(i,3);\n"
"Tm = xtime(Tm);\n"
"state(i,2) ^= Tm ^ Tmp;\n"
"Tm  = state(i,3) ^ t;\n"
"Tm = xtime(Tm);\n"
"state(i,3) ^= Tm ^ Tmp;\n"
"}\n"
"}\n"
"void AES_encrypt_state(STATES_PARAM, NB_PARAM, SBOX_PARAM, ROUNDKEY_PARAM, unsigned int num_rounds)\n"
"{\n"
"AES_AddRoundKey(in_state, state, roundkey, Nb, 0);\n"
"for(unsigned int roundi=1; roundi<num_rounds; roundi++)\n"
"{\n"
"AES_SubBytes(state, sbox);\n"
"AES_ShiftRows(state);\n"
"AES_MixColumns(state);\n"
"AES_AddRoundKey(state, state, roundkey, Nb, roundi);\n"
"}\n"
"//Last iteration without MixColumns\n"
"AES_SubBytes(state, sbox);\n"
"AES_ShiftRows(state);\n"
"AES_AddRoundKey(state, state, roundkey, Nb, num_rounds);\n"
"}\n"
"void counter_add_rec(global unsigned char *iv, unsigned int block, int id){\n"
"unsigned int carry;\n"
"unsigned char *counter = iv+get_global_id(0)*16;\n"
"carry = iv[id] + block;\n"
"if (block <=(255-iv[id]) || id == 0) {\n"
"counter[id] = carry;\n"
"for(int i = id-1; i>=0; i--) counter[i] = iv[i];\n"
"return;\n"
"}\n"
"else {\n"
"counter[id] = carry;\n"
"carry >>= 8;\n"
"counter_add_rec(iv, carry, id-1);\n"
"}\n"
"}\n"
"void counter_add(global unsigned char *iv, unsigned int block){\n"
"counter_add_rec(iv, block, 15);\n"
"}\n"
"void kernel\n"
"AES_encrypt(DATA_PARAM)\n"
"{\n"
"global unsigned char *pt = plaintext+get_global_id(0)*16;\n"
"global unsigned char *final_state = cyphertext+get_global_id(0)*16;\n"
"global unsigned char *counter = iv+get_global_id(0)*16;\n"
"/* set the counter value */\n"
"counter_add(iv, get_global_id(0));\n"
"/* Operations per state */\n"
"AES_encrypt_state(counter, final_state, Nb, sbox, roundkey, Nr);\n"
"/* XOR iv with plaintext */\n"
"for(int y = 0; y < Nb; y++) *((unsigned int*) &final_state[4*y]) ^= *((unsigned int*) &pt[4*y]);\n"
"}\n"
;
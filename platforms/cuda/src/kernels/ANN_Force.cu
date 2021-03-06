// real3 force1 = make_real3(- force_constant * (pos1.x - POTENTIAL_CENTER[0]), 0.0, 0.0) ; 
// real3 force2 = make_real3(0.0, 0.0, 0.0);

int num_of_rows, num_of_cols;
float force_constant = FORCE_CONSTANT[0];

// // forward propagation
// // input layer
// for (int ii = 0; ii < NUM_OF_NODES[0]; ii ++) {
//     OUTPUT_0[ii] = INPUT_0[ii];
// }
// // layer 1
// num_of_rows = NUM_OF_NODES[1];
// num_of_cols = NUM_OF_NODES[0];
// for (int ii = 0; ii < num_of_rows; ii ++) {
//     INPUT_1[ii] = BIAS_0[ii];
//     for (int jj = 0; jj < num_of_cols; jj ++) {
//         INPUT_1[ii] += COEFF_0[ii * num_of_cols + jj] * OUTPUT_0[jj];
//     }
// }
// if (LAYER_TYPES[0] == 0) { // linear
//     for (int ii = 0; ii < num_of_rows; ii ++) {
//         OUTPUT_1[ii] = INPUT_1[ii];
//     }
// }
// else if (LAYER_TYPES[0] == 1) { // tanh
//     for (int ii = 0; ii < num_of_rows; ii ++) {
//         OUTPUT_1[ii] = tanh(INPUT_1[ii]);
//     }
// }
// // layer 2
// num_of_rows = NUM_OF_NODES[2];
// num_of_cols = NUM_OF_NODES[1];
// for (int ii = 0; ii < num_of_rows; ii ++) {
//     INPUT_2[ii] = BIAS_1[ii];
//     for (int jj = 0; jj < num_of_cols; jj ++) {
//         INPUT_2[ii] += COEFF_1[ii * num_of_cols + jj] * OUTPUT_1[jj];
//     }
// }
// if (LAYER_TYPES[1] == 0) { // linear
//     for (int ii = 0; ii < num_of_rows; ii ++) {
//         OUTPUT_2[ii] = INPUT_2[ii];
//     }
// }
// else if (LAYER_TYPES[1] == 1) { // tanh
//     for (int ii = 0; ii < num_of_rows; ii ++) {
//         OUTPUT_2[ii] = tanh(INPUT_2[ii]);
//     }
// }

// // backward propagation, INPUT_{0,1,2} are reused to store derivatives in each layer
// // layer 2
// for (int ii = 0; ii < NUM_OF_NODES[2]; ii ++) {
//     INPUT_2[ii] = (OUTPUT_2[ii] - POTENTIAL_CENTER[ii]) * force_constant;
//     energy += 0.5 * (OUTPUT_2[ii] - POTENTIAL_CENTER[ii]) * (OUTPUT_2[ii] - POTENTIAL_CENTER[ii]) * force_constant;
// }
// if (LAYER_TYPES[1] == 1) {
//     for (int ii = 0; ii < NUM_OF_NODES[2]; ii ++) {
//         INPUT_2[ii] *= (1 - OUTPUT_2[ii] * OUTPUT_2[ii]);    
//     }
// }

// // layer 1
// num_of_rows = NUM_OF_NODES[2];
// num_of_cols = NUM_OF_NODES[1];
// for (int ii = 0; ii < num_of_cols; ii ++) {
//     INPUT_1[ii] = 0;
//     for (int jj = 0; jj < num_of_rows; jj ++) {
//         INPUT_1[ii] += COEFF_1[ii + jj * num_of_cols] * INPUT_2[jj];
//     }
// }
// if (LAYER_TYPES[0] == 1) {
//     for (int ii = 0; ii < NUM_OF_NODES[1]; ii ++) {
//         INPUT_1[ii] *= (1 - OUTPUT_1[ii] * OUTPUT_1[ii]);    
//     }
// }

// // input layer
// num_of_rows = NUM_OF_NODES[1];
// num_of_cols = NUM_OF_NODES[0];
// for (int ii = 0; ii < num_of_cols; ii ++) {
//     INPUT_0[ii] = 0;
//     for (int jj = 0; jj < num_of_rows; jj ++) {
//         INPUT_0[ii] += COEFF_0[ii + jj * num_of_cols] * INPUT_1[jj];
//     }
// }

// forward propagation
// input layer
for (int ii = index; ii < NUM_OF_NODES[0]; ii += num_of_parallel_threads) {
    OUTPUT_0[ii] = INPUT_0[ii];
}
__syncthreads();
// layer 1
num_of_rows = NUM_OF_NODES[1];
num_of_cols = NUM_OF_NODES[0];

for (int ii = index; ii < num_of_rows; ii += num_of_parallel_threads) {
    float temp = BIAS_0[ii];
    for (int jj = 0; jj < num_of_cols; jj ++) {
        temp += COEFF_0[ii * num_of_cols + jj] * OUTPUT_0[jj];
    }
    INPUT_1[ii] = temp;
}

__syncthreads();

if (LAYER_TYPES[0] == 0) { // linear
    for (int ii = 0; ii < num_of_rows; ii ++) {
        OUTPUT_1[ii] = INPUT_1[ii];
    }
}
else if (LAYER_TYPES[0] == 1) { // tanh
    for (int ii = index; ii < num_of_rows; ii += num_of_parallel_threads) {
        OUTPUT_1[ii] = tanh(INPUT_1[ii]);
    }
}
__syncthreads();
// layer 2
num_of_rows = NUM_OF_NODES[2];
num_of_cols = NUM_OF_NODES[1];
for (int ii = index; ii < num_of_rows; ii += num_of_parallel_threads) {
    float temp = BIAS_1[ii];
    for (int jj = 0; jj < num_of_cols; jj ++) {
        temp += COEFF_1[ii * num_of_cols + jj] * OUTPUT_1[jj];
    }
    INPUT_2[ii] = temp;
}
__syncthreads();
if (LAYER_TYPES[1] == 0) { // linear
    for (int ii = 0; ii < num_of_rows; ii ++) {
        OUTPUT_2[ii] = INPUT_2[ii];
    }
}
else if (LAYER_TYPES[1] == 1) { // tanh
    for (int ii = index; ii < num_of_rows; ii += num_of_parallel_threads) {
        OUTPUT_2[ii] = tanh(INPUT_2[ii]);
    }
}
__syncthreads();

// backward propagation, INPUT_{0,1,2} are reused to store derivatives in each layer
// layer 2
for (int ii = index; ii < NUM_OF_NODES[2]; ii += num_of_parallel_threads) {
    INPUT_2[ii] = (OUTPUT_2[ii] - POTENTIAL_CENTER[ii]) * force_constant;
    energy += 0.5 * (OUTPUT_2[ii] - POTENTIAL_CENTER[ii]) * (OUTPUT_2[ii] - POTENTIAL_CENTER[ii]) * force_constant;
}
if (LAYER_TYPES[1] == 1) {
    for (int ii = index; ii < NUM_OF_NODES[2]; ii += num_of_parallel_threads) {
        INPUT_2[ii] *= (1 - OUTPUT_2[ii] * OUTPUT_2[ii]);    
    }
}
__syncthreads();

// layer 1
num_of_rows = NUM_OF_NODES[2];
num_of_cols = NUM_OF_NODES[1];
for (int ii = index; ii < num_of_cols; ii += num_of_parallel_threads) {
    float temp = 0;
    for (int jj = 0; jj < num_of_rows; jj ++) {
        temp += COEFF_1[ii + jj * num_of_cols] * INPUT_2[jj];
    }
    INPUT_1[ii] = temp;
}
__syncthreads();
if (LAYER_TYPES[0] == 1) {
    for (int ii = index; ii < NUM_OF_NODES[1]; ii += num_of_parallel_threads) {
        INPUT_1[ii] *= (1 - OUTPUT_1[ii] * OUTPUT_1[ii]);    
    }
}
__syncthreads();

// input layer
num_of_rows = NUM_OF_NODES[1];
num_of_cols = NUM_OF_NODES[0];
for (int ii = index; ii < num_of_cols; ii += num_of_parallel_threads) {
    float temp = 0;
    for (int jj = 0; jj < num_of_rows; jj ++) {
        temp += COEFF_0[ii + jj * num_of_cols] * INPUT_1[jj];
    }
    INPUT_0[ii] = temp;
}
__syncthreads();


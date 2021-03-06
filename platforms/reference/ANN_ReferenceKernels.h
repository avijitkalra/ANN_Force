#ifndef ANN_OPENMM_REFERENCE_KERNELS_H_
#define ANN_OPENMM_REFERENCE_KERNELS_H_

#include "OpenMM_ANN.h"
#include "openmm/System.h"
#include "openmm/ANN_Kernels.h"
#include "openmm/reference/RealVec.h"
#include <algorithm>

#include "openmm/reference/SimTKOpenMMRealType.h"

using std::min;

namespace OpenMM {

/**
 * This kernel is invoked by ANN_Force to calculate the forces acting on the system and the energy of the system.
 */
class ReferenceCalcANN_ForceKernel : public CalcANN_ForceKernel {
public:
    ReferenceCalcANN_ForceKernel(std::string name, 
                                               const Platform& platform,
                                               const System& system);
    ~ReferenceCalcANN_ForceKernel();
    /**
     * Initialize the kernel.
     * 
     * @param system     the System this kernel will be applied to
     * @param force      the ANN_Force this kernel will be used for
     */
    void initialize(const System& system, const ANN_Force& force);
    /**
     * Execute the kernel to calculate the forces and/or energy.
     *
     * @param context        the context in which to execute this kernel
     * @param includeForces  true if forces should be calculated
     * @param includeEnergy  true if the energy should be calculated
     * @return the potential energy due to the force
     */
    double execute(ContextImpl& context, bool includeForces, bool includeEnergy);
    /**
     * Copy changed parameters over to a context.
     *
     * @param context    the context to copy parameters to
     * @param force      the ANN_Force to copy the parameters from
     */
    void copyParametersToContext(ContextImpl& context, const ANN_Force& force);

    /**
     * Calculate force and energy
     *
     * @param positionData    the coordinates of all atoms
     * @param forceData      calculated force values based on the positions
     * @return          the energy associated with this force
     */
    RealOpenMM calculateForceAndEnergy(vector<RealVec>& positionData, vector<RealVec>& forceData);

    RealOpenMM candidate_1(vector<RealVec>& positionData, vector<RealVec>& forceData);

    RealOpenMM candidate_2(vector<RealVec>& positionData, vector<RealVec>& forceData);

    void get_cos_and_sin_of_dihedral_angles(const vector<RealVec>& positionData, vector<RealOpenMM>& cos_sin_value);

    void get_cos_and_sin_for_four_atoms(int idx_1, int idx_2, int idx_3, int idx_4, 
                                const vector<RealVec>& positionData, RealOpenMM& cos_value, RealOpenMM& sin_value);

    void calculate_output_of_each_layer(const vector<RealOpenMM>& input);

    vector<vector<double> >& get_output_of_each_layer() {
        return output_of_each_layer;
    }

    vector<double** >& get_coeff() {
        return coeff;
    }
    
    void back_prop(vector<vector<double> >& derivatives_of_each_layer);

    void get_force_from_derivative_of_first_layer(int index_of_node_in_input_layer_1, 
                                                                            int index_of_node_in_input_layer_2,
                                                                            vector<RealVec>& positionData,
                                                                            vector<RealVec>& forceData,
                                                                            vector<double>& derivatives_of_first_layer);

    void get_all_forces_from_derivative_of_first_layer(vector<RealVec>& positionData,
                                                                            vector<RealVec>& forceData,
                                                                            vector<double>& derivatives_of_first_layer);

    double update_and_get_potential_energy() {
        // FIXME: fix for circular layer
        potential_energy = 0;
        if (layer_types[NUM_OF_LAYERS - 2] != "Circular") {
            for (int ii = 0; ii < num_of_nodes[NUM_OF_LAYERS - 1]; ii ++) {
                potential_energy += 0.5 * force_constant * (output_of_each_layer[NUM_OF_LAYERS - 1][ii] - potential_center[ii])
                                                         * (output_of_each_layer[NUM_OF_LAYERS - 1][ii] - potential_center[ii]);
            }
        }
        else {
            for (int ii = 0; ii < num_of_nodes[NUM_OF_LAYERS - 1] / 2; ii ++) {
                double cos_value = output_of_each_layer[NUM_OF_LAYERS - 1][2 * ii];
                double sin_value = output_of_each_layer[NUM_OF_LAYERS - 1][2 * ii + 1];
                int sign = sin_value > 0 ? 1 : -1;
                double angle = acos(cos_value) * sign;
                
                double angle_distance_1 = angle - potential_center[ii];
                double angle_distance_2 = angle_distance_1 + 6.2832;
                double angle_distance_3 = angle_distance_1 - 6.2832;
                // need to take periodicity into account
                double angle_distance_squared = min( min(
                                angle_distance_1 * angle_distance_1,
                                angle_distance_2 * angle_distance_2),
                                angle_distance_3 * angle_distance_3
                                );  
                potential_energy += 0.5 * force_constant * angle_distance_squared;
            }
        }
        
        return potential_energy;
    }


private:
    bool remove_translation_degrees_of_freedom  = true;
    double potential_energy;
    vector<int> num_of_nodes = vector<int>(NUM_OF_LAYERS);    // store the number of nodes for first 3 layers
    std::vector<std::vector<int> > list_of_index_of_atoms_forming_dihedrals;
    std::vector<std::vector<int> > list_of_pair_index_for_distances;
    std::vector<int> index_of_backbone_atoms;
    vector<double** > coeff = vector<double** >(NUM_OF_LAYERS - 1);  // each coeff of connection is a matrix
    vector<string> layer_types = vector<string>(NUM_OF_LAYERS - 1);
    vector<vector<double> > output_of_each_layer = vector<vector<double> >(NUM_OF_LAYERS);
    vector<vector<double> > input_of_each_layer = vector<vector<double> >(NUM_OF_LAYERS);
    vector<vector<double> > values_of_biased_nodes = vector<vector<double> >(NUM_OF_LAYERS - 1);
    std::vector<double> potential_center;  // the size should be equal to num_of_nodes[NUM_OF_LAYERS - 1]
    double force_constant;
    double scaling_factor;
    int data_type_in_input_layer;
    const System& system;  
};


} // namespace OpenMM

#endif /*ANN_OPENMM_REFERENCE_KERNELS_H*/

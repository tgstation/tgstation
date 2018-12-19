//////////////////////////////////////////////////////////
//A bunch of helpers to make genetics less of a headache//
//////////////////////////////////////////////////////////

#define get_initialized_mutation(A) GLOB.all_mutations[A]
#define get_gene_string(A, B) (B.mutation_index[A])
#define get_sequence(A) (GLOB.full_sequences[A])

#define get_stabilizer(A) ((A.stabilizer_coeff < 0) ? 1 : A.stabilizer_coeff)
#define get_synchronizer(A) ((A.synchronizer_coeff < 0) ? 1 : A.synchronizer_coeff)
#define get_power(A) ((A.power_coeff < 0) ? 1 : A.power_coeff)
#define get_energy(A) ((A.energy_coeff < 0) ? 1 : A.energy_coeff)
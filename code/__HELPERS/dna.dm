//////////////////////////////////////////////////////////
//A bunch of helpers to make genetics less of a headache//
//////////////////////////////////////////////////////////

#define get_initialized_mutation(A) GLOB.all_mutations[A]
#define mutation_in_sequence(A, B) ((A) in B.mutation_index)
#define get_gene_string(A, B) (B.mutation_index[A])
#define get_sequence(A) (GLOB.full_sequences[A])
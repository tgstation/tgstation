//Species
#define isprimitive(A) (is_species(A, /datum/species/human/genemod/primitive))
//Customization bases
#define isinsectoid(A) (is_species(A, /datum/species/insectoid))
#define issnail(A) (is_species(A, /datum/species/snail))
//Species with green blood
#define hasgreenblood(A) (isinsectoid(A) || HAS_TRAIT(A, TRAIT_GREEN_BLOOD))

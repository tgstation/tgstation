//Species
#define isprimitive(A) (is_species(A, /datum/species/genemod/primitive))
//Customization bases
#define isinsectoid(A) (is_species(A, /datum/species/insectoid))
#define issnail(A) (is_species(A, /datum/species/snail))
#define ishemophage(A) (is_species(A, /datum/species/genemod/hemophage))
#define isramatan(A) (is_species(A, /datum/species/ramatan))
//Species blood colors
#define hasgreenblood(A) (isinsectoid(A) || issnail(A) || isflyperson(A) || HAS_TRAIT(A, TRAIT_GREEN_BLOOD))
#define hasblueblood(A) (isandroid(A) || HAS_TRAIT(A, TRAIT_BLUE_BLOOD))

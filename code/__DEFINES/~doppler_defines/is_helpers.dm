//Species
#define isprimitivedemihuman(A) (is_species(A, /datum/species/human/felinid/primitive))
//Customization bases
#define isfeline(A) (isfelinid(A) || HAS_TRAIT(A, TRAIT_FELINE))
#define isinsectoid(A) (is_species(A, /datum/species/insectoid))
#define issnail(A) (is_species(A, /datum/species/snail))
//Species with green blood
#define hasgreenblood(A) (isinsectoid(A) || HAS_TRAIT(A, TRAIT_GREEN_BLOOD))

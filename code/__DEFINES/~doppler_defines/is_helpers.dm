//Species
#define isprimitivedemihuman(A) (is_species(A, /datum/species/human/felinid/primitive))
//Customization bases
#define isfeline(A) (isfelinid(A) || HAS_TRAIT(A, TRAIT_FELINE))

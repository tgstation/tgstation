#define UNDERWEAR_HIDE_SOCKS (1<<0)
#define UNDERWEAR_HIDE_SHIRT (1<<1)
#define UNDERWEAR_HIDE_UNDIES (1<<2)
#define UNDERWEAR_HIDE_BRA (1<<3)
#define UNDERWEAR_HIDE_ALL (UNDERWEAR_HIDE_SOCKS | UNDERWEAR_HIDE_SHIRT | UNDERWEAR_HIDE_UNDIES | UNDERWEAR_HIDE_BRA)

#define BODYPART_ICON_SNAIL 'modular_doppler/modular_species/species_types/snails/icons/bodyparts/snail_bodyparts.dmi'
#define BODYPART_ICON_ROUNDSTARTSLIME 'modular_doppler/modular_species/species_types/slimes/icons/bodyparts.dmi'

#define DIGI_HOOF "Hooved Legs"
#define DIGI_TALON "Taloned Legs"
#define DIGI_BUG "Insectoid Legs"

GLOBAL_LIST_INIT(digi_leg_types, list(
	NORMAL_LEGS,
	DIGITIGRADE_LEGS,
//	DIGI_HOOF,
//	DIGI_TALON,
	DIGI_BUG,
))

/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if((!(C.dna)) || (!(C.dna.species))) return

//Defines copying names of mutations in all cases, make sure to change this if you change mutation's name
#define HULK		"Hulk"
#define XRAY		"X Ray Vision"
#define COLDRES		"Cold Resistance"
#define TK			"Telekinesis"
#define NERVOUS		"Nervousness"
#define EPILEPSY	"Epilepsy"
#define MUTATE		"Unstable DNA"
#define COUGH		"Cough"
#define DWARFISM	"Dwarfism"
#define CLOWNMUT	"Clumsiness"
#define TOURETTES	"Tourettes Syndrome"
#define DEAFMUT		"Deafness"
#define BLINDMUT	"Blindness"
#define RACEMUT		"Monkified"
#define BADSIGHT	"Near Sightness"
#define LASEREYES	"Laser Eyes"
#define CHAMELEON	"Chameleon"
#define WACKY		"Wacky"
#define MUT_MUTE	"Mute"
#define SMILE		"Smile"
#define STONER		"Stoner"
#define UNINTELLIGIBLE		"Unintelligible"
#define SWEDISH		"Swedish"
#define CHAV		"Chav"
#define ELVIS		"Elvis"

#define UI_CHANGED "ui changed"
#define UE_CHANGED "ue changed"

#define CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY 204

// String identifiers for associative list lookup

//Types of usual mutations
#define	POSITIVE 			1
#define	NEGATIVE			2
#define	MINOR_NEGATIVE		3

//Mutations that cant be taken from genetics and are not in SE
#define	NON_SCANNABLE		-1

//DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE				3

#define DNA_UNI_IDENTITY_BLOCKS		7
#define DNA_HAIR_COLOR_BLOCK		1
#define DNA_FACIAL_HAIR_COLOR_BLOCK	2
#define DNA_SKIN_TONE_BLOCK			3
#define DNA_EYE_COLOR_BLOCK			4
#define DNA_GENDER_BLOCK			5
#define DNA_FACIAL_HAIR_STYLE_BLOCK	6
#define DNA_HAIR_STYLE_BLOCK		7

#define DNA_STRUC_ENZYMES_BLOCKS	18
#define DNA_UNIQUE_ENZYMES_LEN		32

//Transformation proc stuff
#define TR_KEEPITEMS	(1<<0)
#define TR_KEEPVIRUS	(1<<1)
#define TR_KEEPDAMAGE	(1<<2)
#define TR_HASHNAME		(1<<3)	// hashing names (e.g. monkey(e34f)) (only in monkeyize)
#define TR_KEEPIMPLANTS	(1<<4)
#define TR_KEEPSE		(1<<5)	// changelings shouldn't edit the DNA's SE when turning into a monkey
#define TR_DEFAULTMSG	(1<<6)
#define TR_KEEPORGANS	(1<<8)


#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

//species traits for mutantraces
#define MUTCOLORS		1
#define HAIR			2
#define FACEHAIR		3
#define EYECOLOR		4
#define LIPS			5
#define NOBLOOD			6
#define NOTRANSSTING	7
#define MUTCOLORS_PARTSONLY	8	//Used if we want the mutant colour to be only used by mutant bodyparts. Don't combine this with MUTCOLORS, or it will be useless.
#define NOZOMBIE		9
#define DIGITIGRADE		10	//Uses weird leg sprites. Optional for Lizards, required for ashwalkers. Don't give it to other races unless you make sprites for this (see human_parts_greyscale.dmi)
#define NO_UNDERWEAR	11
#define NOLIVER			12
#define NOSTOMACH		13
#define NO_DNA_COPY     14
#define DRINKSBLOOD		15
#define NOEYES			16

#define ORGAN_SLOT_BRAIN "brain"
#define ORGAN_SLOT_APPENDIX "appendix"
#define ORGAN_SLOT_RIGHT_ARM_AUG "r_arm_device"
#define ORGAN_SLOT_LEFT_ARM_AUG "l_arm_device"
#define ORGAN_SLOT_STOMACH "stomach"
#define ORGAN_SLOT_STOMACH_AID "stomach_aid"
#define ORGAN_SLOT_BREATHING_TUBE "breathing_tube"
#define ORGAN_SLOT_EARS "ears"
#define ORGAN_SLOT_EYES "eye_sight"
#define ORGAN_SLOT_LUNGS "lungs"
#define ORGAN_SLOT_HEART "heart"
#define ORGAN_SLOT_ZOMBIE "zombie_infection"
#define ORGAN_SLOT_THRUSTERS "thrusters"
#define ORGAN_SLOT_HUD "eye_hud"
#define ORGAN_SLOT_LIVER "liver"
#define ORGAN_SLOT_TONGUE "tongue"
#define ORGAN_SLOT_VOICE "vocal_cords"
#define ORGAN_SLOT_ADAMANTINE_RESONATOR "adamantine_resonator"
#define ORGAN_SLOT_HEART_AID "heartdrive"
#define ORGAN_SLOT_BRAIN_ANTIDROP "brain_antidrop"
#define ORGAN_SLOT_BRAIN_ANTISTUN "brain_antistun"
#define ORGAN_SLOT_TAIL "tail"

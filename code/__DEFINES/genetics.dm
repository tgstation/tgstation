
//Defines copying names of mutations in all cases, make sure to change this if you change mutation's name
#define HULK		"Hulk"
#define XRAY		"X Ray Vision"
#define COLDRES		"Cold Resistance"
#define TK			"Telekinesis"
#define NERVOUS		"Nervousness"
#define EPILEPSY	"Epilepsy"
#define MUTATE		"Unstable DNA"
#define COUGH		"Cough"
#define CLOWNMUT	"Clumsiness"
#define TOURETTES	"Tourettes Syndrome"
#define DEAFMUT		"Deafness"
#define BLINDMUT	"Blindness"
#define RACEMUT		"Monkified"
#define BADSIGHT	"Near Sightness"
#define LASEREYES	"Laser Eyes"
#define STEALTH		"Cloak Of Darkness"
#define CHAMELEON	"Chameleon"
#define WACKY		"Wacky"
#define MUT_MUTE	"Mute"
#define SMILE		"Smile"
#define UNINTELLIGABLE		"Unintelligable"
#define SWEDISH		"Swedish"
#define CHAV		"Chav"
#define ELVIS		"Elvis"

// String identifiers for associative list lookup

//Types of usual mutations
#define	POSITIVE 			1
#define	NEGATIVE			2
#define	MINOR_NEGATIVE		3

//Mutations that cant be taken from genetics and are not in SE
#define	NON_SCANNABLE		-1

	// Extra powers:
#define LASER			9 	// harm intent - click anywhere to shoot lasers from eyes
#define HEAL			10 	// healing people with hands
#define SHADOW			11 	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			12 	// supersonic screaming (25%)
#define EXPLOSIVE		13 	// exploding on-demand (15%)
#define REGENERATION	14 	// superhuman regeneration (30%)
#define REPROCESSOR		15 	// eat anything (50%)
#define SHAPESHIFTING	16 	// take on the appearance of anything (40%)
#define PHASING			17 	// ability to phase through walls (40%)
#define SHIELD			18 	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		19 	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		20 	// ability to shoot electric attacks (15%)

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

#define DNA_STRUC_ENZYMES_BLOCKS	23
#define DNA_UNIQUE_ENZYMES_LEN		32

//Transformation proc stuff
#define TR_KEEPITEMS	1
#define TR_KEEPVIRUS	2
#define TR_KEEPDAMAGE	4
#define TR_HASHNAME		8	// hashing names (e.g. monkey(e34f)) (only in monkeyize)
#define TR_KEEPIMPLANTS	16
#define TR_KEEPSE		32 // changelings shouldn't edit the DNA's SE when turning into a monkey
#define TR_DEFAULTMSG	64
#define TR_KEEPSRC		128

//Organ stuff, It's here because "Genetics" is the most relevant file for organs
#define ORGAN_ORGANIC   1
#define ORGAN_ROBOTIC   2

//Nutrition levels for humans. No idea where else to put it
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150

// Mutations
#define	TK				1
#define COLD_RESISTANCE	2
#define XRAY			3
#define HULK			4
#define LASER			5 	// harm intent - click anywhere to shoot lasers from eyes
#define HEAL			6 	// healing people with hands // Doesn't actually do anything

// Conditions
#define FAT				1
#define HUSK			2
#define NOCLONE			3

// Disabilities
#define CLUMSY			1
#define NEARSIGHTED		2
#define EPILEPSY		3
#define COUGHING		4
#define TOURETTES		5
#define NERVOUS			6
#define BLIND			7
#define MUTE			8
#define DEAF			9

// Unused things - leaving here because they are cool
/*
#define SHADOW			(1<<10)	// shadow teleportation (create in/out portals anywhere) (25%)
#define SHADOW			11 	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			(1<<11)	// supersonic screaming (25%)
#define SCREAM			12 	// supersonic screaming (25%)
#define EXPLOSIVE		(1<<12)	// exploding on-demand (15%)
#define EXPLOSIVE		13 	// exploding on-demand (15%)
#define REGENERATION	(1<<13)	// superhuman regeneration (30%)
#define REGENERATION	14 	// superhuman regeneration (30%)
#define REPROCESSOR		(1<<14)	// eat anything (50%)
#define REPROCESSOR		15 	// eat anything (50%)
#define SHAPESHIFTING	(1<<15)	// take on the appearance of anything (40%)
#define SHAPESHIFTING	16 	// take on the appearance of anything (40%)
#define PHASING			(1<<16)	// ability to phase through walls (40%)
#define PHASING			17 	// ability to phase through walls (40%)
#define SHIELD			(1<<17)	// shielding from all projectile attacks (30%)
#define SHIELD			18 	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		(1<<18)	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define SHOCKWAVE		19 	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		(1<<19)	// ability to shoot electric attacks (15%)
#define ELECTRICITY		20 	// ability to shoot electric attacks (15%)
*/

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

#define DNA_STRUC_ENZYMES_BLOCKS	14
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
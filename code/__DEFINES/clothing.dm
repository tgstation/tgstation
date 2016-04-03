//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING	1
#define SLOT_ICLOTHING	2
#define SLOT_GLOVES		4
#define SLOT_EYES		8
#define SLOT_EARS		16
#define SLOT_MASK		32
#define SLOT_HEAD		64
#define SLOT_FEET		128
#define SLOT_ID			256
#define SLOT_BELT		512
#define SLOT_BACK		1024
#define SLOT_POCKET		2048		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET	4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES		1
#define HIDESUITSTORAGE	2
#define HIDEJUMPSUIT	4	//these first four are only used in exterior suits
#define HIDESHOES		8
#define HIDEMASK		16	//these last six are only used in masks and headgear.
#define HIDEEARS		32	// (ears means headsets and such)
#define HIDEEYES		64	// Whether eyes and glasses are hidden
#define HIDEFACE		128	// Whether we appear as unknown.
#define HIDEHAIR		256
#define HIDEFACIALHAIR	512

//slots
#define slot_back			1
#define slot_wear_mask		2
#define slot_handcuffed		3
#define slot_l_hand			4
#define slot_r_hand			5
#define slot_belt			6
#define slot_wear_id		7
#define slot_ears			8
#define slot_glasses		9
#define slot_gloves			10
#define slot_head			11
#define slot_shoes			12
#define slot_wear_suit		13
#define slot_w_uniform		14
#define slot_l_store		15
#define slot_r_store		16
#define slot_s_store		17
#define slot_in_backpack	18
#define slot_legcuffed		19
#define slot_drone_storage	20

#define slots_amt			20 // Keep this up to date!

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts - also used for limbs
#define HEAD		1
#define CHEST		2
#define GROIN		4
#define LEG_LEFT	8
#define LEG_RIGHT	16
#define LEGS		24
#define FOOT_LEFT	32
#define FOOT_RIGHT	64
#define FEET		96
#define ARM_LEFT	128
#define ARM_RIGHT	256
#define ARMS		384
#define HAND_LEFT	512
#define HAND_RIGHT	1024
#define HANDS		1536
#define FULL_BODY	2047

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_CHEST		0.15
#define THERMAL_PROTECTION_GROIN		0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025

//flags for female outfits: How much the game can safely "take off" the uniform without it looking weird

#define NO_FEMALE_UNIFORM			0
#define FEMALE_UNIFORM_FULL			1
#define FEMALE_UNIFORM_TOP			2


//flags for covering body parts
#define GLASSESCOVERSEYES	1
#define MASKCOVERSEYES		2		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		4		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		8		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		16

#define TINT_DARKENED 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

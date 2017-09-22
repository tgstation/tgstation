/*ALL DEFINES RELATED TO INVENTORY OBJECTS, MANAGEMENT, ETC, GO HERE*/

//ITEM INVENTORY WEIGHT, FOR w_class
#define WEIGHT_CLASS_TINY     1 //Usually items smaller then a human hand, ex: Playing Cards, Lighter, Scalpel, Coins/Money
#define WEIGHT_CLASS_SMALL    2 //Pockets can hold small and tiny items, ex: Flashlight, Multitool, Grenades, GPS Device
#define WEIGHT_CLASS_NORMAL   3 //Standard backpacks can carry tiny, small & normal items, ex: Fire extinguisher, Stunbaton, Gas Mask, Metal Sheets
#define WEIGHT_CLASS_BULKY    4 //Items that can be weilded or equipped but not stored in an inventory, ex: Defibrillator, Backpack, Space Suits
#define WEIGHT_CLASS_HUGE     5 //Usually represents objects that require two hands to operate, ex: Shotgun, Two Handed Melee Weapons
#define WEIGHT_CLASS_GIGANTIC 6 //Essentially means it cannot be picked up or placed in an inventory, ex: Mech Parts, Safe

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH		3
#define STORAGE_VIEW_DEPTH	2

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
#define SLOT_POCKET		2048 // this is to allow items with a w_class of WEIGHT_CLASS_NORMAL or WEIGHT_CLASS_BULKY to fit in pockets.
#define SLOT_DENYPOCKET	4096 // this is to deny items with a w_class of WEIGHT_CLASS_SMALL or WEIGHT_CLASS_TINY to fit in pockets.
#define SLOT_NECK		8192

//SLOTS
#define slot_back			1
#define slot_wear_mask		2
#define slot_handcuffed		3
#define slot_hands			4 //wherever you provide a slot for hands you provide slot_hands
								//slot_hands as a slot will pick ANY available hand
#define slot_belt			5
#define slot_wear_id		6
#define slot_ears			7
#define slot_glasses		8
#define slot_gloves			9
#define slot_neck			10
#define slot_head			11
#define slot_shoes			12
#define slot_wear_suit		13
#define slot_w_uniform		14
#define slot_l_store		15
#define slot_r_store		16
#define slot_s_store		17
#define slot_in_backpack	18
#define slot_legcuffed		19
#define slot_generic_dextrous_storage	20

#define slots_amt			20 // Keep this up to date!

//I hate that this has to exist
/proc/slotdefine2slotbit(slotdefine) //Keep this up to date with the value of SLOT BITMASKS and SLOTS (the two define sections above)
	. = 0
	switch(slotdefine)
		if(slot_back)
			. = SLOT_BACK
		if(slot_wear_mask)
			. = SLOT_MASK
		if(slot_neck)
			. = SLOT_NECK
		if(slot_belt)
			. = SLOT_BELT
		if(slot_wear_id)
			. = SLOT_ID
		if(slot_ears)
			. = SLOT_EARS
		if(slot_glasses)
			. = SLOT_EYES
		if(slot_gloves)
			. = SLOT_GLOVES
		if(slot_head)
			. = SLOT_HEAD
		if(slot_shoes)
			. = SLOT_FEET
		if(slot_wear_suit)
			. = SLOT_OCLOTHING
		if(slot_w_uniform)
			. = SLOT_ICLOTHING
		if(slot_l_store, slot_r_store)
			. = SLOT_POCKET


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
#define HIDENECK		1024

//bitflags for clothing coverage - also used for limbs
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
#define NECK		2048
#define FULL_BODY	4095

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

//flags for alternate styles: These are hard sprited so don't set this if you didn't put the effort in
#define NORMAL_STYLE		0
#define ALT_STYLE			1
#define DIGITIGRADE_STYLE 	2

//flags for outfits that have mutantrace variants (try not to use this): Currently only needed if you're trying to add tight fitting bootyshorts
#define NO_MUTANTRACE_VARIATION		0
#define MUTANTRACE_VARIATION		1

#define NOT_DIGITIGRADE				0
#define FULL_DIGITIGRADE			1
#define SQUISHED_DIGITIGRADE		2

//flags for covering body parts
#define GLASSESCOVERSEYES	1
#define MASKCOVERSEYES		2		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		4		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		8		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		16

#define TINT_DARKENED 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

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
#define ITEM_SLOT_OCLOTHING		(1<<0)
#define ITEM_SLOT_ICLOTHING		(1<<1)
#define ITEM_SLOT_GLOVES		(1<<2)
#define ITEM_SLOT_EYES			(1<<3)
#define ITEM_SLOT_EARS			(1<<4)
#define ITEM_SLOT_MASK			(1<<5)
#define ITEM_SLOT_HEAD			(1<<6)
#define ITEM_SLOT_FEET			(1<<7)
#define ITEM_SLOT_ID			(1<<8)
#define ITEM_SLOT_BELT			(1<<9)
#define ITEM_SLOT_BACK			(1<<10)
#define ITEM_SLOT_POCKET		(1<<11) // this is to allow items with a w_class of WEIGHT_CLASS_NORMAL or WEIGHT_CLASS_BULKY to fit in pockets.
#define ITEM_SLOT_DENYPOCKET	(1<<12) // this is to deny items with a w_class of WEIGHT_CLASS_SMALL or WEIGHT_CLASS_TINY to fit in pockets.
#define ITEM_SLOT_NECK			(1<<13)

//SLOTS
#define SLOT_BACK			1
#define SLOT_WEAR_MASK		2
#define SLOT_HANDCUFFED		3
#define SLOT_HANDS			4 //wherever you provide a slot for hands you provide SLOT_HANDS
								//SLOT_HANDS as a slot will pick ANY available hand
#define SLOT_BELT			5
#define SLOT_WEAR_ID		6
#define SLOT_EARS			7
#define SLOT_GLASSES		8
#define SLOT_GLOVES			9
#define SLOT_NECK			10
#define SLOT_HEAD			11
#define SLOT_SHOES			12
#define SLOT_WEAR_SUIT		13
#define SLOT_W_UNIFORM		14
#define SLOT_L_STORE		15
#define SLOT_R_STORE		16
#define SLOT_S_STORE		17
#define SLOT_IN_BACKPACK	18
#define SLOT_LEGCUFFED		19
#define SLOT_GENERC_DEXTROUS_STORAGE	20

#define SLOTS_AMT			20 // Keep this up to date!

//I hate that this has to exist
/proc/slotdefine2slotbit(slotdefine) //Keep this up to date with the value of SLOT BITMASKS and SLOTS (the two define sections above)
	. = 0
	switch(slotdefine)
		if(SLOT_BACK)
			. = ITEM_SLOT_BACK
		if(SLOT_WEAR_MASK)
			. = ITEM_SLOT_MASK
		if(SLOT_NECK)
			. = ITEM_SLOT_NECK
		if(SLOT_BELT)
			. = ITEM_SLOT_BELT
		if(SLOT_WEAR_ID)
			. = ITEM_SLOT_ID
		if(SLOT_EARS)
			. = ITEM_SLOT_EARS
		if(SLOT_GLASSES)
			. = ITEM_SLOT_EYES
		if(SLOT_GLOVES)
			. = ITEM_SLOT_GLOVES
		if(SLOT_HEAD)
			. = ITEM_SLOT_HEAD
		if(SLOT_SHOES)
			. = ITEM_SLOT_FEET
		if(SLOT_WEAR_SUIT)
			. = ITEM_SLOT_OCLOTHING
		if(SLOT_W_UNIFORM)
			. = ITEM_SLOT_ICLOTHING
		if(SLOT_L_STORE, SLOT_R_STORE)
			. = ITEM_SLOT_POCKET


//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
//Make sure to update check_obscured_slots() if you add more.
#define HIDEGLOVES		(1<<0)
#define HIDESUITSTORAGE	(1<<1)
#define HIDEJUMPSUIT	(1<<2)	//these first four are only used in exterior suits
#define HIDESHOES		(1<<3)
#define HIDEMASK		(1<<4)	//these last six are only used in masks and headgear.
#define HIDEEARS		(1<<5)	// (ears means headsets and such)
#define HIDEEYES		(1<<6)	// Whether eyes and glasses are hidden
#define HIDEFACE		(1<<7)	// Whether we appear as unknown.
#define HIDEHAIR		(1<<8)
#define HIDEFACIALHAIR	(1<<9)
#define HIDENECK		(1<<10)

//bitflags for clothing coverage - also used for limbs
#define HEAD		(1<<0)
#define CHEST		(1<<1)
#define GROIN		(1<<2)
#define LEG_LEFT	(1<<3)
#define LEG_RIGHT	(1<<4)
#define LEGS		(LEG_LEFT | LEG_RIGHT)
#define FOOT_LEFT	(1<<5)
#define FOOT_RIGHT	(1<<6)
#define FEET		(FOOT_LEFT | FOOT_RIGHT)
#define ARM_LEFT	(1<<7)
#define ARM_RIGHT	(1<<8)
#define ARMS		(ARM_LEFT | ARM_RIGHT)
#define HAND_LEFT	(1<<9)
#define HAND_RIGHT	(1<<10)
#define HANDS		(HAND_LEFT | HAND_RIGHT)
#define NECK		(1<<11)
#define FULL_BODY	(~0)

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
#define GLASSESCOVERSEYES	(1<<0)
#define MASKCOVERSEYES		(1<<1)		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES		(1<<2)		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		(1<<3)		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH		(1<<4)

#define TINT_DARKENED 2			//Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//Threshold of tint level to obscure vision fully

//Allowed equipment lists for security vests and hardsuits.

GLOBAL_LIST_INIT(advanced_hardsuit_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals)))

GLOBAL_LIST_INIT(security_hardsuit_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/melee/baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals)))

GLOBAL_LIST_INIT(detective_vest_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/detective_scanner,
	/obj/item/flashlight,
	/obj/item/taperecorder,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/melee/classic_baton,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman)))

GLOBAL_LIST_INIT(security_vest_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/kitchen/knife/combat,
	/obj/item/melee/baton,
	/obj/item/melee/classic_baton/telescopic,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman)))

GLOBAL_LIST_INIT(security_wintercoat_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/melee/classic_baton/telescopic,
	/obj/item/reagent_containers/spray/pepper,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/toy)))

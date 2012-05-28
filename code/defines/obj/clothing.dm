// All currently in-game clothing. Gimmicks moved to obj\clothing\gimmick.dm for all of your gay fantasy roleplay dress-up shenanigans.

/obj/item/clothing
	name = "clothing"
//	var/obj/item/clothing/master = null

	var/see_face = 1.0
	var/color = null

	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags

	var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N

	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)






// Belt slot clothing (only suspenders for now, because utility belt is a storage item)
/*
/obj/item/clothing/belt
	name = "belt"

	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
*/


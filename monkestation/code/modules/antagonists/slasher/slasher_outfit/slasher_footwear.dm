/obj/item/clothing/shoes/slasher_shoes
	name = "Industrial Boots"
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	clothing_traits = list(TRAIT_NO_SLIP_ALL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/shoes/slasher_shoes/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "slasher")

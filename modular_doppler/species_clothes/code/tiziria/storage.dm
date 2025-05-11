// backpacks

/obj/item/storage/backpack/lizard
	name = "\improper Tizirian tan kitbag"
	desc = "A high mounted backpack for the carrying of specialist equipment, mounted the way it is to prevent \
		interference with movement of the tail and any attached equipment. \
		This one is tan for the empire's obligate service members."
	icon = 'modular_doppler/species_clothes/icons/tiziria/gear.dmi'
	icon_state = "backpack_levy"
	worn_icon = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi'
	worn_icon_state = "backpack_levy"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null

/obj/item/storage/backpack/lizard/white
	name = "\improper Tizirian white kitbag"
	desc = "A high mounted backpack for the carrying of specialist equipment, mounted the way it is to prevent \
		interference with movement of the tail and any attached equipment. \
		This one is white for the empire's career service members."
	icon_state = "backpack_reg"
	worn_icon_state = "backpack_reg"

/obj/item/storage/backpack/lizard/black
	name = "\improper Tizirian black kitbag"
	desc = "A high mounted backpack for the carrying of specialist equipment, mounted the way it is to prevent \
		interference with movement of the tail and any attached equipment. \
		This one is black, typically \
		a taboo color for anything other than your armor and your legwear, due to black's capacity for absorbing the sun."
	icon_state = "backpack_black"
	worn_icon_state = "backpack_black"

// tailbags

/obj/item/storage/backpack/lizard_tailbag
	name = "tan tailbag"
	desc = "A pair of essentially saddlebags with straps for wear around a Tizirian's large tail. \
		The most common and most popular type of storage, even amongst Tiziria's non-military members. \
		This one is white for the empire's obligate service members."
	icon = 'modular_doppler/species_clothes/icons/tiziria/gear.dmi'
	icon_state = "tailbag_levy"
	worn_icon = 'modular_doppler/species_clothes/icons/tiziria/gear_worn.dmi'
	worn_icon_state = "tailbag_levy"
	lefthand_file = 'modular_doppler/species_clothes/icons/generic/lefthand.dmi'
	righthand_file = 'modular_doppler/species_clothes/icons/generic/righthand.dmi'
	inhand_icon_state = null

/obj/item/storage/backpack/lizard_tailbag/mob_can_equip(mob/living/M, slot, disable_warning, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if(!HAS_TRAIT(M, TRAIT_TACKLING_TAILED_DEFENDER))
		to_chat(M, span_warning("You need a tail to wear this!"))
		return FALSE // Non tail-oids get out
	return ..()

/obj/item/storage/backpack/lizard_tailbag/white
	name = "white tailbag"
	desc = "A pair of essentially saddlebags with straps for wear around a Tizirian's large tail. \
		The most common and most popular type of storage, even amongst Tiziria's non-military members. \
		This one is white for the empire's career service members."
	icon_state = "tailbag_reg"
	worn_icon_state = "tailbag_reg"

/obj/item/storage/backpack/lizard_tailbag/black
	name = "black tailbag"
	desc = "A pair of essentially saddlebags with straps for wear around a Tizirian's large tail. \
		The most common and most popular type of storage, even amongst Tiziria's non-military members. \
		This one is black, typically \
		a taboo color for anything other than your armor and your legwear, due to black's capacity for absorbing the sun."
	icon_state = "tailbag_black"
	worn_icon_state = "tailbag_black"

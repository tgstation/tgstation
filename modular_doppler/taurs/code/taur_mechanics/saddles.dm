/obj/item/riding_saddle
	name = "generic riding saddle"
	desc = "someone spawned a basetype!"
	slot_flags = ITEM_SLOT_BACK // no storage

	icon = 'modular_doppler/taurs/icons/taur_mechanics/saddles.dmi'
	worn_icon = 'modular_doppler/taurs/icons/taur_mechanics/saddles.dmi'

/obj/item/riding_saddle/Initialize(mapload)
	. = ..()
	if(type == /obj/item/riding_saddle) // don't even let these prototypes exist
		return INITIALIZE_HINT_QDEL

	AddComponent(/datum/component/carbon_saddle, RIDING_TAUR) // FREE HANDS
	AddComponent(/datum/component/taur_clothing_offset)

/obj/item/riding_saddle/leather
	name = "riding saddle"
	desc = "A thick leather riding saddle. Typically used for animals, this one has been designed for use by the taurs of the galaxy. \n\
		This saddle has specialized footrests that will allow a rider to <b>use both their hands</b> while riding."

	icon_state = "saddle_leather_item"
	worn_icon_state = "saddle_leather"

	inhand_icon_state = "syringe_kit" // placeholder
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

/obj/item/riding_saddle/leather/Initialize(mapload)
	. = ..()

/obj/item/riding_saddle/leather/blue
	name = "blue riding saddle"

	icon_state = "saddle_blue_item"
	worn_icon_state = "saddle_blue"

/obj/item/riding_saddle/leather/blue/Initialize(mapload)
	. = ..()

	desc += " This one is painted in blue and white."

/obj/item/storage/backpack/saddlebags
	name = "saddlebags"
	desc = "A collection of small pockets bound together by belt, typically used on caravan animals due to their superior storage capacity. This one has been designed for use by the taurs of the galaxy. \n\
		These saddlebags can be accessed by anyone if they <b>alt-click</b> the wearer.\n\
		Additionally, they have been modified with a hand grip that would allow <b>one free hand</b> during riding."
	gender = PLURAL

	slot_flags = ITEM_SLOT_BACK

	icon = 'modular_doppler/taurs/icons/taur_mechanics/saddles.dmi'
	worn_icon = 'modular_doppler/taurs/icons/taur_mechanics/saddles.dmi'

	storage_type = /datum/storage/saddlebags

	icon_state = "saddle_satchel_item"
	worn_icon_state = "saddle_satchel"

// slightly better than a backpack, but accessable_storage counterbalances this
/datum/storage/saddlebags
	max_total_storage = 26
	max_slots = 21

/obj/item/storage/backpack/saddlebags/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/carbon_saddle, RIDING_TAUR|RIDER_NEEDS_ARM) // one arm
	AddComponent(/datum/component/accessable_storage)
	AddComponent(/datum/component/taur_clothing_offset)


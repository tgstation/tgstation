/obj/item/storage/belt/utility/invisible
	name = "compact toolbelt"
	desc = "Holds tools. but is more easily hidden underneeth clothing."
	icon_state = "compact_utility"
	inhand_icon_state = "compact_utility"
	worn_icon_state = "hidden_icon"
	worn_icon = "hidden_icon"
	custom_premium_price = PAYCHECK_CREW * 1.5
	icon = 'modular_doppler/modular_items/icons/belts.dmi'
	lefthand_file = 'modular_doppler/modular_items/icons/belt_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/belt_righthand.dmi'

/obj/item/storage/belt/utility/invisible/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 12
	atom_storage.max_slots = 5

/obj/item/storage/belt/medical/invisible
	name = "compact medical belt"
	desc = "Can hold various medical equipment. Its smaller size makes it easier to hide under clothing."
	icon_state = "compact_medical"
	inhand_icon_state = "compact_utility"
	worn_icon_state = "hidden_icon"
	worn_icon = "hidden_icon"
	icon = 'modular_doppler/modular_items/icons/belts.dmi'
	lefthand_file = 'modular_doppler/modular_items/icons/belt_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/belt_righthand.dmi'


/obj/item/storage/belt/medical/invisible/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 12
	atom_storage.max_slots = 5


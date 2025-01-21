/obj/item/clothing/shoes/magboots/greaves_of_the_prophet
	name = "\improper Joint-snap sabatons"
	desc = "Some nice shoes that allow you to always stay up on your feet."
	icon_state = "hereticgreaves"
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF
	active_traits = list(TRAIT_NEGATES_GRAVITY)
	slowdown_active = 0
	fishing_modifier = 0
	magpulse_fishing_modifier = 0

/obj/item/clothing/shoes/magboots/greaves_of_the_prophet/Initialize(mapload)
	. = ..()
	attach_clothing_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NO_SLIP_ALL))

/obj/item/clothing/shoes/magboots/greaves_of_the_prophet/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) // Don't give us magboot sprites when we toggle the traction

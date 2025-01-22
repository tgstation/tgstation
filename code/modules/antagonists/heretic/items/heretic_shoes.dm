/obj/item/clothing/shoes/magboots/greaves_of_the_prophet
	name = "\improper Joint-snap sabatons"
	desc = "Sabatons made out of rugged, worn iron. Feels more stable than the ground they tread on. They're caked in a thin layer of rust - and yet, the sight of it fills you with odd relief."
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

/obj/item/clothing/shoes/magboots/greaves_of_the_prophet/equipped(mob/user, slot)
	if(IS_HERETIC_OR_MONSTER(user) || !(slot_flags & slot) || !iscarbon(user))
		return ..()

	var/mob/living/carbon/carbon_user = user
	for(var/obj/item/bodypart/to_remove as anything in carbon_user.bodyparts)
		if(to_remove.body_part == LEG_LEFT || to_remove.body_part == LEG_RIGHT)
			to_remove.dismember() // Heathens lose rights to their legs :)

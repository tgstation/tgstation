/obj/item/clothing/shoes/galoshes
	desc = "A pair of yellow rubber boots, designed to prevent slipping on wet surfaces."
	name = "galoshes"
	icon_state = "galoshes"
	inhand_icon_state = "galoshes"
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 3 SECONDS
	equip_delay_other = 5 SECONDS
	resistance_flags = NONE
	armor_type = /datum/armor/shoes_galoshes
	can_be_bloody = FALSE
	custom_price = PAYCHECK_CREW * 3
	fastening_type = SHOES_SLIPON
	///How much these boots affect fishing difficulty
	var/fishing_modifier = -3

/obj/item/clothing/shoes/galoshes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, fishing_modifier)

/obj/item/clothing/shoes/galoshes/dry
	name = "absorbent galoshes"
	desc = "A pair of purple rubber boots, designed to prevent slipping on wet surfaces while also drying them."
	icon_state = "galoshes_dry"
	fishing_modifier = -6

/datum/armor/shoes_galoshes
	bio = 100
	fire = 40
	acid = 75

/obj/item/clothing/shoes/galoshes/dry/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, PROC_REF(on_step))

/obj/item/clothing/shoes/galoshes/dry/proc/on_step()
	SIGNAL_HANDLER

	var/turf/open/t_loc = get_turf(src)
	SEND_SIGNAL(t_loc, COMSIG_TURF_MAKE_DRY, TURF_WET_WATER, TRUE, INFINITY)

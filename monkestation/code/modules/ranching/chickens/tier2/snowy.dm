/mob/living/basic/chicken/snowy
	icon_suffix = "snowy"

	breed_name = "Snow"
	egg_type = /obj/item/food/egg/snowy
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 40
	liked_foods = list(/obj/item/food/grown/icepepper = 4)

	book_desc = "These chickens require a sub-zero environment to live. They will melt if its not cold enough for them."
/obj/item/food/egg/snowy
	name = "Snowy Egg"
	icon_state = "snowy"

	layer_hen_type = /mob/living/basic/chicken/snowy

	high_temp = 24
	low_pressure = 3
	high_pressure = 2003

/obj/item/food/egg/snowy/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	eater.apply_status_effect(SNOWY_EGG)

/datum/status_effect/ranching/snowy
	id = "snowy_egg"
	duration = 30 SECONDS
	tick_interval = 2 SECONDS
	///Your alpha at the start of the buff
	var/base_alpha
	///your color at the start of the buff
	var/base_color
	///your temp at the start of the buff
	var/old_temp

/datum/status_effect/ranching/snowy/on_apply()
	old_temp = owner.bodytemperature
	owner.bodytemperature = TCMB
	base_alpha = owner.alpha
	owner.alpha = 155
	base_color = owner.color
	owner.color = "#018eb9"
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(create_ice))
	return ..()

/datum/status_effect/ranching/snowy/tick()
	owner.bodytemperature = TCMB

/datum/status_effect/ranching/snowy/proc/create_ice()
	var/turf/open/owners_location = owner.loc
	if(owners_location)
		owners_location.MakeSlippery(TURF_WET_PERMAFROST, min_wet_time = 10, wet_time_to_add = 5)

/datum/status_effect/ranching/snowy/on_remove()
	owner.bodytemperature = old_temp
	owner.alpha = base_alpha
	owner.color = base_color
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

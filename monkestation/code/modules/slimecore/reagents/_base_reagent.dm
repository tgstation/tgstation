/datum/reagent/slime_ooze
	name = "Generic Slime Ooze"
	evaporation_rate = 0.01
	opacity = 225
	slippery = FALSE
	var/obj/item/slime_extract/extract_path

/datum/reagent/proc/add_to_member(obj/effect/abstract/liquid_turf/adder)
	return

/datum/reagent/proc/remove_from_member(obj/effect/abstract/liquid_turf/remover)
	return

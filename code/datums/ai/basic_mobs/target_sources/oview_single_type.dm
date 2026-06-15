/// Gathers nearby atoms via oview(), returning every atom matching a fixed typepath.
/datum/target_source/oview_single_type
	var/single_typepath

/datum/target_source/oview_single_type/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/candidates = list()
	for(var/atom/candidate as anything in oview(range, pawn))
		if(istype(candidate, single_typepath))
			candidates += candidate
	return candidates

/datum/target_source/oview_single_type/carbon_mob
	single_typepath = /mob/living/carbon

/datum/target_source/oview_single_type/disposal_unit
	single_typepath = /obj/machinery/disposal

/datum/target_source/oview_single_type/watering_can
	single_typepath = /obj/item/reagent_containers/cup/watering_can

/datum/target_source/oview_single_type/ore_stand
	single_typepath = /obj/structure/ore_container/material_stand

/datum/target_source/oview_single_type/flora_tree
	single_typepath = /obj/structure/flora/tree

/datum/target_source/oview_single_type/vent_pump
	single_typepath = /obj/machinery/atmospherics/components/unary/vent_pump

/datum/target_source/oview_single_type/tribal_chief
	single_typepath = /mob/living/basic/mining/mook/worker/tribal_chief

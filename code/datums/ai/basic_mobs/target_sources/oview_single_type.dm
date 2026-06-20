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

/datum/target_source/oview_single_type/human_mob
	single_typepath = /mob/living/carbon/human

/datum/target_source/oview_single_type/living_mob
	single_typepath = /mob/living

/datum/target_source/oview_single_type/disposal_unit
	single_typepath = /obj/machinery/disposal

/datum/target_source/oview_single_type/paper
	single_typepath = /obj/item/paper

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

/datum/target_source/oview_single_type/apc
	single_typepath = /obj/machinery/power/apc

/datum/target_source/oview_single_type/machine
	single_typepath = /obj/machinery

/datum/target_source/oview_single_type/beehive
	single_typepath = /obj/structure/beebox

/datum/target_source/oview_single_type/penguin_egg
	single_typepath = /obj/item/food/egg/penguin_egg

/datum/target_source/oview_single_type/raptor
	single_typepath = /mob/living/basic/raptor

/datum/target_source/oview_single_type/raptor_trough
	single_typepath = /obj/structure/ore_container/food_trough/raptor_trough

/datum/target_source/oview_single_type/gutlunch_trough
	single_typepath = /obj/structure/ore_container/food_trough/gutlunch_trough

/datum/target_source/oview_single_type/mouse
	single_typepath = /mob/living/basic/mouse

/datum/target_source/oview_single_type/oven
	single_typepath = /obj/machinery/oven/range

/datum/target_source/oview_single_type/cable
	single_typepath = /obj/structure/cable

/datum/target_source/oview_single_type/donut
	single_typepath = /obj/item/food/donut

/datum/target_source/oview_single_type/hydroponics
	single_typepath = /obj/machinery/hydroponics

/datum/target_source/oview_single_type/cheese
	single_typepath = /obj/item/food/cheese

/datum/target_source/oview_single_type/piano_synth
	single_typepath = /obj/item/instrument/piano_synth

/datum/target_source/oview_single_type/orbie
	single_typepath = /mob/living/basic/orbie

/datum/target_source/oview_single_type/ore_vent
	single_typepath = /obj/structure/ore_vent

/datum/target_source/oview_single_type/mushroom_food
	single_typepath = /obj/item/food/grown/mushroom

/datum/target_source/oview_single_type/ore
	single_typepath = /obj/item/stack/ore

/datum/target_source/oview_single_type/minebot_target
	single_typepath = /obj/effect/temp_visual/minebot_target

/datum/target_source/oview_single_type/node_drone
	single_typepath = /mob/living/basic/node_drone

/datum/target_source/oview_single_type/icy_rock
	single_typepath = /obj/structure/flora/rock/icy

/datum/target_source/oview_single_type/ice_whelp
	single_typepath = /mob/living/basic/mining/ice_whelp

/datum/target_source/oview_single_type/hivebot
	single_typepath = /mob/living/basic/hivebot

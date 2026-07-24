/**
 * Gathers all targets of a type in the area. This is a define so we can do cheap loops over oview with astype. Yeah it sucks.
 * You can do /datum/target_source/oview_single_type/[sub_type] to use it
 */
#define OVIEW_TARGET_SOURCE(subtype, path) \
/datum/target_source/oview_single_type/##subtype/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range) { \
	var/list/candidates = list(); \
	for(var/##path/candidate in oview(range, pawn)) { \
		candidates += candidate; \
	} \
	return candidates; \
}

/// Abstract parent for target sources that return every nearby atom of a single fixed type.
/// Subtypes are generated with the OVIEW_TARGET_SOURCE() macro above.
/datum/target_source/oview_single_type

OVIEW_TARGET_SOURCE(carbon_mob, mob/living/carbon)
OVIEW_TARGET_SOURCE(human_mob, mob/living/carbon/human)
OVIEW_TARGET_SOURCE(living_mob, mob/living)
OVIEW_TARGET_SOURCE(disposal_unit, obj/machinery/disposal)
OVIEW_TARGET_SOURCE(paper, obj/item/paper)
OVIEW_TARGET_SOURCE(watering_can, obj/item/reagent_containers/cup/watering_can)
OVIEW_TARGET_SOURCE(ore_stand, obj/structure/ore_container/material_stand)
OVIEW_TARGET_SOURCE(flora_tree, obj/structure/flora/tree)
OVIEW_TARGET_SOURCE(vent_pump, obj/machinery/atmospherics/components/unary/vent_pump)
OVIEW_TARGET_SOURCE(tribal_chief, mob/living/basic/mining/mook/worker/tribal_chief)
OVIEW_TARGET_SOURCE(apc, obj/machinery/power/apc)
OVIEW_TARGET_SOURCE(machine, obj/machinery)
OVIEW_TARGET_SOURCE(beehive, obj/structure/beebox)
OVIEW_TARGET_SOURCE(penguin_egg, obj/item/food/egg/penguin_egg)
OVIEW_TARGET_SOURCE(raptor, mob/living/basic/raptor)
OVIEW_TARGET_SOURCE(raptor_trough, obj/structure/ore_container/food_trough/raptor_trough)
OVIEW_TARGET_SOURCE(gutlunch_trough, obj/structure/ore_container/food_trough/gutlunch_trough)
OVIEW_TARGET_SOURCE(mouse, mob/living/basic/mouse)
OVIEW_TARGET_SOURCE(oven, obj/machinery/oven/range)
OVIEW_TARGET_SOURCE(cable, obj/structure/cable)
OVIEW_TARGET_SOURCE(donut, obj/item/food/donut)
OVIEW_TARGET_SOURCE(hydroponics, obj/machinery/hydroponics)
OVIEW_TARGET_SOURCE(cheese, obj/item/food/cheese)
OVIEW_TARGET_SOURCE(piano_synth, obj/item/instrument/piano_synth)
OVIEW_TARGET_SOURCE(orbie, mob/living/basic/orbie)
OVIEW_TARGET_SOURCE(ore_vent, obj/structure/ore_vent)
OVIEW_TARGET_SOURCE(mushroom_food, obj/item/food/grown/mushroom)
OVIEW_TARGET_SOURCE(ore, obj/item/stack/ore)
OVIEW_TARGET_SOURCE(minebot_target, obj/effect/temp_visual/minebot_target)
OVIEW_TARGET_SOURCE(node_drone, mob/living/basic/node_drone)
OVIEW_TARGET_SOURCE(icy_rock, obj/structure/flora/rock/icy)
OVIEW_TARGET_SOURCE(ice_whelp, mob/living/basic/mining/ice_whelp)
OVIEW_TARGET_SOURCE(hivebot, mob/living/basic/hivebot)
OVIEW_TARGET_SOURCE(carrot, obj/item/food/grown/carrotlike/carrot)
OVIEW_TARGET_SOURCE(ants, obj/effect/decal/cleanable/ants)
OVIEW_TARGET_SOURCE(cat_house, obj/structure/cat_house)
OVIEW_TARGET_SOURCE(honeycomb, obj/item/food/honeycomb)
OVIEW_TARGET_SOURCE(kitten, mob/living/basic/pet/cat/kitten)
OVIEW_TARGET_SOURCE(deer_animals, mob/living/basic/deer)

#undef OVIEW_TARGET_SOURCE

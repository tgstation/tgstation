/turf/open/misc/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	base_icon_state = "ice_turf-0"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/ice
	slowdown = 1
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_ORGANIC
	var/can_make_hole = TRUE
	var/static/list/tool_screentips = list(
		TOOL_SHOVEL = list(
			SCREENTIP_CONTEXT_LMB = "Dig fishing hole",
		),
		TOOL_MINING = list(
			SCREENTIP_CONTEXT_LMB = "Dig fishing hole",
		),
	)

/turf/open/misc/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE, FALSE)
	if(can_make_hole)
		AddElement(/datum/element/contextual_screentip_tools, tool_screentips)

/turf/open/misc/ice/break_tile()
	return

/turf/open/misc/ice/burn_tile()
	return

/turf/open/misc/ice/examine(mob/user)
	. = ..()
	if(can_make_hole)
		. += span_info("You could use a [EXAMINE_HINT("shovel")] or a [EXAMINE_HINT("pick")] to dig a fishing hole here.")

/turf/open/misc/ice/attack_animal(mob/living/animal, list/modifiers)
	. = ..()
	if(HAS_TRAIT(animal, TRAIT_MOB_CAN_DIG))
		dig_hole(animal)

/turf/open/misc/ice/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.tool_behaviour != TOOL_SHOVEL && tool.tool_behaviour != TOOL_MINING)
		return NONE
	return dig_hole(user) ? ITEM_INTERACT_SUCCESS : NONE

/turf/open/misc/ice/proc/dig_hole(mob/living/user)
	if(!can_make_hole)
		return FALSE
	balloon_alert(user, "digging...")
	playsound(src, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, src))
		return FALSE
	balloon_alert(user, "dug hole")
	spawn_hole()
	return TRUE

/turf/open/misc/ice/proc/spawn_hole()
	AddComponent(/datum/component/fishing_spot, GLOB.preset_fish_sources[/datum/fish_source/ice_fishing])
	ADD_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)
	add_overlay(mutable_appearance('icons/turf/overlays.dmi', "ice_hole"))
	can_make_hole = FALSE
	RemoveElement(/datum/element/contextual_screentip_tools, tool_screentips)
	flags_1 &= ~HAS_CONTEXTUAL_SCREENTIPS_1

/turf/open/misc/ice/smooth
	icon_state = "ice_turf-255"
	base_icon_state = "ice_turf"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_ICE
	canSmoothWith = SMOOTH_GROUP_FLOOR_ICE

/turf/open/misc/ice/icemoon
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	slowdown = 0

/turf/open/misc/ice/icemoon/no_planet_atmos
	planetary_atmos = FALSE

///Ice turf with a fishing spot already dug
/turf/open/misc/ice/icemoon/no_planet_atmos/holed

/turf/open/misc/ice/icemoon/no_planet_atmos/holed/Initialize(mapload)
	. = ..()
	spawn_hole()

/turf/open/misc/ice/temperate
	baseturfs = /turf/open/misc/ice/temperate
	desc = "Somehow, it is not melting under these conditions. Must be some very thick ice. Just as slippery too."
	initial_gas_mix = COLD_ATMOS //it works with /turf/open/misc/asteroid/snow/temperatre

//For when you want real, genuine ice in your kitchen's cold room.
/turf/open/misc/ice/coldroom
	desc = "Somehow, it is not melting under these conditions. Must be some very thick ice. Just as slippery too."
	baseturfs = /turf/open/misc/ice/coldroom
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = FALSE
	temperature = COLD_ROOM_TEMP

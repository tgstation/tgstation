/turf/open/water
	name = "water"
	gender = PLURAL
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/water
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	turf_flags = NO_RUST
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	/**
	 * Used as the color arg/var for the immerse element. It should be kept more or less in line with
	 * the hue of the turf, as semi-transparent vis overlays can opacify the semi-transparent bits of an icon,
	 * and we're kinda trying to offset that issue.
	 */
	var/immerse_overlay_color = "#5AAA88"

	/// Fishing element for this specific water tile
	var/datum/fish_source/fishing_datum = /datum/fish_source/river

/turf/open/water/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/immerse, icon, icon_state, "immerse", immerse_overlay_color)
	AddElement(/datum/element/watery_tile)
	if(!isnull(fishing_datum))
		AddElement(/datum/element/lazy_fishing_spot, fishing_datum)
	ADD_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)

/turf/open/water/jungle

/turf/open/water/no_planet_atmos
	baseturfs = /turf/open/water/no_planet_atmos
	planetary_atmos = FALSE

/turf/open/water/beach
	planetary_atmos = FALSE
	gender = PLURAL
	desc = "Come on in, it's great!"
	icon = 'icons/turf/beach.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/beach
	immerse_overlay_color = "#7799AA"
	fishing_datum = /datum/fish_source/ocean/beach

/turf/open/water/beach/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MESSAGE_IN_A_BOTTLE_LOCATION, INNATE_TRAIT)

/turf/open/water/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/water/beach/tizira
	desc = "Shallow water. It somehow reminds you of lizardfolk."
	icon_state = "tizira_water"
	base_icon_state = "tizira_water"
	baseturfs = /turf/open/water/beach/tizira

/**
 * A special subtype of water with steam particles and a status effect similar to showers, that's however only applied if
 * the living mob inside the turf is actually immersed in it (eg. not flying, not floating).
 */
/turf/open/water/hot_spring
	name = "hot spring"
	icon_state = "pool"
	desc = "Water kept warm through some unknown heat source, possibly a geothermal heat source far underground. \
		Whatever it is, it feels pretty damn nice to swim in given the rest of the environment around here, and you \
		can even catch a glimpse of the odd fish darting through the water."
	baseturfs = /turf/open/water/hot_spring
	fishing_datum = /datum/fish_source/hot_spring
	planetary_atmos = FALSE
	/// Holder for the steam particles that show up sometimes
	var/obj/effect/abstract/particle_holder/cached/particle_effect

/turf/open/water/hot_spring/Initialize(mapload)
	. = ..()
	particle_effect = new(src, /particles/hotspring_steam, 4)
	particle_effect.vis_flags &= ~VIS_INHERIT_PLANE //render the steam over mobs and objects on the game plane
	var/static/icon/waves_mask = icon('icons/effects/cut.dmi', "pool_waves")
	add_filter("hot_spring_waves", 1, displacement_map_filter(waves_mask, x = 0, y = 0, size = 1))
	/**
	 * turf/Initialize() calls Entered on its contents, however
	 * we need to wait for movables that still need to be initialized.
	 */
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(enter_initialized_movable))

/turf/open/water/hot_spring/Destroy()
	QDEL_NULL(particle_effect)
	remove_filter("hot_spring_waves")
	for(var/atom/movable/movable as anything in contents)
		exit_hot_spring(movable)
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	return ..()

/turf/open/water/hot_spring/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(!(flags_1 & INITIALIZED_1))
		return
	enter_hot_spring(arrived)

/turf/open/water/hot_spring/proc/enter_initialized_movable(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	enter_hot_spring(movable)

///Registers the signals from the immerse element and calls dip_in if the movable has the required trait.
/turf/open/water/hot_spring/proc/enter_hot_spring(atom/movable/movable)
	RegisterSignal(movable, SIGNAL_ADDTRAIT(TRAIT_IMMERSED), PROC_REF(dip_in))
	if(isliving(movable)) //so far, exiting a hot spring only has effects on living mobs.
		RegisterSignal(movable, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED), PROC_REF(dip_out))

	if(HAS_TRAIT(movable, TRAIT_IMMERSED))
		dip_in(movable)

///Handles washing the movable and adding a status effect plus mood event to living mobs.
/turf/open/water/hot_spring/proc/dip_in(atom/movable/movable)
	SIGNAL_HANDLER
	movable.wash(CLEAN_RAD | CLEAN_WASH)
	if(!isliving(movable))
		return

	var/mob/living/living = movable
	if(living.has_status_effect(/datum/status_effect/washing_regen/hot_spring))
		return
	living.apply_status_effect(/datum/status_effect/washing_regen/hot_spring)
	if(!HAS_TRAIT(living, TRAIT_WATER_HATER) || HAS_TRAIT(living, TRAIT_WATER_ADAPTATION))
		living.add_mood_event("hot_spring", /datum/mood_event/hot_spring)
	else
		living.add_mood_event("hot_spring", /datum/mood_event/hot_spring_hater)

/turf/open/water/hot_spring/Exited(atom/movable/gone, atom/new_loc)
	. = ..()
	exit_hot_spring(gone)

//Unregister the signals and remove the status effect from mobs unless they're moving to another hot spring turf.
/turf/open/water/hot_spring/proc/exit_hot_spring(atom/movable/movable)
	UnregisterSignal(movable, list(SIGNAL_ADDTRAIT(TRAIT_IMMERSED), SIGNAL_REMOVETRAIT(TRAIT_IMMERSED)))
	if(!isliving(movable))
		return
	var/mob/living/living = movable
	if(!living.has_status_effect(/datum/status_effect/washing_regen/hot_spring) || istype(living.loc, /turf/open/water/hot_spring))
		return
	dip_out(living)

///Handles removing the status effect from mobs.
/turf/open/water/hot_spring/proc/dip_out(mob/living/living)
	SIGNAL_HANDLER
	living.remove_status_effect(/datum/status_effect/washing_regen/hot_spring)
	if(!HAS_TRAIT(living, TRAIT_WATER_HATER) || HAS_TRAIT(living, TRAIT_WATER_ADAPTATION))
		living.add_mood_event("hot_spring", /datum/mood_event/hot_spring_left)
	else
		living.add_mood_event("hot_spring", /datum/mood_event/hot_spring_hater_left)

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
	///The transparency of the immerse element's overlay
	var/immerse_overlay_alpha = 180
	///Icon state to use for the immersion mask
	var/immerse_overlay = "immerse"

	/// Fishing element for this specific water tile
	var/datum/fish_source/fishing_datum = /datum/fish_source/river

	/// Whether the immerse element has been added yet or not
	var/immerse_added = FALSE

	/**
	 * Variables used for the swimming tile element. If TRUE, we pass these values to the element.
	 * - is_swimming_tile: Whether or not we add the element to this tile.
	 * - stamina_entry_cost: how much stamina it costs to enter the swimming tile, and for each move into a tile
	 * - ticking_stamina_cost: How much stamina is lost for staying in the water.
	 * - ticking_oxy_damage: How much oxygen is lost per tick when drowning in water. Also determines how many breathes are lost.
	 * - exhaust_swimmer_prob: The likelihood that someone suffers stamina damage when entering a swimming tile.
	 */
	var/is_swimming_tile = FALSE
	var/stamina_entry_cost = 7
	var/ticking_stamina_cost = 5
	var/ticking_oxy_damage = 2
	var/exhaust_swimmer_prob = 30

/turf/open/water/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_atom_inited))
	AddElement(/datum/element/watery_tile)
	if(!isnull(fishing_datum))
		add_lazy_fishing(fishing_datum)
	ADD_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)

///We lazily add the immerse element when something is spawned or crosses this turf and not before.
/turf/open/water/proc/on_atom_inited(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	make_immersed(movable)

/**
 * turf/Initialize() calls Entered on its contents too, however
 * we need to wait for movables that still need to be initialized
 * before we add the immerse element.
 */
/turf/open/water/Entered(atom/movable/arrived)
	. = ..()
	make_immersed(arrived)

///Makes this turf immersable, return true if we actually did anything so child procs don't have to repeat our checks
/turf/open/water/proc/make_immersed(atom/movable/triggering_atom)
	if(immerse_added || is_type_in_typecache(triggering_atom, GLOB.immerse_ignored_movable))
		return FALSE
	AddElement(/datum/element/immerse, icon, icon_state, immerse_overlay, immerse_overlay_color, alpha = immerse_overlay_alpha)
	immerse_added = TRUE
	if(is_swimming_tile)
		AddElement(/datum/element/swimming_tile, stamina_entry_cost, ticking_stamina_cost, ticking_oxy_damage, exhaust_swimmer_prob)
	return TRUE

/turf/open/water/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	return ..()


/turf/open/water/jungle

/turf/open/water/no_planet_atmos
	baseturfs = /turf/open/water/no_planet_atmos
	planetary_atmos = FALSE

/turf/open/water/no_planet_atmos/deep
	name = "deep water"
	desc = "Less shallow water."
	icon_state = "deep_riverwater_motion"
	immerse_overlay = "immerse_deep"
	baseturfs = /turf/open/water/no_planet_atmos/deep
	is_swimming_tile = TRUE

/turf/open/water/no_planet_atmos/deep/lethal
	name = "treacherous water"
	desc = "Less shallow, very dangerous water. You feel like it would be a very bad idea to enter this water."
	stamina_entry_cost = 25
	ticking_stamina_cost = 15
	ticking_oxy_damage = 2
	exhaust_swimmer_prob = 100

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

/// Deep water drains stamina and starts drowning you
/turf/open/water/deep_beach
	name = "deep water"
	desc = "Don't forget your life jacket."
	immerse_overlay = "immerse_deep"
	icon = 'icons/turf/beach.dmi'
	icon_state = "deepwater"
	base_icon_state = "deepwater"
	baseturfs = /turf/open/water/deep_beach
	immerse_overlay_color = "#57707c"
	fishing_datum = /datum/fish_source/ocean
	is_swimming_tile = TRUE

/turf/open/water/deep_beach/lethal
	name = "treacherous water"
	desc = "You think entering this water would probably go extremely badly."

/turf/open/water/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/water/beach/tizira
	desc = "Shallow water. It somehow reminds you of lizardfolk."
	icon_state = "tizira_water"
	base_icon_state = "tizira_water"
	baseturfs = /turf/open/water/beach/tizira
	fishing_datum = /datum/fish_source/tizira

/**
 * A special subtype of water with steam particles and a status effect similar to showers, that's however only applied if
 * the living mob inside the turf is actually immersed in it (eg. not flying, not floating).
 */
/turf/open/water/hot_spring
	name = "hot spring"
	icon_state = "pool_1"
	desc = "Water kept warm through some unknown heat source, possibly a geothermal heat source far underground. \
		Whatever it is, it feels pretty damn nice to swim, and you can even catch a glimpse of \
		the odd fish darting through the water."
	baseturfs = /turf/open/water/hot_spring
	planetary_atmos = FALSE
	immerse_overlay_color = "#A0E2DE"
	immerse_overlay_alpha = 190
	fishing_datum = /datum/fish_source/hot_spring

/turf/open/water/hot_spring/Initialize(mapload)
	. = ..()
	// We need to add the immerse element now because the icon_states are randomized and
	// we don't want to end up with 4 different immerse elements, which would cause
	// the immerse trait to be repeatedly removed and readded as someone moves within the pool,
	// replacing the status effect over and over, which can be seen through the status effect alert icon.
	if(!immerse_added)
		AddElement(/datum/element/immerse, icon, icon_state, "immerse", immerse_overlay_color, alpha = immerse_overlay_alpha)
		immerse_added = TRUE
	icon_state = "pool_[rand(1, 4)]"
	var/obj/effect/abstract/shared_particle_holder/holder = add_shared_particles(/particles/hotspring_steam, "hot_springs_[GET_TURF_PLANE_OFFSET(src)]", pool_size = 4)
	// Render the steam over mobs and objects on the game plane
	holder.vis_flags &= ~VIS_INHERIT_PLANE
	// And be unaffected by ambient occlusions, which would render the steam grey
	holder.plane = MUTATE_PLANE(MASSIVE_OBJ_PLANE, src)
	add_filter("hot_spring_waves", 1, wave_filter(y = 1, size = 1, offset = 0, flags = WAVE_BOUNDED))
	var/filter = get_filter("hot_spring_waves")
	animate(filter, offset = 1, time = 3 SECONDS, loop = -1, easing = SINE_EASING|EASE_IN|EASE_OUT)
	animate(offset = 0, time = 3 SECONDS, easing = SINE_EASING|EASE_IN|EASE_OUT)

/turf/open/water/hot_spring/Destroy()
	remove_shared_particles("hot_springs_[GET_TURF_PLANE_OFFSET(src)]")
	remove_filter("hot_spring_waves")
	for(var/atom/movable/movable as anything in contents)
		exit_hot_spring(movable)
	return ..()

/turf/open/water/hot_spring/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(!(flags_1 & INITIALIZED_1))
		return
	enter_hot_spring(arrived)

/turf/open/water/hot_spring/on_atom_inited(datum/source, atom/movable/movable)
	enter_hot_spring(movable)

///Registers the signals from the immerse element and calls dip_in if the movable has the required trait.
/turf/open/water/hot_spring/proc/enter_hot_spring(atom/movable/movable)
	if(is_type_in_typecache(movable, GLOB.immerse_ignored_movable)) // So we don't immerse weird things like turf decals/effects, projectiles, etc
		return FALSE
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

/turf/open/water/hot_spring/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

//Bubble that grants space protection to those inside of it.
/datum/proximity_monitor/advanced/bubble/space_protection
	edge_is_a_field = FALSE
	///List of all traits that's given to mobs in the field, which is our "space proof" we grant.
	var/static/list/traits_to_give = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
	)

/datum/proximity_monitor/advanced/bubble/space_protection/setup_effect_directions()
	effect_direction_images = list(
		"[SOUTH]" = image('icons/effects/fields.dmi', icon_state = "space_protection_south"),
		"[NORTH]" = image('icons/effects/fields.dmi', icon_state = "space_protection_north"),
		"[WEST]" =  image('icons/effects/fields.dmi', icon_state = "space_protection_west"),
		"[EAST]" = image('icons/effects/fields.dmi', icon_state = "space_protection_east"),
		"[NORTHWEST]" = image('icons/effects/fields.dmi', icon_state = "space_protection_northwest"),
		"[SOUTHWEST]" = image('icons/effects/fields.dmi', icon_state = "space_protection_southwest"),
		"[NORTHEAST]" = image('icons/effects/fields.dmi', icon_state = "space_protection_northeast"),
		"[SOUTHEAST]" = image('icons/effects/fields.dmi', icon_state = "space_protection_southeast"),
	)

/datum/proximity_monitor/advanced/bubble/space_protection/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isliving(movable) || HAS_TRAIT_FROM(movable, traits_to_give[1], REF(src)))
		return
	give_space_immunity(movable)

/datum/proximity_monitor/advanced/bubble/space_protection/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isliving(movable) || get_dist(new_location, host) <= (edge_is_a_field ? current_range : current_range - 1))
		return
	remove_space_immunity(movable)

/datum/proximity_monitor/advanced/bubble/space_protection/setup_field_turf(turf/target)
	for(var/mob/possible_mob in target)
		give_space_immunity(possible_mob)

/datum/proximity_monitor/advanced/bubble/space_protection/cleanup_field_turf(turf/target)
	for(var/mob/possible_mob in target)
		if(HAS_TRAIT_FROM(possible_mob, traits_to_give[1], REF(src)))
			remove_space_immunity(possible_mob)

///a mob has entered our field, apply the space protection to them.
/datum/proximity_monitor/advanced/bubble/space_protection/proc/give_space_immunity(mob/living/new_immunne)
	new_immunne.add_traits(traits_to_give, REF(src))

///removing the effects after the mob has exited our field.
/datum/proximity_monitor/advanced/bubble/space_protection/proc/remove_space_immunity(mob/living/no_longer_immune)
	no_longer_immune.remove_traits(traits_to_give, REF(src))

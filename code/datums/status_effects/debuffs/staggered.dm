/datum/status_effect/staggered
	id = "staggered"
	duration = SHOVE_SLOWDOWN_LENGTH
	remove_on_fullheal = TRUE
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/staggered/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	..()

/datum/status_effect/staggered/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/staggered)
	owner.emote("sway")
	return ..()

/datum/status_effect/staggered/on_remove()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/staggered)

	var/active_item = owner.get_active_held_item()
	if(is_type_in_typecache(active_item, GLOB.shove_disarming_types))
		owner.visible_message(span_warning("[owner.name] regains their grip on \the [active_item]!"), span_warning("You regain your grip on \the [active_item]"), null, COMBAT_MESSAGE_RANGE)
	return ..()

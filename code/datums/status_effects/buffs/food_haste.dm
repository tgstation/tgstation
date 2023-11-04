/// Haste makes the eater move faster
/datum/status_effect/food/haste
	var/datum/movespeed_modifier/food_haste/modifier

/datum/status_effect/food/haste/on_apply()
	modifier = new()
	modifier.multiplicative_slowdown = -0.04 * strength
	owner.add_movespeed_modifier(modifier, update = TRUE)
	return ..()

/datum/status_effect/food/haste/be_replaced()
	owner.remove_movespeed_modifier(modifier, update = TRUE)
	return ..()

/datum/status_effect/food/haste/on_remove()
	owner.remove_movespeed_modifier(modifier, update = TRUE)
	return ..()

/datum/movespeed_modifier/food_haste
	multiplicative_slowdown = -0.1

///Haste makes the eater move and act faster
/datum/status_effect/food/haste
	var/datum/movespeed_modifier/food_haste/speed_mod
	var/datum/actionspeed_modifier/status_effect/food_haste/action_mod

/datum/status_effect/food/haste/on_apply()
	speed_mod = new()
	speed_mod.multiplicative_slowdown = -0.04 * strength
	owner.add_movespeed_modifier(speed_mod, update = TRUE)
	action_mod = new()
	action_mod.multiplicative_slowdown = -0.06 * strength
	owner.add_actionspeed_modifier(action_mod, update = TRUE)
	return ..()

/datum/status_effect/food/haste/be_replaced()
	owner.remove_movespeed_modifier(speed_mod)
	owner.remove_actionspeed_modifier(action_mod)
	return ..()

/datum/status_effect/food/haste/on_remove()
	owner.remove_movespeed_modifier(speed_mod, update = TRUE)
	owner.remove_actionspeed_modifier(action_mod, update = TRUE)
	return ..()

/datum/movespeed_modifier/food_haste
	multiplicative_slowdown = -0.04

/datum/actionspeed_modifier/status_effect/food_haste
	multiplicative_slowdown = -0.06

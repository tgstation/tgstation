/// Buffs given by eating hand-crafted food. The duration scales with consumable reagents purity.
/datum/status_effect/food
	id = "food_buff"
	duration = 5 MINUTES // Same as food mood buffs
	status_type = STATUS_EFFECT_REPLACE // Only one food buff allowed
	alert_type = /atom/movable/screen/alert/status_effect/food
	show_duration = TRUE
	/// Buff power
	var/strength

/datum/status_effect/food/on_creation(mob/living/new_owner, timeout_mod = 1, strength = 1)
	src.strength = strength
	//Generate alert when not specified
	if(isnum(timeout_mod))
		duration *= timeout_mod
	. = ..()
	if(istype(linked_alert, /atom/movable/screen/alert/status_effect/food))
		linked_alert.icon_state = "[linked_alert.base_icon_state]_[strength]"

/atom/movable/screen/alert/status_effect/food
	name = "Hand-crafted meal"
	desc = "Eating it made me feel better."
	icon_state = "food_buff_1"
	base_icon_state = "food_buff"

/// Makes you gain a trait
/datum/status_effect/food/trait
	var/trait = TRAIT_DUMB // You need to override this

/datum/status_effect/food/trait/on_apply()
	ADD_TRAIT(owner, trait, type)
	return ..()

/datum/status_effect/food/trait/be_replaced()
	REMOVE_TRAIT(owner, trait, type)
	return ..()

/datum/status_effect/food/trait/on_remove()
	REMOVE_TRAIT(owner, trait, type)
	return ..()

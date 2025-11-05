/// Buffs given by eating hand-crafted food. The duration scales with consumable reagents purity.
/datum/status_effect/food
	id = "food_effect"
	duration = 5 MINUTES // Same as food mood buffs
	status_type = STATUS_EFFECT_REPLACE // Only one food buff allowed
	alert_type = /atom/movable/screen/alert/status_effect/food
	show_duration = TRUE
	/// Buff power equal to food complexity (1 to 5)
	var/strength

/datum/status_effect/food/on_creation(mob/living/new_owner, timeout_mod = 1, strength = 1)
	. = ..()
	src.strength = strength
	if(isnum(timeout_mod))
		duration *= timeout_mod
	if(istype(linked_alert, /atom/movable/screen/alert/status_effect/food))
		linked_alert.overlay_state = "food_buff_[strength]"

/atom/movable/screen/alert/status_effect/food
	name = "Hand-crafted meal"
	desc = "Eating it made me feel better."
	use_user_hud_icon = TRUE
	overlay_state = "food_buff_1"

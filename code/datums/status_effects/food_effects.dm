/// Buffs given by eating hand-crafted food. The duration scales with consumable reagents purity.
/datum/status_effect/food
	id = "food_buff"
	duration = 5 MINUTES // Same as food mood buffs
	status_type = STATUS_EFFECT_REPLACE // Only one food buff allowed
	/// Buff power
	var/strength

/datum/status_effect/food/on_creation(mob/living/new_owner, timeout_mod = 1, strength = 1)
	src.strength = strength
	if(isnum(timeout_mod))
		duration *= timeout_mod
	. = ..()

/// Haste makes the eater move faster
/datum/status_effect/food/haste
	alert_type = /atom/movable/screen/alert/status_effect/food_haste
	var/datum/movespeed_modifier/food_haste/modifier

/datum/status_effect/food/haste/on_apply()
	modifier = new()
	modifier.multiplicative_slowdown = -0.04 * strength
	owner.add_movespeed_modifier(modifier, update = TRUE)
	return ..()

/datum/status_effect/food/haste/on_remove()
	owner.remove_movespeed_modifier(modifier, update = TRUE)
	return ..()

/datum/movespeed_modifier/food_haste
	multiplicative_slowdown = -0.1

/atom/movable/screen/alert/status_effect/food_haste
	name = "Energetic meal"
	desc = "That meal makes me pumped up with energy!"
	icon_state = "realignment"

/// Makes you gain a trait
/datum/status_effect/food/trait
	var/trait = TRAIT_DUMB // You need to override this

/datum/status_effect/food/trait/on_apply()
	ADD_TRAIT(owner, trait, type)
	return ..()

/datum/status_effect/food/trait/on_remove()
	REMOVE_TRAIT(owner, trait, type)
	return ..()

/datum/status_effect/food/trait/jolly
	alert_type = /atom/movable/screen/alert/status_effect/food_trait_jolly
	trait = TRAIT_JOLLY

/atom/movable/screen/alert/status_effect/food_trait_jolly
	name = "Jolly"
	desc = "That meal made me feel funny..."
	icon_state = "drunk2"

/datum/status_effect/food/trait/shockimmune
	alert_type = /atom/movable/screen/alert/status_effect/food_trait_shockimmune
	trait = TRAIT_SHOCKIMMUNE

/atom/movable/screen/alert/status_effect/food_trait_shockimmune
	name = "Grounded"
	desc = "That meal made me feel like a superconductor..."
	icon_state = "woozy"

/datum/status_effect/food/trait/stunimmune
	alert_type = /atom/movable/screen/alert/status_effect/food_trait_stunimmune
	trait = TRAIT_STUNIMMUNE

/atom/movable/screen/alert/status_effect/food_trait_stunimmune
	name = "Unstoppable"
	desc = "That meal made me feel like a mountain..."
	icon_state = "stun"

/datum/status_effect/food/trait/noslip
	alert_type = /atom/movable/screen/alert/status_effect/food_trait_noslip
	trait = TRAIT_NO_SLIP_ALL

/atom/movable/screen/alert/status_effect/food_trait_noslip
	name = "Stable"
	desc = "That meal made me feel that I have complete control over my balance..."
	icon_state = "terrified"

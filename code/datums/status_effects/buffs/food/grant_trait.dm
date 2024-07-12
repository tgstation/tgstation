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

/datum/status_effect/food/trait/shockimmune
	alert_type = /atom/movable/screen/alert/status_effect/shockimmune
	trait = TRAIT_SHOCKIMMUNE

/atom/movable/screen/alert/status_effect/shockimmune
	name = "Grounded"
	desc = "That meal made me feel like a superconductor..."
	icon_state = "shock_immune"

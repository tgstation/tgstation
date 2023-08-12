#define WATER_STACK_TO_SLIME_WASH_RATIO (1/2)
#define MIN_WATER_STACKS 10

/atom/movable/screen/alert/status_effect/slimed
	name = "Covered in Slime"
	desc = "You are covered in slime and it's eating away at you! Find a way to wash it off!"
	icon_state = "slimed"

/datum/status_effect/slimed
	id = "slimed"
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/slimed
	remove_on_fullheal = TRUE

	var/washing_required = 20

/datum/status_effect/slimed/on_creation(mob/living/new_owner, ...)
	return ..()

/datum/status_effect/slimed/on_apply()
	to_chat(owner, span_userdanger("You have been covered in thick slime residue!"))
	return ..()

/datum/status_effect/slimed/tick(seconds_per_tick)
	// handle washing slime off
	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in owner.status_effects
	if(istype(wetness) && wetness.stacks > MIN_WATER_STACKS)
		washing_required--
		wetness.adjust_stacks(-5)

		if(washing_required <= 0)
			to_chat(owner, span_notice("You manage to wash off the slime completely."))
			qdel(src)
			return

		if(SPT_PROB(10, seconds_per_tick))
			to_chat(owner, span_warning("The slime is slowly washing off your skin."))
		return

	// otherwise deal brute damage
	owner.adjustBruteLoss(rand(1,3) * seconds_per_tick)
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(owner, span_userdanger(pick("Your entire body is stinging with pain!",
		"Your skin feels like it's coming off!", "Your body feels like it's melting together!")))

#undef MIN_WATER_STACKS
#undef WATER_STACK_TO_SLIME_WASH_RATIO

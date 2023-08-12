#define WATER_STACK_TO_SLIME_WASH_RATIO (1/2)
#define MIN_WATER_STACKS 5

/atom/movable/screen/alert/status_effect/slimed
	name = "Covered in Slime"
	desc = "You are covered in slime and it's eating away at you! Find a way to wash it off!"
	icon_state = "slimed"

/datum/status_effect/slimed
	id = "slimed"
	tick_interval = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/slimed
	remove_on_fullheal = TRUE

	var/slime_stacks = 10 // ~10 seconds of standing under a shower

/datum/status_effect/slimed/on_apply()
	to_chat(owner, span_userdanger("You have been covered in thick slime residue! You need to wash it off!"))
	return ..()

/datum/status_effect/slimed/tick(seconds_per_tick)
	// handle washing slime off
	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in owner.status_effects
	if(istype(wetness) && wetness.stacks > MIN_WATER_STACKS)
		slime_stacks -= seconds_per_tick // lose 1 stack per second
		wetness.adjust_stacks(-5 * seconds_per_tick)

		if(slime_stacks <= 0)
			to_chat(owner, span_notice("You manage to wash off the slime completely."))
			qdel(src)
			return

		if(SPT_PROB(10, seconds_per_tick))
			to_chat(owner, span_warning("The slime layer is slowly washing off your skin."))
		return

	// otherwise deal brute damage
	owner.adjustBruteLoss(rand(3,5) * seconds_per_tick)
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(owner, span_userdanger(pick("Your entire body is stinging with pain!",
		"Your skin feels like it's coming off!", "Your body feels like it's melting together!")))

#undef MIN_WATER_STACKS
#undef WATER_STACK_TO_SLIME_WASH_RATIO

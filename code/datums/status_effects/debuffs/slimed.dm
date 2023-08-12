/// The minimum amount of water stacks needed to start washing off the slime.
#define MIN_WATER_STACKS 5
/// The minimum amount of health a mob has to have before the status effect is removed.
#define MIN_HEALTH 10

/atom/movable/screen/alert/status_effect/slimed
	name = "Covered in Slime"
	desc = "You are covered in slime and it's eating away at you! Find a way to wash it off!"
	icon_state = "slimed"

/datum/status_effect/slimed
	id = "slimed"
	tick_interval = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/slimed
	remove_on_fullheal = TRUE

	/// The amount of slime stacks that were applied, reduced by showering yourself in water.
	var/slime_stacks = 10 // ~10 seconds of standing under a shower

/datum/status_effect/slimed/on_apply()
	if(owner.get_organic_health() <= MIN_HEALTH)
		return FALSE
	owner.visible_message(
		span_warning("[owner] has been covered in a thick layer of slime!"),
		span_userdanger("You have been covered in a thick layer of slime! Find a way to wash it off!"))
	return ..()

/datum/status_effect/slimed/tick(seconds_per_tick)
	// remove from the mob once we have dealt enough damage
	if(owner.get_organic_health() <= MIN_HEALTH)
		owner.visible_message(
			span_warning("The layer of slime slowly drips off [owner] as it leaves [owner.p_their()] weakened body behind."),
			span_warning("You feel the layer of slime crawling off of your weakened body."))
		qdel(src)
		return

	// handle washing slime off
	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in owner.status_effects
	if(istype(wetness) && wetness.stacks > (MIN_WATER_STACKS * seconds_per_tick))
		slime_stacks -= seconds_per_tick // lose 1 stack per second
		wetness.adjust_stacks(-5 * seconds_per_tick)

		// got rid of it
		if(slime_stacks <= 0)
			owner.visible_message(
				span_notice("[owner] manages to wash the layer of slime off [owner.p_their()] body."),
				span_notice("You manage to wash off the layer of slime completely."))
			qdel(src)
			return

		if(SPT_PROB(10, seconds_per_tick))
			owner.visible_message(
				span_warning("The layer of slime is slowly washing off of [owner][owner.p_s()] body."),
				span_warning("The layer of slime is slowly getting thinner as it's washing off your skin."))

		return

	// otherwise deal brute damage
	owner.adjustBruteLoss(rand(2,4) * seconds_per_tick)

	if(SPT_PROB(10, seconds_per_tick))
		owner.visible_message(
			span_warning("[owner] tenses up as the layer of slime on [owner.p_their()] eats away at [owner.p_their()] skin!"),
			span_userdanger("[pick("Your entire body screams with pain",
					"Your skin feels like it's coming off",
					"Your body feels like it's melting together")] as the layer of slime eats away at you!"))

#undef MIN_HEALTH
#undef MIN_WATER_STACKS

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

	/// The amount of slime stacks that were applied, reduced by showering yourself under water.
	var/slime_stacks = 10 // ~10 seconds of standing under a shower
	/// Slime color, used for particles.
	var/slime_color
	/// Changes particle colors to rainbow, this overrides `slime_color`.
	var/rainbow

/datum/status_effect/slimed/on_creation(mob/living/new_owner, slime_color = COLOR_SLIME_GREY, rainbow = FALSE)
	src.slime_color = slime_color
	src.rainbow = rainbow
	return ..()

/datum/status_effect/slimed/on_apply()
	if(owner.get_organic_health() <= MIN_HEALTH)
		return FALSE
	to_chat(owner, span_userdanger("You have been covered in a thick layer of slime! Find a way to wash it off!"))
	return ..()

/datum/status_effect/slimed/tick(seconds_between_ticks)
	// remove from the mob once we have dealt enough damage
	if(owner.get_organic_health() <= MIN_HEALTH)
		to_chat(owner, span_warning("You feel the layer of slime crawling off of your weakened body."))
		qdel(src)
		return

	// handle washing slime off
	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in owner.status_effects
	if(istype(wetness) && wetness.stacks > (MIN_WATER_STACKS * seconds_between_ticks))
		slime_stacks -= seconds_between_ticks // lose 1 stack per second
		wetness.adjust_stacks(-5 * seconds_between_ticks)

		// got rid of it
		if(slime_stacks <= 0)
			to_chat(owner, span_notice("You manage to wash off the layer of slime completely."))
			qdel(src)
			return

		if(SPT_PROB(10, seconds_between_ticks))
			to_chat(owner,span_warning("The layer of slime is slowly getting thinner as it's washing off your skin."))

		return

	// otherwise deal brute damage
	owner.apply_damage(rand(2,4) * seconds_between_ticks, damagetype = BRUTE)

	if(SPT_PROB(10, seconds_between_ticks))
		var/feedback_text = pick(list(
			"Your entire body screams with pain",
			"Your skin feels like it's coming off",
			"Your body feels like it's melting together"
		))
		to_chat(owner, span_userdanger("[feedback_text] as the layer of slime eats away at you!"))

/datum/status_effect/slimed/update_particles()
	if(particle_effect)
		return

	// taste the rainbow
	var/particle_type = rainbow ? /particles/slime/rainbow : /particles/slime
	particle_effect = new(owner, particle_type)

	if(!rainbow)
		particle_effect.particles.color = "[slime_color]a0"

/datum/status_effect/slimed/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] covered in bubbling slime!")

#undef MIN_HEALTH
#undef MIN_WATER_STACKS

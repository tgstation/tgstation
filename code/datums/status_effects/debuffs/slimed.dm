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

/datum/status_effect/slime
	id = "bruh"
	/// Type of the owner so we can use slime procs.
	var/mob/living/simple_animal/slime/slime_owner
	/// Duration is forced to be at most this.
	var/max_duration = null

/datum/status_effect/slime/on_apply()
	ASSERT(isslime(owner))
	slime_owner = owner
	..()

/datum/status_effect/slime/on_remove()
	slime_owner = null
	return ..()

/datum/status_effect/slime/refresh(mob/living/owner, to_add)
	. = ..()
	duration += min(to_add, max_duration)

#define MAXIMUM_TRITRATION_TIME 60 SECONDS
#define TRITRATED_FILTER "tritrated"

/atom/movable/screen/alert/status_effect/tritrated
	name = "Tritrated Slime"
	desc = "Your slime body has completely adapted to Tritium! It will mutate until becoming green, and you will constantly send out powerful radioactive pulses."
	icon_state = "radiation"

/datum/status_effect/slime/tritrated
	id = "tritrated"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	max_duration = MAXIMUM_TRITRATION_TIME
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/tritrated
	remove_on_fullheal = TRUE

/datum/status_effect/slime/tritrated/on_apply()
	. = ..()
	to_chat(slime_owner, span_userdanger("You've absorbed so much tritium you've become a radiation engine!"))
	slime_owner.AddElement(
		/datum/element/radioactive, \
		range = 5, \
		threshold = RAD_HEAVY_INSULATION, \
	)
	slime_owner.add_filter(TRITRATED_FILTER, 10, list("type" = "rays", "size" = 35, "color" = "#32cd32"))
	return .

/datum/status_effect/slime/tritrated/on_remove()
	slime_owner.RemoveElement(/datum/element/radioactive)
	slime_owner.remove_filter(TRITRATED_FILTER)
	return ..()


/datum/status_effect/slime/tritrated/tick(seconds_between_ticks)
	if(SPT_PROB(45, seconds_between_ticks))
		slime_owner.set_colour(pick(slime_owner.slime_colours))
		owner.apply_damage(rand(2,4) * seconds_between_ticks, damagetype = BRUTE)
	if(SPT_PROB(25, seconds_between_ticks))
		slime_owner.fire_nuclear_particle()
		owner.apply_damage(rand(4, 8) * seconds_between_ticks, damagetype = BRUTE)
		slime_owner.force_mood_change(force_mood = "angry")

/datum/status_effect/slime/tritrated/update_particles()
	if(particle_effect)
		return

	particle_effect = new(owner, /particles/slime)

	// Green is radioactive and tritium and whatnot
	particle_effect.particles.color = "[COLOR_SLIME_GREEN]a0"

/datum/status_effect/slime/tritrated/get_examine_text()
	return span_bolddanger("Its surface mass is shifting and bubbling wildly, radiation pulses beaming out!")

#undef MAXIMUM_TRITRATION_TIME
#undef TRITRATED_FILTER

#define MAXIMUM_STUPOR_TIME 4 MINUTES
#define STUPOR_FILTER "stupefied"

/atom/movable/screen/alert/status_effect/stupor
	name = "Hallucinogenic Stupor"
	desc = "You've fallen under the influence of Slime Weed, AKA Pluoxium gas. You feel very friendly..."
	icon_state = "???"

/datum/status_effect/slime/stupor
	id = "stupor"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	max_duration = MAXIMUM_STUPOR_TIME
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/stupor
	remove_on_fullheal = TRUE
	var/stored_docility
	var/stored_friends

/datum/status_effect/slime/stupor/on_apply()
	. = ..()
	to_chat(slime_owner, span_userdanger("You've fallen into a pleasant stupor..."))
	ADD_TRAIT(slime_owner, TRAIT_PACIFISM, REF(src))
	slime_owner.add_filter(STUPOR_FILTER, 2, list("type" = "drop_shadow", "color" = "#9370db", "alpha" = 0, "size" = 2))
	stored_docility = slime_owner.docile
	stored_friends = slime_owner.Friends
	slime_owner.docile = TRUE
	slime_owner.clear_friends()
	return .

/datum/status_effect/slime/stupor/on_remove()
	REMOVE_TRAIT(slime_owner, TRAIT_PACIFISM, REF(src))
	slime_owner.remove_filter(STUPOR_FILTER)
	slime_owner.docile = stored_docility
	slime_owner.Friends = stored_friends
	stored_friends = null
	. = ..()

/datum/status_effect/slime/stupor/tick(seconds_between_ticks)
	if(!SPT_PROB(15, seconds_between_ticks))
		return
	for(var/mob/friend in view())
		if(isslime(friend))
			continue
		slime_owner.Friends |= friend

	slime_owner.visible_message("[slime_owner] looks all around it and smiles contentedly.")
	slime_owner.force_mood_change(force_mood = ":3")
	slime_owner.powerlevel--

/datum/status_effect/slime/stupor/get_examine_text()
	return span_bolddanger("It is smiling contentedly.")

#undef MAXIMUM_STUPOR_TIME
#undef STUPOR_FILTER

#define MAXIMUM_NITRATE_TIME 2.5 MINUTES
#define NITRATED_FILTER_RAYS "nitrated_rays"
#define NITRATED_FILTER_SHADOW "nitrated_shadow"

/datum/status_effect/slime/nitrated
	id = "nitrated"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	max_duration = MAXIMUM_NITRATE_TIME
	tick_interval = 2 SECONDS
	remove_on_fullheal = FALSE

/datum/status_effect/slime/nitrated/on_apply()
	. = ..()
	to_chat(slime_owner, span_userdanger("You've become supercharged!"))
	slime_owner.add_filter(NITRATED_FILTER_SHADOW, 2, list("type" = "drop_shadow", "color" = "#a52a2a", "alpha" = 0, "size" = 2))
	slime_owner.add_filter(NITRATED_FILTER_RAYS, 10, list("type" = "rays", "size" = 15, "color" = "#a52a2a"))
	slime_owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

	return .

/datum/status_effect/slime/nitrated/on_remove()
	slime_owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	slime_owner.remove_filter(NITRATED_FILTER_SHADOW)
	slime_owner.remove_filter(NITRATED_FILTER_RAYS)
	REMOVE_TRAIT(slime_owner, TRAIT_IGNOREDAMAGESLOWDOWN, REF(src))
	. = ..()

/datum/status_effect/slime/nitrated/tick(seconds_between_ticks)
	if(SPT_PROB(15, seconds_between_ticks))
		slime_owner.powerlevel++

/datum/status_effect/slime/nitrated/get_examine_text()
	return span_bolddanger("It is smiling mischeviously, vibrating with unspent energy!")

#undef MAXIMUM_NITRATE_TIME
#undef NITRATED_FILTER_RAYS
#undef NITRATED_FILTER_SHADOW

#define MAXIMUM_HYPERNOB_TIME 10 SECONDS

/atom/movable/screen/alert/status_effect/hypernob_protection
	name = "Hyper-Noblium Coating"
	desc = "Your slime body has been coated with a thin layer of Hyper-Noblium. You feel... non-reactive?"
	icon_state = "???"

/datum/status_effect/slime/hypernob_protection
	id = "hypernob_protection"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	max_duration = MAXIMUM_HYPERNOB_TIME
	alert_type = /atom/movable/screen/alert/status_effect/hypernob_protection
	tick_interval = 2 SECONDS
	remove_on_fullheal = FALSE

/datum/status_effect/slime/hypernob_protection/on_apply()
	. = ..()
	to_chat(slime_owner, span_userdanger("A layer of hypernoblium forms over your body, coating it. You feel extremely stable..."))
	slime_owner.mutation_chance = 0
	slime_owner.add_filter("hypernob_protection", 1, list("type" = "outline", "color" = "#008080", "alpha" = 0, "size" = 1))
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop), slime_owner), 3 SECONDS)
	slime_owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/hypernoblium) // small slowdown as a tradeoff!
	ADD_TRAIT(slime_owner, TRAIT_SLIME_WATER_IMMUNE, REF(src))

/datum/status_effect/slime/hypernob_protection/proc/start_glow_loop(atom/movable/parent_movable)
	var/filter = parent_movable.get_filter("hypernob_protection")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 2.5 SECONDS)

	return .

/datum/status_effect/slime/hypernob_protection/on_remove()
	slime_owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/hypernoblium)
	REMOVE_TRAIT(slime_owner, TRAIT_SLIME_WATER_IMMUNE, REF(src))
	. = ..()

/datum/status_effect/slime/hypernob_protection/get_examine_text()
	return span_bolddanger("It has a softly pulsating blue-white coating on its body.")

#undef MAXIMUM_HYPERNOB_TIME

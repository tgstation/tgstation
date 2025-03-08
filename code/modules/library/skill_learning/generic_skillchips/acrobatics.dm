/obj/item/skillchip/acrobatics
	name = "old F058UR7 skillchip"
	desc = "A formerly cutting-edge skillchip that granted the user an advanced, Olympian-level degree of kinesthesics for flipping, spinning, and absolutely nothing else. \
		It was pulled off the markets shortly after release due to users damaging the chip's integrity from excessive acrobatics, causing deadly malfunctions. It really puts the 'flop' in 'Fosbury Flop'!"
	skill_name = "Spinesthetics"
	skill_description = "Allows you to flip and spin at an illegal and dangerous rate."
	skill_icon = FA_ICON_WHEELCHAIR_ALT
	activate_message = span_notice("You suddenly have an extremely advanced and complex sense of how to spin and flip with grace.")
	deactivate_message = span_notice("Your divine grasp of Spinesthesics disappears entirely.")
	custom_premium_price = PAYCHECK_CREW * 4
	/// set integrity to 1 when mapping for !!FUN!!
	max_integrity = 100
	/// list of emotes whose cd is overridden by this skillchip. can be edited in mapping or ingame
	var/list/affected_emotes = list("spin", "flip")
	var/datum/effect_system/spark_spread/sparks
	// you can use this without lowering integrity! let's be honest. nobody's doing that
	var/allowed_usage = 3
	var/reload_charge = 10 SECONDS
	// current particle effect used for smoking brain
	var/obj/effect/abstract/particle_holder/particle_effect

/obj/item/skillchip/acrobatics/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_EMOTE_COOLDOWN_CHECK, PROC_REF(whowee))

/obj/item/skillchip/acrobatics/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_EMOTE_COOLDOWN_CHECK)

/obj/item/skillchip/acrobatics/Destroy(force)
	QDEL_NULL(sparks)
	QDEL_NULL(particle_effect)
	return ..()

/obj/item/skillchip/acrobatics/proc/whowee(mob/living/carbon/bozo, emote_key, emote_intentional)
	SIGNAL_HANDLER

	if(!(emote_key in affected_emotes))
		return

	if(allowed_usage)
		allowed_usage--
		addtimer(CALLBACK(src, PROC_REF(charge)), reload_charge)
	else
		take_damage(1, sound_effect = FALSE)

	if(!sparks)
		sparks = new(src)

	// minimum roll is by default capped at 50, with the min value lowering as integrity is reduced.
	var/mintegrity = clamp(50 - (100 - get_integrity()), 1, 100)
	switch(rand(mintegrity, get_integrity())) // 1 to 100 but gets worse every time
		// CRIT FAIL
		if(1)
			bozo.visible_message(span_userdanger("[bozo]'s head suddenly explodes outwards!"))

			explosion(bozo, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
			// WITNESS THE GORE
			for(var/mob/living/splashed in view(2, bozo))
				if(bozo.has_status_effect(/datum/status_effect/grouped/blindness))
					to_chat(splashed, span_userdanger("You're splashed with something"))
				else
					to_chat(splashed, span_userdanger("You are blinded by a shower of blood!"))
				splashed.Stun(1 SECONDS)
				splashed.Knockdown(2 SECONDS)
				splashed.set_eye_blur_if_lower(15 SECONDS)
				splashed.adjust_confusion(4 SECONDS)

			// GORE
			var/obj/item/bodypart/bozopart = bozo.get_bodypart(BODY_ZONE_HEAD)
			if(bozopart)
				var/datum/wound/cranial_fissure/crit_wound = new()
				crit_wound.apply_wound(bozopart)
			/*
				var/list/droppage_candidates = bozo.get_organs_for_zone(BODY_ZONE_HEAD, include_children = TRUE)
				if(droppage_candidates)
					var/obj/thing_to_drop = pick(droppage_candidates)
					thing_to_drop.forceMove(bozo.drop_location())
			*/ //WHY DOESNTY IT OWRK

			// does not necessarily kill you directly. instead it causes cranial fissure + something to drop from your head. could be eyes, tongue, ears, brain, even implants
			new /obj/effect/gibspawner/generic(get_turf(bozo), bozo)

			sparks.set_up(15, cardinals_only = FALSE, location = get_turf(src))
			sparks.start()

			qdel(src)
		// last chance to stop
		if(7 to 9)
			bozo.visible_message(
				span_danger("[bozo] seems to short circuit!"),
				span_userdanger("Your brain short circuits!"),
			)
			// if they're susceptible to electrocution, confuse them
			if(bozo.electrocute_act(15, bozo, 1, SHOCK_NOGLOVES|SHOCK_NOSTUN))
				bozo.adjust_confusion(15 SECONDS)
				bozo.set_eye_blur_if_lower(10 SECONDS)
			// but the rest of the effects will happen either way
			bozo.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20 - get_integrity())

			sparks.set_up(5, cardinals_only = FALSE, location = get_turf(src))
			sparks.start()

		// brain Smoking. you should probably stop now
		if(13 to 15)
			// if already hot, light 'em up
			var/particle_path = /particles/smoke/steam/mild
			if(bozo.has_status_effect(/datum/status_effect/temperature_over_time/chip_overheat))
				bozo.adjust_fire_stacks(11 - get_integrity())
				bozo.ignite_mob()
				bozo.visible_message(
					span_danger("[bozo]'s head lights up!"),
					span_userdanger("Your head hurts so much, it feels like it's on fire!"),
				)
				ASYNC
					bozo.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
				if(particle_effect?.type == particle_path)
					return
				particle_path = /particles/smoke/steam/bad
			else
				bozo.visible_message(
					span_danger("[bozo]'s head starts smoking!"),
					span_userdanger("Your brain feels like it's on fire!"),
				)

				// increase smokiness if already smoking
				if(particle_effect?.type == /particles/smoke/steam/mild)
					particle_path = /particles/smoke/steam
				else
					particle_path = /particles/smoke/steam/mild

			bozo.adjust_confusion(4 SECONDS)
			bozo.set_eye_blur_if_lower(3 SECONDS)

			particle_effect = new(bozo, particle_path)
			// roughly head position.
			// dont know how to make this not hardcoded
			particle_effect.set_particle_position(-2, 12, 0)
			bozo.apply_status_effect(/datum/status_effect/temperature_over_time/chip_overheat, 15 SECONDS)
			QDEL_IN(particle_effect, 15 SECONDS)

			sparks.set_up(10, cardinals_only = FALSE, location = get_turf(src))
			sparks.start()

		// hey, something isn't right...
		if(16 to 50)
			bozo.visible_message(
				span_warning("[bozo]'s head sparks."),
			)

			sparks.set_up(rand(1,2), cardinals_only = TRUE, location = get_turf(src))
			sparks.start()

	return COMPONENT_EMOTE_COOLDOWN_BYPASS

/obj/item/skillchip/acrobatics/proc/charge()
	allowed_usage++

/obj/item/skillchip/acrobatics/kiss
	name = "prototype N. 807 - K1SS skillchip"
	desc = "An idle experiment when developing skillchips led to this catastrophe. Everyone involved swore to keep it a secret until death, but it looks like someone has let loose this mistake into the world."
	skill_name = "ERROERERROROROEROEORROER"
	skill_description = "NULL DESCRIPTION NOT FOUND"
	skill_icon = FA_ICON_KISS_BEAM
	activate_message = span_userdanger("This was a mistake.")
	deactivate_message = span_userdanger("The mistake is over.")
	custom_premium_price = PAYCHECK_CREW * 500
	max_integrity = 25
	affected_emotes = list("kiss")
	allowed_usage = 1
	reload_charge = 30 SECONDS

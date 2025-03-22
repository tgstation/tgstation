#define FEAR_SCALING(base, min, max) clamp(base * (terror_buildup - min) / (max - min), 0, base)

// Common terror effect handlers

/// Causes mild jittering, scaling with current terror level
/datum/terror_handler/jittering
	handler_type = TERROR_HANDLER_EFFECT
	default = TRUE
	COOLDOWN_DECLARE(message_cd)

/datum/terror_handler/jittering/tick(seconds_per_tick, terror_buildup)
	. = ..()
	if (terror_buildup < TERROR_BUILDUP_FEAR)
		return

	// If we're terrified, keep constant jittering and dizzyness
	if (terror_buildup > TERROR_BUILDUP_TERROR)
		owner.adjust_dizzy_up_to(10 SECONDS * seconds_per_tick, 10 SECONDS)
		owner.adjust_jitter_up_to(10 SECONDS * seconds_per_tick, 10 SECONDS)
		return

	if (!SPT_PROB(1 + FEAR_SCALING(4, TERROR_BUILDUP_FEAR, TERROR_BUILDUP_TERROR), seconds_per_tick)) // 1% to 5% chance
		return

	if (COOLDOWN_FINISHED(src, message_cd) && !owner.has_status_effect(/datum/status_effect/jitter)) // Don't display the message if we're already shaking
		to_chat(owner, span_warning("You can't stop shaking..."))
		COOLDOWN_START(src, message_cd, TERROR_MESSAGE_CD)

	owner.set_jitter_if_lower(20 SECONDS)
	owner.set_dizzy_if_lower(20 SECONDS)

/// Stutter when terrified, or
/datum/terror_handler/stuttering
	handler_type = TERROR_HANDLER_EFFECT
	default = TRUE

/datum/terror_handler/stuttering/tick(seconds_per_tick, terror_buildup)
	. = ..()
	if (terror_buildup < TERROR_BUILDUP_FEAR)
		return

	if (terror_buildup > TERROR_BUILDUP_TERROR || SPT_PROB(1 + FEAR_SCALING(4, TERROR_BUILDUP_FEAR, TERROR_BUILDUP_TERROR), seconds_per_tick))
		owner.adjust_stutter_up_to(10 SECONDS * seconds_per_tick, 10 SECONDS)

/// Low chance to vomit when terrified, increases significantly during panic attacks
/datum/terror_handler/vomiting
	handler_type = TERROR_HANDLER_EFFECT

/datum/terror_handler/vomiting/tick(seconds_per_tick, terror_buildup)
	. = ..()
	if (terror_buildup < TERROR_BUILDUP_TERROR)
		return

	if (SPT_PROB((terror_buildup >= TERROR_BUILDUP_PANIC) ? 3 : 1, seconds_per_tick))
		to_chat(owner, span_warning("You feel sick..."))
		// Vomit blood if we're *really* freaking out
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living/carbon, vomit), terror_buildup >= TERROR_BUILDUP_PASSIVE_MAXIMUM), 5 SECONDS)

/// Can randomly give you some oxyloss, and cause a heart attack past TERROR_BUILDUP_HEART_ATTACK
/datum/terror_handler/heart_problems
	handler_type = TERROR_HANDLER_EFFECT
	default = TRUE
	COOLDOWN_DECLARE(effect_cd)

/datum/terror_handler/heart_problems/tick(seconds_per_tick, terror_buildup)
	. = ..()
	if (terror_buildup < TERROR_BUILDUP_FEAR)
		return

	if (!SPT_PROB(1 + FEAR_SCALING(4, TERROR_BUILDUP_FEAR, TERROR_BUILDUP_PANIC), seconds_per_tick)) // 1% to 5% chance
		continue

	if (terror_buildup < TERROR_BUILDUP_HEART_ATTACK || !prob(15))
		owner.adjustOxyLoss(8)
		if (terror_buildup < TERROR_BUILDUP_FEAR)
			to_chat(owner, span_warning("Your heart skips a beat."))
		else
			to_chat(owner, span_userdanger("You feel your heart lurching in your chest..."))
		return

	owner.visible_message(
		span_warning("[owner] clutches [owner.p_their()] chest for a moment, then collapses to the floor."),
		span_alert("The shadows begin to creep up from the corners of your vision, and then there is nothing..."),
		span_hear("You hear something heavy collide with the ground."),
	)
	var/datum/disease/heart_failure/heart_attack = new(src)
	heart_attack.stage_prob = 2 //Advances twice as fast
	owner.ForceContractDisease(heart_attack)
	owner.Unconscious(20 SECONDS)

#undef FEAR_SCALING

/obj/item/melee/blood_magic/stun/afterattack(mob/living/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity || IS_CULTIST(target))
		return
	var/datum/antagonist/cult/cult = IS_CULTIST(user)
	if(QDELETED(cult))
		return
	user.visible_message(span_warning("[user] holds up [user.p_their()] hand, which explodes in a flash of red light!"), \
						span_cultitalic("You attempt to stun [target] with the spell!"))
	user.mob_light(range = 3, color = LIGHT_COLOR_BLOOD_MAGIC, duration = 0.2 SECONDS)
	if(!snowflake_martial_arts_handler(target, user))
		if(IS_HERETIC(target))
			effect_heretic(target, user)
		else if(IS_CLOCK(target))
			effect_coggers(target, user)
		else if(target.can_block_magic(MAGIC_RESISTANCE | MAGIC_RESISTANCE_HOLY))
			effect_magic_resist(target, user)
		else if(target.get_drunk_amount() >= OLD_MAN_HENDERSON_DRUNKENNESS)
			effect_henderson(target, user)
		else if(HAS_TRAIT(target, TRAIT_MINDSHIELD) || HAS_MIND_TRAIT(target, TRAIT_OCCULTIST) || HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE) || cult.cult_team.cult_ascendent || cult.cult_team.is_sacrifice_target(target.mind))
			effect_weakened(target, user)
		else
			effect_full(target, user)
	uses--
	return ..()

/obj/item/melee/blood_magic/stun/proc/effect_heretic(mob/living/target, mob/living/carbon/user)
	to_chat(user, span_warning("Some force greater than you intervenes! [target] is protected by the Forgotten Gods!"), type = MESSAGE_TYPE_COMBAT)
	to_chat(target, span_warning("You are protected by your faith to the Forgotten Gods!"), type = MESSAGE_TYPE_COMBAT)
	var/old_color = target.color
	target.color = rgb(0, 128, 0)
	animate(target, color = old_color, time = 1 SECONDS, easing = EASE_IN)

/obj/item/melee/blood_magic/stun/proc/effect_coggers(mob/living/target, mob/living/carbon/user)
	to_chat(user, span_warning("Some force greater than you intervenes! [target] is protected by the heretic Ratvar!"), type = MESSAGE_TYPE_COMBAT)
	to_chat(target, span_warning("You are protected by your faith to Ratvar!"), type = MESSAGE_TYPE_COMBAT)
	var/old_color = target.color
	target.color = rgb(190, 135, 0)
	animate(target, color = old_color, time = 1 SECONDS, easing = EASE_IN)

/obj/item/melee/blood_magic/stun/proc/effect_magic_resist(mob/living/target, mob/living/carbon/user)
	to_chat(user, span_warning("The spell had no effect!"), type = MESSAGE_TYPE_COMBAT)

/obj/item/melee/blood_magic/stun/proc/effect_henderson(mob/living/target, mob/living/carbon/user)
	to_chat(user, span_cultitalic("[target] is barely phased by your spell, rambling with drunken annoyance instead!"), type = MESSAGE_TYPE_COMBAT)
	to_chat(target, span_cultboldtalic("Eldritch horrors try to flood your thoughts, before being drowned out by an intense alcoholic haze!"), type = MESSAGE_TYPE_COMBAT) // yeah nobody's gonna be able to understand you through the slurring but it's funny anyways
	target.say("MUCKLE DAMRED CULT! 'AIR EH NAMBLIES BE KEEPIN' ME WEE MEN!?!!", forced = "drunk cult stun")
	target.adjust_silence(15 SECONDS)
	target.adjust_confusion(15 SECONDS)
	target.set_jitter_if_lower(15 SECONDS)

/obj/item/melee/blood_magic/stun/proc/effect_weakened(mob/living/target, mob/living/carbon/user, silent = FALSE)
	if(!silent)
		to_chat(user, span_cultitalic("In a brilliant flash of red, [target] falls to the ground, [target.p_their()] strength drained, albeit managing to somewhat resist the effects!"), type = MESSAGE_TYPE_COMBAT)
		to_chat(target, span_userdanger("You barely manage to resist [user]'s spell, falling to the ground in agony, but still able to gather enough strength to act!"), type = MESSAGE_TYPE_COMBAT)
	target.emote("scream")
	target.AdjustKnockdown(5 SECONDS)
	target.stamina.adjust(-80)
	target.adjust_timed_status_effect(12 SECONDS, /datum/status_effect/speech/slurring/cult)
	target.adjust_silence(8 SECONDS)
	target.adjust_stutter(20 SECONDS)
	target.set_jitter_if_lower(20 SECONDS)

/obj/item/melee/blood_magic/stun/proc/effect_full(mob/living/target, mob/living/carbon/user)
	to_chat(user, span_cultitalic("In a brilliant flash of red, [target] crumples to the ground!"), type = MESSAGE_TYPE_COMBAT)
	target.Paralyze(16 SECONDS)
	target.flash_act(1, TRUE)
	if(issilicon(target))
		var/mob/living/silicon/silicon_target = target
		silicon_target.emp_act(EMP_HEAVY)
	else if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.adjust_silence(12 SECONDS)
		carbon_target.adjust_stutter(30 SECONDS)
		carbon_target.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/speech/slurring/cult)
		carbon_target.set_jitter_if_lower(30 SECONDS)

// If this is gonna be a snowflake touch spell despite not being an actual touch spell, then we get to have snowflake code to ensure it behaves like it should.
/obj/item/melee/blood_magic/stun/proc/snowflake_martial_arts_handler(mob/living/target, mob/living/carbon/user)
	var/datum/martial_art/martial_art = target?.mind?.martial_art
	if(!martial_art?.can_use())
		return FALSE
	if(istype(martial_art, /datum/martial_art/cqc))
		target.visible_message(
			span_danger("[target] twists [user]'s arm, sending [user.p_their()] [src] back towards [user.p_them()]!"),
			span_userdanger("Making sure to avoid [user]'s [src], you twist [user.p_their()] arm to send it right back at [user.p_them()]!"),
			ignored_mobs = list(user)
		)
		to_chat(user, span_userdanger("As you attempt to stun [target] with the spell, [target.p_they()] twist your arm and send the spell back at you!"), type = MESSAGE_TYPE_COMBAT)
		effect_weakened(user, silent = TRUE)
		return TRUE
	else if(istype(martial_art, /datum/martial_art/the_sleeping_carp))
		var/datum/martial_art/the_sleeping_carp/eepy_carp = martial_art
		if(eepy_carp.can_deflect(target))
			target.visible_message(
				span_danger("[target] carefully dodges [user]'s [src]!"),
				span_userdanger("You take great care to remain untouched by [user]'s [src]!"),
			)
			return TRUE
	return FALSE

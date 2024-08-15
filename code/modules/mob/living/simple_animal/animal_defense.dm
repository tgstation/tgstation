/mob/living/simple_animal/attack_hand(mob/living/carbon/human/user, list/modifiers)
	// so that martial arts don't double dip
	if (..())
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.disarm(src)
		return TRUE

	if(!user.combat_mode)
		if (stat == DEAD)
			return
		visible_message(span_notice("[user] [response_help_continuous] [src]."), \
						span_notice("[user] [response_help_continuous] you."), null, null, user)
		to_chat(user, span_notice("You [response_help_simple] [src]."))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	else
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_warning("You don't want to hurt [src]!"))
			return
		if(check_block(user, harm_intent_damage, "[user]'s punch", UNARMED_ATTACK, 0, BRUTE))
			return
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		visible_message(span_danger("[user] [response_harm_continuous] [src]!"),\
						span_userdanger("[user] [response_harm_continuous] you!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [response_harm_simple] [src]!"))
		playsound(loc, attacked_sound, 25, TRUE, -1)
		apply_damage(harm_intent_damage)
		log_combat(user, src, "attacked")
		return TRUE

/mob/living/simple_animal/get_shoving_message(mob/living/shover, obj/item/weapon, shove_flags)
	if(weapon) // no "gently pushing aside" if you're pressing a shield at them.
		return ..()
	var/moved = !(shove_flags & SHOVE_BLOCKED)
	shover.visible_message(
		span_danger("[shover.name] [response_disarm_continuous] [src][moved ? ", pushing [p_them()]" : ""]!"),
		span_danger("You [response_disarm_simple] [src][moved ? ", pushing [p_them()]" : ""]!"),
		span_hear("You hear aggressive shuffling!"),
		COMBAT_MESSAGE_RANGE,
		list(src),
	)
	to_chat(src, span_userdanger("You're [moved ? "pushed" : "shoved"] by [shover.name]!"))

/mob/living/simple_animal/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger("[user] punches [src]!"), \
					span_userdanger("You're punched by [user]!"), null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You punch [src]!"))
	adjustBruteLoss(15)

/mob/living/simple_animal/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			return apply_damage(rand(1, 3))
	if (!user.combat_mode)
		if (health > 0)
			visible_message(span_notice("[user.name] [response_help_continuous] [src]."), \
							span_notice("[user.name] [response_help_continuous] you."), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_notice("You [response_help_simple] [src]."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)


/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	if(..()) //if harm or disarm intent.
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] [response_disarm_continuous] [name]!"), \
							span_userdanger("[user] [response_disarm_continuous] you!"), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You [response_disarm_simple] [name]!"))
			log_combat(user, src, "disarmed")
		else
			var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
			visible_message(span_danger("[user] slashes at [src]!"), \
							span_userdanger("You're slashed at by [user]!"), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You slash at [src]!"))
			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
			apply_damage(damage)
			log_combat(user, src, "attacked")
		return 1

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	. = ..()
	if(. && stat != DEAD) //successful larva bite
		var/damage_done = apply_damage(rand(L.melee_damage_lower, L.melee_damage_upper), BRUTE)
		if(damage_done > 0)
			L.amount_grown = min(L.amount_grown + damage_done, L.max_grown)

/mob/living/simple_animal/attack_drone(mob/living/basic/drone/user)
	if(user.combat_mode) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/simple_animal/attack_drone_secondary(mob/living/basic/drone/user)
	if(user.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/simple_animal/ex_act(severity, target, origin)
	. = ..()
	if(!. || QDELETED(src))
		return FALSE

	switch (severity)
		if (EXPLODE_DEVASTATE)
			ex_act_devastate()
		if (EXPLODE_HEAVY)
			ex_act_heavy()
		if (EXPLODE_LIGHT)
			ex_act_light()

	return TRUE

/// Called when a devastating explosive acts on this mob
/mob/living/simple_animal/proc/ex_act_devastate()
	var/bomb_armor = getarmor(null, BOMB)
	if(prob(bomb_armor))
		adjustBruteLoss(500)
	else
		investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
		gib()

/// Called when a heavy explosive acts on this mob
/mob/living/simple_animal/proc/ex_act_heavy()
	var/bomb_armor = getarmor(null, BOMB)
	var/bloss = 60
	if(prob(bomb_armor))
		bloss = bloss / 1.5
	adjustBruteLoss(bloss)

/// Called when a light explosive acts on this mob
/mob/living/simple_animal/proc/ex_act_light()
	var/bomb_armor = getarmor(null, BOMB)
	var/bloss = 30
	if(prob(bomb_armor))
		bloss = bloss / 1.5
	adjustBruteLoss(bloss)

/mob/living/simple_animal/blob_act(obj/structure/blob/B)
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage_upper)
		if(attack_vis_effect && !iswallturf(A)) // override the standard visual effect.
			visual_effect_icon = attack_vis_effect
		else if(melee_damage_upper < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()

/mob/living/simple_animal/emp_act(severity)
	. = ..()
	if(mob_biotypes & MOB_ROBOTIC)
		switch (severity)
			if (EMP_LIGHT)
				visible_message(span_danger("[src] shakes violently, its parts coming loose!"))
				apply_damage(maxHealth * 0.6)
				Shake(duration = 1 SECONDS)
			if (EMP_HEAVY)
				visible_message(span_danger("[src] suddenly bursts apart!"))
				apply_damage(maxHealth)

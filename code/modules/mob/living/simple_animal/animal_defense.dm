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
		visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(response_help_continuous)] [declent_ru(ACCUSATIVE)]."), \
						span_notice("[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(response_help_continuous)] вас."), null, null, user)
		to_chat(user, span_notice("Вы [ru_attack_verb(response_help_simple)] [declent_ru(ACCUSATIVE)]."))
		playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
	else
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_warning("Вы не хотите причинить вред [declent_ru(DATIVE)]!"))
			return
		if(check_block(user, harm_intent_damage, "удар [capitalize(user.declent_ru(GENITIVE))]", UNARMED_ATTACK, 0, BRUTE))
			return
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(response_harm_continuous)] [declent_ru(ACCUSATIVE)]!"),\
						span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(response_harm_continuous)] вас!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("Вы [ru_attack_verb(response_harm_simple)] [declent_ru(ACCUSATIVE)]!"))
		playsound(loc, attacked_sound, 25, TRUE, -1)
		apply_damage(harm_intent_damage)
		log_combat(user, src, "attacked")
		return TRUE

/mob/living/simple_animal/get_shoving_message(mob/living/shover, obj/item/weapon, shove_flags)
	if(weapon) // no "gently pushing aside" if you're pressing a shield at them.
		return ..()
	var/moved = !(shove_flags & SHOVE_BLOCKED)
	shover.visible_message(
		span_danger("[capitalize(shover.declent_ru(NOMINATIVE))] [ru_attack_verb(response_disarm_continuous)] [declent_ru(ACCUSATIVE)][moved ? ", толкая [ru_p_them()]" : ""]!"),
		span_danger("Вы [ru_attack_verb(response_disarm_simple)] [declent_ru(ACCUSATIVE)][moved ? ", толкая [ru_p_them()]" : ""]!"),
		span_hear("Вы слышите агрессивное шарканье!"),
		COMBAT_MESSAGE_RANGE,
		list(src),
	)
	to_chat(src, span_userdanger("Вас [moved ? "подталкивает" : "толкает"] [shover.declent_ru(NOMINATIVE)]!"))

/mob/living/simple_animal/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] бьет [declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("Вас бьет [user.declent_ru(NOMINATIVE)]!"), null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("Вы бьете [declent_ru(ACCUSATIVE)]!"))
	adjust_brute_loss(15)

/mob/living/simple_animal/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			return apply_damage(rand(1, 3))
	if (!user.combat_mode)
		if (health > 0)
			visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))]] [ru_attack_verb(response_help_continuous)] [declent_ru(ACCUSATIVE)]."), \
							span_notice("[capitalize(user.declent_ru(NOMINATIVE))]] [ru_attack_verb(response_help_continuous)] вас."), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_notice("Вы [ru_attack_verb(response_help_simple)] [declent_ru(ACCUSATIVE)]."))
			playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)


/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	if(..()) //if harm or disarm intent.
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			playsound(loc, 'sound/items/weapons/pierce.ogg', 25, TRUE, -1)
			visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(response_disarm_continuous)] [declent_ru(ACCUSATIVE)]!"), \
							span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(response_disarm_continuous)] вас!"), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("Вы [ru_attack_verb(response_disarm_simple)] [declent_ru(ACCUSATIVE)]!"))
			log_combat(user, src, "disarmed")
		else
			var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
			visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] режет [declent_ru(ACCUSATIVE)]!"), \
							span_userdanger("Вас режет [user.declent_ru(NOMINATIVE)]!"), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("Вы режете [declent_ru(ACCUSATIVE)]!"))
			playsound(loc, 'sound/items/weapons/slice.ogg', 25, TRUE, -1)
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
		adjust_brute_loss(500)
	else
		investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
		gib()

/// Called when a heavy explosive acts on this mob
/mob/living/simple_animal/proc/ex_act_heavy()
	var/bomb_armor = getarmor(null, BOMB)
	var/bloss = 60
	if(prob(bomb_armor))
		bloss = bloss / 1.5
	adjust_brute_loss(bloss)

/// Called when a light explosive acts on this mob
/mob/living/simple_animal/proc/ex_act_light()
	var/bomb_armor = getarmor(null, BOMB)
	var/bloss = 30
	if(prob(bomb_armor))
		bloss = bloss / 1.5
	adjust_brute_loss(bloss)

/mob/living/simple_animal/blob_act(obj/structure/blob/B)
	adjust_brute_loss(20)
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
				visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))]] сильно трясется, а детали разбалтываются!"))
				apply_damage(maxHealth * 0.6)
				Shake(duration = 1 SECONDS)
			if (EMP_HEAVY)
				visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))]] внезапно разрывается на части!"))
				apply_damage(maxHealth)

/mob/living/basic/attack_hand(mob/living/carbon/human/user, list/modifiers)
	// so that martial arts don't double dip
	if (..())
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.disarm(src)
		return TRUE

	if(!user.combat_mode)
		if (stat != DEAD)
			visible_message(
				span_notice("[user] [response_help_continuous] [src]."),
				span_notice("[user] [response_help_continuous] you."),
				ignored_mobs = user,
			)
			to_chat(user, span_notice("You [response_help_simple] [src]."))
			playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
		return TRUE

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to hurt [src]!"))
		return TRUE
	var/obj/item/bodypart/arm/active_arm = user.get_active_hand()
	var/damage = rand(active_arm.unarmed_damage_low, active_arm.unarmed_damage_high)
	if(check_block(user, damage, "[user]'s [response_harm_simple]", UNARMED_ATTACK, 0, BRUTE))
		return
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	combat_message(
		attacker = user,
		defender = src,
		to_attacker = "You [response_harm_simple] [src]!",
		to_defender = "[user] [response_harm_continuous] you!",
		to_blind_attacker = "You [response_harm_simple] someone!",
		to_blind_defender = "Someone [response_harm_continuous] you!",
		to_viewers = "[user] [response_harm_continuous] [src]!",
	)
	playsound(loc, attacked_sound, 25, TRUE, -1)
	apply_damage(damage)
	log_combat(user, src, "attacked")
	updatehealth()
	return TRUE

/mob/living/basic/get_shoving_message(mob/living/shover, obj/item/weapon, shove_flags)
	if(weapon) // no "gently pushing aside" if you're pressing a shield at them.
		return ..()
	var/moved = !(shove_flags & SHOVE_BLOCKED)
	combat_message(
		attacker = shover,
		defender = src,
		to_attacker = "You [response_disarm_continuous] [src][moved ? ", sending [p_them()] backwards" : ""]!",
		to_defender = "[shover] [response_disarm_continuous] you[moved ? ", sending you backwards" : ""]!",
		to_blind_attacker = "You [response_disarm_simple] someone[moved ? ", sending [p_them()] backwards" : ""]!",
		to_blind_defender = "Someone [response_disarm_continuous] you[moved ? ", sending you backwards" : ""]!",
		to_viewers = "[shover] [response_disarm_continuous] [src][moved ? ", sending [p_them()] backwards" : ""]!",
		to_blind_viewers = "You hear aggressive shuffling!",
	)

/mob/living/basic/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	playsound(loc, /datum/sound_effect/punch, 25, TRUE, -1)
	combat_message(
		attacker = user,
		defender = src,
		to_attacker = "You punch [src]!",
		to_defender = "[user] punches you!",
		to_blind_attacker = "You punch someone!",
		to_blind_defender = "Someone punches you!",
		to_viewers = "[user] punches [src]!",
		to_blind_viewers = "You hear a thudding sound!",
	)
	apply_damage(15, damagetype = BRUTE)

/mob/living/basic/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			return apply_damage(rand(1, 3))

	if (!user.combat_mode)
		if (health > 0)
			visible_message(span_notice("[user.name] [response_help_continuous] [src]."), \
							span_notice("[user.name] [response_help_continuous] you."), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_notice("You [response_help_simple] [src]."))
			playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)


/mob/living/basic/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		playsound(loc, 'sound/items/weapons/pierce.ogg', 25, TRUE, -1)
		combat_message(
			attacker = user,
			defender = src,
			to_attacker = "You [response_disarm_simple] [name]!",
			to_defender = "[user] [response_disarm_continuous] you!",
			to_blind_attacker = "You [response_disarm_simple] someone!",
			to_blind_defender = "Someone [response_disarm_continuous] you!",
			to_viewers = "[user] [response_disarm_continuous] [name]!",
			to_blind_viewers = "You hear aggressive shuffling!",
		)
		log_combat(user, src, "disarmed")
		return
	var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
	combat_message(
		attacker = user,
		defender = src,
		to_attacker = "You slash [name]!",
		to_defender = "[user] slashes you!",
		to_blind_attacker = "You slash at someone!",
		to_blind_defender = "Someone slashes at you!",
		to_viewers = "[user] slashes [name]!",
		to_blind_viewers = "You hear a slicing sound!",
	)
	playsound(loc, 'sound/items/weapons/slice.ogg', 25, TRUE, -1)
	apply_damage(damage)
	log_combat(user, src, "attacked")

/mob/living/basic/attack_larva(mob/living/carbon/alien/larva/attacking_larva, list/modifiers)
	. = ..()
	if(. && stat != DEAD) //successful larva bite
		var/damage_done = apply_damage(rand(attacking_larva.melee_damage_lower, attacking_larva.melee_damage_upper), BRUTE)
		if(damage_done > 0)
			attacking_larva.amount_grown = min(attacking_larva.amount_grown + damage_done, XENOMORPH_MAX_GROWTH)

/mob/living/basic/attack_drone(mob/living/basic/drone/attacking_drone)
	if(attacking_drone.combat_mode) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/basic/attack_drone_secondary(mob/living/basic/drone/attacking_drone)
	if(attacking_drone.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/basic/check_projectile_armor(def_zone, obj/projectile/impacting_projectile, is_silent)
	return 0

/mob/living/basic/ex_act(severity, target, origin)
	. = ..()
	if(!. || QDELETED(src))
		return FALSE
	var/bomb_armor = getarmor(null, BOMB)
	var/bomb_multi = clamp(1 - bomb_armor/166.6, 0, 1) // Scales linearly down to 40% damage at 100 armor
	var/bloss = 0
	switch(severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD)
				investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
				gib(DROP_ALL_REMAINS)
			else
				bloss = 600
		if (EXPLODE_HEAVY)
			bloss = 60
		if (EXPLODE_LIGHT)
			bloss = 30
	if(bloss)
		bloss = round(bloss * bomb_multi, 0.1)
		apply_damage(bloss, damagetype = BRUTE)
	return TRUE

/mob/living/basic/blob_act(obj/structure/blob/attacking_blob)
	. = ..()
	if (!.)
		return
	apply_damage(20, damagetype = BRUTE)

/mob/living/basic/do_attack_animation(atom/attacked_atom, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage_upper)
		if(attack_vis_effect && !iswallturf(attacked_atom)) // override the standard visual effect.
			visual_effect_icon = attack_vis_effect
		else if(melee_damage_upper < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()

/mob/living/basic/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(STABLE)
	med_hud_set_status()

/mob/living/basic/emp_act(severity)
	. = ..()
	if(mob_biotypes & MOB_ROBOTIC)
		emp_reaction(severity)

/mob/living/basic/proc/emp_reaction(severity)
	switch(severity)
		if(EMP_LIGHT)
			visible_message(span_danger("[src] shakes violently, its parts coming loose!"))
			apply_damage(maxHealth * 0.6)
			Shake(duration = 1 SECONDS)
		if(EMP_HEAVY)
			visible_message(span_danger("[src] suddenly bursts apart!"))
			apply_damage(maxHealth)

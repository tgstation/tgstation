/mob/living/simple_animal/attack_drone(mob/living/simple_animal/drone/M)
	if(M.combat_mode) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/simple_animal/attack_drone_secondary(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE)
	if(damage * (damage_coeff[damagetype] || 0) <= force_threshold)
		visible_message(span_warning("[src] looks unharmed!"))
		return FALSE

	return TRUE

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

/mob/living/simple_animal/check_block(atom/hitby, damage, attack_text, attack_type, armour_penetration)
	. = ..()
	if(.)
		return

	var/tap_vol = 50
	if(isitem(hitby))
		var/obj/item/item_hitting = hitby
		if(!attack_threshold_check(damage, item_hitting.damtype))
			tap_vol = item_hitting.get_clamped_volume()
			. = TRUE

	else if(!attack_threshold_check(damage))
		// This operates on the assumption the damage being recieved is brute damage, should be changed later.
		. = TRUE

	if(.)
		playsound(loc, 'sound/weapons/tap.ogg', tap_vol, TRUE, -1)
		visible_message(span_warning("[src] looks unharmed!"), blind_message = span_hear("You hear a thud."))
	return .

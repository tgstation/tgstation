/mob/living/basic/attack_drone(mob/living/simple_animal/drone/attacking_drone)
	if(attacking_drone.combat_mode) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/basic/attack_drone_secondary(mob/living/simple_animal/drone/attacking_drone)
	if(attacking_drone.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/basic/proc/attack_threshold_check(damage, damagetype = BRUTE)
	if(damage * (damage_coeff[damagetype] || 0) <= force_threshold)
		visible_message(span_warning("[src] looks unharmed!"))
		return FALSE

	return TRUE

/mob/living/basic/check_projectile_armor(def_zone, obj/projectile/impacting_projectile, is_silent)
	return 0

/mob/living/basic/ex_act(severity, target, origin)
	. = ..()
	if(!. || QDELETED(src))
		return FALSE

	var/bomb_armor = getarmor(null, BOMB)
	switch(severity)
		if (EXPLODE_DEVASTATE)
			if(prob(bomb_armor))
				apply_damage(500, damagetype = BRUTE)
			else
				investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
				gib()

		if (EXPLODE_HEAVY)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			apply_damage(bloss, damagetype = BRUTE)

		if (EXPLODE_LIGHT)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			apply_damage(bloss, damagetype = BRUTE)

	return TRUE

/mob/living/basic/blob_act(obj/structure/blob/attacking_blob)
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
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
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


/mob/living/basic/check_block(atom/hitby, damage, attack_text, attack_type, armour_penetration)
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

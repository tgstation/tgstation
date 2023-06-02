
/mob/living/silicon/grippedby(mob/living/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection()//no ears
	return 2


/mob/living/silicon/was_attacked_effects(obj/item/attacking_item, mob/living/user, obj/item/bodypart/hit_limb, damage, armor_block)
	. = ..()
	if(prob(damage))
		for(var/mob/living/buckled in buckled_mobs)
			buckled.Paralyze(2 SECONDS)
			unbuckle_mob(buckled)
			buckled.visible_message(
				span_danger("[buckled] is knocked off of [src] by [user]!"),
				span_userdanger("You're knocked off of [src] by [user]!"),
				ignored_mobs = user,
			)
			to_chat(user, span_danger("You knock [buckled] off of [src]!"))

/mob/living/silicon/attack_paw(mob/living/carbon/human/user, list/modifiers)
	return attack_hand(user, modifiers)

/mob/living/silicon/check_block(atom/hitby, damage, attack_text, attack_type, armour_penetration, damage_type = BRUTE)
	. = ..()
	if(.)
		return
	if(damage_type != BRUTE)
		return FALSE
	if(attack_text == UNARMED_ATTACK && damage <= 10)
		playsound(loc, 'sound/effects/bang.ogg', 10, TRUE)
		visible_message(span_danger("[attack_text] doesn't leave a dent on [src]!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return TRUE
	return FALSE

/mob/living/silicon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.combat_mode)
		CRASH("Silicon attack hand was called from someone in combat mode, this shouldn't be possible in theory")
	if(has_buckled_mobs())
		user_unbuckle_mob(buckled_mobs[1], user)
		return

	visible_message(
		span_notice("[user] pets [src]."),
		span_notice("[user] pets you."),
		ignored_mobs = user,
	)
	to_chat(user, span_notice("You pet [src]."))
	user.add_mood_event("pet_borg", /datum/mood_event/pet_borg)

/mob/living/silicon/attack_drone(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return
	return ..()

/mob/living/silicon/attack_drone_secondary(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/silicon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(buckled_mobs)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.electrocute_act(shock_damage/100, source, siemens_coeff, flags) //Hard metal shell conducts!
	return 0 //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	. = ..()
	to_chat(src, span_danger("Warning: Electromagnetic pulse detected."))
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			src.take_bodypart_damage(20)
		if(2)
			src.take_bodypart_damage(10)
	to_chat(src, span_userdanger("*BZZZT*"))
	for(var/mob/living/M in buckled_mobs)
		if(prob(severity*50))
			unbuckle_mob(M)
			M.Paralyze(40)
			M.visible_message(span_boldwarning("[M] is thrown off of [src]!"))
	flash_act(affect_silicon = 1)

/mob/living/silicon/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, Proj, def_zone)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		adjustBruteLoss(Proj.damage)
		if(prob(Proj.damage*1.5))
			for(var/mob/living/M in buckled_mobs)
				M.visible_message(span_boldwarning("[M] is knocked off of [src]!"))
				unbuckle_mob(M)
				M.Paralyze(40)
	if(Proj.stun || Proj.knockdown || Proj.paralyze)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.visible_message(span_boldwarning("[M] is knocked off of [src] by the [Proj]!"))
	Proj.on_hit(src, 0, piercing_hit)
	return BULLET_ACT_HIT

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static, length = 25)
	if(affect_silicon)
		return ..()

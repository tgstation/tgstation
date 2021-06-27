
/mob/living/silicon/grippedby(mob/living/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection()//no ears
	return 2

/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/user, list/modifiers)
	if(..()) //if harm or disarm intent
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		if (prob(90))
			log_combat(user, src, "attacked")
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] slashes at [src]!"), \
							span_userdanger("[user] slashes at you!"), null, null, user)
			to_chat(user, span_danger("You slash at [src]!"))
			if(prob(8))
				flash_act(affect_silicon = 1)
			log_combat(user, src, "attacked")
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user]'s swipe misses [src]!"), \
							span_danger("You avoid [user]'s swipe!"), null, null, user)
			to_chat(user, span_warning("Your swipe misses [src]!"))

/mob/living/silicon/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	if(.)
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		if(prob(damage))
			for(var/mob/living/buckled in buckled_mobs)
				buckled.Paralyze(20)
				unbuckle_mob(buckled)
				buckled.visible_message(span_danger("[buckled] is knocked off of [src] by [user]!"), \
								span_userdanger("You're knocked off of [src] by [user]!"), null, null, user)
				to_chat(user, span_danger("You knock [buckled] off of [src]!"))
		switch(user.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)

/mob/living/silicon/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L)
	if(!L.combat_mode)
		visible_message(span_notice("[L.name] rubs its head against [src]."))

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(rand(10, 15))
	playsound(loc, "punch", 25, TRUE, -1)
	visible_message(span_danger("[user] punches [src]!"), \
					span_userdanger("[user] punches you!"), null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You punch [src]!"))

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	if(has_buckled_mobs() && !user.combat_mode)
		user_unbuckle_mob(buckled_mobs[1], user)
	else
		if(user.combat_mode)
			user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			playsound(src.loc, 'sound/effects/bang.ogg', 10, TRUE)
			visible_message(span_danger("[user] punches [src], but doesn't leave a dent!"), \
							span_warning("[user] punches you, but doesn't leave a dent!"), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You punch [src], but don't leave a dent!"))
		else
			visible_message(span_notice("[user] pets [src]."), \
							span_notice("[user] pets you."), null, null, user)
			to_chat(user, span_notice("You pet [src]."))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT_RND, "pet_borg", /datum/mood_event/pet_borg)


/mob/living/silicon/attack_drone(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return
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

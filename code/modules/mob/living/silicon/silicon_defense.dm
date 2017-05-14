
/mob/living/silicon/grippedby(mob/living/user)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection()//no ears
	return 2

/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent
		var/damage = 20
		if (prob(90))
			add_logs(M, src, "attacked")
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
							"<span class='userdanger'>[M] has slashed at [src]!</span>")
			if(prob(8))
				flash_act(affect_silicon = 1)
			add_logs(M, src, "attacked")
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] took a swipe at [src]!</span>", \
							"<span class='userdanger'>[M] took a swipe at [src]!</span>")

/mob/living/silicon/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(prob(damage))
			for(var/mob/living/N in buckled_mobs)
				N.Weaken(1)
				unbuckle_mob(N)
				N.visible_message("<span class='boldwarning'>[N] is knocked off of [src] by [M]!</span>")
		switch(M.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)
			if(TOX)
				adjustToxLoss(damage)
			if(OXY)
				adjustOxyLoss(damage)
			if(CLONE)
				adjustCloneLoss(damage)
			if(STAMINA)
				adjustStaminaLoss(damage)

/mob/living/silicon/attack_paw(mob/living/user)
	return attack_hand(user)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L)
	if(L.a_intent == INTENT_HELP)
		visible_message("[L.name] rubs its head against [src].")

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		adjustBruteLoss(rand(10, 15))
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[user] has punched [src]!</span>", \
				"<span class='userdanger'>[user] has punched [src]!</span>")
		return 1
	return 0

/mob/living/silicon/attack_hand(mob/living/carbon/human/M)
	switch(M.a_intent)
		if ("help")
			M.visible_message("[M] pets [src].", \
							"<span class='notice'>You pet [src].</span>")
		if("grab")
			grabbedby(M)
		else
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			playsound(src.loc, 'sound/effects/bang.ogg', 10, 1)
			visible_message("<span class='danger'>[M] punches [src], but doesn't leave a dent.</span>", \
				"<span class='warning'>[M] punches [src], but doesn't leave a dent.</span>", null, COMBAT_MESSAGE_RANGE)
	return 0

/mob/living/silicon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	if(buckled_mobs)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.electrocute_act(shock_damage/100, source, siemens_coeff, safety, tesla_shock, illusion, stun)	//Hard metal shell conducts!
	return 0 //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_bodypart_damage(20)
		if(2)
			src.take_bodypart_damage(10)
	to_chat(src, "<span class='userdanger'>*BZZZT*</span>")
	to_chat(src, "<span class='danger'>Warning: Electromagnetic pulse detected.</span>")
	for(var/mob/living/M in buckled_mobs)
		if(prob(severity*50))
			unbuckle_mob(M)
			M.Weaken(2)
			M.visible_message("<span class='boldwarning'>[M] is thrown off of [src]!</span>")
	flash_act(affect_silicon = 1)
	..()

/mob/living/silicon/bullet_act(obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		adjustBruteLoss(Proj.damage)
		if(prob(Proj.damage*1.5))
			for(var/mob/living/M in buckled_mobs)
				M.visible_message("<span class='boldwarning'>[M] is knocked off of [src]!</span>")
				unbuckle_mob(M)
				M.Weaken(2)
	if(Proj.stun || Proj.weaken)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.visible_message("<span class='boldwarning'>[M] is knocked off of [src] by the [Proj]!</span>")
	Proj.on_hit(src)
	return 2

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash/static)
	if(affect_silicon)
		return ..()

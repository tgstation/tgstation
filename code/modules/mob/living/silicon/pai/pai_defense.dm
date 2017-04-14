
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/pai/emp_act(severity)
	take_holo_damage(severity * 25)
	fullstun(severity * 10)
	silent = max(severity * 15, silent)
	if(holoform)
		fold_in(force = TRUE)
	//Need more effects that aren't instadeath or permanent law corruption.

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(severity * 50)
	switch(severity)
		if(1)	//RIP
			qdel(card)
			qdel(src)
		if(2)
			fold_in(force = 1)
			fullstun(20)
		if(3)
			fold_in(force = 1)
			fullstun(10)

/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user)
	switch(user.a_intent)
		if("help")
			visible_message("<span class='notice'>[user] gently pats [src] on the head, eliciting an off-putting buzzing from its holographic field.</span>")
		if("disarm")
			visible_message("<span class='notice'>[user] boops [src] on the head!</span>")
		if("harm")
			user.do_attack_animation(src)
			if (user.name == master)
				visible_message("<span class='notice'>Responding to its master's touch, [src] disengages its holochassis emitter, rapidly losing coherence.</span>")
				spawn(10)
					fold_in()
					if(user.put_in_hands(card))
						user.visible_message("<span class='notice'>[user] promptly scoops up their pAI's card.</span>")
			else
				visible_message("<span class='danger'>[user] stomps on [src]!.</span>")
				take_holo_damage(2)

/mob/living/silicon/pai/bullet_act(obj/item/projectile/Proj)
	if(Proj.stun)
		fold_in(force = TRUE)
		src.visible_message("<span class='warning'>The electrically-charged projectile disrupts [src]'s holomatrix, forcing [src] to fold in!</span>")
	. = ..(Proj)

/mob/living/silicon/pai/stripPanelUnequip(obj/item/what, mob/who, where) //prevents stripping
	to_chat(src, "<span class='warning'>Your holochassis stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>")

/mob/living/silicon/pai/stripPanelEquip(obj/item/what, mob/who, where) //prevents stripping
	to_chat(src, "<span class='warning'>Your holochassis stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>")

/mob/living/silicon/pai/IgniteMob(var/mob/living/silicon/pai/P)
	return FALSE //No we're not flammable

/mob/living/silicon/pai/proc/take_holo_damage(amount)
	emitterhealth = Clamp((emitterhealth - amount), -50, emittermaxhealth)
	if(emitterhealth < 0)
		fold_in(force = TRUE)
	to_chat(src, "<span class='userdanger'>The impact degrades your holochassis!</span>")
	hit_slowdown += amount
	return amount

/mob/living/silicon/pai/proc/fullstun(amount)
	Weaken(amount)

/mob/living/silicon/pai/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	return take_holo_damage(amount)

/mob/living/silicon/pai/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	return take_holo_damage(amount)

/mob/living/silicon/pai/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/pai/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/pai/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/pai/adjustStaminaLoss(amount)
	take_holo_damage(amount/4)

/mob/living/silicon/pai/adjustBrainLoss(amount)
	fullstun(amount/10)

/mob/living/silicon/pai/getBruteLoss()
	return emittermaxhealth - emitterhealth

/mob/living/silicon/pai/getFireLoss()
	return emittermaxhealth - emitterhealth

/mob/living/silicon/pai/getToxLoss()
	return FALSE

/mob/living/silicon/pai/getOxyLoss()
	return FALSE

/mob/living/silicon/pai/getCloneLoss()
	return FALSE

/mob/living/silicon/pai/getBrainLoss()
	return FALSE

/mob/living/silicon/pai/getStaminaLoss()
	return FALSE

/mob/living/silicon/pai/setCloneLoss()
	return FALSE

/mob/living/silicon/pai/setBrainLoss()
	return FALSE

/mob/living/silicon/pai/setStaminaLoss()
	return FALSE

/mob/living/silicon/pai/setToxLoss()
	return FALSE

/mob/living/silicon/pai/setOxyLoss()
	return FALSE

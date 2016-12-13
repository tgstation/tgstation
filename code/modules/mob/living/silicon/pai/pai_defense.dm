
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/pai/emp_act(severity)
	take_holo_damage(severity * 25)
	fullstun(severity * 5)
	//Need more effects that aren't instadeath or permanent law corruption.

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(severity * 50)
	switch(severity)
		if(1)	//RIP
			qdel(card)
			qdel(src)
		if(2)
			fold_in(force = 1)
			fullstun(15)
		if(3)
			fold_in(force = 1)
			fullstun(10)

/mob/living/silicon/pai/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>[M] pets [src]!</span>")
		playsound(loc, 'sound/weapons/tap.ogg', 50, 1, 1)
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='warning'>[M] [M.attacktext] [src]!</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		take_holo_damage(damage)

/mob/living/silicon/pai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	switch(M.a_intent)
		if ("help")
			M.visible_message("<span class='notice'>[M] caresses [src]'s casing with its scythe like arm.</span>")
		else
			M.do_attack_animation(src)
			var/damage = rand(10, 20)
			playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			M.visible_message("<span class='warning'>[M] has slashed at [src]!</span>")
			take_holo_damage(damage)

/mob/living/silicon/pai/attackby(obj/item/weapon/W, mob/living/user)
	if(loc == card)
		card.attackby(W, user)

	user.do_attack_animation(src)

	if(!W.force)
		user.visible_message("<span class='notice'>[user] strikes [src] harmlessly with [W], passing clean through its holographic projection.</span>")
	else
		visible_message("<span class='warning'>[user] strikes [src] with [W], the impact rippling through [W]'s holomatrix!</span>")

/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user)
	switch(user.a_intent)
		if("help")
			visible_message("<span class='notice'>[user] gently pats [src] on the head, eliciting an off-putting buzzing from its holographic field.</span>")
		if("disarm")
			visible_message("<span class='notice'>[user] boops [src] on the head!</span>")
		if("harm")
			visible_message("<span class='danger'>[user] stomps on [src]!.</span>")
			if (user.name == master)
				visible_message("<span class='notice'>Responding to its master's touch, [src] disengages its holochassis emitter, rapidly losing coherence.</span>")
				spawn(10)
					fold_in()
					if(user.put_in_hands(card))
						user.visible_message("<span class='notice'>[user] promptly scoops up their pAI's card.</span>")
			else
				take_holo_damage(2)


/mob/living/silicon/pai/hitby(atom/movable/AM)
	visible_message("<span class='warning'>[AM] flies clean through [src]'s holographic field, causing it to stutter and warp wildly!")
	if(istype(AM, /obj))
		var/obj/O = AM
		if(O.throwforce)
			take_holo_damage(O.throwforce)
		else
			take_holo_damage(5)
	return FALSE

/mob/living/silicon/pai/bullet_act(obj/item/projectile/Proj)
	take_holo_damage(Proj.damage)
	return FALSE

/mob/living/silicon/pai/Crossed(atom/movable/AM) //cannot intercept projectiles
	if(istype(AM, /obj/item/projectile))
		var/obj/item/projectile/P = AM
		take_holo_damage(P.damage)
	return FALSE

/mob/living/silicon/pai/stripPanelUnequip(obj/item/what, mob/who, where) //prevents stripping
	src << "<span class='warning'>Your holochassis stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>"

/mob/living/silicon/pai/stripPanelEquip(obj/item/what, mob/who, where) //prevents stripping
	src << "<span class='warning'>Your holochassis stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>"

/mob/living/silicon/pai/IgniteMob(var/mob/living/silicon/pai/P)
	return FALSE	//No we're not flammable

/mob/living/silicon/pai/proc/take_holo_damage(amount)
	emitterhealth = Clamp((emitterhealth - amount), -50, emittermaxhealth)
	if(emitterhealth < 0)
		fold_in(force = TRUE)
	src << "<span class='userdanger'>The impact degrades your holochassis!</span>"

/mob/living/silicon/pai/proc/fullstun(amount)
	Weaken(amount)


/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return 0

/mob/living/silicon/pai/emp_act(severity)
	take_holo_damage(severity * 25)
	//Need more effects that aren't instadeath or permanent law corruption.

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(severity * 50)
	switch(severity)
		if(1)	//RIP
			qdel(card)
			qdel(src)
		if(2)
			cardform(force = 1)
			fullstun(30)
		if(3)
			cardform(force = 1)
			fullstun(5)

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
	if (user.a_intent != "help")
		visible_message("<span class='danger'>[user] stomps on [src]!.</span>")
		if (user.name == master)
			visible_message("<span class='info'>Responding to its master's touch, [src] disengages its holographic emitter, rapidly losing coherence..</span>")
			spawn(10)
				close_up()
		else
			take_holo_damage(5)


/mob/living/silicon/pai/hitby(atom/movable/AM)
	visible_message("<span class='info'>[AM] flies clean through [src]'s holographic field, causing it to stutter and warp wildly!")
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		take_holo_damage(O.throwforce)
	return 0

/mob/living/silicon/pai/bullet_act(/obj/item/projectile/P)
	visible_message("<span class='info'>[Proj] tears cleanly through [src]'s holographic field, distorting its image horribly!!")
	take_holo_damage(P.damage)
	return 0
	return

/*
/mob/living/silicon/pai/Crossed(AM as mob|obj) //cannot intercept projectiles
	return
*/

/mob/living/silicon/pai/stripPanelUnequip(obj/item/what, mob/who, where) //prevents stripping
	src << "<span class='warning'>Your containment field stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>"

/mob/living/silicon/pai/stripPanelEquip(obj/item/what, mob/who, where) //prevents stripping
	src << "<span class='warning'>Your containment field stutters and warps intensely as you attempt to interact with the object, forcing you to cease lest the field fail.</span>"

/mob/living/silicon/pai/IgniteMob(var/mob/living/silicon/pai/P)
	return 0	//No we're not flammable

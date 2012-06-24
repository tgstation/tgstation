//Banhammer deserves to be the first thing here

/obj/item/weapon/banhammer/attack(mob/M as mob, mob/user as mob)
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"

/obj/effect/mine/proc/triggerrad(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 50
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		del(src)

/obj/effect/mine/proc/triggerstun(obj)
	if(ismob(obj))
		var/mob/M = obj
		M.Stun(30)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		del(src)

/obj/effect/mine/proc/triggern2o(obj)
	//example: n2o triggerproc
	//note: im lazy

	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)

			var/datum/gas_mixture/payload = new
			var/datum/gas/sleeping_agent/trace_gas = new

			trace_gas.moles = 30
			payload += trace_gas
			payload.update_values()

			target.air.merge(payload)

	spawn(0)
		del(src)

/obj/effect/mine/proc/triggerplasma(obj)
	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)

			var/datum/gas_mixture/payload = new

			payload.toxins = 30
			payload.update_values()

			target.air.merge(payload)

			target.hotspot_expose(1000, CELL_VOLUME)

	spawn(0)
		del(src)

/obj/effect/mine/proc/triggerkick(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(obj:client)
	spawn(0)
		del(src)

/obj/effect/mine/proc/explode(obj)
	explosion(loc, 0, 1, 2, 3)
	spawn(0)
		del(src)


/obj/effect/mine/HasEntered(AM as mob|obj)
	Bumped(AM)

/obj/effect/mine/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]</font>"
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/mine/New()
	icon_state = "uglyminearmed"

/atom/proc/ex_act()
	return

/atom/proc/blob_act()
	return

// bullet_act called when anything is hit buy a projectile (bullet, tazer shot, laser, etc.)
// flag is projectile type, can be:
//PROJECTILE_TASER = 1   		taser gun
//PROJECTILE_LASER = 2			laser gun
//PROJECTILE_BULLET = 3			traitor pistol
//PROJECTILE_PULSE = 4			pulse rifle
//PROJECTILE_BOLT = 5			crossbow
//PROJECTILE_WEAKBULLET = 6		detective's revolver

/turf/Entered(atom/A as mob|obj)
	..()
	if ((A && A.density && !( istype(A, /obj/effect/beam) )))
		for(var/obj/effect/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				return
	return

/obj/item/weapon/mousetrap/examine()
	set src in oview(12)
	..()
	if(armed)
		usr << "\red It looks like it's armed."

/obj/item/weapon/mousetrap/proc/triggered(mob/target as mob, var/type = "feet")
	if(!armed)
		return
	var/datum/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_organ(pick("l_leg", "r_leg"))
					if(!(affecting.status & ROBOT))
						H.Weaken(3)
			if("l_hand", "r_hand")
				if(!H.gloves)
					affecting = H.get_organ(type)
					if(!(affecting.status & ROBOT))
						H.Stun(3)
		if(affecting && !(affecting.status & ROBOT))
			affecting.take_damage(1, 0)
			H.UpdateDamageIcon()
			H.updatehealth()
	playsound(target.loc, 'snap.ogg', 50, 1)
	icon_state = "mousetrap"
	armed = 0
/*
	else if (ismouse(target))
		target.adjustBruteLoss(100)
*/

/obj/item/weapon/mousetrap/attack_self(mob/user as mob)
	if(!armed)
		icon_state = "mousetraparmed"
		user << "\blue You arm the mousetrap."
	else
		icon_state = "mousetrap"
		if(( (user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50)))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			src.triggered(user, which_hand)
			user << "\red <B>You accidentally trigger the mousetrap!</B>"
			for(var/mob/O in viewers(user, null))
				if(O == user)
					continue
				O.show_message("\red <B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>", 1)
			return
		user << "\blue You disarm the mousetrap."
	armed = !armed
	playsound(user.loc, 'handcuffs.ogg', 30, 1, -3)

/obj/item/weapon/mousetrap/attack_hand(mob/user as mob)
	if(armed)
		if(( (user.getBrainLoss() >= 60 || CLUMSY in user.mutations)) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			src.triggered(user, which_hand)
			user << "\red <B>You accidentally trigger the mousetrap!</B>"
			for(var/mob/O in viewers(user, null))
				if(O == user)
					continue
				O.show_message("\red <B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>", 1)
			return
	..()

/obj/item/weapon/mousetrap/HasEntered(AM as mob|obj)
	if((ishuman(AM)) && (armed))
		var/mob/living/carbon/H = AM
		if(H.m_intent == "run")
			src.triggered(H)
			H << "\red <B>You accidentally step on the mousetrap!</B>"
			for(var/mob/O in viewers(H, null))
				if(O == H)
					continue
				O.show_message("\red <B>[H] accidentally steps on the mousetrap.</B>", 1)
	..()

/obj/item/weapon/mousetrap/hitby(A as mob|obj)
	if(!armed)
		return ..()
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>The mousetrap is triggered by [A].</B>", 1)
	src.triggered(null)

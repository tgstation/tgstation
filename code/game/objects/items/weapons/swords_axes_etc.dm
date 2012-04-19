/*
CONTAINS:
SWORD
BLADE
AXE
STUN BATON
*/




// SWORD
/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/melee/energy/sword/New()
	color = pick("red","blue","green","purple")

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red You accidentally cut yourself with [src]."
		user.take_organ_damage(5,5)
	active = !active
	if (active)
		force = 30
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass1"
		else
			icon_state = "sword[color]"
		w_class = 4
		playsound(user, 'saberon.ogg', 50, 1)
		user << "\blue [src] is now active."
	else
		force = 3
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass0"
		else
			icon_state = "sword0"
		w_class = 2
		playsound(user, 'saberoff.ogg', 50, 1)
		user << "\blue [src] can now be concealed."
	add_fingerprint(user)
	user.update_clothing()
	return

/obj/item/weapon/melee/energy/sword/green
	New()
		color = "green"

/obj/item/weapon/melee/energy/sword/red
	New()
		color = "red"


// BLADE
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/weapon/melee/energy/blade/dropped()
	del(src)
	return

/obj/item/weapon/melee/energy/blade/proc/throw()
	del(src)
	return

// AXE

/obj/item/weapon/melee/energy/axe/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/melee/energy/axe/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		user << "\blue The axe is now energised."
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = 5
	else
		user << "\blue The axe can now be concealed."
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = 5
	src.add_fingerprint(user)
	return

// STUN BATON

/obj/item/weapon/melee/baton/update_icon()
	if(src.status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"

/obj/item/weapon/melee/baton/attack_self(mob/user as mob)
	src.status = !( src.status )
	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red You grab the stunbaton on the wrong side."
		usr.Paralyse(60)
		return
	if (src.status)
		user << "\blue The baton is now on."
		playsound(src.loc, "sparks", 75, 1, -1)
	else
		user << "\blue The baton is now off."
		playsound(src.loc, "sparks", 75, 1, -1)

	update_icon()
	src.add_fingerprint(user)
	return

/obj/item/weapon/melee/baton/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red You grab the stunbaton on the wrong side."
		usr.Weaken(30)
		return
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")



	if(isrobot(M))
		..()
		return

	if (status == 0 || (status == 1 && charges ==0))
		if(user.a_intent == "hurt")
			if(!..()) return
			M.Weaken(5)
			for(var/mob/O in viewers(M))
				if (O.client)	O.show_message("\red <B>[M] has been beaten with the stun baton by [user]!</B>", 1)
			if(status == 1 && charges == 0)
				user << "\red Not enough charge"
			return
		else
			for(var/mob/O in viewers(M))
				if (O.client)	O.show_message("\red <B>[M] has been prodded with the stun baton by [user]! Luckily it was off.</B>", 1)
			if(status == 1 && charges == 0)
				user << "\red Not enough charge"
			return
	if((charges > 0 && status == 1) && (istype(H, /mob/living/carbon)))
		flick("baton_active", src)
		if (user.a_intent == "hurt")
			if(!..()) return
			playsound(src.loc, 'Genhit.ogg', 50, 1, -1)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				charges--
			if (M.stuttering < 1 && (!(M.mutations & HULK) && M.canstun)  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 1
			M.Stun(1)
			M.Weaken(1)
		else
			playsound(src.loc, 'Egloves.ogg', 50, 1, -1)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				charges--
			if (M.stuttering < 10 && (!(M.mutations & HULK) && M.canstun)  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 10
			M.Stun(10)
			M.Weaken(10)
			user.lastattacked = M
			M.lastattacker = user
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with the stun baton by [user]!</B>", 1, "\red You hear someone fall", 2)

/obj/item/weapon/melee/baton/emp_act(severity)
	switch(severity)
		if(1)
			src.charges = 0
		if(2)
			charges -= 5

/obj/item/weapon/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red You club yourself over the head."
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_organ_damage(2*force)
		return
	src.add_fingerprint(user)

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


	if (user.a_intent == "hurt")
		if(!..()) return
		playsound(src.loc, "swing_hit", 50, 1, -1)
		if (M.stuttering < 8 && (!(M.mutations & HULK))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been beaten with the police baton by [user]!</B>", 1, "\red You hear someone fall", 2)
	else
		playsound(src.loc, 'Genhit.ogg', 50, 1, -1)
		M.Stun(5)
		M.Weaken(5)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with the police baton by [user]!</B>", 1, "\red You hear someone fall", 2)

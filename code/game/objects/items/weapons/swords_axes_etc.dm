/*
CONTAINS:
SWORD
BLADE
AXE
STUN BATON
*/




// SWORD
/obj/item/weapon/sword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/sword/New()
	color = pick("red","blue","green","purple")

/obj/item/weapon/sword/attack_self(mob/user as mob)
	if ((user.mutations & 16) && prob(50))
		user << "\red You accidentally cut yourself with [src]."
		user.bruteloss += 5
		user.fireloss +=5
	src.active = !( src.active )
	if (src.active)
		user << "\blue [src] is now active."
		src.force = 30
		if(istype(src,/obj/item/weapon/sword/pirate))
			src.icon_state = "cutlass1"
		else
			src.icon_state = "sword[color]"
		src.w_class = 4
		playsound(user, 'saberon.ogg', 50, 1)
	else
		user << "\blue [src] can now be concealed."
		src.force = 3
		if(istype(src,/obj/item/weapon/sword/pirate))
			src.icon_state = "cutlass0"
		else
			src.icon_state = "sword0"
		src.w_class = 2
		playsound(user, 'saberoff.ogg', 50, 1)
	src.add_fingerprint(user)
	return

/obj/item/weapon/sword/green
	New()
		color = "green"

/obj/item/weapon/sword/red
	New()
		color = "red"


// BLADE
//Most of the other special functions are handled in their own files.

/obj/item/weapon/blade/New()
	src.spark_system = new /datum/effects/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/weapon/blade/dropped()
	del(src)
	return

/obj/item/weapon/blade/proc/throw()
	del(src)
	return

// AXE

/obj/item/weapon/axe/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/axe/attack_self(mob/user as mob)
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

/obj/item/weapon/baton/update_icon()
	if(src.status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"

/obj/item/weapon/baton/attack_self(mob/user as mob)
	src.status = !( src.status )
	if ((usr.mutations & 16) && prob(50))
		usr << "\red You grab the stunbaton on the wrong side."
		usr.paralysis += 60
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

/obj/item/weapon/baton/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red You grab the stunbaton on the wrong side."
		usr.weakened += 30
		return
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M


	if (status == 0 || (status == 1 && charges ==0))
		if(user.a_intent == "hurt")
			if(!..()) return
		/*	if (!istype(H:r_hand, /obj/item/weapon/shield/riot) && prob(40))
				for(var/mob/O in viewers(M, null))
					if (O.client)	O.show_message(text("\red <B>[] has blocked []'s stun baton with the riot shield!</B>", M, user), 1, "\red You hear a cracking sound", 2)
				return
			if (!istype(H:l_hand, /obj/item/weapon/shield/riot) && prob(40))
				for(var/mob/O in viewers(M, null))
					if (O.client)	O.show_message(text("\red <B>[] has blocked []'s stun baton with the riot shield!</B>", M, user), 1, "\red You hear a cracking sound", 2)
				return*/
			if (M.weakened < 5 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.weakened = 5
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
		/*	if (!istype(H:r_hand, /obj/item/weapon/shield/riot) && prob(40))
				for(var/mob/O in viewers(M, null))
					if (O.client)	O.show_message(text("\red <B>[] has blocked []'s stun baton with the riot shield!</B>", M, user), 1, "\red You hear a cracking sound", 2)
				return
			if (!istype(H:l_hand, /obj/item/weapon/shield/riot) && prob(40))
				for(var/mob/O in viewers(M, null))
					if (O.client)	O.show_message(text("\red <B>[] has blocked []'s stun baton with the riot shield!</B>", M, user), 1, "\red You hear a cracking sound", 2)
				return*/
			playsound(src.loc, 'Genhit.ogg', 50, 1, -1)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				charges--
			if (M.weakened < 1 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.weakened = 1
			if (M.stuttering < 1 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 1
			if (M.stunned < 1 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stunned = 1
		else
		/*	if (!istype(H:r_hand, /obj/item/weapon/shield/riot) && prob(40))
				for(var/mob/O in viewers(M, null))
					if (O.client)	O.show_message(text("\red <B>[] has blocked []'s stun baton with the riot shield!</B>", M, user), 1, "\red You hear a cracking sound", 2)
				return
			if (!istype(H:l_hand, /obj/item/weapon/shield/riot) && prob(40))
				for(var/mob/O in viewers(M, null))
					if (O.client)	O.show_message(text("\red <B>[] has blocked []'s stun baton with the riot shield!</B>", M, user), 1, "\red You hear a cracking sound", 2)
				return*/
			playsound(src.loc, 'Egloves.ogg', 50, 1, -1)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				charges--
			if (M.weakened < 10 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.weakened = 10
			if (M.stuttering < 10 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 10
			if (M.stunned < 10 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stunned = 10
			user.lastattacked = M
			M.lastattacker = user
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with the stun baton by [user]!</B>", 1, "\red You hear someone fall", 2)

/obj/item/weapon/baton/emp_act(severity)
	switch(severity)
		if(1)
			src.charges = 0
		if(2)
			charges -= 5

/obj/item/weapon/classic_baton/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red You club yourself over the head."
		usr.weakened = max(3 * force, usr.weakened)
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			H.TakeDamage("head", 2 * force, 0)
		else
			usr.bruteloss += 2 * force
		return
	src.add_fingerprint(user)

	if (user.a_intent == "hurt")
		if(!..()) return
		playsound(src.loc, "swing_hit", 50, 1, -1)
		if (M.weakened < 8 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.weakened = 8
		if (M.stuttering < 8 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stuttering = 8
		if (M.stunned < 8 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stunned = 8
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been beaten with the police baton by [user]!</B>", 1, "\red You hear someone fall", 2)
	else
		playsound(src.loc, 'Genhit.ogg', 50, 1, -1)
		if (M.weakened < 5 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.weakened = 5
		if (M.stunned < 5 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stunned = 5
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with the police baton by [user]!</B>", 1, "\red You hear someone fall", 2)

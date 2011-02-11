/*
CONTAINS:
EMP GRENADE
FLASHBANG

*/

/obj/item/weapon/empgrenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if ((user.mutations & 16) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.state = 1
			src.icon_state = "empar"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
				return
		else if (!( src.state ))
			user << "\red You prime the emp grenade! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "empar"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/empgrenade/proc/prime()
	playsound(src.loc, 'Welder2.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

	var/grenade = src // detaching the proc - in theory
	empulse(src, 5, 7)

	del(grenade)

	return

/obj/item/weapon/flashbang/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		switch(src.det_time)
			if ("1")
				src.det_time = 30
				user.show_message("\blue You set the flashbang for 3 second detonation time.")
				src.desc = "It is set to detonate in 3 seconds."
			if ("30")
				src.det_time = 100
				user.show_message("\blue You set the flashbang for 10 second detonation time.")
				src.desc = "It is set to detonate in 10 seconds."
			if ("100")
				src.det_time = 1
				user.show_message("\blue You set the flashbang for instant detonation.")
				src.desc = "It is set to detonate instantly."
		src.add_fingerprint(user)
	return

/obj/item/weapon/flashbang/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if ((user.mutations & 16) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
				return
		else if (!( src.state ))
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/flashbang/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/flashbang/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/flashbang/proc/prime()
	playsound(src.loc, 'bang.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

	for(var/mob/living/carbon/M in viewers(T, null))
		if (locate(/obj/item/weapon/cloaking_device, M))
			for(var/obj/item/weapon/cloaking_device/S in M)
				S.active = 0
				S.icon_state = "shield0"
		if ((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
			flick("e_flash", M.flash)
			if(!(M.mutations & 8))  M.stunned = 10
			if(!(M.mutations & 8))  M.weakened = 3
			M << "\red <B>BANG</B>"
			if ((prob(14) || (M == src.loc && prob(70))))
				M.ear_damage += rand(1, 10)
			else
				if (prob(30))
					M.ear_damage += rand(0, 5)
			if (!( M.paralysis ))
				M.eye_stat += rand(0, 5)
			if (prob(10))
				M.eye_stat += rand(0, 4)
			M.ear_deaf += 30
			if (M == src.loc)
				M.eye_stat += rand(2, 5)
				if (prob(60))
					if (istype(M, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = M
						if (!( istype(H.ears, /obj/item/clothing/ears/earmuffs) ))
							M.ear_damage += 15
							M.ear_deaf += 60
					else
						M.ear_damage += 15
						M.ear_deaf += 60
		else
			if (get_dist(M, T) <= 5)
				flick("e_flash", M.flash)
				if (!( istype(M, /mob/living/carbon/human) ))
					if(!(M.mutations & 8))  M.stunned = 7
					if(!(M.mutations & 8))  M.weakened = 2
				else
					var/mob/living/carbon/human/H = M
					M.ear_deaf += 10
					if (prob(20))
						M.ear_damage += rand(0, 4)
					if ((!( istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || istype(H.head, /obj/item/clothing/head/helmet/welding) ) || M.paralysis))
						if(!(M.mutations & 8))  M.stunned = 7
						if(!(M.mutations & 8))  M.weakened = 2
					else
						if (!( M.paralysis ))
							M.eye_stat += rand(1, 3)
				M << "\red <B>BANG</B>"
			else
				if (!( istype(M, /mob/living/carbon/human) ))
					flick("flash", M.flash)
				else
					var/mob/living/carbon/human/H = M
					if (!( istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || istype(H.head, /obj/item/clothing/head/helmet/welding) ) )
						flick("flash", M.flash)
				M.eye_stat += rand(1, 2)
				M.ear_deaf += 5
				M << "\red <B>BANG</B>"
		if (M.eye_stat >= 20)
			M << "\red Your eyes start to burn badly!"
			M.disabilities |= 1
			if (prob(M.eye_stat - 20 + 1))
				M << "\red You can't see anything!"
				M.sdisabilities |= 1
		if (M.ear_damage >= 15)
			M << "\red Your ears start to ring badly!"
			if (prob(M.ear_damage - 10 + 5))
				M << "\red You can't hear anything!"
				M.sdisabilities |= 4
		else
			if (M.ear_damage >= 5)
				M << "\red Your ears start to ring!"

	for(var/obj/blob/B in view(8,T))
		var/damage = round(30/(get_dist(B,T)+1))
		B.health -= damage
		B.update()
	del(src)
	return

/obj/item/weapon/flashbang/attack_self(mob/user as mob)
	if (!src.state)
		if (user.mutations & 16)
			user << "\red Huh? How does this thing work?!"
			spawn( 5 )
				prime()
				return
		else
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			add_fingerprint(user)
			spawn( src.det_time )
				prime()
				return
	return

/obj/item/weapon/empgrenade/attack_self(mob/user as mob)
	if (!src.state)
		if (user.mutations & 16)
			user << "\red Huh? How does this thing work?!"
			spawn( 5 )
				prime()
				return
		else
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "empar"
			add_fingerprint(user)
			spawn( src.det_time )
				prime()
				return
	return
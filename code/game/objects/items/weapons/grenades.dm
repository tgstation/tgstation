/*
CONTAINS:
EMP GRENADE
FLASHBANG

*/

/obj/item/weapon/empgrenade
	desc = "It is set to detonate in 5 seconds."
	name = "emp grenade"
	w_class = 2.0
	icon = 'device.dmi'
	icon_state = "emp"
	item_state = "emp"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	origin_tech = "materials=2;magnets=3"
	var
		active = 0
		det_time = 50
	proc
		prime()
		clown_check(var/mob/living/user)


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if((user.equipped() == src)&&(!active)&&(clown_check(user)))
			user << "\red You prime the emp grenade! [det_time/10] seconds!"
			src.active = 1
			src.icon_state = "empar"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
			user.dir = get_dir(user, target)
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)
		return


	attack_self(mob/user as mob)
		if(!active)
			if(clown_check(user))
				user << "\red You prime the EMP grenade! [det_time/10] seconds!"
				src.active = 1
				src.icon_state = "empar"
				add_fingerprint(user)
				spawn(src.det_time)
					prime()
					return
		return


	prime()
		playsound(src.loc, 'Welder2.ogg', 25, 1)
		var/turf/T = get_turf(src)
		if(T)
			T.hotspot_expose(700,125)
		if(empulse(src, 5, 7))
			del(src)
		return


	clown_check(var/mob/living/user)
		if((user.mutations & CLOWN) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.active = 1
			src.icon_state = "empar"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
			return 0
		return 1



/****************************Flashbang***********************************************/
/obj/item/weapon/flashbang
	desc = "It is set to detonate in 3 seconds."
	name = "flashbang"
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	origin_tech = "materials=2;combat=1"
	var
		active = 0
		det_time = 30
	proc
		prime()
		clown_check(var/mob/living/user)


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (isscrewdriver(W))
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
		..()
		return


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if((user.equipped() == src)&&(!active)&&(clown_check(user)))
			user << "\red You prime the flashbang! [det_time/10] seconds!"
			src.active = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(src.det_time)
				prime()
				return
			user.dir = get_dir(user, target)
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)
		return


	attack_paw(mob/user as mob)
		return src.attack_hand(user)


	attack_hand()
		walk(src, null, null)
		..()
		return


	prime()
		playsound(src.loc, 'bang.ogg', 25, 1)
		var/turf/T = get_turf(src)
		if(T)
			T.hotspot_expose(700,125)

		for(var/mob/living/carbon/M in viewers(T, null))
			if (locate(/obj/item/weapon/cloaking_device, M))
				for(var/obj/item/weapon/cloaking_device/S in M)
					S.active = 0
					S.icon_state = "shield0"

			M << "\red <B>BANG</B>"

//Checking for protections
			var/eye_safety = 0
			var/ear_safety = 0
			if(iscarbon(M))
				eye_safety = M.eyecheck()
				if(ishuman(M))
					if(istype(M:ears, /obj/item/clothing/ears/earmuffs))
						ear_safety = 1
					if(M.mutations & HULK)
						ear_safety = 1

//Flashing everyone
			if(!eye_safety)
				flick("e_flash", M.flash)
				M.eye_stat += rand(1, 3)
				M.weakened = max(M.weakened,10)

//Now applying sound
			if((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
				if(ear_safety)
					M.stunned = max(M.stunned,2)
					M.weakened = max(M.weakened,1)
				else
					M.stunned = max(M.stunned,10)
					M.weakened = max(M.weakened,3)
					if ((prob(14) || (M == src.loc && prob(70))))
						M.ear_damage += rand(1, 10)
					else
						M.ear_damage += rand(0, 5)
					M.ear_deaf = max(M.ear_deaf,15)

			else if(get_dist(M, T) <= 5)
				if(!ear_safety)
					M.stunned = max(M.stunned,8)
					M.ear_damage += rand(0, 3)
					M.ear_deaf = max(M.ear_deaf,10)

			else if(!ear_safety)
				M.stunned = max(M.stunned,4)
				M.ear_damage += rand(0, 1)
				M.ear_deaf = max(M.ear_deaf,5)

//This really should be in mob not every check
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

//Blob damage here
		for(var/obj/blob/B in view(8,T))
			var/damage = round(30/(get_dist(B,T)+1))
			B.health -= damage
			B.update()
		del(src)
		return


	attack_self(mob/user as mob)
		if(!active)
			if(clown_check(user))
				user << "\red You prime the flashbang! [det_time/10] seconds!"
				src.active = 1
				src.icon_state = "flashbang1"
				add_fingerprint(user)
				spawn( src.det_time )
					prime()
					return
		return


	clown_check(var/mob/living/user)
		if ((user.mutations & CLOWN) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.active = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
			return 0
		return 1

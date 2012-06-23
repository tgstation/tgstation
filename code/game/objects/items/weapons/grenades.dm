/*
CONTAINS:
EMP GRENADE
FLASHBANG
CRITTER GRENADE

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
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;magnets=3"
	var/active = 0
	var/det_time = 50

	proc/prime()
		return

	proc/clown_check(var/mob/living/user)
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
		if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
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
		if((CLUMSY in user.mutations) && prob(50))
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
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;combat=1"
	var/active = 0
	var/det_time = 30
	var/banglet = 0

	proc/bang(var/turf/T , var/mob/living/carbon/M)
		return

	proc/prime()
		return

	proc/clown_check(var/mob/living/user)
		return

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
		if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
		if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
		if((user.equipped() == src)&&(!active)&&(clown_check(user)))
			user << "\red You prime the flashbang! [det_time/10] seconds!"

			log_attack("<font color='red'>[user.name] ([user.ckey]) primed a flashbang.</font>")
			log_admin("ATTACK: [user] ([user.ckey]) primed a flashbang.")
			message_admins("ATTACK: [user] ([user.ckey]) primed a flashbang.")

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

	bang(var/turf/T , var/mob/living/carbon/M)						// Added a new proc called 'bang' that takes a location and a person to be banged.
		if (locate(/obj/item/weapon/cloaking_device, M))			// Called during the loop that bangs people in lockers/containers and when banging
			for(var/obj/item/weapon/cloaking_device/S in M)			// people in normal view.  Could theroetically be called during other explosions.
				S.active = 0										// -- Polymorph
				S.icon_state = "shield0"

		M << "\red <B>BANG</B>"
		playsound(src.loc, 'bang.ogg', 25, 1)

//Checking for protections
		var/eye_safety = 0
		var/ear_safety = 0
		if(iscarbon(M))
			eye_safety = M.eyecheck()
			if(ishuman(M))
				if(istype(M:l_ear, /obj/item/clothing/ears/earmuffs) || istype(M:r_ear, /obj/item/clothing/ears/earmuffs))
					ear_safety += 2
				if(HULK in M.mutations)
					ear_safety += 1
				if(istype(M:head, /obj/item/clothing/head/helmet))
					ear_safety += 1

//Flashing everyone
		if(eye_safety < 1)
			flick("e_flash", M.flash)
			M.eye_stat += rand(1, 3)
			M.Stun(2)
			M.Weaken(10)



//Now applying sound
		if((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
			if(ear_safety > 0)
				M.Stun(2)
				M.Weaken(1)
			else
				M.Stun(10)
				M.Weaken(3)
				if ((prob(14) || (M == src.loc && prob(70))))
					M.ear_damage += rand(1, 10)
				else
					M.ear_damage += rand(0, 5)
					M.ear_deaf = max(M.ear_deaf,15)

		else if(get_dist(M, T) <= 5)
			if(!ear_safety)
				M.Stun(8)
				M.ear_damage += rand(0, 3)
				M.ear_deaf = max(M.ear_deaf,10)

		else if(!ear_safety)
			M.Stun(4)
			M.ear_damage += rand(0, 1)
			M.ear_deaf = max(M.ear_deaf,5)

//This really should be in mob not every check
		if (M.eye_stat >= 20)
			M << "\red Your eyes start to burn badly!"
			M.disabilities |= 1
			if(!banglet && !(istype(src , /obj/item/weapon/flashbang/clusterbang)))
				if (prob(M.eye_stat - 20 + 1))
					M << "\red You can't see anything!"
					M.disabilities |= 128
		if (M.ear_damage >= 15)
			M << "\red Your ears start to ring badly!"
			if(!banglet && !(istype(src , /obj/item/weapon/flashbang/clusterbang)))
				if (prob(M.ear_damage - 10 + 5))
					M << "\red You can't hear anything!"
					M.disabilities |= 32
		else
			if (M.ear_damage >= 5)
				M << "\red Your ears start to ring!"
		M.update_icons()

	prime()													// Prime now just handles the two loops that query for people in lockers and people who can see it.
		var/turf/T = get_turf(src)
		if(T)
			T.hotspot_expose(700,125)

		for(var/obj/structure/closet/L in view(T, null))
			if(locate(/mob/living/carbon/, L))
				for(var/mob/living/carbon/M in L)
					bang(T, M)


		for(var/mob/living/carbon/M in viewers(T, null))
			bang(T, M)

		for(var/obj/effect/blob/B in view(8,T))       		//Blob damage here
			var/damage = round(30/(get_dist(B,T)+1))
			B.health -= damage
			B.update()
		del(src)
		return


	attack_self(mob/user as mob)
		if(!active)
			if(clown_check(user))
				log_attack("<font color='red'>[user.name] ([user.ckey]) primed a flashbang.</font>")
				log_admin("ATTACK: [user] ([user.ckey]) primed a flashbang.")
				message_admins("ATTACK: [user] ([user.ckey]) primed a flashbang.")
				user << "\red You prime the flashbang! [det_time/10] seconds!"
				src.active = 1
				src.icon_state = "flashbang1"
				add_fingerprint(user)
				spawn( src.det_time )
					prime()
					return
		return


	attack_hand()
		walk(src, null, null)
		..()
		return


	clown_check(var/mob/living/user)
		if ((CLUMSY in user.mutations) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.active = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
			return 0
		return 1

/obj/item/weapon/flashbang/clusterbang
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'grenade.dmi'
	icon_state = "clusterbang"
	var/child = 0

	attack_self(mob/user as mob)
		if(!active)
			//world << "cluster attack self"
			user << "\red You prime the clusterbang! [det_time/10] seconds!"
			log_attack("<font color='red'>[user.name] ([user.ckey]) primed a [src].</font>")
			log_admin("ATTACK: [user] ([user.ckey]) primed a [src].")
			message_admins("ATTACK: [user] ([user.ckey]) primed a [src].")
			src.active = 1
			src.icon_state = "clusterbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(src.det_time)
				arm(user)
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
		if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
		if((user.equipped() == src)&&(!active))
			//world << "cluster after attack"
			arm(user)
			user.dir = get_dir(user, target)
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)
		return

/obj/item/weapon/flashbang/clusterbang/proc/arm(mob/user as mob)

	//world << "Armed!"
	var/numspawned = rand(4,8)
//	world << numspawned
	var/again = 0
	if(!child)
		for(var/more = numspawned,more > 0,more--)
			if(prob(35))
				again++
				numspawned --

	for(,numspawned > 0, numspawned--)
		//world << "Spawned Flashbang!"
		spawn(0)
			var/obj/item/weapon/flashbang/F = new /obj/item/weapon/flashbang(src)
			F.loc = src.loc
			F.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			F.active = 1
			F.banglet = 1
			var/stepdist = rand(1,3)
			walk_away(F,src,stepdist)
			var/dettime = rand(15,60)
			spawn(dettime)
				F.prime()

	for(,again > 0, again--)
		//world << "Spawned CFlashbang!"
		spawn(0)
			var/obj/item/weapon/flashbang/clusterbang/F = new /obj/item/weapon/flashbang/clusterbang(src)
			F.loc = src.loc
			F.active = 1
			F.child = 1
			F.icon_state = "clusterbang1"
			var/stepdist = rand(1,4)
			walk_away(F,src,stepdist)
			spawn(30)
				F.arm()

	spawn(70)
		prime()

	return



/****************************Critter Grenades***********************************************/


/obj/item/weapon/spawnergrenade
	desc = "It is set to detonate in 3 seconds. It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'grenade.dmi'
	icon_state = "delivery"
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	origin_tech = "materials=3;magnets=4"
	var/active = 0
	var/det_time = 30
	var/banglet = 0
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver


	proc/prime()
		return

	proc/clown_check(var/mob/living/user)
		return

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (isscrewdriver(W))
			switch(src.det_time)
				if ("1")
					src.det_time = 30
					user.show_message("\blue You set the delivery grenade for 3 second detonation time.")
					src.desc = "It is set to detonate in 3 seconds."
				if ("30")
					src.det_time = 100
					user.show_message("\blue You set the delivery grenade for 10 second detonation time.")
					src.desc = "It is set to detonate in 10 seconds."
				if ("100")
					src.det_time = 1
					user.show_message("\blue You set the delivery grenade for instant detonation.")
					src.desc = "It is set to detonate instantly."
			src.add_fingerprint(user)
		..()
		return


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
		if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
		if((user.equipped() == src)&&(!active)&&(clown_check(user)))
			user << "\red You prime the delivery grenade! [det_time/10] seconds!"
			src.active = 1
			src.icon_state = "delivery1"
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

	prime()													// Prime now just handles the two loops that query for people in lockers and people who can see it.

		if(spawner_type && deliveryamt)
			// Make a quick flash
			var/turf/T = get_turf(src)
			playsound(T, 'phasein.ogg', 100, 1)
			for(var/mob/living/carbon/human/M in viewers(T, null))
				if(M:eyecheck() <= 0)
					flick("e_flash", M.flash) // flash dose faggots

			for(var/i=1, i<=deliveryamt, i++)
				var/atom/movable/x = new spawner_type
				x.loc = T
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(x, pick(NORTH,SOUTH,EAST,WEST))

				// Spawn some hostile syndicate critters
				if(istype(x, /obj/effect/critter))
					var/obj/effect/critter/C = x

					C.atkcarbon = 1
					C.atksilicon = 1
					C.atkmech = 0
					C.atksynd = 0
					C.aggressive = 1

		del(src)
		return


	attack_self(mob/user as mob)
		if(!active)
			if(clown_check(user))
				user << "\red You prime the delivery grenade! [det_time/10] seconds!"
				src.active = 1
				src.icon_state = "delivery1"
				add_fingerprint(user)
				spawn( src.det_time )
					prime()
					return
		return


	attack_hand()
		walk(src, null, null)
		..()
		return


	clown_check(var/mob/living/user)
		if ((CLUMSY in user.mutations) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.active = 1
			src.icon_state = "delivery1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
			return 0
		return 1

/obj/item/weapon/spawnergrenade/manhacks
	name = "manhack delivery grenade"
	spawner_type = /obj/effect/critter/manhack
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /obj/effect/critter/spesscarp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/spawnergrenade/elitespesscarp
	name = "elite carp delivery grenade"
	spawner_type = /obj/effect/critter/spesscarp/elite
	deliveryamt = 2
	origin_tech = "materials=3;magnets=4;syndicate=4"




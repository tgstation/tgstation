/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"
	var/banglet = 0

	prime()
		..()
		for(var/obj/structure/closet/L in view(get_turf(src), null))
			if(locate(/mob/living/carbon/, L))
				for(var/mob/living/carbon/M in L)
					bang(get_turf(src), M)


		for(var/mob/living/carbon/M in viewers(get_turf(src), null))
			bang(get_turf(src), M)

		for(var/obj/effect/blob/B in view(8,get_turf(src)))       		//Blob damage here
			var/damage = round(30/(get_dist(B,get_turf(src))+1))
			B.health -= damage
			B.update_icon()
		del(src)
		return

	proc/bang(var/turf/T , var/mob/living/carbon/M)						// Added a new proc called 'bang' that takes a location and a person to be banged.
		if (locate(/obj/item/weapon/cloaking_device, M))			// Called during the loop that bangs people in lockers/containers and when banging
			for(var/obj/item/weapon/cloaking_device/S in M)			// people in normal view.  Could theroetically be called during other explosions.
				S.active = 0										// -- Polymorph
				S.icon_state = "shield0"

		M << "\red <B>BANG</B>"
		playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)

//Checking for protections
		var/eye_safety = 0
		var/ear_safety = 0
		if(iscarbon(M))
			eye_safety = M.eyecheck()
			if(ishuman(M))
				if(istype(M:ears, /obj/item/clothing/ears/earmuffs))
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
			M.disabilities |= NEARSIGHTED
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/flashbang/clusterbang)))
				if (prob(M.eye_stat - 20 + 1))
					M << "\red You can't see anything!"
					M.sdisabilities |= BLIND
		if (M.ear_damage >= 15)
			M << "\red Your ears start to ring badly!"
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/flashbang/clusterbang)))
				if (prob(M.ear_damage - 10 + 5))
					M << "\red You can't hear anything!"
					M.sdisabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				M << "\red Your ears start to ring!"
		M.update_icons()


/obj/item/weapon/grenade/flashbang/clusterbang//Created by Polymorph, fixed by Sieve
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"

/obj/item/weapon/grenade/flashbang/clusterbang/prime()
	var/numspawned = rand(4,8)
	var/again = 0
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(src.loc)//Launches flashbangs
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	for(,again > 0, again--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/clusterbang/segment(src.loc)//Creates a 'segment' that launches a few more flashbangs
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(0)
		del(src)
		return

/obj/item/weapon/grenade/flashbang/clusterbang/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/flashbang/clusterbang/segment/New()//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	icon_state = "clusterbang_segment_active"
	active = 1
	banglet = 1
	var/stepdist = rand(1,4)//How far to step
	var/temploc = src.loc//Saves the current location to know where to step away from
	walk_away(src,temploc,stepdist)//I must go, my people need me
	var/dettime = rand(15,60)
	spawn(dettime)
		prime()
	..()

/obj/item/weapon/grenade/flashbang/clusterbang/segment/prime()
	var/numspawned = rand(4,8)
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/flashbang/cluster(src.loc)
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(0)
		del(src)
		return

/obj/item/weapon/grenade/flashbang/cluster/New()//Same concept as the segments, so that all of the parts don't become reliant on the clusterbang
	spawn(0)
		icon_state = "flashbang_active"
		active = 1
		banglet = 1
		var/stepdist = rand(1,3)
		var/temploc = src.loc
		walk_away(src,temploc,stepdist)
		var/dettime = rand(15,60)
		spawn(dettime)
		prime()
	..()
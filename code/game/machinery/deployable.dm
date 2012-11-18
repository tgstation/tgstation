/*
CONTAINS:

Deployable items
Barricades

for reference:

	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_genetics = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	access_court = 42
	access_clown = 43
	access_mime = 44

*/


//Barricades, maybe there will be a metal one later...
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	anchored = 1.0
	density = 1.0
	var/health = 100.0
	var/maxhealth = 100.0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/stack/sheet/wood))
			if (src.health < src.maxhealth)
				visible_message("\red [user] begins to repair the [src]!")
				if(do_after(user,20))
					src.health = src.maxhealth
					W:use(1)
					visible_message("\red [user] repairs the [src]!")
					return
			else
				return
			return
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 1
				if("brute")
					src.health -= W.force * 0.75
				else
			if (src.health <= 0)
				visible_message("\red <B>The barricade is smashed apart!</B>")
				new /obj/item/stack/sheet/wood(get_turf(src))
				new /obj/item/stack/sheet/wood(get_turf(src))
				new /obj/item/stack/sheet/wood(get_turf(src))
				del(src)
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("\red <B>The barricade is blown apart!</B>")
				del(src)
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					visible_message("\red <B>The barricade is blown apart!</B>")
					new /obj/item/stack/sheet/wood(get_turf(src))
					new /obj/item/stack/sheet/wood(get_turf(src))
					new /obj/item/stack/sheet/wood(get_turf(src))
					del(src)
				return

	meteorhit()
		visible_message("\red <B>The barricade is smashed apart!</B>")
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		del(src)
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			visible_message("\red <B>The blob eats through the barricade!</B>")
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0


//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 100.0
	var/maxhealth = 100.0
	var/locked = 0.0
//	req_access = list(access_maint_tunnels)

	New()
		..()

		src.icon_state = "barrier[src.locked]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/card/id/))
			if (src.allowed(user))
				if	(src.emagged < 2.0)
					src.locked = !src.locked
					src.anchored = !src.anchored
					src.icon_state = "barrier[src.locked]"
					if ((src.locked == 1.0) && (src.emagged < 2.0))
						user << "Barrier lock toggled on."
						return
					else if ((src.locked == 0.0) && (src.emagged < 2.0))
						user << "Barrier lock toggled off."
						return
				else
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, src)
					s.start()
					visible_message("\red BZZzZZzZZzZT")
					return
			return
		else if (istype(W, /obj/item/weapon/card/emag))
			if (src.emagged == 0)
				src.emagged = 1
				src.req_access = null
				user << "You break the ID authentication lock on the [src]."
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("\red BZZzZZzZZzZT")
				return
			else if (src.emagged == 1)
				src.emagged = 2
				user << "You short out the anchoring mechanism on the [src]."
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("\red BZZzZZzZZzZT")
				return
		else if (istype(W, /obj/item/weapon/wrench))
			if (src.health < src.maxhealth)
				src.health = src.maxhealth
				src.emagged = 0
				src.req_access = list(access_security)
				visible_message("\red [user] repairs the [src]!")
				return
			else if (src.emagged > 0)
				src.emagged = 0
				src.req_access = list(access_security)
				visible_message("\red [user] repairs the [src]!")
				return
			return
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 0.75
				if("brute")
					src.health -= W.force * 0.5
				else
			if (src.health <= 0)
				src.explode()
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.explode()
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					src.explode()
				return

	meteorhit()
		src.explode()
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			src.explode()
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

	proc/explode()

		visible_message("\red <B>[src] blows apart!</B>")
		var/turf/Tsec = get_turf(src)

	/*	var/obj/item/stack/rods/ =*/
		new /obj/item/stack/rods(Tsec)

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		explosion(src.loc,-1,-1,0)
		if(src)
			del(src)
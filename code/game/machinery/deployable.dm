//Barricades, maybe there will be a metal one later...
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'structures.dmi'
	icon_state = "woodenbarricade"
	anchored = 1.0
	density = 1.0
	var/health = 100.0
	var/maxhealth = 100.0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/stack/sheet/wood))
			if (src.health < src.maxhealth)
				for(var/mob/O in viewers(src, null))
					O << "\red [user] begins to repair the [src]!"
				if(do_after(user,20))
					src.health = src.maxhealth
					W:use(1)
					for(var/mob/O in viewers(src, null))
						O << "\red [user] repairs the [src]!"
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
				for(var/mob/O in viewers(src, null))
					O << "\red <B>The barricade is smashed apart!</B>"
				new /obj/item/stack/sheet/wood(get_turf(src))
				new /obj/item/stack/sheet/wood(get_turf(src))
				new /obj/item/stack/sheet/wood(get_turf(src))
				del(src)
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				for(var/mob/O in viewers(src, null))
					O << "\red <B>The barricade is blown apart!</B>"
				del(src)
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					for(var/mob/O in viewers(src, null))
						O << "\red <B>The barricade is blown apart!</B>"
					new /obj/item/stack/sheet/wood(get_turf(src))
					new /obj/item/stack/sheet/wood(get_turf(src))
					new /obj/item/stack/sheet/wood(get_turf(src))
					del(src)
				return

	meteorhit()
		for(var/mob/O in viewers(src, null))
			O << "\red <B>The barricade is smashed apart!</B>"
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		del(src)
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			for(var/mob/O in viewers(src, null))
				O << "\red <B>The blob eats through the barricade!</B>"
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.pass_flags&PASSTABLE)
			return 1
		else
			return 0


//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'objects.dmi'
	req_access = list(ACCESS_SECURITY)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 100.0
	var/maxhealth = 100.0
	var/locked = 0.0
//	req_access = list(ACCESS_MAINT_TUNNELS)

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
					for(var/mob/O in viewers(src, null))
						O << "\red BZZzZZzZZzZT"
					return
			return
		else if (istype(W, /obj/item/weapon/card/emag))
			var/obj/item/weapon/card/emag/E = W
			if(E.uses)
				E.uses--
			else
				return
			if (src.emagged == 0)
				src.emagged = 1
				src.req_access = null
				user << "You break the ID authentication lock on the [src]."
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				for(var/mob/O in viewers(src, null))
					O << "\red BZZZZT"
				return
			else if (src.emagged == 1)
				src.emagged = 2
				user << "You short out the anchoring mechanism on the [src]."
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				for(var/mob/O in viewers(src, null))
					O << "\red BZZZZT"
				return
		else if (istype(W, /obj/item/weapon/wrench))
			if (src.health < src.maxhealth)
				src.health = src.maxhealth
				src.emagged = 0
				src.req_access = list(ACCESS_SECURITY)
				for(var/mob/O in viewers(src, null))
					O << "\red [user] repairs the [src]!"
				return
			else if (src.emagged > 0)
				src.emagged = 0
				src.req_access = list(ACCESS_SECURITY)
				for(var/mob/O in viewers(src, null))
					O << "\red [user] repairs the [src]!"
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
		if(istype(mover) && mover.pass_flags&PASSTABLE)
			return 1
		else
			return 0

	proc/explode()

		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] blows apart!</B>", 1)
		var/turf/Tsec = get_turf(src)

	/*	var/obj/item/stack/rods/ =*/
		new /obj/item/stack/rods(Tsec)

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		explosion(src.loc,-1,-1,0)
		if(src)
			del(src)
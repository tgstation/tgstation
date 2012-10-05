//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/matter = 0
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0


	New()
		desc = "A RCD. It currently holds [matter]/30 matter-units."
		src.spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		return


	attackby(obj/item/weapon/W, mob/user)
		..()
		if(istype(W, /obj/item/weapon/rcd_ammo))
			if((matter + 10) > 30)
				user << "<span class='notice'>The RCD cant hold any more matter-units.</span>"
				return
			user.drop_item()
			del(W)
			matter += 10
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user << "<span class='notice'>The RCD now holds [matter]/30 matter-units.</span>"
			desc = "A RCD. It currently holds [matter]/30 matter-units."
			return


	attack_self(mob/user)
		//Change the mode
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		switch(mode)
			if(1)
				mode = 2
				user << "<span class='notice'>Changed mode to 'Airlock'</span>"
				if(prob(20))
					src.spark_system.start()
				return
			if(2)
				mode = 3
				user << "<span class='notice'>Changed mode to 'Deconstruct'</span>"
				if(prob(20))
					src.spark_system.start()
				return
			if(3)
				mode = 1
				user << "<span class='notice'>Changed mode to 'Floor & Walls'</span>"
				if(prob(20))
					src.spark_system.start()
				return

	proc/activate()
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


	afterattack(atom/A, mob/user)
		if(disabled && !isrobot(user))
			return 0
		if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
			return 0
		if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return 0

		switch(mode)
			if(1)
				if(istype(A, /turf/space))
					if(useResource(1, user))
						user << "Building Floor..."
						activate()
						A:ReplaceWithPlating()
						return 1
					return 0

				if(istype(A, /turf/simulated/floor))
					if(checkResource(3, user))
						user << "Building Wall ..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 20))
							if(!useResource(3, user)) return 0
							activate()
							A:ReplaceWithWall()
							return 1
					return 0

			if(2)
				if(istype(A, /turf/simulated/floor))
					if(checkResource(10, user))
						user << "Building Airlock..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(10, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
							T.autoclose = 1
							return 1
						return 0
					return 0

			if(3)
				if(istype(A, /turf/simulated/wall))
					if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
						return 0
					if(checkResource(5, user))
						user << "Deconstructing Wall..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 40))
							if(!useResource(5, user)) return 0
							activate()
							A:ReplaceWithPlating()
							return 1
					return 0

				if(istype(A, /turf/simulated/floor))
					if(checkResource(5, user))
						user << "Deconstructing Floor..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(5, user)) return 0
							activate()
							A:ReplaceWithSpace()
							return 1
					return 0

				if(istype(A, /obj/machinery/door/airlock))
					if(checkResource(10, user))
						user << "Deconstructing Airlock..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(10, user)) return 0
							activate()
							del(A)
							return 1
					return	0
				return 0
			else
				user << "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin."
				return 0

/obj/item/weapon/rcd/proc/useResource(var/amount, var/mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	desc = "A RCD. It currently holds [matter]/30 matter-units."
	return 1

/obj/item/weapon/rcd/proc/checkResource(var/amount, var/mob/user)
	return matter >= amount
/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 30)

/obj/item/weapon/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 30)

/obj/item/weapon/rcd/borg/New()
	..()
	desc = "A device used to rapidly build walls/floor."
	canRwall = 1

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls and floors."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	m_amt = 100000
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0
	var/airlock_type = /obj/machinery/door/airlock
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available

/obj/item/weapon/rcd/verb/change_airlock_setting()
	set name = "Change Airlock Setting"
	set category = "Object"
	set src in usr

	var airlockcat = input(usr, "Select whether the airlock is solid or glass.") in list("Solid", "Glass")
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var airlockpaint = input(usr, "Select the paintjob of the airlock.") in list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")
				switch(airlockpaint)
					if("Default")
						airlock_type = /obj/machinery/door/airlock
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/external
					if("High Security")
						airlock_type = /obj/machinery/door/airlock/highsecurity
			else
				airlock_type = /obj/machinery/door/airlock

		if("Glass")
			if(advanced_airlock_setting == 1)
				var airlockpaint = input(usr, "Select the paintjob of the airlock.") in list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining")
				switch(airlockpaint)
					if("Default")
						airlock_type = /obj/machinery/door/airlock/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/glass_engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/glass_atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/glass_security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/glass_command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/glass_medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/glass_research
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/glass_mining
			else
				airlock_type = /obj/machinery/door/airlock/glass
		else
			airlock_type = /obj/machinery/door/airlock


/obj/item/weapon/rcd/New()
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return


/obj/item/weapon/rcd/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/R = W
		if((matter + R.ammoamt) > max_matter)
			user << "<span class='warning'>The RCD can't hold any more matter-units!</span>"
			return
		user.drop_item()
		qdel(W)
		matter += R.ammoamt
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		user << "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>"
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
		return


/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(1)
			mode = 2
			user << "<span class='notice'>You change RCD's mode to 'Airlock'.</span>"
			if(prob(20))
				src.spark_system.start()
			return
		if(2)
			mode = 3
			user << "<span class='notice'>You change RCD's mode to 'Deconstruct'.</span>"
			if(prob(20))
				src.spark_system.start()
			return
		if(3)
			mode = 1
			user << "<span class='notice'>You change RCD's mode to 'Floor & Walls'.</span>"
			if(prob(20))
				src.spark_system.start()
			return

/obj/item/weapon/rcd/proc/activate()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


/obj/item/weapon/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return 0
	if(disabled && !isrobot(user))
		return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0
	if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
		return 0

	switch(mode)
		if(1)
			if(istype(A, /turf/space))
				var/turf/space/S = A
				if(useResource(1, user))
					user << "<span class='notice'>You start building floor...</span>"
					activate()
					S.ChangeTurf(/turf/simulated/floor/plating)
					return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				var/turf/simulated/floor/F = A
				if(checkResource(3, user))
					user << "<span class='notice'>You start building wall...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 20))
						if(!useResource(3, user)) return 0
						activate()
						F.ChangeTurf(/turf/simulated/wall)
						return 1
				return 0

		if(2)
			if(istype(A, /turf/simulated/floor))
				if(checkResource(10, user))
					var/door_check = 1
					for(var/obj/machinery/door/D in A)
						if(!D.sub_door)
							door_check = 0
							break

					if(door_check)
						user << "<span class='notice'>You start building airlock...</span>"
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(10, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new airlock_type( A )
							if(!T.checkForMultipleDoors())
								qdel(T)
								useResource(-10, user)
								return 0
							T.autoclose = 1
							return 1
						return 0
					else
						user << "<span class='warning'>There is another door here!</span>"
						return 0
				return 0

		if(3)
			if(istype(A, /turf/simulated/wall))
				var/turf/simulated/wall/W
				if(istype(W, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				if(checkResource(5, user))
					user << "<span class='notice'>You start deconstructing wall...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40))
						if(!useResource(5, user)) return 0
						activate()
						W.ChangeTurf(/turf/simulated/floor/plating)
						return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				var/turf/simulated/floor/F = A
				if(istype(F, F.baseturf))
					user << "<span class='notice'>You can't dig any deeper!</span>"
					return 0
				else if(checkResource(5, user))
					user << "<span class='notice'>You start deconstructing floor...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(5, user)) return 0
						activate()
						F.ChangeTurf(F.baseturf)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource(20, user))
					user << "<span class='notice'>You start deconstructing airlock...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(20, user)) return 0
						activate()
						qdel(A)
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
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	return 1

/obj/item/weapon/rcd/proc/checkResource(var/amount, var/mob/user)
	return matter >= amount
/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 160)

/obj/item/weapon/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 160)

/obj/item/weapon/rcd/borg/New()
	..()
	advanced_airlock_setting = 0 //Borgs can't set the access levels, so they only get the defaults!
	desc = "A device used to rapidly build walls/floor."
	canRwall = 1

/obj/item/weapon/rcd/loaded
	matter = 100

/obj/item/weapon/rcd/combat
	name = "combat RCD"
	max_matter = 500
	matter = 500
	canRwall = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	m_amt = 16000
	g_amt = 8000
	var/ammoamt = 20

/obj/item/weapon/rcd_ammo/large
	ammoamt = 100
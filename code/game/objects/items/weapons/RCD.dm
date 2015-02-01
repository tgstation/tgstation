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
	flags = FPRINT
	siemens_coefficient = 1
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL // Lots of metal
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 30
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0
	var/airlock_type = /obj/machinery/door/airlock
	var/floor_cost = 1
	var/wall_cost = 3
	var/airlock_cost = 3
	var/decon_cost = 5

/obj/item/weapon/rcd/verb/change_airlock_setting()
	set name = "Change Airlock Setting"
	set category = "Object"
	set src in usr

	var airlockcat = input(usr, "Select the type of the airlock.") in list("Solid", "Glass")
	switch(airlockcat)
		if("Solid")
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

		if("Glass")
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
			airlock_type = /obj/machinery/door/airlock

/obj/item/weapon/rcd/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is using the deconstruct function on the [src.name] on \himself! It looks like \he's  trying to commit suicide!</b>"
	return (user.death(1))

/obj/item/weapon/rcd/New()
	..()
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return


/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/rcd_ammo))
		if((matter + 10) > max_matter)
			user << "<span class='notice'>The RCD cant hold any more matter-units.</span>"
			return
		user.drop_item()
		del(W)
		matter += 10
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
		user << "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>"
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
		return


/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
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

/obj/item/weapon/rcd/proc/activate()
	playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)


/obj/item/weapon/rcd/afterattack(atom/A, mob/user)
	if(disabled && !isrobot(user))
		return 0
	if(get_dist(user,A)>1)
		return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0
	if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
		return 0

	switch(mode)
		if(1)
			if(istype(A, /turf/space))
				if(useResource(floor_cost, user))
					user << "Building Floor..."
					activate()
					A:ChangeTurf(/turf/simulated/floor/plating/airless)
					return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				if(checkResource(wall_cost, user))
					user << "Building Wall ..."
					playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 20))
						if(!useResource(wall_cost, user)) return 0
						activate()
						A:ChangeTurf(/turf/simulated/wall)
						return 1
				return 0

		if(2)
			if(checkResource(airlock_cost, user))
				user << "Building Airlock..."
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
				if(do_after(user, 50))
					if(!useResource(airlock_cost, user)) return 0
					if(locate(/obj/machinery/door/airlock) in A) return 0
					activate()
					var/obj/machinery/door/airlock/T = new airlock_type( A )
					T.autoclose = 1
					return 1
				return 0
			return 0

		if(3)
			if(istype(A, /turf/simulated/wall))
				if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				if(checkResource(decon_cost, user))
					user << "Deconstructing Wall..."
					playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40))
						if(!useResource(decon_cost, user)) return 0
						activate()
						A:ChangeTurf(/turf/simulated/floor/plating)
						return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				if(checkResource(decon_cost, user))
					user << "Deconstructing Floor..."
					playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(decon_cost, user)) return 0
						activate()
						A:ChangeTurf(/turf/space)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource((decon_cost * 2), user))
					user << "Deconstructing Airlock..."
					playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource((decon_cost * 2), user)) return 0
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
	desc = "An RCD. It currently holds [matter]/[max_matter] matter-units."
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
	w_class = 2.0
	m_amt = 30000
	g_amt = 15000
	w_type = RECYK_ELECTRONIC

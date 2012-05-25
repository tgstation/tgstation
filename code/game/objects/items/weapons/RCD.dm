//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'items.dmi'
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
	var/disabled = 0


	New()
		desc = "A RCD. It currently holds [matter]/30 matter-units."
		src.spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		return


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/rcd_ammo))
			if((matter + 10) > 30)
				user << "The RCD cant hold any more matter."
				return
			del(W)
			matter += 10
			playsound(src.loc, 'click.ogg', 50, 1)
			user << "The RCD now holds [matter]/30 matter-units."
			desc = "A RCD. It currently holds [matter]/30 matter-units."
			return


	attack_self(mob/user as mob)
		//Change the mode
		playsound(src.loc, 'pop.ogg', 50, 0)
		if(mode == 1)
			mode = 2
			user << "Changed mode to 'Airlock'"
			src.spark_system.start()
			return
		if(mode == 2)
			mode = 3
			user << "Changed mode to 'Deconstruct'"
			src.spark_system.start()
			return
		if(mode == 3)
			mode = 1
			user << "Changed mode to 'Floor & Walls'"
			src.spark_system.start()
			return


	afterattack(atom/A, mob/user as mob)
		if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))//Nanotrasen Matter Jammer TM -Sieve
			disabled = 1
		else
			disabled = 0
		if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return

		if(istype(A, /turf) && mode == 1)
			if(istype(A, /turf/space) && matter >= 1)
				user << "Building Floor (1)..."
				if(!disabled && matter >= 1)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					spark_system.set_up(5, 0, src)
					src.spark_system.start()
					A:ReplaceWithPlating()
					matter--
					user << "The RCD now holds [matter]/30 matter-units."
					desc = "A RCD. It currently holds [matter]/30 matter-units."
				return
			if(istype(A, /turf/simulated/floor) && matter >= 3)
				user << "Building Wall (3)..."
				playsound(src.loc, 'click.ogg', 50, 1)
				if(do_after(user, 20))
					if(!disabled && matter >= 3)
						spark_system.set_up(5, 0, src)
						src.spark_system.start()
						A:ReplaceWithWall()
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						matter -= 3
						user << "The RCD now holds [matter]/30 matter-units."
						desc = "A RCD. It currently holds [matter]/30 matter-units."
				return
		else if(istype(A, /turf/simulated/floor) && mode == 2 && matter >= 10)
			user << "Building Airlock (10)..."
			playsound(src.loc, 'click.ogg', 50, 1)
			if(do_after(user, 50))
				if(!disabled && matter >= 10)
					spark_system.set_up(5, 0, src)
					src.spark_system.start()
					if(locate(/obj/machinery/door) in get_turf(src))	return
					var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
					var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
					if(killthis)
						killthis.ex_act(2)//Smashin windows
					T.autoclose = 1
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					playsound(src.loc, 'sparks2.ogg', 50, 1)
					matter -= 10
					user << "The RCD now holds [matter]/30 matter-units."
					desc = "A RCD. It currently holds [matter]/30 matter-units."
			return
		else if(mode == 3 && (istype(A, /turf) || istype(A, /obj/machinery/door/airlock) ) )
			if(istype(A, /turf/simulated/wall) && !istype(A, /turf/simulated/wall/r_wall) && matter >= 4)
				user << "Deconstructing Wall (4)..."
				playsound(src.loc, 'click.ogg', 50, 1)
				if(do_after(user, 40))
					if(!disabled && matter >= 4)
						spark_system.set_up(5, 0, src)
						src.spark_system.start()
						A:ReplaceWithPlating()
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						matter -= 4
						user << "The RCD now holds [matter]/30 matter-units."
						desc = "A RCD. It currently holds [matter]/30 matter-units."
				return
			if(istype(A, /turf/simulated/wall/r_wall))
				return
			if(istype(A, /turf/simulated/floor) && matter >= 5)
				user << "Deconstructing Floor (5)..."
				playsound(src.loc, 'click.ogg', 50, 1)
				if(do_after(user, 50))
					if(!disabled && matter >= 5)
						spark_system.set_up(5, 0, src)
						src.spark_system.start()
						A:ReplaceWithSpace()
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						matter -= 5
						user << "The RCD now holds [matter]/30 matter-units."
						desc = "A RCD. It currently holds [matter]/30 matter-units."
				return
			if(istype(A, /obj/machinery/door/airlock) && matter >= 10)
				user << "Deconstructing Airlock (10)..."
				playsound(src.loc, 'click.ogg', 50, 1)
				if(do_after(user, 50))
					if(!disabled && matter >= 10)
						spark_system.set_up(5, 0, src)
						src.spark_system.start()
						del(A)
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						matter -= 10
						user << "The RCD now holds [matter]/30 matter-units."
						desc = "A RCD. It currently holds [matter]/30 matter-units."
				return

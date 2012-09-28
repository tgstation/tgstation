//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "Electrified Arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

	attack(mob/M as mob, mob/living/silicon/robot/user as mob)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

		log_attack(" <font color='red'>[user.name] ([user.ckey]) used the [src.name] to attack [M.name] ([M.ckey])</font>")

		user.cell.charge -= 30

		M.Weaken(5)
		if (M.stuttering < 5)
			M.stuttering = 5
		M.Stun(5)

		for(var/mob/O in viewers(M, null))
			if (O.client)
				O.show_message("\red <B>[user] has prodded [M] with an electrically-charged arm!</B>", 1, "\red You hear someone fall", 2)

/obj/item/borg/overdrive
	name = "Overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "X-ray Vision"
	sight_mode = BORGXRAY


/obj/item/borg/sight/thermal
	name = "Thermal Vision"
	sight_mode = BORGTHERM


/obj/item/borg/sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON


/obj/item/borg/sight/hud
	name = "Hud"
	var/obj/item/clothing/glasses/hud/hud = null


/obj/item/borg/sight/hud/med
	name = "Medical Hud"


	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health(src)
		return


/obj/item/borg/sight/hud/sec
	name = "Security Hud"


	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/security(src)
		return



/**********************************************************************
						Chemical things
***********************************************************************/

//Moved to modules/chemistry






/**********************************************************************
						RCD
***********************************************************************/
/obj/item/borg/rcd
	name = "robotic rapid-construction-device"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 3.0
	//	datum/effect/effect/system/spark_spread/spark_system
	var/working = 0
	var/mode = 1
	var/disabled = 0

/*
	New()
		src.spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		return
*/

	proc/activate()
//		spark_system.set_up(5, 0, src)
//		src.spark_system.start()
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


	attack_self(mob/user as mob)
		//Change the mode
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		if(mode == 1)
			mode = 2
			user << "Changed mode to 'Airlock'"
//			src.spark_system.start()
			return
		if(mode == 2)
			mode = 3
			user << "Changed mode to 'Deconstruct'"
//			src.spark_system.start()
			return
		if(mode == 3)
			mode = 1
			user << "Changed mode to 'Floor & Walls'"
//			src.spark_system.start()
			return


	afterattack(atom/A, mob/user as mob)
		if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))//No RCDs on the shuttles -Sieve
			disabled = 1
		else
			disabled = 0
		if(!isrobot(user)|| disabled == 1)	return

		var/mob/living/silicon/robot/R = user
		var/obj/item/weapon/cell/cell = R.cell

		if(!cell)	return

		if((istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			switch(mode)
				if(1)
					if(istype(A, /turf/space))
						if(!cell.use(30))	return
						user << "Building Floor..."
						activate()
						A:ReplaceWithPlating()
						return

					if(istype(A, /turf/simulated/floor))
						if(!cell.use(90))	return
						user << "Building Wall ..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 20))
							activate()
							A:ReplaceWithWall()
						return

				if(2)
					if(istype(A, /turf/simulated/floor))
						if(!cell.use(300))	return
						user << "Building Airlock..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							activate()
							var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
							T.autoclose = 1
						return

				if(3)
					if(istype(A, /turf/simulated/wall))
						if(!cell.use(150))	return
						user << "Deconstructing Wall..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 40))
							activate()
							A:ReplaceWithPlating()
						return

					if(istype(A, /turf/simulated/floor))
						user << "Deconstructing Floor..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							activate()
							A:ReplaceWithSpace()
						return

					if(istype(A, /obj/machinery/door/airlock))
						user << "Deconstructing Airlock..."
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							activate()
							del(A)
						return
		return


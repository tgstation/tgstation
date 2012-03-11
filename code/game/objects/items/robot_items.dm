/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "Electrified Arm"
	icon = 'decals.dmi'
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
	icon = 'decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'decals.dmi'
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

/obj/item/weapon/reagent_containers/glass/bottle/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	volume = 60
	var
		reagent = ""


/obj/item/weapon/reagent_containers/glass/bottle/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'chemical.dmi'
	icon_state = "bottle16"
	reagent = "inaprovaline"

	New()
		..()
		reagents.add_reagent("inaprovaline", 60)
		return


/obj/item/weapon/reagent_containers/glass/bottle/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'chemical.dmi'
	icon_state = "bottle17"
	reagent = "anti_toxin"

	New()
		..()
		reagents.add_reagent("anti_toxin", 60)
		return



/obj/item/weapon/reagent_containers/robodropper
	name = "Industrial Dropper"
	desc = "A larger dropper. Transfers 10 units."
	icon = 'chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,3,4,5,6,7,8,9,10)
	volume = 10
	var/filled = 0

	afterattack(obj/target, mob/user , flag)
		if(!target.reagents) return

		if(filled)

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food)) //You can inject humans and food but you cant remove the shit.
				user << "\red You cannot directly fill this object."
				return

			if(ismob(target))
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] drips something onto []!</B>", user, target), 1)
				src.reagents.reaction(target, TOUCH)

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution."
			if (src.reagents.total_volume<=0)
				filled = 0
				icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
				user << "\red You cannot directly remove reagents from [target]."
				return

			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

			user << "\blue You fill the dropper with [trans] units of the solution."

			filled = 1
			icon_state = "dropper[filled]"

		return


/**********************************************************************
						Chemical things
***********************************************************************/
/obj/item/borg/rcd
	name = "robotic rapid-construction-device"
	desc = "A device used to rapidly build walls/floor."
	icon = 'items.dmi'
	icon_state = "rcd"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 3.0
	var
	//	datum/effect/effect/system/spark_spread/spark_system
		working = 0
		mode = 1

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
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)


	attack_self(mob/user as mob)
		//Change the mode
		playsound(src.loc, 'pop.ogg', 50, 0)
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
		if(!isrobot(user))	return
		if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))	return

		var/mob/living/silicon/robot/R = user
		var/obj/item/weapon/cell/cell = R.cell
		if(!cell)	return

		if(istype(A, /turf))
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
						user << "Building Wall (3)..."
						playsound(src.loc, 'click.ogg', 50, 1)
						if(do_after(user, 20))
							activate()
							A:ReplaceWithWall()
						return

				if(2)
					if(istype(A, /turf/simulated/floor))
						if(!cell.use(300))	return
						user << "Building Airlock..."
						playsound(src.loc, 'click.ogg', 50, 1)
						if(do_after(user, 50))
							activate()
							if(locate(/obj/machinery/door) in get_turf(src))	return
							var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
							T.autoclose = 1
						return

				if(3)
					if(istype(A, /turf/simulated/wall))
						if(!cell.use(150))	return
						user << "Deconstructing Wall..."
						playsound(src.loc, 'click.ogg', 50, 1)
						if(do_after(user, 40))
							activate()
							A:ReplaceWithPlating()
						return

					if(istype(A, /turf/simulated/wall/r_wall))	//by order of muskets -pete
						return

					if(istype(A, /turf/simulated/floor))
						user << "Deconstructing Floor..."
						playsound(src.loc, 'click.ogg', 50, 1)
						if(do_after(user, 50))
							activate()
							A:ReplaceWithSpace()
						return

					if(istype(A, /obj/machinery/door/airlock))
						user << "Deconstructing Airlock..."
						playsound(src.loc, 'click.ogg', 50, 1)
						if(do_after(user, 50))
							playsound(src.loc, 'click.ogg', 50, 1)
							del(A)
						return
		return


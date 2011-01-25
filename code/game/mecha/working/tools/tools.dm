/datum/mecha_tool
	var/name = "mecha tool"
	var/tool_cooldown = 0
	var/tool_ready = 1
	var/energy_drain = 0
	var/obj/mecha/working/chassis = null


/datum/mecha_tool/New(mecha)
	if(!istype(mecha, /obj/mecha/working))
		return
	src.chassis = mecha
	chassis.log_append_to_last("[src.name] initialized.")
	return


/datum/mecha_tool/proc/destroy()
	spawn
		del src
	return

/datum/mecha_tool/proc/get_tool_info()
	return src.name


/datum/mecha_tool/proc/action(atom/target)
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(energy_drain && chassis.cell.charge < energy_drain)
		return 0
	if(!tool_ready)
		return 0
	return 1

/datum/mecha_tool/proc/range_action(atom/target)
	return


/*
	//Merde, cette proc est tres bugged
/datum/mecha_tool/uni_interface
	name = "Universal Interface"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 5

	action(atom/target)
		if(!..()) return
		if(istype(target, /obj))
			var/obj/O = target
			if(O.allowed(chassis.occupant))
				target.attack_hand(chassis.occupant)
		return

*/

/datum/mecha_tool/hydraulic_clamp
	name = "Hydraulic Clamp"
	tool_cooldown = 15
	energy_drain = 10
	var/force = 15
	var/obj/mecha/working/ripley/cargo_holder

	New()
		..()
		if(istype(chassis, /obj/mecha/working/ripley))
			cargo_holder = chassis
		return

	action(atom/target)
		if(!..()) return
		if(!cargo_holder) return
		if(istype(target,/obj))
			var/obj/O = target
			if(!O.anchored)
				if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
					chassis.occupant_message("You lift [target] and start to load it into cargo compartment.")
					chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
					tool_ready = 0
					chassis.cell.use(energy_drain)
					O.anchored = 1
					var/T = chassis.loc
					spawn(tool_cooldown)
						if(chassis)
							if(T == chassis.loc && src == chassis.selected_tool)
								cargo_holder.cargo += O
								O.loc = chassis
								O.anchored = 0
								if(istype(O, /obj/machinery/bot))// That's shit-code right here, folks.
									O:on = 0
								chassis.occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
								chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
							else
								chassis.occupant_message("<font color='red'>You must hold still while handling objects.</font>")
								O.anchored = initial(O.anchored)
							tool_ready = 1

				else
					chassis.occupant << "<font color='red'>Not enough room in cargo compartment.</font>"
			else
				chassis.occupant << "<font color='red'>[target] is firmly secured.</font>"

		else if(istype(target,/mob))
			var/mob/M = target
			if(M.stat>1) return
			if(chassis.occupant.a_intent == "hurt")
				M.bruteloss += force
				M.oxyloss += round(force/2)
				M.updatehealth()
				chassis.occupant_message("\red You squeese [target] with [src.name]. Something cracks.")
				chassis.visible_message("\red [chassis] squeeses [target].")
			else
				step_away(M,chassis)
				chassis.occupant_message("You push [target] out of the way.")
				chassis.visible_message("[chassis] pushes [target] out of the way.")
			tool_ready = 0
			chassis.cell.use(energy_drain)
			spawn(tool_cooldown)
				tool_ready = 1
		return

/datum/mecha_tool/drill
	name = "Drill"
	tool_cooldown = 40
	energy_drain = 20
	var/force = 15

	action(atom/target)
		if(!..()) return
		tool_ready = 0
		chassis.cell.use(energy_drain)
		chassis.visible_message("<font color='red'><b>[chassis] starts to drill [target]</b></font>", "You hear the drill.")
		chassis.occupant_message("<font color='red'><b>You start to drill [target]</b></font>")
		var/T = chassis.loc
		spawn(tool_cooldown)
			if(chassis)
				if(T == chassis.loc && src == chassis.selected_tool)
					if(istype(target, /turf/simulated/wall/r_wall))
						chassis.occupant_message("<font color='red'>[target] is too durable to drill through.</font>")
					else if(istype(target, /turf/simulated/mineral))
						var/turf/simulated/mineral/M = target
						chassis.log_message("Drilled through [target]")
						M.gets_drilled()
					else
						chassis.log_message("Drilled through [target]")
						target.ex_act(2)
				tool_ready = 1
		return


/datum/mecha_tool/extinguisher
	name = "Extinguisher"
	tool_cooldown = 7
	energy_drain = 0
	var/datum/reagents/reagents


	New()
		reagents = new/datum/reagents(200)
		reagents.my_atom = src
		reagents.add_reagent("water", 200)
		..()
		return

	action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
		if(!..()) return
		if(get_dist(chassis, target)>2) return
		tool_ready = 0
		spawn(tool_cooldown)
			tool_ready = 1
		if(istype(target, /obj/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
			var/obj/o = target
			o.reagents.trans_to(src, 200)
			chassis.occupant_message("\blue Extinguisher refilled")
			playsound(chassis, 'refill.ogg', 50, 1, -6)
		else
			if(src.reagents.total_volume > 0)
				playsound(chassis, 'extinguish.ogg', 75, 1, -3)
				var/direction = get_dir(chassis,target)
				var/turf/T = get_turf(target)
				var/turf/T1 = get_step(T,turn(direction, 90))
				var/turf/T2 = get_step(T,turn(direction, -90))

				var/list/the_targets = list(T,T1,T2)
				for(var/a=0, a<5, a++)
					spawn(0)
						var/obj/effects/water/W = new /obj/effects/water(get_turf(chassis))
						if(!W)
							return
						var/turf/my_target = pick(the_targets)
						var/datum/reagents/R = new/datum/reagents(5)
						W.reagents = R
						R.my_atom = W
						src.reagents.trans_to(W,1)
						for(var/b=0, b<5, b++)
							if(!W)
								return
							step_towards(W,my_target)
							if(!W)
								return
							var/turf/W_turf = get_turf(W)
							W.reagents.reaction(W_turf)
							for(var/atom/atm in W_turf)
								W.reagents.reaction(atm)
							if(W.loc == my_target)
								break
							sleep(2)
		return

	get_tool_info()
		return "[src.name] \[[src.reagents.total_volume]\]"

	proc/on_reagent_change()
		return


/*
/datum/mecha_tool/gimmick
	name = "Gimmick"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 10
	var/real_tool_type
	var/real_tool_obj

	action(atom/target)
		if(!..()) return
		target.attackby(real_tool_obj,chassis.occupant)
		tool_ready = 0
		chassis.cell.use(energy_drain)
		spawn(tool_cooldown)
			tool_ready = 1
		return

	New()
		..()
		real_tool_obj = new real_tool_type(chassis)
		return

/datum/mecha_tool/gimmick/screwdriver
	name = "Screwdriver"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 10
	real_tool_type =  /obj/item/weapon/screwdriver


/datum/mecha_tool/gimmick/wrench
	name = "Wrench"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 10
	real_tool_type = /obj/item/weapon/wrench

/datum/mecha_tool/gimmick/wirecutters
	name = "Wirecutters"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 10
	real_tool_type = /obj/item/weapon/wirecutters

/datum/mecha_tool/gimmick/multitool
	name = "Multitool"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 10
	real_tool_type = /obj/item/device/multitool

/datum/mecha_tool/gimmick/crowbar
	name = "Crowbar"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 10
	real_tool_type = /obj/item/weapon/crowbar

/datum/mecha_tool/gimmick/weldingtool
	name = "Weldingtool"
	tool_cooldown = 10
	tool_ready = 1
	energy_drain = 15
	real_tool_type = /obj/item/weapon/weldingtool

	action(atom/target)
		var/obj/item/weapon/weldingtool/W = real_tool_obj
		W.welding = 1
		W.reagents.add_reagent("fuel", W.reagents.maximum_volume - W.get_fuel())
		..()
		return
*/




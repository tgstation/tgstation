/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	name = "Hydraulic Clamp"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder

	can_attach(obj/mecha/M as obj)
		if(..())
			if(istype(M, /obj/mecha/working/ripley))
				return 1
		return 0

	attach(obj/mecha/M as obj)
		..()
		cargo_holder = M
		return

	action(atom/target)
		if(!action_checks(target)) return
		if(!cargo_holder) return
		if(istype(target,/obj))
			var/obj/O = target
			if(!O.anchored)
				if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
					chassis.occupant_message("You lift [target] and start to load it into cargo compartment.")
					chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
					equip_ready = 0
					chassis.cell.use(energy_drain)
					O.anchored = 1
					var/T = chassis.loc
					if(do_after_cooldown())
						if(T == chassis.loc && src == chassis.selected)
							cargo_holder.cargo += O
							O.loc = chassis
							O.anchored = 0
							/*
							if(istype(O, /obj/machinery/bot))// That's shit-code right here, folks.
								O:on = 0
							*/
							chassis.occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
							chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
						else
							chassis.occupant_message("<font color='red'>You must hold still while handling objects.</font>")
							O.anchored = initial(O.anchored)
						equip_ready = 1

				else
					chassis.occupant_message("<font color='red'>Not enough room in cargo compartment.</font>")
			else
				chassis.occupant_message("<font color='red'>[target] is firmly secured.</font>")

		else if(istype(target,/mob))
			var/mob/M = target
			if(M.stat>1) return
			if(chassis.occupant.a_intent == "hurt")
				M.bruteloss += dam_force
				M.oxyloss += round(dam_force/2)
				M.updatehealth()
				chassis.occupant_message("\red You squeese [target] with [src.name]. Something cracks.")
				chassis.visible_message("\red [chassis] squeeses [target].")
			else
				step_away(M,chassis)
				chassis.occupant_message("You push [target] out of the way.")
				chassis.visible_message("[chassis] pushes [target] out of the way.")
			equip_ready = 0
			chassis.cell.use(energy_drain)
			spawn(equip_cooldown)
				equip_ready = 1
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill
	name = "Drill"
	icon_state = "mecha_drill"
	equip_cooldown = 40
	energy_drain = 20
	force = 15

	action(atom/target)
		if(!action_checks(target)) return
		equip_ready = 0
		chassis.cell.use(energy_drain)
		chassis.visible_message("<font color='red'><b>[chassis] starts to drill [target]</b></font>", "You hear the drill.")
		chassis.occupant_message("<font color='red'><b>You start to drill [target]</b></font>")
		var/T = chassis.loc
		if(do_after_cooldown())
			if(T == chassis.loc && src == chassis.selected)
				if(istype(target, /turf/simulated/wall/r_wall))
					chassis.occupant_message("<font color='red'>[target] is too durable to drill through.</font>")
				else if(istype(target, /turf/simulated/mineral))
					var/turf/simulated/mineral/M = target
					chassis.log_message("Drilled through [target]")
					M.gets_drilled()
					for(var/turf/simulated/mineral/N in range(chassis,1))
						if(get_dir(chassis,N)&chassis.dir)
							N.gets_drilled()
				else
					chassis.log_message("Drilled through [target]")
					target.ex_act(2)
			equip_ready = 1
		return 1


/obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	name = "Extinguisher"
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0

	New()
		reagents = new/datum/reagents(200)
		reagents.my_atom = src
		reagents.add_reagent("water", 200)
		..()
		return

	action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
		if(!action_checks(target)) return
		if(get_dist(chassis, target)>2) return
		equip_ready = 0
		if(do_after_cooldown())
			equip_ready = 1
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
		return 1

	get_equip_info()
		return "[..()] \[[src.reagents.total_volume]\]"

	on_reagent_change()
		return


/obj/item/mecha_parts/mecha_equipment/tool/rcd
	name = "Mounted RCD"
	icon_state = "mecha_rcd"
	equip_cooldown = 20
	energy_drain = 250
	ranged = 1
	construction_time = 1200
	construction_cost = list("metal"=50000,"plasma"=40000,"silver"=30000,"gold"=20000)
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/disabled = 0 //malf

	action(atom/target)
		if(!action_checks(target) || disabled || get_dist(chassis, target)>3) return
		playsound(src.loc, 'click.ogg', 50, 1)
		//meh
		switch(mode)
			if(0)
				if (istype(target, /turf/simulated/wall))
					chassis.occupant_message("Deconstructing [target]...")
					equip_ready = 0
					if(do_after_cooldown())
						if(disabled) return
						chassis.spark_system.start()
						target:ReplaceWithFloor()
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						equip_ready = 1
						chassis.cell.give(energy_drain)
				else if (istype(target, /turf/simulated/floor))
					chassis.occupant_message("Deconstructing [target]...")
					equip_ready = 0
					if(do_after_cooldown())
						if(disabled) return
						chassis.spark_system.start()
						target:ReplaceWithSpace()
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						equip_ready = 1
						chassis.cell.give(energy_drain)
				else if (istype(target, /obj/machinery/door/airlock))
					chassis.occupant_message("Deconstructing [target]...")
					equip_ready = 0
					if(do_after_cooldown())
						if(disabled) return
						chassis.spark_system.start()
						del(target)
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						equip_ready = 1
						chassis.cell.give(energy_drain)
			if(1)
				if(istype(target, /turf/space))
					chassis.occupant_message("Building Floor...")
					equip_ready = 0
					if(do_after_cooldown())
						if(disabled) return
						target:ReplaceWithFloor()
						playsound(chassis.loc, 'Deconstruct.ogg', 50, 1)
						chassis.spark_system.start()
						equip_ready = 1
						chassis.cell.use(energy_drain*3)
				else if(istype(target, /turf/simulated/floor))
					chassis.occupant_message("Building Wall...")
					equip_ready = 0
					if(do_after_cooldown())
						if(disabled) return
						target:ReplaceWithWall()
						playsound(chassis.loc, 'Deconstruct.ogg', 50, 1)
						chassis.spark_system.start()
						equip_ready = 1
						chassis.cell.use(energy_drain*3)
			if(2)
				if(istype(target, /turf/simulated/floor))
					chassis.occupant_message("Building Airlock...")
					equip_ready = 0
					if(do_after_cooldown())
						if(disabled) return
						chassis.spark_system.start()
						var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
						T.autoclose = 1
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						playsound(src.loc, 'sparks2.ogg', 50, 1)
						equip_ready = 1
						chassis.cell.use(energy_drain*3)
		return


	Topic(href,href_list)
		..()
		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			switch(mode)
				if(0)
					chassis.occupant_message("Swithed RCD to Deconstruct.")
				if(1)
					chassis.occupant_message("Swithed RCD to Construct.")
				if(2)
					chassis.occupant_message("Swithed RCD to Construct Airlock.")
		return

	get_equip_info()
		return "[..()] \[<a href='?src=\ref[src];mode=0'>D</a>|<a href='?src=\ref[src];mode=1'>C</a>|<a href='?src=\ref[src];mode=2'>A</a>\]"




/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "Teleporter"
	icon_state = "mecha_teleport"
	equip_cooldown = 300
	energy_drain = 1000
	ranged = 1

	action(atom/target)
		if(!action_checks(target)) return
		var/turf/T = get_turf(target)
		if(T)
			equip_ready = 0
			do_teleport(chassis, T, 4)
			if(do_after_cooldown())
				equip_ready = 1
		return


/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "Wormhole Generator"
	icon_state = "mecha_teleport"
	equip_cooldown = 50
	energy_drain = 300
	ranged = 1


	action(atom/target)
		if(!action_checks(target)) return
		var/list/theareas = list()
		for(var/area/AR in orange(100, chassis))
			if(AR in theareas) continue
			theareas += AR
		if(!theareas.len)
			return
		var/area/thearea = pick(theareas)
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T
		if(!L.len)
			return
		var/turf/target_turf = pick(L)
		if(!target_turf)
			return
		chassis.cell.use(energy_drain)
		equip_ready = 0
		var/obj/portal/P = new /obj/portal(get_turf(target))
		P.target = target_turf
		P.creator = null
		P.icon = 'objects.dmi'
		P.failchance = 0
		P.icon_state = "anom"
		P.name = "wormhole"
		if(do_after_cooldown())
			equip_ready = 1
		src = null
		spawn(rand(150,300))
			del(P)
		return
/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	name = "Hydraulic Clamp"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder

	can_attach(obj/mecha/working/ripley/M as obj)
		if(..())
			if(istype(M))
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
					occupant_message("You lift [target] and start to load it into cargo compartment.")
					chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
					set_ready_state(0)
					chassis.use_power(energy_drain)
					O.anchored = 1
					var/T = chassis.loc
					if(do_after_cooldown(target))
						if(T == chassis.loc && src == chassis.selected)
							cargo_holder.cargo += O
							O.loc = chassis
							O.anchored = 0
							occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
							log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
						else
							occupant_message("<font color='red'>You must hold still while handling objects.</font>")
							O.anchored = initial(O.anchored)
				else
					occupant_message("<font color='red'>Not enough room in cargo compartment.</font>")
			else
				occupant_message("<font color='red'>[target] is firmly secured.</font>")

		else if(istype(target,/mob/living))
			var/mob/living/M = target
			if(M.stat>1) return
			if(chassis.occupant.a_intent == "hurt")
				M.take_overall_damage(dam_force)
				M.adjustOxyLoss(round(dam_force/2))
				M.updatehealth()
				occupant_message("\red You squeeze [target] with [src.name]. Something cracks.")
				chassis.visible_message("\red [chassis] squeezes [target].")
			else
				step_away(M,chassis)
				occupant_message("You push [target] out of the way.")
				chassis.visible_message("[chassis] pushes [target] out of the way.")
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_after_cooldown()
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill
	name = "Drill"
	desc = "This is the drill that'll pierce the heavens! (Can be attached to: Combat and Engineering Exosuits)"
	icon_state = "mecha_drill"
	equip_cooldown = 30
	energy_drain = 10
	force = 15

	action(atom/target)
		if(!action_checks(target)) return
		set_ready_state(0)
		chassis.use_power(energy_drain)
		chassis.visible_message("<font color='red'><b>[chassis] starts to drill [target]</b></font>", "You hear the drill.")
		occupant_message("<font color='red'><b>You start to drill [target]</b></font>")
		var/T = chassis.loc
		var/C = target.loc	//why are these backwards? we may never know -Pete
		if(do_after_cooldown(target))
			if(T == chassis.loc && src == chassis.selected)
				if(istype(target, /turf/simulated/wall/r_wall))
					occupant_message("<font color='red'>[target] is too durable to drill through.</font>")
				else if(istype(target, /turf/simulated/mineral))
					for(var/turf/simulated/mineral/M in range(chassis,1))
						if(get_dir(chassis,M)&chassis.dir)
							M.gets_drilled()
					log_message("Drilled through [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/weapon/ore/ore in range(chassis,1))
								if(get_dir(chassis,ore)&chassis.dir)
									ore.Move(ore_box)
				else if(target.loc == C)
					log_message("Drilled through [target]")
					target.ex_act(2)
		return 1

	can_attach(obj/mecha/M as obj)
		if(..())
			if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
				return 1
		return 0

/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	name = "Diamond Drill"
	desc = "This is an upgraded version of the drill that'll pierce the heavens! (Can be attached to: Combat and Engineering Exosuits)"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=3"
	construction_cost = list("metal"=10000,"diamond"=6500)
	equip_cooldown = 20
	force = 15

	action(atom/target)
		if(!action_checks(target)) return
		set_ready_state(0)
		chassis.use_power(energy_drain)
		chassis.visible_message("<font color='red'><b>[chassis] starts to drill [target]</b></font>", "You hear the drill.")
		occupant_message("<font color='red'><b>You start to drill [target]</b></font>")
		var/T = chassis.loc
		var/C = target.loc	//why are these backwards? we may never know -Pete
		if(do_after_cooldown(target))
			if(T == chassis.loc && src == chassis.selected)
				if(istype(target, /turf/simulated/wall/r_wall))
					if(do_after_cooldown(target))//To slow down how fast mechs can drill through the station
						log_message("Drilled through [target]")
						target.ex_act(3)
				else if(istype(target, /turf/simulated/mineral))
					for(var/turf/simulated/mineral/M in range(chassis,1))
						if(get_dir(chassis,M)&chassis.dir)
							M.gets_drilled()
					log_message("Drilled through [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/weapon/ore/ore in range(chassis,1))
								if(get_dir(chassis,ore)&chassis.dir)
									ore.Move(ore_box)
				else if(istype(target,/turf/simulated/floor/plating/airless/asteroid))
					for(var/turf/simulated/floor/plating/airless/asteroid/M in range(target,1))
						M.gets_dug()
					log_message("Drilled through [target]")
					if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
						var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
						if(ore_box)
							for(var/obj/item/weapon/ore/ore in range(chassis,1))
								ore.Move(ore_box)
				else if(target.loc == C)
					log_message("Drilled through [target]")
					target.ex_act(2)
		return 1

	can_attach(obj/mecha/M as obj)
		if(..())
			if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
				return 1
		return 0

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	name = "Extinguisher"
	desc = "Exosuit-mounted extinguisher (Can be attached to: Engineering exosuits)"
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MELEE|RANGED

	New()
		reagents = new/datum/reagents(200)
		reagents.my_atom = src
		reagents.add_reagent("water", 200)
		..()
		return

	action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
		if(!action_checks(target) || get_dist(chassis, target)>3) return
		if(get_dist(chassis, target)>2) return
		set_ready_state(0)
		if(do_after_cooldown(target))
			if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
				var/obj/o = target
				o.reagents.trans_to(src, 200)
				occupant_message("\blue Extinguisher refilled")
				playsound(chassis, 'refill.ogg', 50, 1, -6)
			else
				if(src.reagents.total_volume > 0)
					playsound(chassis, 'extinguish.ogg', 75, 1, -3)
					var/direction = get_dir(chassis,target)
					var/turf/T = get_turf(target)
					var/turf/T1 = get_step(T,turn(direction, 90))
					var/turf/T2 = get_step(T,turn(direction, -90))

					var/list/the_targets = list(T,T1,T2)
					spawn(0)
						for(var/a=0, a<5, a++)
							var/obj/effect/effect/water/W = new /obj/effect/effect/water(get_turf(chassis))
							if(!W)
								return
							var/turf/my_target = pick(the_targets)
							var/datum/reagents/R = new/datum/reagents(5)
							W.reagents = R
							R.my_atom = W
							src.reagents.trans_to(W,1)
							for(var/b=0, b<4, b++)
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

	can_attach(obj/mecha/working/M as obj)
		if(..())
			if(istype(M))
				return 1
		return 0


/obj/item/mecha_parts/mecha_equipment/tool/rcd
	name = "Mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device. (Can be attached to: Any exosuit)"
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MELEE|RANGED
	construction_time = 1200
	construction_cost = list("metal"=30000,"plasma"=25000,"silver"=20000,"gold"=20000)
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/disabled = 0 //malf

	action(atom/target)
		if(istype(target,/area/shuttle)||istype(target, /turf/space/transit))//>implying these are ever made -Sieve
			disabled = 1
		else
			disabled = 0
		if(!istype(target, /turf) && !istype(target, /obj/machinery/door/airlock))
			target = get_turf(target)
		if(!action_checks(target) || disabled || get_dist(chassis, target)>3) return
		playsound(chassis, 'click.ogg', 50, 1)
		//meh
		switch(mode)
			if(0)
				if (istype(target, /turf/simulated/wall))
					occupant_message("Deconstructing [target]...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						target:ReplaceWithPlating()
						playsound(target, 'Deconstruct.ogg', 50, 1)
						chassis.give_power(energy_drain)
				else if (istype(target, /turf/simulated/floor))
					occupant_message("Deconstructing [target]...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						target:ReplaceWithSpace()
						playsound(target, 'Deconstruct.ogg', 50, 1)
						chassis.give_power(energy_drain)
				else if (istype(target, /obj/machinery/door/airlock))
					occupant_message("Deconstructing [target]...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						del(target)
						playsound(target, 'Deconstruct.ogg', 50, 1)
						chassis.give_power(energy_drain)
			if(1)
				if(istype(target, /turf/space))
					occupant_message("Building Floor...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						target:ReplaceWithPlating()
						playsound(target, 'Deconstruct.ogg', 50, 1)
						chassis.spark_system.start()
						chassis.use_power(energy_drain*2)
				else if(istype(target, /turf/simulated/floor))
					occupant_message("Building Wall...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						target:ReplaceWithWall()
						playsound(target, 'Deconstruct.ogg', 50, 1)
						chassis.spark_system.start()
						chassis.use_power(energy_drain*2)
			if(2)
				if(istype(target, /turf/simulated/floor))
					occupant_message("Building Airlock...")
					set_ready_state(0)
					if(do_after_cooldown(target))
						if(disabled) return
						chassis.spark_system.start()
						var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
						T.autoclose = 1
						playsound(target, 'Deconstruct.ogg', 50, 1)
						playsound(target, 'sparks2.ogg', 50, 1)
						chassis.use_power(energy_drain*2)
		return


	Topic(href,href_list)
		..()
		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			switch(mode)
				if(0)
					occupant_message("Switched RCD to Deconstruct.")
				if(1)
					occupant_message("Switched RCD to Construct.")
				if(2)
					occupant_message("Switched RCD to Construct Airlock.")
		return

	get_equip_info()
		return "[..()] \[<a href='?src=\ref[src];mode=0'>D</a>|<a href='?src=\ref[src];mode=1'>C</a>|<a href='?src=\ref[src];mode=2'>A</a>\]"




/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "Teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=10"
	equip_cooldown = 150
	energy_drain = 1000
	range = RANGED

	action(atom/target)
		if(!action_checks(target)) return
		var/turf/T = get_turf(target)
		if(T)
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_teleport(chassis, T, 4)
			do_after_cooldown()
		return


/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "Wormhole Generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	origin_tech = "bluespace=3"
	equip_cooldown = 50
	energy_drain = 300
	range = RANGED


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
		chassis.use_power(energy_drain)
		set_ready_state(0)
		var/obj/effect/portal/P = new /obj/effect/portal(get_turf(target))
		P.target = target_turf
		P.creator = null
		P.icon = 'objects.dmi'
		P.failchance = 0
		P.icon_state = "anom"
		P.name = "wormhole"
		do_after_cooldown()
		src = null
		spawn(rand(150,300))
			del(P)
		return

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "Gravitational Catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=2;magnets=3"
	equip_cooldown = 10
	energy_drain = 100
	range = MELEE|RANGED
	var/atom/movable/locked
	var/mode = 1 //1 - gravsling 2 - gravpush


	action(atom/movable/target)
		switch(mode)
			if(1)
				if(!action_checks(target) && !locked) return
				if(!locked)
					if(!istype(target) || target.anchored)
						occupant_message("Unable to lock on [target]")
						return
					locked = target
					occupant_message("Locked on [target]")
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
					return
				else if(target!=locked)
					if(locked in view(chassis))
						locked.throw_at(target, 14, 1.5)
						locked = null
						send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
						set_ready_state(0)
						chassis.use_power(energy_drain)
						do_after_cooldown()
					else
						locked = null
						occupant_message("Lock on [locked] disengaged.")
						send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
			if(2)
				if(!action_checks(target)) return
				var/list/atoms = list()
				if(isturf(target))
					atoms = range(target,3)
				else
					atoms = orange(target,3)
				for(var/atom/movable/A in atoms)
					if(A.anchored) continue
					spawn(0)
						var/iter = 5-get_dist(A,target)
						for(var/i=0 to iter)
							step_away(A,target)
							sleep(2)
				set_ready_state(0)
				chassis.use_power(energy_drain)
				do_after_cooldown()
		return

	get_equip_info()
		return "[..()] [mode==1?"([locked||"Nothing"])":null] \[<a href='?src=\ref[src];mode=1'>S</a>|<a href='?src=\ref[src];mode=2'>P</a>\]"

	Topic(href, href_list)
		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		return


/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "Armor Booster Module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = "materials=3"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	construction_cost = list("metal"=20000,"silver"=5000)
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8

	can_attach(obj/mecha/M as obj)
		if(..())
			if(!istype(M, /obj/mecha/combat/honker))
				if(!M.proc_res["dynattackby"])
					return 1
		return 0

	attach(obj/mecha/M as obj)
		..()
		chassis.proc_res["dynattackby"] = src
		return

	detach()
		chassis.proc_res["dynattackby"] = null
		..()
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

	proc/dynattackby(obj/item/weapon/W as obj, mob/user as mob)
		if(!action_checks(user))
			return chassis.dynattackby(W,user)
		chassis.log_message("Attacked by [W]. Attacker - [user]")
		if(prob(chassis.deflect_chance*deflect_coeff))
			user << "\red The [W] bounces off [chassis] armor."
			chassis.log_append_to_last("Armor saved.")
		else
			chassis.occupant_message("<font color='red'><b>[user] hits [chassis] with [W].</b></font>")
			user.visible_message("<font color='red'><b>[user] hits [chassis] with [W].</b></font>", "<font color='red'><b>You hit [src] with [W].</b></font>")
			chassis.take_damage(round(W.force*damage_coeff),W.damtype)
			chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
		return


/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "Armor Booster Module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = "materials=4"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	construction_cost = list("metal"=20000,"gold"=5000)
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8

	can_attach(obj/mecha/M as obj)
		if(..())
			if(!istype(M, /obj/mecha/combat/honker))
				if(!M.proc_res["dynbulletdamage"] && !M.proc_res["dynhitby"])
					return 1
		return 0

	attach(obj/mecha/M as obj)
		..()
		chassis.proc_res["dynbulletdamage"] = src
		chassis.proc_res["dynhitby"] = src
		return

	detach()
		chassis.proc_res["dynbulletdamage"] = null
		chassis.proc_res["dynhitby"] = null
		..()
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

	proc/dynbulletdamage(var/obj/item/projectile/Proj)
		if(!action_checks(src))
			return chassis.dynbulletdamage(Proj)
		if(prob(chassis.deflect_chance*deflect_coeff))
			chassis.occupant_message("\blue The armor deflects incoming projectile.")
			chassis.visible_message("The [chassis.name] armor deflects the projectile")
			chassis.log_append_to_last("Armor saved.")
		else
			chassis.take_damage(round(Proj.damage*src.damage_coeff),Proj.flag)
			chassis.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			Proj.on_hit(chassis)
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
		return

	proc/dynhitby(atom/movable/A)
		if(!action_checks(A))
			return chassis.dynhitby(A)
		if(prob(chassis.deflect_chance*deflect_coeff) || istype(A, /mob/living) || istype(A, /obj/item/mecha_parts/mecha_tracking))
			chassis.occupant_message("\blue The [A] bounces off the armor.")
			chassis.visible_message("The [A] bounces off the [chassis] armor")
			chassis.log_append_to_last("Armor saved.")
			if(istype(A, /mob/living))
				var/mob/living/M = A
				M.take_organ_damage(10)
		else if(istype(A, /obj))
			var/obj/O = A
			if(O.throwforce)
				chassis.take_damage(round(O.throwforce*damage_coeff))
				chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
		return


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "Repair Droid"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	origin_tech = "magnets=3;programming=3"
	equip_cooldown = 20
	energy_drain = 100
	range = 0
	construction_cost = list("metal"=10000,"gold"=1000,"silver"=2000,"glass"=5000)
	var/health_boost = 2
	var/datum/global_iterator/pr_repair_droid
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)

	New()
		..()
		pr_repair_droid = new /datum/global_iterator/mecha_repair_droid(list(src),0)
		pr_repair_droid.set_delay(equip_cooldown)
		return

	attach(obj/mecha/M as obj)
		..()
		droid_overlay = new(src.icon, icon_state = "repair_droid")
		M.overlays += droid_overlay
		return

	destroy()
		chassis.overlays -= droid_overlay
		..()
		return

	detach()
		chassis.overlays -= droid_overlay
		pr_repair_droid.stop()
		..()
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_repairs=1'>[pr_repair_droid.active()?"Dea":"A"]ctivate</a>"


	Topic(href, href_list)
		..()
		if(href_list["toggle_repairs"])
			chassis.overlays -= droid_overlay
			if(pr_repair_droid.toggle())
				droid_overlay = new(src.icon, icon_state = "repair_droid_a")
				log_message("Activated.")
			else
				droid_overlay = new(src.icon, icon_state = "repair_droid")
				log_message("Deactivated.")
				set_ready_state(1)
			chassis.overlays += droid_overlay
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		return


/datum/global_iterator/mecha_repair_droid

	process(var/obj/item/mecha_parts/mecha_equipment/repair_droid/RD as obj)
		if(!RD.chassis)
			stop()
			RD.set_ready_state(1)
			return
		var/health_boost = RD.health_boost
		var/repaired = 0
		if(RD.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			health_boost *= -2
		else if(RD.chassis.hasInternalDamage() && prob(15))
			for(var/int_dam_flag in RD.repairable_damage)
				if(RD.chassis.hasInternalDamage(int_dam_flag))
					RD.chassis.clearInternalDamage(int_dam_flag)
					repaired = 1
					break
		if(health_boost<0 || RD.chassis.health < initial(RD.chassis.health))
			RD.chassis.health += min(health_boost, initial(RD.chassis.health)-RD.chassis.health)
			repaired = 1
		if(repaired)
			if(RD.chassis.use_power(RD.energy_drain))
				RD.set_ready_state(0)
			else
				stop()
				RD.set_ready_state(1)
				return
		else
			RD.set_ready_state(1)
		return


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "Energy Relay"
	desc = "Wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	origin_tech = "magnets=4;syndicate=2"
	equip_cooldown = 10
	energy_drain = 0
	range = 0
	construction_cost = list("metal"=10000,"gold"=2000,"silver"=3000,"glass"=2000)
	var/datum/global_iterator/pr_energy_relay
	var/coeff = 100
	var/list/use_channels = list(EQUIP,ENVIRON,LIGHT)

	New()
		..()
		pr_energy_relay = new /datum/global_iterator/mecha_energy_relay(list(src),0)
		pr_energy_relay.set_delay(equip_cooldown)
		return

	detach()
		pr_energy_relay.stop()
		chassis.proc_res["dynusepower"] = null
		chassis.proc_res["dyngetcharge"] = null
		..()
		return

	attach(obj/mecha/M)
		..()
		chassis.proc_res["dyngetcharge"] = src
		chassis.proc_res["dynusepower"] = src
		return

	can_attach(obj/mecha/M)
		if(..())
			if(!M.proc_res["dynusepower"] && !M.proc_res["dyngetcharge"])
				return 1
		return 0

	proc/dyngetcharge()
		if(equip_ready) //disabled
			return chassis.dyngetcharge()
		var/area/A = get_area(chassis)
		var/pow_chan = get_power_channel(A)
		var/charge = 0
		if(pow_chan)
			charge = 1000 //making magic
		return charge

	proc/get_power_channel(var/area/A)
		var/pow_chan
		if(A)
			for(var/c in use_channels)
				if(A.master && A.master.powered(c))
					pow_chan = c
					break
		return pow_chan

	Topic(href, href_list)
		..()
		if(href_list["toggle_relay"])
			if(pr_energy_relay.toggle())
				set_ready_state(0)
				log_message("Activated.")
			else
				set_ready_state(1)
				log_message("Deactivated.")
		return

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_relay=1'>[pr_energy_relay.active()?"Dea":"A"]ctivate</a>"

	proc/dynusepower(amount)
		if(!equip_ready) //enabled
			var/area/A = get_area(chassis)
			var/pow_chan = get_power_channel(A)
			if(pow_chan)
				A.master.use_power(amount*coeff, pow_chan)
				return 1
		return chassis.dynusepower(amount)

/datum/global_iterator/mecha_energy_relay

	process(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/ER)
		if(!ER.chassis || ER.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
			stop()
			ER.set_ready_state(1)
			return
		var/cur_charge = ER.chassis.get_charge()
		if(isnull(cur_charge))
			stop()
			ER.set_ready_state(1)
			ER.occupant_message("No powercell detected.")
			return
		if(cur_charge<ER.chassis.cell.maxcharge)
			var/area/A = get_area(ER.chassis)
			if(A)
				var/pow_chan
				for(var/c in list(EQUIP,ENVIRON,LIGHT))
					if(A.master.powered(c))
						pow_chan = c
						break
				if(pow_chan)
					var/delta = min(2, ER.chassis.cell.maxcharge-cur_charge)
					ER.chassis.give_power(delta)
					A.master.use_power(delta*ER.coeff, pow_chan)
		return



/obj/item/mecha_parts/mecha_equipment/generator
	name = "Plasma Converter"
	desc = "Generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "plasmatech=2;powerstorage=2;engineering=1"
	equip_cooldown = 10
	energy_drain = 0
	range = MELEE
	construction_cost = list("metal"=10000,"silver"=500,"glass"=1000)
	var/datum/global_iterator/pr_mech_generator
	var/coeff = 100
	var/obj/item/stack/sheet/fuel
	var/max_fuel = 150000
	var/fuel_per_cycle_idle = 100
	var/fuel_per_cycle_active = 500
	var/power_per_cycle = 20
	reliability = 1000

	New()
		..()
		init()
		return

	proc/init()
		fuel = new /obj/item/stack/sheet/plasma(src)
		fuel.amount = 0
		pr_mech_generator = new /datum/global_iterator/mecha_generator(list(src),0)
		pr_mech_generator.set_delay(equip_cooldown)
		return

	detach()
		pr_mech_generator.stop()
		..()
		return


	Topic(href, href_list)
		..()
		if(href_list["toggle"])
			if(pr_mech_generator.toggle())
				set_ready_state(0)
				log_message("Activated.")
			else
				set_ready_state(1)
				log_message("Deactivated.")
		return

	get_equip_info()
		var/output = ..()
		if(output)
			return "[output] \[[fuel]: [round(fuel.amount*fuel.perunit,0.1)] cm<sup>3</sup>\] - <a href='?src=\ref[src];toggle=1'>[pr_mech_generator.active()?"Dea":"A"]ctivate</a>"
		return

	action(target)
		if(chassis)
			var/result = load_fuel(target)
			var/message
			if(isnull(result))
				message = "<font color='red'>[fuel] traces in target minimal. [target] cannot be used as fuel.</font>"
			else if(!result)
				message = "Unit is full."
			else
				message = "[result] unit\s of [fuel] successfully loaded."
				send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
			occupant_message(message)
		return

	proc/load_fuel(var/obj/item/stack/sheet/P)
		if(P.type == fuel.type && P.amount)
			var/to_load = max(max_fuel - fuel.amount*fuel.perunit,0)
			if(to_load)
				var/units = min(max(round(to_load / P.perunit),1),P.amount)
				if(units)
					fuel.amount += units
					P.use(units)
					return units
			else
				return 0
		return

	attackby(weapon,mob/user)
		var/result = load_fuel(weapon)
		if(isnull(result))
			user.visible_message("[user] tries to shove [weapon] into [src]. What a dumb-ass.","<font color='red'>[fuel] traces minimal. [weapon] cannot be used as fuel.</font>")
		else if(!result)
			user << "Unit is full."
		else
			user.visible_message("[user] loads [src] with [fuel].","[result] unit\s of [fuel] successfully loaded.")
		return

	critfail()
		..()
		var/turf/simulated/T = get_turf(src)
		if(!T)
			return
		var/datum/gas_mixture/GM = new
		if(prob(10))
			GM.toxins += 100
			GM.temperature = 1500+T0C //should be enough to start a fire
			T.visible_message("The [src] suddenly disgorges a cloud of heated plasma.")
			destroy()
		else
			GM.toxins += 5
			GM.temperature = istype(T) ? T.air.return_temperature() : T20C
			T.visible_message("The [src] suddenly disgorges a cloud of plasma.")
		T.assume_air(GM)
		return

/datum/global_iterator/mecha_generator

	process(var/obj/item/mecha_parts/mecha_equipment/generator/EG)
		if(!EG.chassis)
			stop()
			EG.set_ready_state(1)
			return 0
		if(EG.fuel.amount<=0)
			stop()
			EG.log_message("Deactivated - no fuel.")
			EG.set_ready_state(1)
			return 0
		if(anyprob(EG.reliability))
			EG.critfail()
			stop()
			return 0
		var/cur_charge = EG.chassis.get_charge()
		if(isnull(cur_charge))
			EG.set_ready_state(1)
			EG.occupant_message("No powercell detected.")
			EG.log_message("Deactivated.")
			stop()
			return 0
		var/use_fuel = EG.fuel_per_cycle_idle
		if(cur_charge<EG.chassis.cell.maxcharge)
			use_fuel = EG.fuel_per_cycle_active
			EG.chassis.give_power(EG.power_per_cycle)
		EG.fuel.amount -= min(use_fuel/EG.fuel.perunit,EG.fuel.amount)
		EG.update_equip_info()
		return 1


/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "ExoNuclear Reactor"
	desc = "Generates power using uranium. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "powerstorage=3;engineering=3"
	construction_cost = list("metal"=10000,"silver"=500,"glass"=1000)
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 0.3
	reliability = 1000

	init()
		fuel = new /obj/item/stack/sheet/uranium(src)
		fuel.amount = 0
		pr_mech_generator = new /datum/global_iterator/mecha_generator/nuclear(list(src),0)
		pr_mech_generator.set_delay(equip_cooldown)
		return

	critfail()
		return

/datum/global_iterator/mecha_generator/nuclear

	process(var/obj/item/mecha_parts/mecha_equipment/generator/nuclear/EG)
		if(..())
			for(var/mob/living/carbon/M in view(EG.chassis))
				if(istype(M,/mob/living/carbon/human))
					M.apply_effect((EG.rad_per_cycle*3),IRRADIATE,0)
				else
					M.radiation += EG.rad_per_cycle
		return 1


/obj/item/mecha_parts/mecha_equipment/tool/sleeper
	name = "Mounted Sleeper"
	desc = "Mounted Sleeper. (Can be attached to: Medical Exosuits)"
	icon = 'Cryogenic2.dmi'
	icon_state = "sleeper_0"
	origin_tech = "programming=2;biotech=3"
	energy_drain = 20
	range = MELEE
	construction_cost = list("metal"=5000,"glass"=10000)
	reliability = 1000
	equip_cooldown = 20
	var/mob/living/carbon/occupant = null
	var/datum/global_iterator/pr_mech_sleeper
	var/inject_amount = 10
	salvageable = 0

	can_attach(obj/mecha/medical/M)
		if(..())
			if(istype(M))
				return 1
		return 0

	New()
		..()
		pr_mech_sleeper = new /datum/global_iterator/mech_sleeper(list(src),0)
		pr_mech_sleeper.set_delay(equip_cooldown)
		return

	allow_drop()
		return 0

	destroy()
		for(var/atom/movable/AM in src)
			AM.forceMove(get_turf(src))
		return ..()

	Exit(atom/movable/O)
		return 0

	action(var/mob/living/carbon/target)
		if(!action_checks(target))
			return
		if(!istype(target))
			return
		if(occupant)
			occupant_message("The sleeper is already occupied")
			return
		for(var/mob/living/carbon/metroid/M in range(1,target))
			if(M.Victim == target)
				occupant_message("[target] will not fit into the sleeper because they have a Metroid latched onto their head.")
				return
		occupant_message("You start putting [target] into [src].")
		chassis.visible_message("[chassis] starts putting [target] into the [src].")
		var/C = chassis.loc
		var/T = target.loc
		if(do_after_cooldown(target))
			if(chassis.loc!=C || target.loc!=T)
				return
			if(occupant)
				occupant_message("<font color=\"red\"><B>The sleeper is already occupied!</B></font>")
				return
			target.forceMove(src)
			occupant = target
			target.reset_view(src)
			/*
			if(target.client)
				target.client.perspective = EYE_PERSPECTIVE
				target.client.eye = chassis
			*/
			set_ready_state(0)
			pr_mech_sleeper.start()
			occupant_message("<font color='blue'>[target] successfully loaded into [src]. Life support functions engaged.</font>")
			chassis.visible_message("[chassis] loads [target] into [src].")
			log_message("[target] loaded. Life support functions engaged.")
		return

	proc/go_out()
		if(!occupant)
			return
		occupant.forceMove(get_turf(src))
		occupant_message("[occupant] ejected. Life support functions disabled.")
		log_message("[occupant] ejected. Life support functions disabled.")
		occupant.reset_view()
		/*
		if(occupant.client)
			occupant.client.eye = occupant.client.mob
			occupant.client.perspective = MOB_PERSPECTIVE
		*/
		occupant = null
		pr_mech_sleeper.stop()
		set_ready_state(1)
		return

	detach()
		if(occupant)
			occupant_message("Unable to detach [src] - equipment occupied.")
			return
		pr_mech_sleeper.stop()
		return ..()

	get_equip_info()
		var/output = ..()
		if(output)
			var/temp = ""
			if(occupant)
				temp = "<br />\[Occupant: [occupant] (Health: [occupant.health]%)\]<br /><a href='?src=\ref[src];view_stats=1'>View stats</a>|<a href='?src=\ref[src];eject=1'>Eject</a>"
			return "[output] [temp]"
		return

	Topic(href,href_list)
		..()
		var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
		if(filter.get("eject"))
			go_out()
		if(filter.get("view_stats"))
			chassis.occupant << browse(get_occupant_stats(),"window=msleeper")
			onclose(chassis.occupant, "msleeper")
			return
		if(filter.get("inject"))
			inject_reagent(filter.getType("inject",/datum/reagent),filter.getObj("source"))
		return

	proc/get_occupant_stats()
		if(!occupant)
			return
		return {"<html>
					<head>
					<title>[occupant] statistics</title>
					<script language='javascript' type='text/javascript'>
					[js_byjax]
					</script>
					<style>
					h3 {margin-bottom:2px;font-size:14px;}
					#lossinfo, #reagents, #injectwith {padding-left:15px;}
					</style>
					</head>
					<body>
					<h3>Health statistics</h3>
					<div id="lossinfo">
					[get_occupant_dam()]
					</div>
					<h3>Reagents in bloodstream</h3>
					<div id="reagents">
					[get_occupant_reagents()]
					</div>
					<div id="injectwith">
					[get_available_reagents()]
					</div>
					</body>
					</html>"}

	proc/get_occupant_dam()
		var/t1
		switch(occupant.stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
			else
				t1 = "Unknown"
		return {"<font color="[occupant.health > 50 ? "blue" : "red"]"><b>Health:</b> [occupant.health]% ([t1])</font><br />
					<font color="[occupant.bodytemperature > 50 ? "blue" : "red"]"><b>Core Temperature:</b> [src.occupant.bodytemperature-T0C]&deg;C ([src.occupant.bodytemperature*1.8-459.67]&deg;F)</font><br />
					<font color="[occupant.getBruteLoss() < 60 ? "blue" : "red"]"><b>Brute Damage:</b> [occupant.getBruteLoss()]%</font><br />
					<font color="[occupant.getOxyLoss() < 60 ? "blue" : "red"]"><b>Respiratory Damage:</b> [occupant.getOxyLoss()]%</font><br />
					<font color="[occupant.getToxLoss() < 60 ? "blue" : "red"]"><b>Toxin Content:</b> [occupant.getToxLoss()]%</font><br />
					<font color="[occupant.getFireLoss() < 60 ? "blue" : "red"]"><b>Burn Severity:</b> [occupant.getFireLoss()]%</font><br />
					"}

	proc/get_occupant_reagents()
		if(occupant.reagents)
			for(var/datum/reagent/R in occupant.reagents.reagent_list)
				if(R.volume > 0)
					. += "[R]: [round(R.volume,0.01)]<br />"
		return . || "None"

	proc/get_available_reagents()
		var/output
		var/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun) in chassis
		if(SG && SG.reagents && islist(SG.reagents.reagent_list))
			for(var/datum/reagent/R in SG.reagents.reagent_list)
				if(R.volume > 0)
					output += "<a href=\"?src=\ref[src];inject=\ref[R];source=\ref[SG]\">Inject [R.name]</a><br />"
		return output


	proc/inject_reagent(var/datum/reagent/R,var/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/SG)
		if(!R || !occupant || !SG || !(SG in chassis.equipment))
			return 0
		var/to_inject = min(R.volume, inject_amount)
		if(to_inject && occupant.reagents.get_reagent_amount(R.id) + to_inject <= inject_amount*2)
			SG.reagents.trans_id_to(occupant,R.id,to_inject)
			occupant_message("[occupant] injected with [to_inject] units of [R.name].")
			log_message("[occupant] injected with [to_inject] units of [R.name].")
			update_equip_info()
		return

	update_equip_info()
		if(..())
			send_byjax(chassis.occupant,"msleeper.browser","lossinfo",get_occupant_dam())
			send_byjax(chassis.occupant,"msleeper.browser","reagents",get_occupant_reagents())
			send_byjax(chassis.occupant,"msleeper.browser","injectwith",get_available_reagents())
			return 1
		return

/datum/global_iterator/mech_sleeper

	process(var/obj/item/mecha_parts/mecha_equipment/tool/sleeper/S)
		if(!S.chassis)
			S.set_ready_state(1)
			return stop()
		if(!S.chassis.has_charge(S.energy_drain))
			S.set_ready_state(1)
			S.log_message("Deactivated.")
			S.occupant_message("[src] deactivated - no power.")
			return stop()
		var/mob/living/carbon/M = S.occupant
		if(!M)
			return
		if(M.health > 0)
			M.adjustOxyLoss(-1)
			M.updatehealth()
		M.AdjustStunned(-4)
		M.AdjustWeakened(-4)
		M.AdjustStunned(-4)
		M.Paralyse(2)
		M.Weaken(2)
		M.Stun(2)
		if(M.reagents.get_reagent_amount("inaprovaline") < 5)
			M.reagents.add_reagent("inaprovaline", 5)
		S.chassis.use_power(S.energy_drain)
		S.update_equip_info()
		return


/obj/item/mecha_parts/mecha_equipment/tool/cable_layer
	name = "Cable Layer"
	icon_state = "mecha_wire"
	var/datum/event/event
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/weapon/cable_coil/cable
	var/max_cable = 1000

	New()
		cable = new(src)
		cable.amount = 0
		..()

	can_attach(obj/mecha/working/M)
		if(..())
			if(istype(M))
				return 1
		return 0

	attach()
		..()
		event = chassis.events.addEvent("onMove",src,"layCable")
		return

	detach()
		chassis.events.clearEvent("onMove",event)
		return ..()

	destroy()
		chassis.events.clearEvent("onMove",event)
		return ..()

	action(var/obj/item/weapon/cable_coil/target)
		if(!action_checks(target))
			return
		var/result = load_cable(target)
		var/message
		if(isnull(result))
			message = "<font color='red'>Unable to load [target] - no cable found.</font>"
		else if(!result)
			message = "Reel is full."
		else
			message = "[result] meters of cable successfully loaded."
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		occupant_message(message)
		return

	Topic(href,href_list)
		..()
		if(href_list["toggle"])
			set_ready_state(!equip_ready)
			occupant_message("[src] [equip_ready?"dea":"a"]ctivated.")
			log_message("[equip_ready?"Dea":"A"]ctivated.")
			return
		if(href_list["cut"])
			if(cable && cable.amount)
				var/m = round(input(chassis.occupant,"Please specify the length of cable to cut","Cut cable",min(cable.amount,30)) as num, 1)
				m = min(m, cable.amount)
				if(m)
					use_cable(m)
					var/obj/item/weapon/cable_coil/CC = new (get_turf(chassis))
					CC.amount = m
			else
				occupant_message("There's no more cable on the reel.")
		return

	get_equip_info()
		var/output = ..()
		if(output)
			return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=\ref[src];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=\ref[src];cut=1'>Cut</a>" : null]"
		return

	proc/load_cable(var/obj/item/weapon/cable_coil/CC)
		if(istype(CC) && CC.amount)
			var/cur_amount = cable? cable.amount : 0
			var/to_load = max(max_cable - cur_amount,0)
			if(to_load)
				to_load = min(CC.amount, to_load)
				if(!cable)
					cable = new(src)
					cable.amount = 0
				cable.amount += to_load
				CC.use(to_load)
				return to_load
			else
				return 0
		return

	proc/use_cable(amount)
		if(!cable || cable.amount<1)
			set_ready_state(1)
			occupant_message("Cable depleted, [src] deactivated.")
			log_message("Cable depleted, [src] deactivated.")
			return
		if(cable.amount < amount)
			occupant_message("No enough cable to finish the task.")
			return
		cable.use(amount)
		update_equip_info()
		return 1

	proc/reset()
		last_piece = null

	proc/dismantleFloor(var/turf/new_turf)
		if(istype(new_turf, /turf/simulated/floor))
			var/turf/simulated/floor/T = new_turf
			if(!T.is_plating())
				if(!T.broken && !T.burnt)
					new T.floor_tile.type(T)
				T.make_plating()
		return !new_turf.intact

	proc/layCable(var/turf/new_turf)
		if(equip_ready || !istype(new_turf) || !dismantleFloor(new_turf))
			return reset()
		var/fdirn = turn(chassis.dir,180)
		for(var/obj/structure/cable/LC in new_turf)		// check to make sure there's not a cable there already
			if(LC.d1 == fdirn || LC.d2 == fdirn)
				return reset()
		if(!use_cable(1))
			return reset()
		var/obj/structure/cable/NC = new(new_turf)
		NC.cableColor("red")
		NC.d1 = 0
		NC.d2 = fdirn
		NC.updateicon()
		var/netnum
		var/datum/powernet/PN
		if(last_piece && last_piece.d2 != chassis.dir)
			last_piece.d1 = min(last_piece.d2, chassis.dir)
			last_piece.d2 = max(last_piece.d2, chassis.dir)
			last_piece.updateicon()
			netnum = last_piece.netnum
		if(netnum)
			NC.netnum = netnum
			PN = powernets[netnum]
		else
			PN = new()
			PN.number = powernets.len + 1
			powernets += PN
			NC.netnum = PN.number
		PN.cables += NC
		NC.mergeConnectedNetworks(NC.d2)
		//NC.mergeConnectedNetworksOnTurf()
		last_piece = NC
		return 1

/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	name = "Syringe Gun"
	desc = "Exosuit-mounted chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur. (Can be attached to: Medical Exosuits)"
	icon = 'gun.dmi'
	icon_state = "syringegun"
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/mode = 0 //0 - fire syringe, 1 - analyze reagents.
	var/datum/global_iterator/mech_synth/synth
	range = MELEE|RANGED
	equip_cooldown = 10
	origin_tech = "materials=3;biotech=4;magnets=4;programming=3"
	construction_time = 200
	construction_cost = list("metal"=3000,"glass"=2000)

	New()
		..()
		flags |= NOREACT
		syringes = new
		known_reagents = list("inaprovaline"="Inaprovaline","anti_toxin"="Anti-Toxin (Dylovene)")
		processed_reagents = new
		create_reagents(max_volume)
		synth = new (list(src),0)

	detach()
		synth.stop()
		return ..()

	critfail()
		..()
		flags &= ~NOREACT
		return

	can_attach(obj/mecha/medical/M)
		if(..())
			if(istype(M))
				return 1
		return 0

	get_equip_info()
		var/output = ..()
		if(output)
			return "[output] \[<a href=\"?src=\ref[src];toggle_mode=1\">[mode? "Analyze" : "Launch"]</a>\]<br />\[Syringes: [syringes.len]/[max_syringes] | Reagents: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='?src=\ref[src];show_reagents=1'>Reagents list</a>"
		return

	action(atom/movable/target)
		if(!action_checks(target))
			return
		if(istype(target,/obj/item/weapon/reagent_containers/syringe))
			return load_syringe(target)
		if(mode)
			return analyze_reagents(target)
		if(!syringes.len)
			occupant_message("<span class=\"alert\">No syringes loaded.</span>")
			return
		if(reagents.total_volume<=0)
			occupant_message("<span class=\"alert\">No available reagents to load syringe with.</span>")
			return
		set_ready_state(0)
		chassis.use_power(energy_drain)
		var/turf/trg = get_turf(target)
		var/obj/item/weapon/reagent_containers/syringe/S = syringes[1]
		S.forceMove(get_turf(chassis))
		reagents.trans_to(S, min(S.volume, reagents.total_volume))
		syringes -= S
		S.icon = 'chemical.dmi'
		S.icon_state = "syringeproj"
		playsound(chassis, 'syringeproj.ogg', 50, 1)
		log_message("Launched [S] from [src], targeting [target].")
		spawn(-1)
			src = null //if src is deleted, still process the syringe
			for(var/i=0, i<6, i++)
				if(!S)
					break
				if(step_towards(S,trg))
					var/list/mobs = new
					for(var/mob/living/carbon/M in S.loc)
						mobs += M
					var/mob/living/carbon/M = safepick(mobs)
					if(M)
						S.icon_state = initial(S.icon_state)
						S.icon = initial(S.icon)
						S.reagents.trans_to(M, S.reagents.total_volume)
						M.take_organ_damage(2)
						S.visible_message("<span class=\"attack\"> [M] was hit by the syringe!</span>")
						break
					else if(S.loc == trg)
						S.icon_state = initial(S.icon_state)
						S.icon = initial(S.icon)
						S.update_icon()
						break
				else
					S.icon_state = initial(S.icon_state)
					S.icon = initial(S.icon)
					S.update_icon()
					break
				sleep(1)
		do_after_cooldown()
		return 1


	Topic(href,href_list)
		..()
		var/datum/topic_input/filter = new (href,href_list)
		if(filter.get("toggle_mode"))
			mode = !mode
			update_equip_info()
			return
		if(filter.get("select_reagents"))
			processed_reagents.len = 0
			var/m = 0
			var/message
			for(var/i=1 to known_reagents.len)
				if(m>=synth_speed)
					break
				var/reagent = filter.get("reagent_[i]")
				if(reagent && (reagent in known_reagents))
					message = "[m ? ", " : null][known_reagents[reagent]]"
					processed_reagents += reagent
					m++
			if(processed_reagents.len)
				message += " added to production"
				synth.start()
				occupant_message(message)
				occupant_message("Reagent processing started.")
				log_message("Reagent processing started.")
			return
		if(filter.get("show_reagents"))
			chassis.occupant << browse(get_reagents_page(),"window=msyringegun")
		if(filter.get("purge_reagent"))
			var/reagent = filter.get("purge_reagent")
			if(reagent)
				reagents.del_reagent(reagent)
			return
		if(filter.get("purge_all"))
			reagents.clear_reagents()
			return
		return

	proc/get_reagents_page()
		var/output = {"<html>
							<head>
							<title>Reagent Synthesizer</title>
							<script language='javascript' type='text/javascript'>
							[js_byjax]
							</script>
							<style>
							h3 {margin-bottom:2px;font-size:14px;}
							#reagents, #reagents_form {}
							form {width: 90%; margin:10px auto; border:1px dotted #999; padding:6px;}
							#submit {margin-top:5px;}
							</style>
							</head>
							<body>
							<h3>Current reagents:</h3>
							<div id="reagents">
							[get_current_reagents()]
							</div>
							<h3>Reagents production:</h3>
							<div id="reagents_form">
							[get_reagents_form()]
							</div>
							</body>
							</html>
							"}
		return output

	proc/get_reagents_form()
		var/r_list = get_reagents_list()
		var/inputs
		if(r_list)
			inputs += "<input type=\"hidden\" name=\"src\" value=\"\ref[src]\">"
			inputs += "<input type=\"hidden\" name=\"select_reagents\" value=\"1\">"
			inputs += "<input id=\"submit\" type=\"submit\" value=\"Apply settings\">"
		var/output = {"<form action="byond://" method="get">
							[r_list || "No known reagents"]
							[inputs]
							</form>
							[r_list? "<span style=\"font-size:80%;\">Only the first [synth_speed] selected reagent\s will be added to production</span>" : null]
							"}
		return output

	proc/get_reagents_list()
		var/output
		for(var/i=1 to known_reagents.len)
			var/reagent_id = known_reagents[i]
			output += {"<input type="checkbox" value="[reagent_id]" name="reagent_[i]" [(reagent_id in processed_reagents)? "checked=\"1\"" : null]> [known_reagents[reagent_id]]<br />"}
		return output

	proc/get_current_reagents()
		var/output
		for(var/datum/reagent/R in reagents.reagent_list)
			if(R.volume > 0)
				output += "[R]: [round(R.volume,0.001)] - <a href=\"?src=\ref[src];purge_reagent=[R.id]\">Purge Reagent</a><br />"
		if(output)
			output += "Total: [round(reagents.total_volume,0.001)]/[reagents.maximum_volume] - <a href=\"?src=\ref[src];purge_all=1\">Purge All</a>"
		return output || "None"

	proc/load_syringe(obj/item/weapon/reagent_containers/syringe/S)
		if(syringes.len<max_syringes)
			S.reagents.trans_to(src, S.reagents.total_volume)
			S.forceMove(src)
			syringes += S
			occupant_message("Syringe loaded.")
			update_equip_info()
			return 1
		occupant_message("The [src] syringe chamber is full.")
		return 0

	proc/analyze_reagents(atom/A)
		if(!A.reagents)
			occupant_message("<span class=\"alert\">No reagent info gained from [A].</span>")
			return 0
		occupant_message("Analyzing reagents...")
		for(var/datum/reagent/R in A.reagents.reagent_list)
			if(R.reagent_state == 2 && add_known_reagent(R.id,R.name))
				occupant_message("Reagent analyzed, identified as [R.name] and added to database.")
				send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
		occupant_message("Analyzis complete.")
		return 1

	proc/add_known_reagent(r_id,r_name)
		set_ready_state(0)
		do_after_cooldown()
		if(!(r_id in known_reagents))
			known_reagents += r_id
			known_reagents[r_id] = r_name
			return 1
		return 0


	update_equip_info()
		if(..())
			send_byjax(chassis.occupant,"msyringegun.browser","reagents",get_current_reagents())
			send_byjax(chassis.occupant,"msyringegun.browser","reagents_form",get_reagents_form())
			return 1
		return

	on_reagent_change()
		..()
		update_equip_info()
		return

/datum/global_iterator/mech_synth
	delay = 100

	process(var/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun/S)
		if(!S.chassis)
			return stop()
		var/energy_drain = S.energy_drain*10
		if(!S.processed_reagents.len || S.reagents.total_volume >= S.reagents.maximum_volume || !S.chassis.has_charge(energy_drain))
			S.occupant_message("<span class=\"alert\">Reagent processing stopped.</a>")
			S.log_message("Reagent processing stopped.")
			return stop()
		if(anyprob(S.reliability))
			S.critfail()
		var/amount = S.synth_speed / S.processed_reagents.len
		for(var/reagent in S.processed_reagents)
			S.reagents.add_reagent(reagent,amount)
			S.chassis.use_power(energy_drain)
		return 1


/*
/obj/item/mecha_parts/mecha_equipment/defence_shocker
	name = "Exosuit Defence Shocker"
	desc = ""
	icon_state = "mecha_teleport"
	equip_cooldown = 10
	energy_drain = 100
	range = RANGED
	var/shock_damage = 15
	var/active

	can_attach(obj/mecha/M as obj)
		if(..())
			if(!istype(M, /obj/mecha/combat/honker))
				if(!M.proc_res["dynattackby"] && !M.proc_res["dynattackhand"] && !M.proc_res["dynattackalien"])
					return 1
		return 0

	attach(obj/mecha/M as obj)
		..()
		chassis.proc_res["dynattackby"] = src
		return

	proc/dynattackby(obj/item/weapon/W as obj, mob/user as mob)
		if(!action_checks(user) || !active)
			return
		user.electrocute_act(shock_damage, src)
		return chassis.dynattackby(W,user)
*/

/*
/obj/item/mecha_parts/mecha_equipment/book_stocker

	action(var/mob/target)
		if(!istype(target))
			return
		if(target.search_contents_for(/obj/item/book/WGW))
			target.gib()
			target.client.gib()
			target.client.mom.monkeyize()
			target.client.mom.gib()
			for(var/mob/M in range(target, 1000))
				M.gib()
			explosion(target.loc,100000,100000,100000)
			usr.gib()
			world.Reboot()
			return 1

*/

//This is pretty much just for the death-ripley so that it is harmless
/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	name = "KILL CLAMP"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 0
	var/dam_force = 0
	var/obj/mecha/working/ripley/cargo_holder

	can_attach(obj/mecha/working/ripley/M as obj)
		if(..())
			if(istype(M))
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
					set_ready_state(0)
					chassis.use_power(energy_drain)
					O.anchored = 1
					var/T = chassis.loc
					if(do_after_cooldown(target))
						if(T == chassis.loc && src == chassis.selected)
							cargo_holder.cargo += O
							O.loc = chassis
							O.anchored = 0
							chassis.occupant_message("<font color='blue'>[target] succesfully loaded.</font>")
							chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
						else
							chassis.occupant_message("<font color='red'>You must hold still while handling objects.</font>")
							O.anchored = initial(O.anchored)
				else
					chassis.occupant_message("<font color='red'>Not enough room in cargo compartment.</font>")
			else
				chassis.occupant_message("<font color='red'>[target] is firmly secured.</font>")

		else if(istype(target,/mob/living))
			var/mob/living/M = target
			if(M.stat>1) return
			if(chassis.occupant.a_intent == "hurt")
				chassis.occupant_message("\red You obliterate [target] with [src.name], leaving blood and guts everywhere.")
				chassis.visible_message("\red [chassis] destroys [target] in an unholy fury.")
			if(chassis.occupant.a_intent == "disarm")
				chassis.occupant_message("\red You tear [target]'s limbs off with [src.name].")
				chassis.visible_message("\red [chassis] rips [target]'s arms off.")
			else
				step_away(M,chassis)
				chassis.occupant_message("You smash into [target], sending them flying.")
				chassis.visible_message("[chassis] tosses [target] like a piece of paper.")
			set_ready_state(0)
			chassis.use_power(energy_drain)
			do_after_cooldown()
		return 1

/*
//NEEDS SPRITE! (When this gets uncommented search for 'TODO MECHA JETPACK SPRITE MISSING' through code to uncomment the place where it's missing.)
/obj/item/mecha_parts/mecha_equipment/jetpack
	name = "Jetpack"
	desc = "Using directed ion bursts and cunning solar wind reflection technique, this device enables controlled space flight."
	icon_state = "mecha_equip"
	equip_cooldown = 5
	energy_drain = 50
	var/wait = 0
	var/datum/effect/effect/system/ion_trail_follow/ion_trail


	can_attach(obj/mecha/M as obj)
		if(!(locate(src.type) in M.equipment) && !M.proc_res["dyndomove"])
			return ..()

	detach()
		..()
		chassis.proc_res["dyndomove"] = null
		return

	attach(obj/mecha/M as obj)
		..()
		if(!ion_trail)
			ion_trail = new
		ion_trail.set_up(chassis)
		return

	proc/toggle()
		if(!chassis)
			return
		!equip_ready? turn_off() : turn_on()
		return equip_ready

	proc/turn_on()
		set_ready_state(0)
		chassis.proc_res["dyndomove"] = src
		ion_trail.start()
		occupant_message("Activated")
		log_message("Activated")

	proc/turn_off()
		set_ready_state(1)
		chassis.proc_res["dyndomove"] = null
		ion_trail.stop()
		occupant_message("Deactivated")
		log_message("Deactivated")

	proc/dyndomove(direction)
		if(!action_checks())
			return chassis.dyndomove(direction)
		var/move_result = 0
		if(chassis.hasInternalDamage(MECHA_INT_CONTROL_LOST))
			move_result = step_rand(chassis)
		else if(chassis.dir!=direction)
			chassis.dir = direction
			move_result = 1
		else
			move_result	= step(chassis,direction)
			if(chassis.occupant)
				for(var/obj/effect/speech_bubble/B in range(1, chassis))
					if(B.parent == chassis.occupant)
						B.loc = chassis.loc
		if(move_result)
			wait = 1
			chassis.use_power(energy_drain)
			if(!chassis.pr_inertial_movement.active())
				chassis.pr_inertial_movement.start(list(chassis,direction))
			else
				chassis.pr_inertial_movement.set_process_args(list(chassis,direction))
			do_after_cooldown()
			return 1
		return 0

	action_checks()
		if(equip_ready || wait)
			return 0
		if(energy_drain && !chassis.has_charge(energy_drain))
			return 0
		if(crit_fail)
			return 0
		if(chassis.check_for_support())
			return 0
		return 1

	get_equip_info()
		if(!chassis) return
		return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] \[<a href=\"?src=\ref[src];toggle=1\">Toggle</a>\]"


	Topic(href,href_list)
		..()
		if(href_list["toggle"])
			toggle()

	do_after_cooldown()
		sleep(equip_cooldown)
		wait = 0
		return 1
*/


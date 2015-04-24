/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/can_attach(obj/mecha/working/ripley/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/attach(obj/mecha/M as obj)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/detach(atom/moveto = null)
	..()
	if(can_attach(chassis))
		cargo_holder = chassis
	else
		cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/action(atom/target)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
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
						occupant_message("<span class='notice'>[target] successfully loaded.</span>")
						log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
					else
						occupant_message("<span class='warning'>You must hold still while handling objects.</span>")
						O.anchored = initial(O.anchored)
			else
				occupant_message("<span class='warning'>Not enough room in cargo compartment.</span>")
		else
			occupant_message("<span class='warning'>[target] is firmly secured.</span>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat>1) return
		if(chassis.occupant.a_intent == "harm")
			M.take_overall_damage(dam_force)
			if(!M)
				return
			M.adjustOxyLoss(round(dam_force/2))
			M.updatehealth()
			target.visible_message("<span class='danger'>[chassis] squeezes [target].</span>", \
								"<span class='userdanger'>[chassis] squeezes [target].</span>",\
								"You hear something crack")
			add_logs(chassis.occupant, M, "attacked", object="[name]", addition="(INTENT: [uppertext(chassis.occupant.a_intent)]) (DAMTYE: [uppertext(damtype)])")
		else
			step_away(M,chassis)
			occupant_message("You push [target] out of the way.")
			chassis.visible_message("[chassis] pushes [target] out of the way.")
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill
	name = "exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is the drill that'll pierce the heavens!"
	icon_state = "mecha_drill"
	equip_cooldown = 30
	energy_drain = 10
	force = 15

/obj/item/mecha_parts/mecha_equipment/tool/drill/action(atom/target)
	if(!action_checks(target))
		return
	if(isobj(target))
		var/obj/target_obj = target
		if(target_obj.unacidable)
			return
	set_ready_state(0)
	chassis.use_power(energy_drain)
	target.visible_message("<span class='danger'>[chassis] starts to drill [target]</span>", \
					"<span class='userdanger'>[chassis] starts to drill [target]</span>", \
					 "You hear drilling.")
	var/T = chassis.loc
	var/C = target.loc	//why are these backwards? we may never know -Pete
	if(do_after_cooldown(target))
		if(T == chassis.loc && src == chassis.selected)
			if(istype(target, /turf/simulated/wall/r_wall))
				if(istype(src , /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill))
					if(do_after_cooldown(target))//To slow down how fast mechs can drill through the station
						log_message("Drilled through [target]")
						target.ex_act(3)
				else
					occupant_message("<span class='danger'>[target] is too durable to drill through.</span>")
			else if(istype(target, /turf/simulated/mineral))
				for(var/turf/simulated/mineral/M in range(chassis,1))
					if(get_dir(chassis,M)&chassis.dir)
						M.gets_drilled(chassis.occupant)
				log_message("Drilled through [target]")
				if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
					var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
					if(ore_box)
						for(var/obj/item/weapon/ore/ore in range(chassis,1))
							if(get_dir(chassis,ore)&chassis.dir)
								ore.Move(ore_box)
			else if(istype(target, /turf/simulated/floor/plating/asteroid))
				for(var/turf/simulated/floor/plating/asteroid/M in range(chassis,1))
					if(get_dir(chassis,M)&chassis.dir)
						M.gets_dug()
				log_message("Drilled through [target]")
				if(locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in chassis.equipment)
					var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in chassis:cargo
					if(ore_box)
						for(var/obj/item/weapon/ore/ore in range(chassis,1))
							if(get_dir(chassis,ore)&chassis.dir)
								ore.Move(ore_box)
			else if(target.loc == C)
				log_message("Drilled through [target]")
				if(isliving(target))
					if(istype(src , /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill))
						drill_mob(target, chassis.occupant, 120)
					else
						drill_mob(target, chassis.occupant)
				else
					target.ex_act(2)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/drill/can_attach(obj/mecha/M as obj)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/drill/proc/drill_mob(mob/living/target, mob/user, var/drill_damage=80)
	target.visible_message("<span class='danger'>[chassis] drills [target] with [src].</span>", \
						"<span class='userdanger'>[chassis] drills [target] with [src].</span>")
	add_logs(user, target, "attacked", object="[name]", addition="(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/limb/affecting = H.get_organ("chest")
		affecting.take_damage(drill_damage)
		H.update_damage_overlays(0)
	else
		target.take_organ_damage(drill_damage)
	if(target)
		target.Paralyse(10)
		target.updatehealth()

/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	name = "diamond-tipped exosuit drill"
	desc = "Equipment for engineering and combat exosuits. This is an upgraded version of the drill that'll pierce the heavens!"
	icon_state = "mecha_diamond_drill"
	origin_tech = "materials=4;engineering=3"
	equip_cooldown = 20
	force = 15


/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/can_attach(obj/mecha/M as obj)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/mining_scanner
	name = "exosuit mining scanner"
	desc = "Equipment for engineering and combat exosuits. It will automatically check surrounding rock for useful minerals."
	icon_state = "mecha_analyzer"
	origin_tech = "materials=3;engineering=2"
	equip_cooldown = 30
	var/scanning = 0

/obj/item/mecha_parts/mecha_equipment/tool/mining_scanner/New()
	SSobj.processing |= src

/obj/item/mecha_parts/mecha_equipment/tool/mining_scanner/process()
	if(!loc)
		SSobj.processing.Remove(src)
		qdel(src)
	if(scanning)
		return
	if(istype(loc,/obj/mecha/working))
		var/obj/mecha/working/mecha = loc
		if(!mecha.occupant)
			return
		var/list/occupant = list()
		occupant |= mecha.occupant
		scanning = 1
		mineral_scan_pulse(occupant,get_turf(loc))
		spawn(equip_cooldown)
			scanning = 0

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/New()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)
	..()
	return

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target) || get_dist(chassis, target)>3) return
	if(get_dist(chassis, target)>2) return
	set_ready_state(0)
	if(do_after_cooldown(target))
		if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
			var/obj/o = target
			o.reagents.trans_to(src, 1000)
			occupant_message("<span class='notice'>Extinguisher refilled.</span>")
			playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
		else
			if(src.reagents.total_volume > 0)
				playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
				var/direction = get_dir(chassis,target)
				var/turf/T = get_turf(target)
				var/turf/T1 = get_step(T,turn(direction, 90))
				var/turf/T2 = get_step(T,turn(direction, -90))

				var/list/the_targets = list(T,T1,T2)
				spawn(0)
					for(var/a=0, a<5, a++)
						var/obj/effect/effect/water/W = PoolOrNew(/obj/effect/effect/water, get_turf(chassis))
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

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/can_attach(obj/mecha/working/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0


/obj/item/mecha_parts/mecha_equipment/tool/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device."
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MELEE|RANGED
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.
	var/disabled = 0 //malf

/obj/item/mecha_parts/mecha_equipment/tool/rcd/action(atom/target)
	if(istype(target,/area/shuttle)||istype(target, /turf/space/transit))//>implying these are ever made -Sieve
		disabled = 1
	else
		disabled = 0
	if(!istype(target, /turf) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)
	if(!action_checks(target) || disabled || get_dist(chassis, target)>3) return
	playsound(chassis, 'sound/machines/click.ogg', 50, 1)
	//meh
	switch(mode)
		if(0)
			if (istype(target, /turf/simulated/wall))
				occupant_message("Deconstructing [target]...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					target:ChangeTurf(/turf/simulated/floor/plating)
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
					chassis.use_power(energy_drain)
			else if (istype(target, /turf/simulated/floor))
				occupant_message("Deconstructing [target]...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					target:ChangeTurf(/turf/space)
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
					chassis.use_power(energy_drain)
			else if (istype(target, /obj/machinery/door/airlock))
				occupant_message("Deconstructing [target]...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					chassis.spark_system.start()
					qdel(target)
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
					chassis.use_power(energy_drain)
		if(1)
			if(istype(target, /turf/space))
				occupant_message("Building Floor...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					target:ChangeTurf(/turf/simulated/floor/plating)
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
					chassis.spark_system.start()
					chassis.use_power(energy_drain*2)
			else if(istype(target, /turf/simulated/floor))
				occupant_message("Building Wall...")
				set_ready_state(0)
				if(do_after_cooldown(target))
					if(disabled) return
					target:ChangeTurf(/turf/simulated/wall)
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
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
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
					playsound(target, 'sound/effects/sparks2.ogg', 50, 1)
					chassis.use_power(energy_drain*2)
	return


/obj/item/mecha_parts/mecha_equipment/tool/rcd/Topic(href,href_list)
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

/obj/item/mecha_parts/mecha_equipment/tool/rcd/get_equip_info()
	return "[..()] \[<a href='?src=\ref[src];mode=0'>D</a>|<a href='?src=\ref[src];mode=1'>C</a>|<a href='?src=\ref[src];mode=2'>A</a>\]"


/obj/item/mecha_parts/mecha_equipment/tool/cable_layer
	name = "cable layer"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	var/datum/event/event
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/New()
	cable = new(src)
	cable.amount = 0
	..()

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/attach()
	..()
	event = chassis.events.addEvent("onMove",src,"layCable")
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/detach()
	chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/destroy()
	chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/action(var/obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	var/result = load_cable(target)
	var/message
	if(isnull(result))
		message = "<span class='danger'>Unable to load [target] - no cable found.</span>"
	else if(!result)
		message = "Reel is full."
	else
		message = "[result] meters of cable successfully loaded."
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	occupant_message(message)
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/Topic(href,href_list)
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
				var/obj/item/stack/cable_coil/CC = new (get_turf(chassis))
				CC.amount = m
		else
			occupant_message("There's no more cable on the reel.")
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=\ref[src];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=\ref[src];cut=1'>Cut</a>" : null]"
	return

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/load_cable(var/obj/item/stack/cable_coil/CC)
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

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/use_cable(amount)
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

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/dismantleFloor(var/turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!istype(T, /turf/simulated/floor/plating))
			if(!T.broken && !T.burnt)
				new T.floor_tile(T)
			T.make_plating()
	return !new_turf.intact

/obj/item/mecha_parts/mecha_equipment/tool/cable_layer/proc/layCable(var/turf/new_turf)
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

	var/datum/powernet/PN
	if(last_piece && last_piece.d2 != chassis.dir)
		last_piece.d1 = min(last_piece.d2, chassis.dir)
		last_piece.d2 = max(last_piece.d2, chassis.dir)
		last_piece.updateicon()
		PN = last_piece.powernet

	if(!PN)
		PN = new()
		powernets += PN
	NC.powernet = PN
	PN.cables += NC
	NC.mergeConnectedNetworks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return 1


/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "mounted teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=10"
	equip_cooldown = 150
	energy_drain = 1000
	range = RANGED

/obj/item/mecha_parts/mecha_equipment/teleporter/action(atom/target)
	if(!action_checks(target) || src.loc.z == ZLEVEL_CENTCOM) return
	var/turf/T = get_turf(target)
	if(T)
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_teleport(chassis, T, 4)
		do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "mounted wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	origin_tech = "bluespace=3"
	equip_cooldown = 50
	energy_drain = 300
	range = RANGED


/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(atom/target)
	if(!action_checks(target) || src.loc.z == ZLEVEL_CENTCOM) return
	var/list/theareas = list()
	for(var/area/AR in orange(100, chassis))
		if(AR in theareas) continue
		theareas += AR
	if(!theareas.len)
		return
	var/area/thearea = pick(theareas)
	var/list/L = list()
	var/turf/pos = get_turf(src)
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && pos.z == T.z)
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
	P.icon = 'icons/obj/objects.dmi'
	P.icon_state = "anom"
	P.name = "wormhole"
	var/turf/T = get_turf(target)
	message_admins("[key_name(chassis.occupant, chassis.occupant.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[chassis.occupant]'>?</A>) used a Wormhole Generator in ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)",0,1)
	log_game("[chassis.occupant.ckey]([chassis.occupant]) used a Wormhole Generator in ([T.x],[T.y],[T.z])")
	do_after_cooldown()
	src = null
	spawn(rand(150,300))
		qdel(P)
	return

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "mounted gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=2;magnets=3"
	equip_cooldown = 10
	energy_drain = 100
	range = MELEE|RANGED
	var/atom/movable/locked
	var/mode = 1 //1 - gravsling 2 - gravpush


/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(atom/movable/target)
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
			var/turf/T = get_turf(target)
			log_game("[chassis.occupant.ckey]([chassis.occupant]) used a Gravitational Catapult in ([T.x],[T.y],[T.z])")
			do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_equip_info()
	return "[..()] [mode==1?"([locked||"Nothing"])":null] \[<a href='?src=\ref[src];mode=1'>S</a>|<a href='?src=\ref[src];mode=2'>P</a>\]"

/obj/item/mecha_parts/mecha_equipment/gravcatapult/Topic(href, href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	return


/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "armor booster module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = "materials=3"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/can_attach(obj/mecha/M as obj)
	if(..())
		if(!istype(M, /obj/mecha/combat/honker))
			if(!M.proc_res["dynattackby"])
				return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/attach(obj/mecha/M as obj)
	..()
	chassis.proc_res["dynattackby"] = src
	return

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/detach()
	chassis.proc_res["dynattackby"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/proc/dynattackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!action_checks(user))
		return chassis.dynattackby(W,user)
	chassis.log_message("Attacked by [W]. Attacker - [user]")
	if(prob(chassis.deflect_chance*deflect_coeff))
		user << "<span class='danger'>The [W] bounces off [chassis] armor.</span>"
		chassis.log_append_to_last("Armor saved.")
	else
		chassis.occupant_message("<span class='userdanger'>[user] hits [chassis] with [W].</span>")
		user.visible_message("<span class='userdanger'>[user] hits [chassis] with [W].</span>", "<span class='userdanger'>You hit [src] with [W].</span>")
		chassis.take_damage(round(W.force*damage_coeff),W.damtype)
		chassis.check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
	set_ready_state(0)
	chassis.use_power(energy_drain)
	do_after_cooldown()
	return


/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "armor booster module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = "materials=4"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/can_attach(obj/mecha/M as obj)
	if(..())
		if(!istype(M, /obj/mecha/combat/honker))
			if(!M.proc_res["dynbulletdamage"] && !M.proc_res["dynhitby"])
				return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/attach(obj/mecha/M as obj)
	..()
	chassis.proc_res["dynbulletdamage"] = src
	chassis.proc_res["dynhitby"] = src
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/detach()
	chassis.proc_res["dynbulletdamage"] = null
	chassis.proc_res["dynhitby"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name]"

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/dynbulletdamage(var/obj/item/projectile/Proj)
	if(!action_checks(src))
		return chassis.dynbulletdamage(Proj)
	if(prob(chassis.deflect_chance*deflect_coeff))
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

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/dynhitby(atom/movable/A)
	if(!action_checks(A))
		return chassis.dynhitby(A)
	if(prob(chassis.deflect_chance*deflect_coeff) || istype(A, /mob/living) || istype(A, /obj/item/mecha_parts/mecha_tracking))
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
	name = "exosuit repair droid"
	desc = "An automated repair droid for exosuits. Scans for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	origin_tech = "magnets=3;programming=3"
	equip_cooldown = 20
	energy_drain = 100
	range = 0
	var/health_boost = 2
	var/datum/global_iterator/pr_repair_droid
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)

/obj/item/mecha_parts/mecha_equipment/repair_droid/New()
	..()
	pr_repair_droid = new /datum/global_iterator/mecha_repair_droid(list(src),0)
	pr_repair_droid.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	qdel(pr_repair_droid)
	pr_repair_droid = null
	..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/mecha/M as obj)
	..()
	droid_overlay = new(src.icon, icon_state = "repair_droid")
	M.overlays += droid_overlay
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/destroy()
	chassis.overlays -= droid_overlay
	..()
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.overlays -= droid_overlay
	pr_repair_droid.stop()
	..()
	return

/obj/item/mecha_parts/mecha_equipment/repair_droid/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_repairs=1'>[pr_repair_droid.active()?"Dea":"A"]ctivate</a>"


/obj/item/mecha_parts/mecha_equipment/repair_droid/Topic(href, href_list)
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

/datum/global_iterator/mecha_repair_droid/process(var/obj/item/mecha_parts/mecha_equipment/repair_droid/RD as obj)
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
	name = "exosuit energy relay"
	desc = "An exosuit module that wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	origin_tech = "magnets=4;powerstorage=3"
	equip_cooldown = 10
	energy_drain = 0
	range = 0
	var/datum/global_iterator/pr_energy_relay
	var/coeff = 100
	var/list/use_channels = list(EQUIP,ENVIRON,LIGHT)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/New()
	..()
	pr_energy_relay = new /datum/global_iterator/mecha_energy_relay(list(src),0)
	pr_energy_relay.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Destroy()
	qdel(pr_energy_relay)
	pr_energy_relay = null
	..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach()
	pr_energy_relay.stop()
//	chassis.proc_res["dynusepower"] = null
	chassis.proc_res["dyngetcharge"] = null
	..()
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/attach(obj/mecha/M)
	..()
	chassis.proc_res["dyngetcharge"] = src
//	chassis.proc_res["dynusepower"] = src
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/can_attach(obj/mecha/M)
	if(..())
		if(!M.proc_res["dyngetcharge"])// && !M.proc_res["dynusepower"])
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/dyngetcharge()
	if(equip_ready) //disabled
		return chassis.dyngetcharge()
	var/area/A = get_area(chassis)
	var/pow_chan = get_power_channel(A)
	var/charge = 0
	if(pow_chan)
		charge = 1000 //making magic
	else
		return chassis.dyngetcharge()
	return charge

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_power_channel(var/area/A)
	var/pow_chan
	if(A)
		for(var/c in use_channels)
			if(A.master && A.master.powered(c))
				pow_chan = c
				break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	..()
	if(href_list["toggle_relay"])
		if(pr_energy_relay.toggle())
			set_ready_state(0)
			log_message("Activated.")
		else
			set_ready_state(1)
			log_message("Deactivated.")
	return

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[src.name] - <a href='?src=\ref[src];toggle_relay=1'>[pr_energy_relay.active()?"Dea":"A"]ctivate</a>"

/*/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/dynusepower(amount)
	if(!equip_ready) //enabled
		var/area/A = get_area(chassis)
		var/pow_chan = get_power_channel(A)
		if(pow_chan)
			A.master.use_power(amount*coeff, pow_chan)
			return 1
	return chassis.dynusepower(amount)*/

/datum/global_iterator/mecha_energy_relay

/datum/global_iterator/mecha_energy_relay/process(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/ER)
	if(!ER.chassis || ER.chassis.hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		stop()
		ER.set_ready_state(1)
		return
	var/cur_charge = ER.chassis.get_charge()
	if(isnull(cur_charge) || !ER.chassis.cell)
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
				var/delta = min(12, ER.chassis.cell.maxcharge-cur_charge)
				ER.chassis.give_power(delta)
				A.master.use_power(delta*ER.coeff, pow_chan)
	return



/obj/item/mecha_parts/mecha_equipment/generator
	name = "exosuit plasma converter"
	desc = "An exosuit module that generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "plasmatech=2;powerstorage=2;engineering=1"
	equip_cooldown = 10
	energy_drain = 0
	range = MELEE
	var/datum/global_iterator/pr_mech_generator
	var/coeff = 100
	var/obj/item/stack/sheet/fuel
	var/max_fuel = 150000
	var/fuel_per_cycle_idle = 25
	var/fuel_per_cycle_active = 200
	var/power_per_cycle = 20
	reliability = 1000

/obj/item/mecha_parts/mecha_equipment/generator/New()
	..()
	init()
	return

/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	qdel(pr_mech_generator)
	pr_mech_generator = null
	..()

/obj/item/mecha_parts/mecha_equipment/generator/proc/init()
	fuel = new /obj/item/stack/sheet/mineral/plasma(src)
	fuel.amount = 0
	pr_mech_generator = new /datum/global_iterator/mecha_generator(list(src),0)
	pr_mech_generator.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	pr_mech_generator.stop()
	..()
	return


/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	..()
	if(href_list["toggle"])
		if(pr_mech_generator.toggle())
			set_ready_state(0)
			log_message("Activated.")
		else
			set_ready_state(1)
			log_message("Deactivated.")
	return

/obj/item/mecha_parts/mecha_equipment/generator/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[[fuel]: [round(fuel.amount*fuel.perunit,0.1)] cm<sup>3</sup>\] - <a href='?src=\ref[src];toggle=1'>[pr_mech_generator.active()?"Dea":"A"]ctivate</a>"
	return

/obj/item/mecha_parts/mecha_equipment/generator/action(target)
	if(chassis)
		var/result = load_fuel(target)
		var/message
		if(isnull(result))
			message = "<span class='danger'>[fuel] traces in target minimal. [target] cannot be used as fuel.</span>"
		else if(!result)
			message = "Unit is full."
		else
			message = "[result] unit\s of [fuel] successfully loaded."
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		occupant_message(message)
	return

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(var/obj/item/stack/sheet/P)
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

/obj/item/mecha_parts/mecha_equipment/generator/attackby(weapon,mob/user, params)
	var/result = load_fuel(weapon)
	if(isnull(result))
		user.visible_message("[user] tries to shove [weapon] into [src]. What a dumb-ass.","<span class='danger'>[fuel] traces minimal. [weapon] cannot be used as fuel.</span>")
	else if(!result)
		user << "Unit is full."
	else
		user.visible_message("[user] loads [src] with [fuel].","[result] unit\s of [fuel] successfully loaded.")
	return

/obj/item/mecha_parts/mecha_equipment/generator/critfail()
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

/datum/global_iterator/mecha_generator/process(var/obj/item/mecha_parts/mecha_equipment/generator/EG)
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
	name = "exonuclear reactor"
	desc = "An exosuit module that generates power using uranium as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "powerstorage=3;engineering=3"
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 0.3
	reliability = 1000

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/init()
	fuel = new /obj/item/stack/sheet/mineral/uranium(src)
	fuel.amount = 0
	pr_mech_generator = new /datum/global_iterator/mecha_generator/nuclear(list(src),0)
	pr_mech_generator.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/critfail()
	return

/datum/global_iterator/mecha_generator/nuclear

/datum/global_iterator/mecha_generator/nuclear/process(var/obj/item/mecha_parts/mecha_equipment/generator/nuclear/EG)
	if(..())
		for(var/mob/living/carbon/M in view(EG.chassis))
			if(istype(M,/mob/living/carbon/human))
				M.irradiate(EG.rad_per_cycle*3)
			else
				M.irradiate(EG.rad_per_cycle)
	return 1



//This is pretty much just for the death-ripley so that it is harmless
/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them!"
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 0
	var/dam_force = 0
	var/obj/mecha/working/ripley/cargo_holder

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/can_attach(obj/mecha/working/ripley/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/attach(obj/mecha/M as obj)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp/action(atom/target)
	if(!action_checks(target)) return
	if(!cargo_holder) return
	if(istype(target,/obj))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
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
						chassis.occupant_message("<span class='notice'>[target] successfully loaded.</span>")
						chassis.log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
					else
						chassis.occupant_message("<span class='warning'>You must hold still while handling objects.</span>")
						O.anchored = initial(O.anchored)
			else
				chassis.occupant_message("<span class='warning'>Not enough room in cargo compartment.</span>")
		else
			chassis.occupant_message("<span class='warning'>[target] is firmly secured.</span>")

	else if(istype(target,/mob/living))
		var/mob/living/M = target
		if(M.stat>1) return
		if(chassis.occupant.a_intent == "harm")
			target.visible_message("<span class='danger'>[chassis] destroys [target] in an unholy fury.</span>", \
								"<span class='userdanger'>[chassis] destroys [target] in an unholy fury.</span>")
		if(chassis.occupant.a_intent == "disarm")
			target.visible_message("<span class='danger'>[chassis] rips [target]'s arms off.</span>", \
								"<span class='userdanger'>[chassis] rips [target]'s arms off.</span>")
		else
			step_away(M,chassis)
			target.visible_message("[chassis] tosses [target] like a piece of paper.")
		set_ready_state(0)
		chassis.use_power(energy_drain)
		do_after_cooldown()
	return 1

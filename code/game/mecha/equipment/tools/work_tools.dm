
//Hydraulic clamp, Kill clamp, Extinguisher, RCD, Cable layer.


/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/mecha/working/ripley/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/mecha/M as obj)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(atom/target)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = 1
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.loc = chassis
					O.anchored = 0
					occupant_message("<span class='notice'>[target] successfully loaded.</span>")
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
		else
			occupant_message("<span class='warning'>[target] is firmly secured!</span>")

	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD) return
		if(chassis.occupant.a_intent == INTENT_HARM)
			M.take_overall_damage(dam_force)
			if(!M)
				return
			M.adjustOxyLoss(round(dam_force/2))
			M.updatehealth()
			target.visible_message("<span class='danger'>[chassis] squeezes [target].</span>", \
								"<span class='userdanger'>[chassis] squeezes [target].</span>",\
								"<span class='italics'>You hear something crack.</span>")
			add_logs(chassis.occupant, M, "attacked", "[name]", "(INTENT: [uppertext(chassis.occupant.a_intent)]) (DAMTYE: [uppertext(damtype)])")
		else
			step_away(M,chassis)
			occupant_message("You push [target] out of the way.")
			chassis.visible_message("[chassis] pushes [target] out of the way.")
		return 1



//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them!"
	energy_drain = 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/action(atom/target)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = 1
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.loc = chassis
					O.anchored = 0
					occupant_message("<span class='notice'>[target] successfully loaded.</span>")
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]")
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message("<span class='warning'>Not enough room in cargo compartment!</span>")
		else
			occupant_message("<span class='warning'>[target] is firmly secured!</span>")

	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD) return
		if(chassis.occupant.a_intent == INTENT_HARM)
			target.visible_message("<span class='danger'>[chassis] destroys [target] in an unholy fury.</span>", \
								"<span class='userdanger'>[chassis] destroys [target] in an unholy fury.</span>")
		if(chassis.occupant.a_intent == INTENT_DISARM)
			target.visible_message("<span class='danger'>[chassis] rips [target]'s arms off.</span>", \
								"<span class='userdanger'>[chassis] rips [target]'s arms off.</span>")
		else
			step_away(M,chassis)
			target.visible_message("[chassis] tosses [target] like a piece of paper.")
		return 1



/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MELEE|RANGED

/obj/item/mecha_parts/mecha_equipment/extinguisher/New()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)
	..()
	return

/obj/item/mecha_parts/mecha_equipment/extinguisher/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message("<span class='notice'>Extinguisher refilled.</span>")
		playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
	else
		if(reagents.total_volume > 0)
			playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
			var/direction = get_dir(chassis,target)
			var/turf/T = get_turf(target)
			var/turf/T1 = get_step(T,turn(direction, 90))
			var/turf/T2 = get_step(T,turn(direction, -90))

			var/list/the_targets = list(T,T1,T2)
			spawn(0)
				for(var/a=0, a<5, a++)
					var/obj/effect/particle_effect/water/W = PoolOrNew(/obj/effect/particle_effect/water, get_turf(chassis))
					if(!W)
						return
					var/turf/my_target = pick(the_targets)
					var/datum/reagents/R = new/datum/reagents(5)
					W.reagents = R
					R.my_atom = W
					reagents.trans_to(W,1)
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

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/on_reagent_change()
	return

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/mecha/working/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0



/obj/item/mecha_parts/mecha_equipment/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device."
	icon_state = "mecha_rcd"
	origin_tech = "materials=4;bluespace=3;magnets=4;powerstorage=4;engineering=4"
	equip_cooldown = 10
	energy_drain = 250
	range = MELEE|RANGED
	var/mode = 0 //0 - deconstruct, 1 - wall or floor, 2 - airlock.

/obj/item/mecha_parts/mecha_equipment/rcd/New()
	rcd_list += src
	..()

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
 	rcd_list -= src
 	..()

/obj/item/mecha_parts/mecha_equipment/rcd/action(atom/target)
	if(istype(target, /turf/open/space/transit))//>implying these are ever made -Sieve
		return

	if(!isturf(target) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, 1)

	switch(mode)
		if(0)
			if(iswallturf(target))
				var/turf/closed/wall/W = target
				occupant_message("Deconstructing [W]...")
				if(do_after_cooldown(W))
					chassis.spark_system.start()
					W.ChangeTurf(/turf/open/floor/plating)
					playsound(W, 'sound/items/Deconstruct.ogg', 50, 1)
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				occupant_message("Deconstructing [F]...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					F.ChangeTurf(F.baseturf)
					playsound(F, 'sound/items/Deconstruct.ogg', 50, 1)
			else if (istype(target, /obj/machinery/door/airlock))
				occupant_message("Deconstructing [target]...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					qdel(target)
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
		if(1)
			if(isspaceturf(target))
				var/turf/open/space/S = target
				occupant_message("Building Floor...")
				if(do_after_cooldown(S))
					S.ChangeTurf(/turf/open/floor/plating)
					playsound(S, 'sound/items/Deconstruct.ogg', 50, 1)
					chassis.spark_system.start()
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				occupant_message("Building Wall...")
				if(do_after_cooldown(F))
					F.ChangeTurf(/turf/closed/wall)
					playsound(F, 'sound/items/Deconstruct.ogg', 50, 1)
					chassis.spark_system.start()
		if(2)
			if(isfloorturf(target))
				occupant_message("Building Airlock...")
				if(do_after_cooldown(target))
					chassis.spark_system.start()
					var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
					T.autoclose = 1
					playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
					playsound(target, 'sound/effects/sparks2.ogg', 50, 1)



/obj/item/mecha_parts/mecha_equipment/rcd/do_after_cooldown(var/atom/target)
	. = ..()

/obj/item/mecha_parts/mecha_equipment/rcd/Topic(href,href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(0)
				occupant_message("Switched RCD to Deconstruct.")
				energy_drain = initial(energy_drain)
			if(1)
				occupant_message("Switched RCD to Construct.")
				energy_drain = 2*initial(energy_drain)
			if(2)
				occupant_message("Switched RCD to Construct Airlock.")
				energy_drain = 2*initial(energy_drain)
	return

/obj/item/mecha_parts/mecha_equipment/rcd/get_equip_info()
	return "[..()] \[<a href='?src=\ref[src];mode=0'>D</a>|<a href='?src=\ref[src];mode=1'>C</a>|<a href='?src=\ref[src];mode=2'>A</a>\]"




/obj/item/mecha_parts/mecha_equipment/cable_layer
	name = "cable layer"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	var/datum/callback/event
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/cable_layer/New()
	cable = new(src)
	cable.amount = 0
	..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/can_attach(obj/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/cable_layer/attach()
	..()
	event = chassis.events.addEvent("onMove", CALLBACK(src, .proc/layCable))
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/detach()
	chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/Destroy()
	if(chassis)
		chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/action(var/obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	if(istype(target) && target.amount)
		var/cur_amount = cable? cable.amount : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(target.amount, to_load)
			if(!cable)
				cable = new(src)
				cable.amount = 0
			cable.amount += to_load
			target.use(to_load)
			occupant_message("<span class='notice'>[to_load] meters of cable successfully loaded.</span>")
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
		else
			occupant_message("<span class='warning'>Reel is full.</span>")
	else
		occupant_message("<span class='warning'>Unable to load [target] - no cable found.</span>")


/obj/item/mecha_parts/mecha_equipment/cable_layer/Topic(href,href_list)
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

/obj/item/mecha_parts/mecha_equipment/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=\ref[src];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=\ref[src];cut=1'>Cut</a>" : null]"
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/use_cable(amount)
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

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/dismantleFloor(var/turf/new_turf)
	if(isfloorturf(new_turf))
		var/turf/open/floor/T = new_turf
		if(!istype(T, /turf/open/floor/plating))
			if(!T.broken && !T.burnt)
				new T.floor_tile(T)
			T.make_plating()
	return !new_turf.intact

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/layCable(var/turf/new_turf)
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

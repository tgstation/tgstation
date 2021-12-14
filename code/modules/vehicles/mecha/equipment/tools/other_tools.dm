
// Teleporter, Wormhole generator, Gravitational catapult, Armor booster modules,
// Repair droid, Tesla Energy relay, Generators

////////////////////////////////////////////// TELEPORTER ///////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "mounted teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	equip_cooldown = 150
	energy_drain = 1000
	range = MECHA_RANGED
	var/teleport_range = 7

/obj/item/mecha_parts/mecha_equipment/teleporter/action(mob/source, atom/target, list/modifiers)
	var/area/ourarea = get_area(src)
	if(!action_checks(target) || ourarea.area_flags & NOTELEPORT)
		return
	var/turf/T = get_turf(target)
	if(T && (loc.z == T.z) && (get_dist(loc, T) <= teleport_range))
		do_teleport(chassis, T, 4, channel = TELEPORT_CHANNEL_BLUESPACE)
		return ..()



////////////////////////////////////////////// WORMHOLE GENERATOR //////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "mounted wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes, allowing for long-range inneacurate teleportation."
	icon_state = "mecha_wholegen"
	equip_cooldown = 50
	energy_drain = 300
	range = MECHA_RANGED


/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(mob/source, atom/target, list/modifiers)
	var/area/ourarea = get_area(src)
	if(!action_checks(target) || ourarea.area_flags & NOTELEPORT)
		return
	var/area/targetarea = pick(get_areas_in_range(100, chassis))
	if(!targetarea)//Literally middle of nowhere how did you even get here
		return
	var/list/validturfs = list()
	var/turf/ourturf = get_turf(src)
	for(var/t in get_area_turfs(targetarea.type))
		var/turf/evaluated_turf = t
		if(evaluated_turf.density || chassis.z != evaluated_turf.z)
			continue
		for(var/obj/evaluated_obj in evaluated_turf)
			if(!evaluated_obj.density)
				continue
			validturfs += evaluated_turf

	var/turf/target_turf = pick(validturfs)
	if(!target_turf)
		return
	var/list/obj/effect/portal/created = create_portal_pair(ourturf, target_turf, 300, 1, /obj/effect/portal/anom)
	message_admins("[ADMIN_LOOKUPFLW(source)] used a Wormhole Generator in [ADMIN_VERBOSEJMP(ourturf)]")
	log_game("[key_name(source)] used a Wormhole Generator in [AREACOORD(ourturf)]")
	QDEL_LIST_IN(created, rand(150,300))
	return ..()


/////////////////////////////////////// GRAVITATIONAL CATAPULT ///////////////////////////////////////////

#define GRAVSLING_MODE 1
#define GRAVPUSH_MODE 2

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "mounted gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	equip_cooldown = 10
	energy_drain = 100
	range = MECHA_MELEE|MECHA_RANGED
	///Which atom we are movable_target onto for
	var/atom/movable/movable_target
	///Whether we will throw movable atomstothrow by locking onto them or just throw them back from where we click
	var/mode = GRAVSLING_MODE


/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(mob/source, atom/movable/target, list/modifiers)
	if(!action_checks(target))
		return
	switch(mode)
		if(GRAVSLING_MODE)
			if(!movable_target)
				if(!istype(target) || target.anchored || target.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)
					to_chat(source, "[icon2html(src, source)][span_warning("Unable to lock on [target]!")]")
					return
				if(ismob(target))
					var/mob/M = target
					if(M.mob_negates_gravity())
						to_chat(source, "[icon2html(src, source)][span_warning("[target] immune to gravitational impulses, unable to lock!")]")
						return
				movable_target = target
				to_chat(source, "[icon2html(src, source)][span_notice("locked on [target].")]")
				send_byjax(source,"exosuit.browser","[REF(src)]", get_equip_info())
			else if(target!=movable_target)
				if(movable_target in view(chassis))
					var/turf/targ = get_turf(target)
					var/turf/orig = get_turf(movable_target)
					movable_target.throw_at(target, 14, 1.5)
					movable_target = null
					send_byjax(source,"exosuit.browser","[REF(src)]", get_equip_info())
					log_game("[key_name(source)] used a Gravitational Catapult to throw [movable_target] (From [AREACOORD(orig)]) at [target] ([AREACOORD(targ)]).")
					return ..()
				movable_target = null
				to_chat(source, "[icon2html(src, source)][span_notice("Lock on [movable_target] disengaged.")]")
				send_byjax(source,"exosuit.browser","[REF(src)]", get_equip_info())

		if(GRAVPUSH_MODE)
			var/list/atomstothrow = list()
			if(isturf(target))
				atomstothrow = range(3, target)
			else
				atomstothrow = orange(3, target)
			for(var/atom/movable/A in atomstothrow)
				if(A.anchored || A.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)
					continue
				if(ismob(A))
					var/mob/M = A
					if(M.mob_negates_gravity())
						continue
				INVOKE_ASYNC(src, .proc/do_scatter, A, target)
			var/turf/targetturf = get_turf(target)
			log_game("[key_name(source)] used a Gravitational Catapult repulse wave on [AREACOORD(targetturf)]")
			return ..()

/obj/item/mecha_parts/mecha_equipment/gravcatapult/proc/do_scatter(atom/movable/A, atom/movable/target)
	var/iter = 5-get_dist(A,target)
	for(var/i in 0 to iter)
		step_away(A,target)
		sleep(2)

/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_equip_info()
	return "[..()] [mode==1?"([movable_target||"Nothing"])":null] \[<a href='?src=[REF(src)];mode=1'>S</a>|<a href='?src=[REF(src)];mode=2'>P</a>\]"

/obj/item/mecha_parts/mecha_equipment/gravcatapult/Topic(href, href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",src.get_equip_info())


#undef GRAVSLING_MODE
#undef GRAVPUSH_MODE

//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "armor booster module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	selectable = FALSE

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/proc/attack_react()
	if(energy_drain && !chassis.has_charge(energy_drain))
		return FALSE
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_ARMOR, equip_cooldown)
	return TRUE



/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "armor booster module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	selectable = FALSE

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/projectile_react()
	if(energy_drain && !chassis.has_charge(energy_drain))
		return FALSE
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_ARMOR, equip_cooldown)
	return TRUE


////////////////////////////////// REPAIR DROID //////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "exosuit repair droid"
	desc = "An automated repair droid for exosuits. Scans for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	energy_drain = 50
	range = 0

	/// Repaired health per second
	var/health_boost = 0.5
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	STOP_PROCESSING(SSobj, src)
	chassis?.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	droid_overlay = new(src.icon, icon_state = "repair_droid")
	M.add_overlay(droid_overlay)

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.cut_overlay(droid_overlay)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/get_equip_info()
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp; [name] - <a href='?src=[REF(src)];toggle_repairs=1'>[equip_ready?"Deactivate":"Activate"]</a>"


/obj/item/mecha_parts/mecha_equipment/repair_droid/Topic(href, href_list)
	..()
	if(href_list["toggle_repairs"])
		chassis.cut_overlay(droid_overlay)
		equip_ready = !equip_ready //now set to FALSE and active, so update the UI
		update_equip_info()
		if(equip_ready)
			START_PROCESSING(SSobj, src)
			droid_overlay = new(src.icon, icon_state = "repair_droid_a")
			log_message("Activated.", LOG_MECHA)
		else
			STOP_PROCESSING(SSobj, src)
			droid_overlay = new(src.icon, icon_state = "repair_droid")
			log_message("Deactivated.", LOG_MECHA)
		chassis.add_overlay(droid_overlay)
		send_byjax(chassis.occupants,"exosuit.browser", "[REF(src)]", get_equip_info())


/obj/item/mecha_parts/mecha_equipment/repair_droid/process(delta_time)
	if(!chassis)
		return PROCESS_KILL
	var/h_boost = health_boost * delta_time
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost *= -2
	else if(chassis.internal_damage && DT_PROB(8, delta_time))
		for(var/int_dam_flag in repairable_damage)
			if(!(chassis.internal_damage & int_dam_flag))
				continue
			chassis.clear_internal_damage(int_dam_flag)
			repaired = TRUE
			break
	if(h_boost<0 || chassis.get_integrity() < chassis.max_integrity)
		chassis.repair_damage(h_boost)
		repaired = TRUE
	if(repaired)
		if(!chassis.use_power(energy_drain))
			return PROCESS_KILL
	else //no repair needed, we turn off
		chassis.cut_overlay(droid_overlay)
		droid_overlay = new(src.icon, icon_state = "repair_droid")
		chassis.add_overlay(droid_overlay)
		return PROCESS_KILL




/////////////////////////////////// TESLA ENERGY RELAY ////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "exosuit energy relay"
	desc = "An exosuit module that wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	energy_drain = 0
	range = 0
	var/coeff = 100
	var/list/use_channels = list(AREA_USAGE_EQUIP,AREA_USAGE_ENVIRON,AREA_USAGE_LIGHT)
	selectable = FALSE

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_charge()
	if(equip_ready) //disabled
		return
	var/pow_chan = get_chassis_area_power(get_area(chassis))
	if(pow_chan)
		return 1000 //making magic


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_chassis_area_power(area/A)
	if(!A)
		return
	var/pow_chan = 0
	for(var/c in use_channels)
		if(!A.powered(c))
			continue
		pow_chan = c
		break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	..()
	if(href_list["toggle_relay"])
		equip_ready = !equip_ready //now set to FALSE and active, so update the UI
		update_equip_info()
		if(equip_ready) //inactive
			START_PROCESSING(SSobj, src)
			log_message("Activated.", LOG_MECHA)
		else
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp; [src.name] - <a href='?src=[REF(src)];toggle_relay=1'>[equip_ready?"Deactivate":"Activate"]</a>"


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/process(delta_time)
	if(!chassis || chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		return PROCESS_KILL
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge) || !chassis.cell)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("No power cell detected.")]")
		return PROCESS_KILL
	if(cur_charge >= chassis.cell.maxcharge)
		return
	var/area/A = get_area(chassis)
	var/pow_chan = get_chassis_area_power(A)
	if(pow_chan)
		var/delta = min(10 * delta_time, chassis.cell.maxcharge-cur_charge)
		chassis.give_power(delta)
		A.use_power(delta*coeff, pow_chan)




/////////////////////////////////////////// GENERATOR /////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/generator
	name = "exosuit plasma converter"
	desc = "An exosuit module that generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	range = MECHA_MELEE
	var/coeff = 100
	var/obj/item/stack/sheet/fuel
	var/max_fuel = 150000
	/// Fuel used per second while idle, not generating
	var/fuelrate_idle = 12.5
	/// Fuel used per second while actively generating
	var/fuelrate_active = 100
	/// Energy recharged per second
	var/rechargerate = 10

/obj/item/mecha_parts/mecha_equipment/generator/Initialize(mapload)
	. = ..()
	generator_init()

/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/proc/generator_init()
	fuel = new /obj/item/stack/sheet/mineral/plasma(src, 0)

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	..()
	if(href_list["toggle"])
		equip_ready = !equip_ready //now set to FALSE and active, so update the UI
		update_equip_info()
		if(equip_ready) //inactive
			START_PROCESSING(SSobj, src)
			log_message("Activated.", LOG_MECHA)
		else
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/generator/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[[fuel]: [round(fuel.amount*MINERAL_MATERIAL_AMOUNT,0.1)] cm<sup>3</sup>\] - <a href='?src=[REF(src)];toggle=1'>[equip_ready?"Deactivate":"Activate"]</a>"

/obj/item/mecha_parts/mecha_equipment/generator/action(mob/source, atom/movable/target, list/modifiers)
	if(!chassis)
		return
	if(load_fuel(target, source))
		send_byjax(chassis.occupants,"exosuit.browser","[REF(src)]",src.get_equip_info())
		return ..()

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/P, mob/user)
	if(P.type == fuel.type && P.amount > 0)
		var/to_load = max(max_fuel - fuel.amount*MINERAL_MATERIAL_AMOUNT,0)
		if(to_load)
			var/units = min(max(round(to_load / MINERAL_MATERIAL_AMOUNT),1),P.amount)
			fuel.amount += units
			P.use(units)
			to_chat(user, "[icon2html(src, user)][span_notice("[units] unit\s of [fuel] successfully loaded.")]")
			return units
		else
			to_chat(user, "[icon2html(src, user)][span_notice("Unit is full.")]")
			return 0
	else
		to_chat(user, "[icon2html(src, user)][span_warning("[fuel] traces in target minimal! [P] cannot be used as fuel.")]")
		return

/obj/item/mecha_parts/mecha_equipment/generator/attackby(weapon,mob/user, params)
	load_fuel(weapon)

/obj/item/mecha_parts/mecha_equipment/generator/process(delta_time)
	if(!chassis)
		return PROCESS_KILL
	if(fuel.amount<=0)
		log_message("Deactivated - no fuel.", LOG_MECHA)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Fuel reserves depleted.")]")
		return PROCESS_KILL
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge))
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("No power cell detected.")]")
		log_message("Deactivated.", LOG_MECHA)
		return PROCESS_KILL
	var/use_fuel = fuelrate_idle
	if(cur_charge < chassis.cell.maxcharge)
		use_fuel = fuelrate_active
		chassis.give_power(rechargerate * delta_time)
	fuel.amount -= min(delta_time * use_fuel / MINERAL_MATERIAL_AMOUNT, fuel.amount)
	update_equip_info()

/////////////////////////////////////////// THRUSTERS /////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/thrusters
	name = "generic exosuit thrusters" //parent object, in-game sources will be a child object
	desc = "A generic set of thrusters, from an unknown source. Uses not-understood methods to propel exosuits seemingly for free."
	icon_state = "thrusters"
	selectable = FALSE
	var/effect_type = /obj/effect/particle_effect/sparks

/obj/item/mecha_parts/mecha_equipment/thrusters/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M)
	for(var/obj/item/I in M.equipment)
		if(istype(I, src))
			to_chat(user, span_warning("[M] already has this thruster package!"))
			return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/attach(obj/vehicle/sealed/mecha/M)
	M.active_thrusters = src //Enable by default
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/detach()
	if(chassis?.active_thrusters == src)
		chassis.active_thrusters = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/Destroy()
	if(chassis?.active_thrusters == src)
		chassis.active_thrusters = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/Topic(href,href_list)
	..()
	if(href_list["toggle"])
		equip_ready = !equip_ready //now set to FALSE and active, so update the UI
		update_equip_info()
		if(equip_ready) //inactive
			START_PROCESSING(SSobj, src)
			enable()
			log_message("Activated.", LOG_MECHA)
		else
			STOP_PROCESSING(SSobj, src)
			disable()
			log_message("Deactivated.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/enable()
	if (chassis.active_thrusters == src)
		return
	chassis.active_thrusters = src
	to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("[src] enabled.")]")

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/disable()
	if(chassis.active_thrusters != src)
		return
	chassis.active_thrusters = null
	to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("[src] disabled.")]")

/obj/item/mecha_parts/mecha_equipment/thrusters/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] <a href='?src=[REF(src)];toggle=1'>[equip_ready?"Deactivate":"Activate"]</a>"

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/thrust(movement_dir)
	if(!chassis)
		return FALSE
	generate_effect(movement_dir)
	return TRUE //This parent should never exist in-game outside admeme use, so why not let it be a creative thruster?

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/generate_effect(movement_dir)
	var/obj/effect/particle_effect/E = new effect_type(get_turf(chassis))
	E.dir = turn(movement_dir, 180)
	step(E, turn(movement_dir, 180))
	QDEL_IN(E, 5)


/obj/item/mecha_parts/mecha_equipment/thrusters/gas
	name = "RCS thruster package"
	desc = "A set of thrusters that allow for exosuit movement in zero-gravity environments, by expelling gas from the internal life support tank."
	effect_type = /obj/effect/particle_effect/smoke
	var/move_cost = 20 //moles per step

/obj/item/mecha_parts/mecha_equipment/thrusters/gas/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M)
	if(!M.internal_tank)
		to_chat(user, span_warning("[M] does not have an internal tank and cannot support this upgrade!"))
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/gas/thrust(movement_dir)
	if(!chassis || !chassis.internal_tank)
		return FALSE
	var/datum/gas_mixture/our_mix = chassis.internal_tank.return_air()
	var/moles = our_mix.total_moles()
	if(moles < move_cost)
		our_mix.remove(moles)
		return FALSE
	our_mix.remove(move_cost)
	generate_effect(movement_dir)
	return TRUE



/obj/item/mecha_parts/mecha_equipment/thrusters/ion //for mechs with built-in thrusters, should never really exist un-attached to a mech
	name = "Ion thruster package"
	desc = "A set of thrusters that allow for exosuit movement in zero-gravity environments."
	detachable = FALSE
	salvageable = FALSE
	effect_type = /obj/effect/particle_effect/ion_trails

/obj/item/mecha_parts/mecha_equipment/thrusters/ion/thrust(movement_dir)
	if(!chassis)
		return FALSE
	if(chassis.use_power(chassis.step_energy_drain))
		generate_effect(movement_dir)
		return TRUE
	return FALSE

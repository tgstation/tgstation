
// Teleporter, Wormhole generator, Gravitational catapult, Armor booster modules,
// Repair droid, Tesla Energy relay, Generators

////////////////////////////////////////////// TELEPORTER ///////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "mounted teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	equip_cooldown = 150
	energy_drain = STANDARD_CELL_CHARGE
	range = MECHA_RANGED
	var/teleport_range = 7

/obj/item/mecha_parts/mecha_equipment/teleporter/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target) || !check_teleport_valid(source, target, TELEPORT_CHANNEL_BLUESPACE))
		return
	var/turf/T = get_turf(target)
	if(T && (loc.z == T.z) && (get_dist(loc, T) <= teleport_range))
		do_teleport(chassis, T, 4, channel = TELEPORT_CHANNEL_BLUESPACE)
		return ..()



////////////////////////////////////////////// WORMHOLE GENERATOR //////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "mounted wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes, allowing for long-range inaccurate teleportation."
	icon_state = "mecha_wholegen"
	equip_cooldown = 50
	energy_drain = 300
	range = MECHA_RANGED


/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target) || !check_teleport_valid(source, target, TELEPORT_CHANNEL_WORMHOLE))
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
	source.log_message("used a Wormhole Generator in [AREACOORD(ourturf)].", LOG_GAME)
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
			else if(target != movable_target)
				if(movable_target in view(chassis))
					var/turf/targ = get_turf(target)
					var/turf/orig = get_turf(movable_target)
					movable_target.throw_at(target, 14, 1.5)
					movable_target = null
					source.log_message("used a Gravitational Catapult to throw [movable_target] (From [AREACOORD(orig)]) at [target] ([AREACOORD(targ)]).", LOG_GAME)
					return ..()
				movable_target = null
				to_chat(source, "[icon2html(src, source)][span_notice("Lock on [movable_target] disengaged.")]")

		if(GRAVPUSH_MODE)
			var/list/atomstothrow = list()
			if(isturf(target))
				atomstothrow = range(3, target)
			else
				atomstothrow = orange(3, target)
			for(var/atom/movable/scatter in atomstothrow)
				if(scatter.anchored || scatter.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)
					continue
				if(ismob(scatter))
					var/mob/scatter_mob = scatter
					if(scatter_mob.mob_negates_gravity())
						continue
				do_scatter(scatter, target)
			var/turf/targetturf = get_turf(target)
			source.log_message("used a Gravitational Catapult repulse wave on [AREACOORD(targetturf)].", LOG_GAME)
			return ..()

/obj/item/mecha_parts/mecha_equipment/gravcatapult/proc/do_scatter(atom/movable/scatter, atom/movable/target)
	var/dist = 5 - get_dist(scatter, target)
	var/delay = 2
	GLOB.move_manager.move_away(scatter, target, delay = delay, timeout = delay * dist, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)

/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_snowflake_data()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_MODE,
		"mode" = mode == GRAVPUSH_MODE ? "Push" : "Sling",
		"mode_label" = "Gravity Catapult",
	)

/obj/item/mecha_parts/mecha_equipment/gravcatapult/handle_ui_act(action, list/params)
	if(action == "change_mode")
		mode++
		if(mode > GRAVPUSH_MODE)
			mode = GRAVSLING_MODE
		return TRUE

#undef GRAVSLING_MODE
#undef GRAVPUSH_MODE

//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////
/obj/item/mecha_parts/mecha_equipment/armor
	equipment_slot = MECHA_ARMOR
	//how much the armor of the mech is modified by
	var/datum/armor/armor_mod

/obj/item/mecha_parts/mecha_equipment/armor/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right)
	. = ..()
	if (armor_mod)
		chassis.set_armor(chassis.get_armor().add_other_armor(armor_mod))

/obj/item/mecha_parts/mecha_equipment/armor/detach(atom/moveto)
	if (armor_mod)
		chassis.set_armor(chassis.get_armor().subtract_other_armor(armor_mod))
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/anticcw_armor_booster
	name = "exosuit impact cushion plates"
	desc = "Boosts exosuit armor against melee attacks"
	icon_state = "mecha_abooster_ccw"
	armor_mod = /datum/armor/mecha_equipment_ccw_boost

/datum/armor/mecha_equipment_ccw_boost
	melee = 20

/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster
	name = "exosuit projectile shielding"
	desc = "Boosts exosuit armor against ranged kinetic and energy projectiles. Completely blocks taser shots."
	icon_state = "mecha_abooster_proj"
	armor_mod = /datum/armor/mecha_equipment_ranged_boost

/datum/armor/mecha_equipment_ranged_boost
	bullet = 15
	laser = 15

/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster
	name = "exosuit ablative insulation"
	desc = "Boosts exosuit armor against energy-based attacks. Also shields the exosuit's internal wiring from hostile EMP attacks. However, this may leave the \
		exosuit slightly more vulnerable to kinetic blows due to taking up valuable hull cushioning."
	icon_state = "mecha_abooster_emp"
	armor_mod = /datum/armor/mecha_equipment_energy_boost

/datum/armor/mecha_equipment_energy_boost
	melee = -5
	bullet = -10
	energy = 15

/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right)
	. = ..()
	chassis.AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)

/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster/detach(atom/moveto)
	chassis.RemoveElement(/datum/element/empprotection, EMP_PROTECT_WIRES)
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster/clandestine
	name = "exosuit hardened ablative insulation"
	desc = "Boosts exosuit armor against energy-based attacks. Also shields the exosuit's internal wiring from hostile EMP attacks."
	armor_mod = /datum/armor/mecha_equipment_improved_energy_boost

/datum/armor/mecha_equipment_improved_energy_boost
	energy = 20

////////////////////////////////// REPAIR DROID //////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "exosuit repair droid"
	desc = "An automated repair droid for exosuits. Scans for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	energy_drain = 50
	range = 0
	unstackable = TRUE
	can_be_toggled = TRUE
	active = FALSE
	equipment_slot = MECHA_UTILITY
	/// Repaired health per second
	var/health_boost = 0.5
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_CABIN_AIR_BREACH)

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	STOP_PROCESSING(SSobj, src)
	chassis?.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right = FALSE)
	. = ..()
	droid_overlay = new(src.icon, icon_state = "repair_droid")
	new_mecha.add_overlay(droid_overlay)

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.cut_overlay(droid_overlay)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/handle_ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "toggle")
		return
	chassis.cut_overlay(droid_overlay)
	if(active)
		START_PROCESSING(SSobj, src)
		droid_overlay = new(src.icon, icon_state = "repair_droid_a")
		log_message("Activated.", LOG_MECHA)
	else
		STOP_PROCESSING(SSobj, src)
		droid_overlay = new(src.icon, icon_state = "repair_droid")
		log_message("Deactivated.", LOG_MECHA)
	chassis.add_overlay(droid_overlay)


/obj/item/mecha_parts/mecha_equipment/repair_droid/process(seconds_per_tick)
	if(!chassis)
		return PROCESS_KILL
	var/h_boost = health_boost * seconds_per_tick
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost *= -2
	else if(chassis.internal_damage && SPT_PROB(8, seconds_per_tick))
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
		if(!chassis.use_energy(energy_drain))
			active = FALSE
			return PROCESS_KILL
	else //no repair needed, we turn off
		chassis.cut_overlay(droid_overlay)
		droid_overlay = new(src.icon, icon_state = "repair_droid")
		chassis.add_overlay(droid_overlay)
		active = FALSE
		return PROCESS_KILL


/////////////////////////////////////////// GENERATOR /////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/generator
	name = "plasma engine"
	desc = "An exosuit module that generates power using solid plasma as fuel."
	icon_state = "tesla"
	range = MECHA_MELEE
	equipment_slot = MECHA_POWER
	can_be_toggled = TRUE
	active = FALSE
	///Type of fuel the generator is using. Is set in generator_init() to add the starting amount of fuel
	var/obj/item/stack/sheet/fuel = null
	///Fuel used per second while idle, not generating, in units
	var/fuelrate_idle = 0.00625 * SHEET_MATERIAL_AMOUNT
	///Fuel used per second while actively generating, in units
	var/fuelrate_active = 0.05 * SHEET_MATERIAL_AMOUNT
	///Maximum fuel capacity of the generator, in units
	var/max_fuel = 75 * SHEET_MATERIAL_AMOUNT
	///Energy recharged per second
	var/rechargerate = 0.05 * STANDARD_CELL_RATE

/obj/item/mecha_parts/mecha_equipment/generator/Initialize(mapload)
	. = ..()
	generator_init()

/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	STOP_PROCESSING(SSobj, src)
	active = FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/get_snowflake_data()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_GENERATOR,
		"fuel" = fuel.amount,
	)

/obj/item/mecha_parts/mecha_equipment/generator/handle_ui_act(action, list/params)
	if(action == "toggle")
		if(active)
			to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Power generation enabled.")]")
			START_PROCESSING(SSobj, src)
			log_message("Activated.", LOG_MECHA)
		else
			to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Power generation disabled.")]")
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.", LOG_MECHA)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/generator/attackby(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!istype(weapon, fuel))
		return FALSE
	load_fuel(weapon, user)

/obj/item/mecha_parts/mecha_equipment/generator/process(seconds_per_tick)
	if(!chassis)
		active = FALSE
		return PROCESS_KILL
	if(fuel.amount <= 0)
		active = FALSE
		log_message("Deactivated - no fuel.", LOG_MECHA)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Fuel reserves depleted.")]")
		return PROCESS_KILL
	var/current_charge = chassis.get_charge()
	if(isnull(current_charge))
		active = FALSE
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("No power cell detected.")]")
		log_message("Deactivated.", LOG_MECHA)
		return PROCESS_KILL
	//how much fuel are we using per tick
	var/fuel_usage_rate = fuelrate_idle
	if(current_charge < chassis.cell.maxcharge)
		fuel_usage_rate = fuelrate_active
		chassis.give_power(rechargerate * seconds_per_tick)
	fuel.amount -= min(seconds_per_tick * fuel_usage_rate / SHEET_MATERIAL_AMOUNT, fuel.amount)

///Try to insert more fuel into the generator
/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/inserted_fuel, mob/user)
	if(inserted_fuel.amount == 0) //if we somehow have a sheet of 0 fuel
		to_chat(user, "[icon2html(src, user)][span_warning("[fuel] traces in target minimal! [inserted_fuel] cannot be used as fuel.")]")
		return
	//how much fuel is needed to fill the generator to its max capacity, in units
	var/units_to_load = max(max_fuel - fuel.amount * SHEET_MATERIAL_AMOUNT, 0)
	if(!units_to_load)
		to_chat(user, "[icon2html(src, user)][span_notice("Unit is full.")]")
		return
	//how much new fuel are we inserting, in sheets
	var/fuel_to_load = min(max(round(units_to_load / SHEET_MATERIAL_AMOUNT), 1), inserted_fuel.amount)
	fuel.amount += fuel_to_load
	inserted_fuel.use(fuel_to_load)
	to_chat(user, "[icon2html(src, user)][span_notice("[fuel_to_load] unit\s of [fuel] successfully loaded.")]")

///Introduces the actual fuel type to be used, as well as the starting amount of said fuel
/obj/item/mecha_parts/mecha_equipment/generator/proc/generator_init()
	fuel = new /obj/item/stack/sheet/mineral/plasma(src, 0)

/////////////////////////////////////////// THRUSTERS /////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/thrusters
	name = "generic exosuit thrusters" //parent object, in-game sources will be a child object
	desc = "A generic set of thrusters, from an unknown source. Uses not-understood methods to propel exosuits seemingly for free."
	icon_state = "thrusters"
	equipment_slot = MECHA_UTILITY
	can_be_toggled = TRUE
	active_label = "Thrusters"
	var/effect_type = /obj/effect/particle_effect/sparks

/obj/item/mecha_parts/mecha_equipment/thrusters/try_attach_part(mob/user, obj/vehicle/sealed/mecha/mecha, attach_right)
	for(var/obj/item/part in mecha.equip_by_category[MECHA_UTILITY])
		if(istype(part, src))
			to_chat(user, span_warning("[mecha] already has this thruster package!"))
			return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/attach(obj/vehicle/sealed/mecha/new_mecha, attach_right = FALSE)
	new_mecha.active_thrusters = src //Enable by default
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/detach(atom/moveto)
	if(chassis.active_thrusters == src)
		chassis.active_thrusters = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/thrusters/set_active(active)
	. = ..()
	if(active)
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

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/thrust(movement_dir)
	if(!chassis)
		return FALSE
	generate_effect(movement_dir)
	return TRUE //This parent should never exist in-game outside admeme use, so why not let it be a creative thruster?

/obj/item/mecha_parts/mecha_equipment/thrusters/proc/generate_effect(movement_dir)
	var/obj/effect/particle_effect/E = new effect_type(get_turf(chassis))
	E.dir = REVERSE_DIR(movement_dir)
	step(E, REVERSE_DIR(movement_dir))
	QDEL_IN(E, 5)

/obj/item/mecha_parts/mecha_equipment/thrusters/gas
	name = "RCS thruster package"
	desc = "A set of thrusters that allow for exosuit movement in zero-gravity environments, by expelling gas from the internal life support tank."
	effect_type = /obj/effect/particle_effect/fluid/smoke
	var/move_cost = 0.05 //moles per step (5 times more than human jetpacks)

/obj/item/mecha_parts/mecha_equipment/thrusters/gas/thrust(movement_dir)
	if(!chassis)
		return FALSE
	var/obj/machinery/portable_atmospherics/canister/internal_tank = chassis.get_internal_tank()
	if(!internal_tank)
		return FALSE
	var/datum/gas_mixture/our_mix = internal_tank.return_air()
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
	effect_type = /obj/effect/particle_effect/ion_trails

/obj/item/mecha_parts/mecha_equipment/thrusters/ion/thrust(movement_dir)
	if(!chassis)
		return FALSE
	if(chassis.use_energy(chassis.step_energy_drain))
		generate_effect(movement_dir)
		return TRUE
	return FALSE

///////////////////////////////////// CONCEALED WEAPON BAY ////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay
	name = "concealed weapon bay"
	desc = "A compartment that allows a non-combat mecha to equip one weapon while hiding the weapon from plain sight."
	icon_state = "mecha_weapon_bay"

/obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M)
	if(M.mech_type & EXOSUIT_MODULE_COMBAT)
		to_chat(user, span_warning("[M] does not have the correct bolt configuration!"))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay/special_attaching_interaction(attach_right = FALSE, obj/vehicle/sealed/mecha/mech, mob/user, checkonly = FALSE)
	if(checkonly)
		return TRUE
	var/obj/item/mecha_parts/mecha_equipment/existing_equip
	if(attach_right)
		existing_equip = mech.equip_by_category[MECHA_R_ARM]
	else
		existing_equip = mech.equip_by_category[MECHA_L_ARM]
	if(existing_equip)
		name = existing_equip.name
		icon = existing_equip.icon
		icon_state = existing_equip.icon_state
		qdel(existing_equip)
		user.visible_message(span_notice("[user] hollows out [src] and puts something in."), span_notice("You attach the concealed weapon bay to [mech] within the shell of [src]."))
	else
		user.visible_message(span_notice("[user] attaches [src] to [mech]."), span_notice("You attach [src] to [mech]."))
	attach(mech, attach_right)
	mech.mech_type |= EXOSUIT_MODULE_CONCEALED_WEP_BAY
	return TRUE

/obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay/detach(atom/moveto)
	var/obj/vehicle/sealed/mecha/mech = chassis
	. = ..()
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	if(!locate(/obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay) in mech.contents) //if no others exist
		mech.mech_type &= ~EXOSUIT_MODULE_CONCEALED_WEP_BAY

/obj/item/mecha_parts/camera_kit
	name = "exosuit-mounted camera"
	desc = "A security camera meant for exosuit-mounted surveillance-on-the-go."
	icon = 'icons/obj/devices/mecha_equipment.dmi'
	icon_state = "mecha_camera"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/mecha_parts/camera_kit/try_attach_part(mob/user, obj/vehicle/sealed/mecha/mech, attach_right)
	if(mech.chassis_camera)
		balloon_alert(user, "already has a camera!")
		return ITEM_INTERACT_BLOCKING

	. = ..()

	mech.chassis_camera = new /obj/machinery/camera/exosuit(mech)
	mech.chassis_camera.update_c_tag(mech)
	mech.diag_hud_set_camera()

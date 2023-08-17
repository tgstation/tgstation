/obj/vehicle/sealed/mecha/steam_helios
	name = "Steam Helios"
	desc = "A huge creation of bronze gears and steam, you have no idea how it stays together."
	icon = 'icons/mecha/coop_mech.dmi'
	base_icon_state = "savannah_ivanov"
	icon_state = "savannah_ivanov_0_0"
	color = rgb(190, 135, 0)
	mecha_flags = CANSTRAFE | IS_ENCLOSED | NOT_ABLE_TO_REMOVE_STOCK_PARTS
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 450
	armor_type = /datum/armor/mecha_steam_helios
	max_temperature = 30000
	force = 40
	destruction_sleep_duration = 4 SECONDS
	exit_delay = 4 SECONDS
	wreckage = /obj/structure/mecha_wreckage/steam_helios
	max_occupants = 2
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 0,
		MECHA_ARMOR = 1,
	)
	phasing_energy_drain = 0
	possible_int_damage = MECHA_INT_FIRE | MECHA_INT_CONTROL_LOST //fire is the only one that really makes sense but I dont want to have only one int damage possible
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/clock/bow_single_shot,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/clock/steam_cannon,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/repair_droid/clock),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/clock)
	)

/datum/armor/mecha_steam_helios
	melee = 35
	bullet = 40
	laser = 35
	energy = 30
	bomb = 40
	fire = 100
	acid = 100

//cant put new parts in
/obj/vehicle/sealed/mecha/steam_helios/add_cell()
	cell = new /obj/item/stock_parts/cell/clock(src)

/obj/vehicle/sealed/mecha/steam_helios/add_scanmod()
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic/clock(src) //walking is free

/obj/vehicle/sealed/mecha/steam_helios/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic/clock(src)

//kinda lame to lose it to a single heretic clicking it once
/obj/vehicle/sealed/mecha/steam_helios/rust_heretic_act()
	visible_message(span_warning("\The [src] glows for a second, but is uneffected by the magic!"))
	return

//restricted to servants only
/obj/vehicle/sealed/mecha/steam_helios/operation_allowed(mob/checked_mob)
	return IS_CLOCK(checked_mob)

/obj/vehicle/sealed/mecha/steam_helios/internals_access_allowed(mob/checked_mob)
	return IS_CLOCK(checked_mob)

/obj/vehicle/sealed/mecha/steam_helios/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]" //steam AOE

/obj/vehicle/sealed/mecha/steam_helios/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/steam_helios/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/steam_discharge, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/judicial_mark, VEHICLE_CONTROL_EQUIPMENT)

/datum/action/vehicle/sealed/mecha/judicial_mark
	name = "Judicial Mark"
	button_icon = 'monkestation/icons/mob/clock_cult/actions_clock.dmi'
	button_icon_state = "Judicial Marker"
	background_icon = 'monkestation/icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"
	///how often the action can be used
	var/mark_cooldown = 30 SECONDS
	var/currently_targeting = FALSE

/datum/action/vehicle/sealed/mecha/judicial_mark/Destroy()
	if(currently_targeting)
		end_mark_targeting()
	return ..()

/datum/action/vehicle/sealed/mecha/judicial_mark/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_JUDICIAL_MARK))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_JUDICIAL_MARK)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before marking another tile."))
		return

	if(currently_targeting)
		end_mark_targeting()
	else
		start_mark_targeting()

/datum/action/vehicle/sealed/mecha/judicial_mark/proc/start_mark_targeting()
	chassis.balloon_alert(owner, "click to choose where to place the center of the judicial marker")
	currently_targeting = TRUE
	RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(on_melee_click))
	RegisterSignal(chassis, COMSIG_MECHA_EQUIPMENT_CLICK, PROC_REF(on_equipment_click))

/datum/action/vehicle/sealed/mecha/judicial_mark/proc/end_mark_targeting()
	currently_targeting = FALSE
	UnregisterSignal(chassis, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))

///signal called from clicking with no equipment
/datum/action/vehicle/sealed/mecha/judicial_mark/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!target)
		return
	mark_tile(get_turf(target))

///signal called from clicking with equipment
/datum/action/vehicle/sealed/mecha/judicial_mark/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!target)
		return
	mark_tile(get_turf(target))

/datum/action/vehicle/sealed/mecha/judicial_mark/proc/mark_tile(turf/target_turf)
	end_mark_targeting()
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_JUDICIAL_MARK, mark_cooldown)
	new /obj/effect/judicial_mark(target_turf)
	button_icon_state = "Judicial Marker Recharging"
	build_all_button_icons()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/vehicle/sealed/mecha/judicial_mark, reset_button_icon)), mark_cooldown)

/datum/action/vehicle/sealed/mecha/judicial_mark/proc/reset_button_icon()
	button_icon_state = "Judicial Marker"
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/steam_discharge
	name = "Steam Discharge"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "smoke"
	background_icon = 'monkestation/icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"
	///how often the action can be used
	var/discharge_cooldown = 45 SECONDS

/datum/action/vehicle/sealed/mecha/steam_discharge/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_STEAM_DISCHARGE))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_STEAM_DISCHARGE)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before discharging steam again."))
		return

	INVOKE_ASYNC(src, PROC_REF(do_discharge))
	chassis.visible_message(span_warning("\The [chassis] releases a burst of steam!"))
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_STEAM_DISCHARGE, discharge_cooldown)

/datum/action/vehicle/sealed/mecha/steam_discharge/proc/do_discharge()
	var/turf/mech_turf = get_turf(chassis)
	if(!mech_turf)
		return
	playsound(chassis, 'sound/machines/clockcult/steam_whoosh.ogg', 100)
	var/list/all_turfs = RANGE_TURFS(5, mech_turf)
	for(var/steam_range in 0 to 5)
		for(var/turf/steam_turf in all_turfs)
			if(get_dist(mech_turf, steam_turf) > steam_range || isclosedturf(steam_turf))
				continue
			new /obj/effect/temp_visual/steam(steam_turf)
			for(var/mob/living/steam_target in steam_turf)
				if(IS_CLOCK(steam_target) || steam_target.throwing)
					continue
				steam_target.visible_message(span_warning("The steam from \The [chassis] sends [steam_target] flying backwards!"),
											 span_userdanger("The steam from \The [chassis] burns and sends you flying backwards!"))
				var/turf/thrownat = get_ranged_target_turf_direct(chassis, steam_target, 10, rand(-10, 10)) //easier to read
				steam_target.throw_at(thrownat, 8, 2, null, TRUE, force = MOVE_FORCE_OVERPOWERING, gentle = TRUE)
				steam_target.apply_damage((IS_CULTIST(steam_target) ? 30 : 20), BURN, wound_bonus = 30) //more damage to blood cultists
			all_turfs -= steam_turf
		sleep(0.2 SECONDS)

/obj/structure/mecha_wreckage/steam_helios
	name = "\improper Steam Helios wreckage"
	icon = 'icons/mecha/coop_mech.dmi'
	icon_state = "savannah_ivanov-broken"
	color = rgb(190, 135, 0)
	welder_salvage = list(/obj/item/stack/sheet/bronze)
	parts = null

/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/machines/sec.dmi'
	icon_state = "recharger"
	base_icon_state = "recharger"
	desc = "A charging dock for energy based weaponry, PDAs, and other devices."
	circuit = /obj/item/circuitboard/machine/recharger
	pass_flags = PASSTABLE
	/// The item currently inserted into the charger
	var/obj/item/charging = null
	/// How good the capacitor is at charging the item
	var/recharge_coeff = 1
	/// Did we put power into "charging" last process()?
	var/using_power = FALSE
	/// Did we finish recharging the currently inserted item?
	var/finished_recharging = FALSE
	/// List of items that can be recharged
	var/static/list/allowed_devices = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton/security,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/modular_computer,
		/obj/item/gun/ballistic/automatic/battle_rifle,
	))

/obj/machinery/recharger/RefreshParts()
	. = ..()
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		recharge_coeff = capacitor.tier

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(charging)
		. += {"[span_notice("\The [src] contains:")]
		[span_notice("- \A [charging].")]"}

	if(machine_stat & (NOPOWER|BROKEN))
		return
	var/status_display_message_shown = FALSE
	if(using_power)
		status_display_message_shown = TRUE
		. += span_notice("The status display reads:")
		. += span_notice("- Recharging efficiency: <b>[recharge_coeff*100]%</b>.")

	if(isnull(charging))
		return
	if(!status_display_message_shown)
		. += span_notice("The status display reads:")

	var/obj/item/stock_parts/power_store/charging_cell = charging.get_cell()
	if(charging_cell)
		. += span_notice("- \The [charging]'s cell is at <b>[charging_cell.percent()]%</b>.")
		return
	if(istype(charging, /obj/item/ammo_box/magazine/recharge))
		var/obj/item/ammo_box/magazine/recharge/power_pack = charging
		. += span_notice("- \The [charging]'s cell is at <b>[PERCENT(power_pack.stored_ammo.len/power_pack.max_ammo)]%</b>.")
		return
	if(istype(charging, /obj/item/gun/ballistic/automatic/battle_rifle))
		var/obj/item/gun/ballistic/automatic/battle_rifle/recalibrating_gun = charging
		. += span_notice("- \The [charging]'s system degradation is at stage [recalibrating_gun.degradation_stage] of [recalibrating_gun.degradation_stage_max]</b>.")
		. += span_notice("- \The [charging]'s degradation buffer is at <b>[PERCENT(recalibrating_gun.shots_before_degradation/recalibrating_gun.max_shots_before_degradation)]%</b>.")
		return
	. += span_notice("- \The [charging] is not reporting a power level.")

/obj/machinery/recharger/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(is_type_in_typecache(arrived, allowed_devices))
		charging = arrived
		START_PROCESSING(SSmachines, src)
		update_use_power(ACTIVE_POWER_USE)
		finished_recharging = FALSE
		using_power = TRUE
		update_appearance()
	return ..()

/obj/machinery/recharger/Exited(atom/movable/gone, direction)
	if(gone == charging)
		if(!QDELING(charging))
			charging.update_appearance()
		charging = null
		update_use_power(IDLE_POWER_USE)
		using_power = FALSE
		update_appearance()
	return ..()

/obj/machinery/recharger/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_type_in_typecache(tool, allowed_devices))
		return NONE

	if(!anchored)
		to_chat(user, span_notice("[src] isn't connected to anything!"))
		return ITEM_INTERACT_BLOCKING
	if(charging || panel_open)
		return ITEM_INTERACT_BLOCKING

	var/area/our_area = get_area(src) //Check to make sure user's not in space doing it, and that the area got proper power.
	if(!isarea(our_area) || our_area.power_equip == 0)
		to_chat(user, span_notice("[src] blinks red as you try to insert [tool]."))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = tool
		if(!energy_gun.can_charge)
			to_chat(user, span_notice("Your gun has no external power connector."))
			return ITEM_INTERACT_BLOCKING
	user.transferItemToLoc(tool, src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/recharger/wrench_act(mob/living/user, obj/item/tool)
	if(charging)
		to_chat(user, span_notice("Remove the charging item first!"))
		return ITEM_INTERACT_BLOCKING
	set_anchored(!anchored)
	power_change()
	to_chat(user, span_notice("You [anchored ? "attached" : "detached"] [src]."))
	tool.play_tool_sound(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/recharger/screwdriver_act(mob/living/user, obj/item/tool)
	if(!anchored || charging)
		return ITEM_INTERACT_BLOCKING
	. = default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool)
	if(.)
		update_appearance()

/obj/machinery/recharger/crowbar_act(mob/living/user, obj/item/tool)
	return (!anchored || charging) ? ITEM_INTERACT_BLOCKING : default_deconstruction_crowbar(tool)

/obj/machinery/recharger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	add_fingerprint(user)
	if(isnull(charging) || user.put_in_hands(charging))
		return
	charging.forceMove(drop_location())

/obj/machinery/recharger/attack_tk(mob/user)
	if(isnull(charging))
		return
	charging.forceMove(drop_location())
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/recharger/process(seconds_per_tick)
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return PROCESS_KILL

	using_power = FALSE
	if(isnull(charging))
		return PROCESS_KILL
	var/obj/item/stock_parts/power_store/charging_cell = charging.get_cell()
	if(charging_cell)
		if(charging_cell.charge < charging_cell.maxcharge)
			charge_cell(charging_cell.chargerate * recharge_coeff * seconds_per_tick, charging_cell)
			using_power = TRUE
		update_appearance()

	if(istype(charging, /obj/item/ammo_box/magazine/recharge)) //if you add any more snowflake ones, make sure to update the examine messages too.
		var/obj/item/ammo_box/magazine/recharge/power_pack = charging
		for(var/charge_iterations in 1 to recharge_coeff)
			if(power_pack.stored_ammo.len >= power_pack.max_ammo)
				break
			power_pack.stored_ammo += new power_pack.ammo_type(power_pack)
			use_energy(active_power_usage * seconds_per_tick)
			using_power = TRUE
		update_appearance()
		return

	if(istype(charging, /obj/item/gun/ballistic/automatic/battle_rifle))
		var/obj/item/gun/ballistic/automatic/battle_rifle/recalibrating_gun = charging

		if(recalibrating_gun.degradation_stage)
			recalibrating_gun.attempt_recalibration(FALSE)
			use_energy(active_power_usage * recharge_coeff * seconds_per_tick)
			using_power = TRUE

		else if(recalibrating_gun.shots_before_degradation < recalibrating_gun.max_shots_before_degradation)
			recalibrating_gun.attempt_recalibration(TRUE, 1 * recharge_coeff)
			use_energy(active_power_usage * recharge_coeff * seconds_per_tick)
			using_power = TRUE

		update_appearance()
		return

	if(!using_power && !finished_recharging) //Inserted thing is at max charge/ammo, notify those around us
		finished_recharging = TRUE
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		say("[charging] has finished recharging!")

/obj/machinery/recharger/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_CONTENTS)
		return
	if((machine_stat & (NOPOWER|BROKEN)) || !anchored)
		return
	if(istype(charging, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = charging
		if(energy_gun.cell)
			energy_gun.cell.emp_act(severity)

	else if(istype(charging, /obj/item/melee/baton/security))
		var/obj/item/melee/baton/security/batong = charging
		if(batong.cell)
			batong.cell.charge = 0

/obj/machinery/recharger/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return
	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]-open", alpha = src.alpha)
		return

	var/icon_to_use = "[base_icon_state]-[isnull(charging) ? "empty" : (using_power ? "charging" : "full")]"
	. += mutable_appearance(icon, icon_to_use, alpha = src.alpha)
	. += emissive_appearance(icon, icon_to_use, src, alpha = src.alpha)

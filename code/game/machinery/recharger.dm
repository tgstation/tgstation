/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger"
	base_icon_state = "recharger"
	desc = "A charging dock for energy based weaponry."
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 250
	circuit = /obj/item/circuitboard/machine/recharger
	pass_flags = PASSTABLE
	var/obj/item/charging = null
	var/recharge_coeff = 1
	var/using_power = FALSE //Did we put power into "charging" last process()?
	///Did we finish recharging the currently inserted item?
	var/finished_recharging = FALSE

	var/static/list/allowed_devices = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton/security,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/modular_computer,
	))

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(charging)
		. += {"[span_notice("\The [src] contains:")]
		[span_notice("- \A [charging].")]"}

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += span_notice("The status display reads:")
		. += span_notice("- Recharging <b>[recharge_coeff*10]%</b> cell charge per cycle.")
		if(charging)
			var/obj/item/stock_parts/cell/C = charging.get_cell()
			. += span_notice("- \The [charging]'s cell is at <b>[C.percent()]%</b>.")


/obj/machinery/recharger/proc/setCharging(new_charging)
	charging = new_charging
	if (new_charging)
		START_PROCESSING(SSmachines, src)
		update_use_power(ACTIVE_POWER_USE)
		finished_recharging = FALSE
		using_power = TRUE
		update_appearance()
	else
		update_use_power(IDLE_POWER_USE)
		using_power = FALSE
		update_appearance()

/obj/machinery/recharger/attackby(obj/item/G, mob/user, params)
	if(G.tool_behaviour == TOOL_WRENCH)
		if(charging)
			to_chat(user, span_notice("Remove the charging item first!"))
			return
		set_anchored(!anchored)
		power_change()
		to_chat(user, span_notice("You [anchored ? "attached" : "detached"] [src]."))
		G.play_tool_sound(src)
		return

	var/allowed = is_type_in_typecache(G, allowed_devices)

	if(allowed)
		if(anchored)
			if(charging || panel_open)
				return 1

			//Checks to make sure he's not in space doing it, and that the area got proper power.
			var/area/a = get_area(src)
			if(!isarea(a) || a.power_equip == 0)
				to_chat(user, span_notice("[src] blinks red as you try to insert [G]."))
				return 1

			if (istype(G, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = G
				if(!E.can_charge)
					to_chat(user, span_notice("Your gun has no external power connector."))
					return 1

			if(!user.transferItemToLoc(G, src))
				return 1
			setCharging(G)

		else
			to_chat(user, span_notice("[src] isn't connected to anything!"))
		return 1

	if(anchored && !charging)
		if(default_deconstruction_screwdriver(user, "recharger", "recharger", G))
			update_appearance()
			return

		if(panel_open && G.tool_behaviour == TOOL_CROWBAR)
			default_deconstruction_crowbar(G)
			return

	return ..()

/obj/machinery/recharger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	add_fingerprint(user)
	if(charging)
		charging.update_appearance()
		charging.forceMove(drop_location())
		user.put_in_hands(charging)
		setCharging(null)


/obj/machinery/recharger/attack_tk(mob/user)
	if(!charging)
		return
	charging.update_appearance()
	charging.forceMove(drop_location())
	setCharging(null)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/machinery/recharger/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return PROCESS_KILL

	using_power = FALSE
	if(charging)
		var/obj/item/stock_parts/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff * delta_time / 2)
				use_power(125 * recharge_coeff * delta_time)
				using_power = TRUE
			update_appearance()

		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				use_power(100 * recharge_coeff * delta_time)
				using_power = TRUE
			update_appearance()
			return
		if(!using_power && !finished_recharging) //Inserted thing is at max charge/ammo, notify those around us
			finished_recharging = TRUE
			playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
			say("[charging] has finished recharging!")

	else
		return PROCESS_KILL

/obj/machinery/recharger/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_CONTENTS)
		return
	if(!(machine_stat & (NOPOWER|BROKEN)) && anchored)
		if(istype(charging,  /obj/item/gun/energy))
			var/obj/item/gun/energy/E = charging
			if(E.cell)
				E.cell.emp_act(severity)

		else if(istype(charging, /obj/item/melee/baton/security))
			var/obj/item/melee/baton/security/batong = charging
			if(batong.cell)
				batong.cell.charge = 0

/obj/machinery/recharger/update_appearance(updates)
	. = ..()
	if((machine_stat & (NOPOWER|BROKEN)) || panel_open || !anchored)
		luminosity = 0
		return
	luminosity = 1

/obj/machinery/recharger/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]-open", alpha = src.alpha)
		return

	if(!charging)
		. += mutable_appearance(icon, "[base_icon_state]-empty", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-empty", alpha = src.alpha)
		return

	if(using_power)
		. += mutable_appearance(icon, "[base_icon_state]-charging", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-charging", alpha = src.alpha)
		return

	. += mutable_appearance(icon, "[base_icon_state]-full", alpha = src.alpha)
	. += emissive_appearance(icon, "[base_icon_state]-full", alpha = src.alpha)

/obj/machinery/computer/mecha
	name = "exosuit control console"
	desc = "Used to remotely locate or lockdown exosuits."
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/computer/mecha_control
	ui_x = 500
	ui_y = 500

/obj/machinery/computer/mecha/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "exosuit_control_console", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/mecha/ui_data(mob/user)
	var/list/data = list()

	var/list/trackerlist = list()
	for(var/obj/mecha/MC in GLOB.mechas_list)
		trackerlist += MC.trackers

	data["mechs"] = list()
	for(var/obj/item/mecha_parts/mecha_tracking/MT in trackerlist)
		if(!MT.chassis)
			continue
		var/obj/mecha/M = MT.chassis
		var/list/mech_data = list(
			name = M.name,
			integrity = round((M.obj_integrity / M.max_integrity) * 100),
			charge = M.cell ? round(M.cell.percent()) : null,
			airtank = M.internal_tank ? M.return_pressure() : null,
			pilot = M.occupant,
			location = get_area_name(M, TRUE),
			active_equipment = M.selected,
			emp_recharging = MT.recharging,
			tracker_ref = REF(MT)
		)
		if(istype(M, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/RM = M
			mech_data += list(
				cargo_space = round((RM.cargo.len / RM.cargo_capacity) * 100)
		)

		data["mechs"] += list(mech_data)

	return data

/obj/machinery/computer/mecha/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("send_message")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["tracker_ref"])
			if(!istype(MT))
				return
			var/message = stripped_input(usr, "Input message", "Transmit message")
			var/obj/mecha/M = MT.chassis
			if(trim(message) && M)
				M.occupant_message(message)
				to_chat(usr, "<span class='notice'>Message sent.</span>")
				. = TRUE
		if("shock")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["tracker_ref"])
			if(!istype(MT))
				return
			var/obj/mecha/M = MT.chassis
			if(M)
				MT.shock()
				log_game("[key_name(usr)] has activated remote EMP on exosuit [M], located at [loc_name(M)], which is currently [M.occupant? "being piloted by [key_name(M.occupant)]." : "without a pilot."] ")
				message_admins("[key_name_admin(usr)][ADMIN_FLW(usr)] has activated remote EMP on exosuit [M][ADMIN_JMP(M)], which is currently [M.occupant ? "being piloted by [key_name_admin(M.occupant)][ADMIN_FLW(M.occupant)]." : "without a pilot."] ")
				. = TRUE

/obj/item/mecha_parts/mecha_tracking
	name = "exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	w_class = WEIGHT_CLASS_SMALL
	/// If this beacon allows for AI control. Exists to avoid using istype() on checking
	var/ai_beacon = FALSE
	/// Cooldown variable for EMP pulsing
	var/recharging = FALSE
	/// The Mecha that this tracking beacon is attached to
	var/obj/mecha/chassis

/**
  * Returns a html formatted string describing attached mech status
  */
/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	if(!chassis)
		return FALSE

	var/cell_charge = chassis.get_charge()
	var/answer = {"<b>Name:</b> [chassis.name]<br>
				<b>Integrity:</b> [round((chassis.obj_integrity/chassis.max_integrity * 100), 0.01)]%<br>
				<b>Cell Charge:</b> [isnull(cell_charge) ? "Not Found":"[chassis.cell.percent()]%"]<br>
				<b>Airtank:</b> [chassis.internal_tank ? "[round(chassis.return_pressure(), 0.01)]" : "Not Equipped"] kPa<br>
				<b>Pilot:</b> [chassis.occupant || "None"]<br>
				<b>Location:</b> [get_area_name(chassis, TRUE) || "Unknown"]<br>
				<b>Active Equipment:</b> [chassis.selected || "None"]"}
	if(istype(chassis, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = chassis
		answer += "<br><b>Used Cargo Space:</b> [round((RM.cargo.len / RM.cargo_capacity * 100), 0.01)]%"

	return answer

/obj/item/mecha_parts/mecha_tracking/emp_act()
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		qdel(src)

/obj/item/mecha_parts/mecha_tracking/Destroy()
	if(chassis)
		if(src in chassis.trackers)
			chassis.trackers -= src
	chassis = null
	return ..()

/obj/item/mecha_parts/mecha_tracking/try_attach_part(mob/user, obj/mecha/M)
	if(!..())
		return
	M.trackers += src
	M.diag_hud_set_mechtracking()
	chassis = M

/**
  * Attempts to EMP mech that the tracker is attached to, if there is one and tracker is not on cooldown
  */
/obj/item/mecha_parts/mecha_tracking/proc/shock()
	if(recharging)
		return
	if(chassis)
		chassis.emp_act(EMP_HEAVY)
		addtimer(CALLBACK(src, /obj/item/mecha_parts/mecha_tracking/proc/recharge), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		recharging = TRUE

/**
  * Resets recharge variable, allowing tracker to be EMP pulsed again
  */
/obj/item/mecha_parts/mecha_tracking/proc/recharge()
	recharging = FALSE

/obj/item/mecha_parts/mecha_tracking/ai_control
	name = "exosuit AI control beacon"
	desc = "A device used to transmit exosuit data. Also allows active AI units to take control of said exosuit."
	ai_beacon = TRUE

/obj/item/storage/box/mechabeacons
	name = "exosuit tracking beacons"

/obj/item/storage/box/mechabeacons/PopulateContents()
	..()
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)

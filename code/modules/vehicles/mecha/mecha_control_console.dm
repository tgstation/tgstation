/obj/machinery/computer/mecha
	name = "exosuit control console"
	desc = "Used to remotely locate or lockdown exosuits."
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/computer/mecha_control

/obj/machinery/computer/mecha/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExosuitControlConsole", name)
		ui.open()

/obj/machinery/computer/mecha/ui_data(mob/user)
	var/list/data = list()

	var/list/trackerlist = list()
	for(var/obj/vehicle/sealed/mecha/MC in GLOB.mechas_list)
		trackerlist += MC.trackers

	data["mechs"] = list()
	for(var/obj/item/mecha_parts/mecha_tracking/MT in trackerlist)
		if(!MT.chassis)
			continue
		var/obj/vehicle/sealed/mecha/M = MT.chassis
		var/list/mech_data = list(
			name = M.name,
			integrity = round((M.get_integrity() / M.max_integrity) * 100),
			charge = M.cell ? round(M.cell.percent()) : null,
			airtank = (M.mecha_flags & IS_ENCLOSED) ? M.return_pressure() : null,
			pilot = M.return_drivers(),
			location = get_area_name(M, TRUE),
			emp_recharging = MT.recharging,
			tracker_ref = REF(MT)
		)
		if(istype(M, /obj/vehicle/sealed/mecha/ripley))
			var/obj/vehicle/sealed/mecha/ripley/workmech = M
			mech_data += list(
				cargo_space = round(workmech.cargo_hold.contents.len / workmech.cargo_hold.cargo_capacity * 100)
		)

		data["mechs"] += list(mech_data)

	return data

/obj/machinery/computer/mecha/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("send_message")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["tracker_ref"])
			if(!istype(MT))
				return
			var/message = tgui_input_text(usr, "Input message", "Transmit message")
			var/obj/vehicle/sealed/mecha/M = MT.chassis
			if(trim(message) && M)
				to_chat(M.occupants, message)
				to_chat(usr, span_notice("Message sent."))
				. = TRUE
		if("shock")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["tracker_ref"])
			if(!istype(MT))
				return
			var/obj/vehicle/sealed/mecha/M = MT.chassis
			if(M)
				MT.shock()
				usr.log_message("has activated remote EMP on exosuit [M], located at [loc_name(M)], which is currently [LAZYLEN(M.occupants) ? "occupied by [M.occupants.Join(", ")]." : "without a pilot."]", LOG_ATTACK)
				usr.log_message("has activated remote EMP on exosuit [M], located at [loc_name(M)], which is currently [LAZYLEN(M.occupants) ? "occupied by [M.occupants.Join(", ")]." : "without a pilot."]", LOG_GAME, log_globally = FALSE)
				message_admins("[key_name_admin(usr)][ADMIN_FLW(usr)] has activated remote EMP on exosuit [M][ADMIN_JMP(M)], which is currently [LAZYLEN(M.occupants) ? "occupied by [M.occupants.Join(",")][ADMIN_FLW(M)]." : "without a pilot."]")
				. = TRUE

/obj/item/mecha_parts/mecha_tracking
	name = "exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/devices/new_assemblies.dmi'
	icon_state = "motion2"
	w_class = WEIGHT_CLASS_SMALL
	/// If this beacon allows for AI control. Exists to avoid using istype() on checking
	var/ai_beacon = FALSE
	/// Cooldown variable for EMP pulsing
	var/recharging = FALSE
	/// The Mecha that this tracking beacon is attached to
	var/obj/vehicle/sealed/mecha/chassis

/**
 * Returns a html formatted string describing attached mech status
 */
/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	if(!chassis)
		return FALSE

	var/cell_charge = chassis.get_charge()
	var/answer = {"<b>Name:</b> [chassis.name]<br>
				<b>Integrity:</b> [round((chassis.get_integrity()/chassis.max_integrity * 100), 0.01)]%<br>
				<b>Cell Charge:</b> [isnull(cell_charge) ? "Not Found":"[chassis.cell.percent()]%"]<br>
				<b>Cabin Pressure:</b> [(chassis.mecha_flags & IS_ENCLOSED) ? "[round(chassis.return_pressure(), 0.01)] kPa" : "Not Sealed"]<br>
				<b>Pilot:</b> [english_list(chassis.return_drivers(), nothing_text = "None")]<br>
				<b>Location:</b> [get_area_name(chassis, TRUE) || "Unknown"]"}
	if(istype(chassis, /obj/vehicle/sealed/mecha/ripley))
		var/obj/item/mecha_parts/mecha_equipment/ejector/cargo_holder = locate(/obj/item/mecha_parts/mecha_equipment/ejector) in chassis.equip_by_category[MECHA_UTILITY]
		answer += "<br><b>Used Cargo Space:</b> [round((cargo_holder.contents.len / cargo_holder.cargo_capacity * 100), 0.01)]%"

	return answer

/obj/item/mecha_parts/mecha_tracking/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		qdel(src)

/obj/item/mecha_parts/mecha_tracking/Destroy()
	if(chassis)
		if(src in chassis.trackers)
			chassis.trackers -= src
	chassis = null
	return ..()

/obj/item/mecha_parts/mecha_tracking/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M, attach_right = FALSE)
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
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_tracking, recharge)), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
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

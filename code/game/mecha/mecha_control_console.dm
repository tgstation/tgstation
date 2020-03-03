/obj/machinery/computer/mecha
	name = "exosuit control console"
	desc = "Used to remotely locate or lockdown exosuits."
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/computer/mecha_control
	ui_x = 400
	ui_y = 500

/obj/machinery/computer/mecha/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "exosuit_control", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/mecha/ui_data(mob/user)
	var/list/data = list()

	var/list/trackerlist = list()
	for(var/obj/mecha/MC in GLOB.mechas_list)
		trackerlist += MC.trackers

	data["mechs"] = list()
	for(var/obj/item/mecha_parts/mecha_tracking/TR in trackerlist)
		if(!TR.in_mecha())
			continue
		var/obj/mecha/M = TR.loc
		var/list/mech_data = list(
			name = M.name,
			integrity = round((M.obj_integrity / M.max_integrity * 100), 0.01),
			charge = M.cell.percent(),
			airtank = round(M.return_pressure(), 0.01),
			pilot = M.occupant,
			location = get_area_name(M, TRUE),
			active_equipment = M.selected,
			ref = REF(M)
		)
		if(istype(M, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/RM = M
			var/cargo_space = round((RM.cargo.len / RM.cargo_capacity * 100), 0.01)
			mech_data += cargo_space

		data["mechs"] += list(mech_data)

	return data

/obj/machinery/computer/mecha/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("send_message")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["send_message"])
			if(!istype(MT))
				return
			var/message = stripped_input(usr, "Input message", "Transmit message")
			var/obj/mecha/M = MT.in_mecha()
			if(trim(message) && M)
				M.occupant_message(message)
				. = TRUE
		if("shock")
			var/obj/item/mecha_parts/mecha_tracking/MT = locate(params["shock"])
			if(istype(MT) && MT.chassis)
				MT.shock()
				log_game("[key_name(usr)] has activated remote EMP on exosuit [MT.chassis], located at [loc_name(MT.chassis)], which is currently [MT.chassis.occupant? "being piloted by [key_name(MT.chassis.occupant)]." : "without a pilot."] ")
				message_admins("[key_name_admin(usr)][ADMIN_FLW(usr)] has activated remote EMP on exosuit [MT.chassis][ADMIN_JMP(MT.chassis)], which is currently [MT.chassis.occupant? "being piloted by [key_name_admin(MT.chassis.occupant)][ADMIN_FLW(MT.chassis.occupant)]." : "without a pilot."] ")
				. = TRUE

/obj/item/mecha_parts/mecha_tracking
	name = "exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	w_class = WEIGHT_CLASS_SMALL
	var/ai_beacon = FALSE //If this beacon allows for AI control. Exists to avoid using istype() on checking.
	var/recharging = FALSE
	var/obj/mecha/chassis

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	if(!in_mecha())
		return FALSE
	var/obj/mecha/M = loc
	var/cell_charge = M.get_charge()
	var/answer = {"<b>Name:</b> [M.name]<br>
<b>Integrity:</b> [round((M.obj_integrity/M.max_integrity*100), 0.01)]%<br>
<b>Cell Charge:</b> [isnull(cell_charge)?"Not Found":"[M.cell.percent()]%"]<br>
<b>Airtank:</b> [M.internal_tank?"[round(M.return_pressure(), 0.01)]":"Not Equipped"] kPa<br>
<b>Pilot:</b> [M.occupant||"None"]<br>
<b>Location:</b> [get_area_name(M, TRUE)||"Unknown"]<br>
<b>Active Equipment:</b> [M.selected||"None"]"}
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer += "<br><b>Used Cargo Space:</b> [round((RM.cargo.len/RM.cargo_capacity*100), 0.01)]%"

	return answer

/obj/item/mecha_parts/mecha_tracking/emp_act()
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		qdel(src)

/obj/item/mecha_parts/mecha_tracking/Destroy()
	if(ismecha(loc))
		var/obj/mecha/M = loc
		if(src in M.trackers)
			M.trackers -= src
	chassis = null
	return ..()

/obj/item/mecha_parts/mecha_tracking/try_attach_part(mob/user, obj/mecha/M)
	if(!..())
		return
	M.trackers += src
	M.diag_hud_set_mechtracking()
	chassis = M

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(ismecha(loc))
		return loc
	return FALSE

/obj/item/mecha_parts/mecha_tracking/proc/shock()
	if(recharging)
		return
	var/obj/mecha/M = in_mecha()
	if(M)
		M.emp_act(EMP_HEAVY)
		addtimer(CALLBACK(src, /obj/item/mecha_parts/mecha_tracking/proc/recharge), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		recharging = TRUE

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

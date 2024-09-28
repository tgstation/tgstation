/obj/machinery/computer/apc_control
	name = "power flow control console"
	desc = "Used to remotely control the flow of power to different parts of the station."
	icon_screen = "solar"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_CE)
	circuit = /obj/item/circuitboard/computer/apc_control
	light_color = LIGHT_COLOR_DIM_YELLOW
	var/obj/machinery/power/apc/active_apc //The APC we're using right now
	var/should_log = TRUE
	var/restoring = FALSE
	var/list/logs
	var/auth_id = "\[NULL\]:"

/obj/machinery/computer/apc_control/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	logs = list()

/obj/machinery/computer/apc_control/on_set_machine_stat(old_value)
	. = ..()
	if(machine_stat)
		disconnect_apc()

/obj/machinery/computer/apc_control/attack_ai(mob/user)
	if(!isAdminGhostAI(user))
		to_chat(user,span_warning("[src] does not support AI control.")) //You already have APC access, cheater!
		return
	..()

/obj/machinery/computer/apc_control/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if (user)
		user.log_message("emagged [src].", LOG_ATTACK, color="red")
		balloon_alert(user, "access controller shorted")
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/computer/apc_control/proc/log_activity(log_text)
	if(!should_log)
		return
	LAZYADD(logs, "([station_time_timestamp()]): [auth_id] [log_text]")

/obj/machinery/computer/apc_control/proc/restore_comp(mob/user)
	obj_flags &= ~EMAGGED
	should_log = TRUE
	user.log_message("restored the logs of [src].", LOG_GAME)
	log_activity("-=- Logging restored to full functionality at this point -=-")
	restoring = FALSE

/obj/machinery/computer/apc_control/proc/connect_apc(obj/machinery/power/apc/apc, mob/user)
	if(isnull(apc))
		return
	if(apc.remote_control_user)
		to_chat(user, span_warning("\The [apc] is being controlled by someone else!"))
		return
	if(active_apc)
		disconnect_apc()
	playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 50, FALSE)
	apc.connect_remote_access(user)
	user.log_message("remotely accessed [apc] from [src].", LOG_GAME)
	log_activity("[auth_id] remotely accessed APC in [get_area_name(apc.area, TRUE)]")
	active_apc = apc

/obj/machinery/computer/apc_control/proc/disconnect_apc()
	// check if apc exists and is not controlled by anyone
	if(QDELETED(active_apc))
		return
	if(active_apc.remote_control_user)
		active_apc.disconnect_remote_access()
	active_apc = null

/obj/machinery/computer/apc_control/proc/check_apc(obj/machinery/power/apc/APC)
	return APC.z == z && !APC.malfhack && !APC.aidisabled && !(APC.obj_flags & EMAGGED) && !APC.machine_stat && !istype(APC.area, /area/station/ai_monitored)

/obj/machinery/computer/apc_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApcControl")
		ui.open()

/obj/machinery/computer/apc_control/ui_data(mob/user)
	var/list/data = list()
	data["auth_id"] = auth_id
	data["authenticated"] = authenticated
	data["emagged"] = obj_flags & EMAGGED
	data["logging"] = should_log
	data["restoring"] = restoring
	data["logs"] = list()
	data["apcs"] = list()

	for(var/entry in logs)
		data["logs"] += list(list("entry" = entry))

	for(var/obj/machinery/power/apc/apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(check_apc(apc))
			var/has_cell = (apc.cell) ? TRUE : FALSE
			data["apcs"] += list(list(
					"name" = apc.area.name,
					"operating" = apc.operating,
					"charge" = (has_cell) ? apc.cell.percent() : "NOCELL",
					"load" = display_power(apc.lastused_total),
					"charging" = apc.charging,
					"chargeMode" = apc.chargemode,
					"eqp" = apc.equipment,
					"lgt" = apc.lighting,
					"env" = apc.environ,
					"responds" = apc.aidisabled || apc.panel_open,
					"ref" = REF(apc)
				)
			)
	return data

/obj/machinery/computer/apc_control/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("log-in")
			if(obj_flags & EMAGGED)
				authenticated = TRUE
				auth_id = "Unknown (Unknown):"
				log_activity("[auth_id] logged in to the terminal")
				return
			var/mob/living/operator = usr
			if(!istype(operator))
				return
			var/obj/item/card/id/ID = operator.get_idcard(TRUE)
			if(ID && istype(ID))
				if(check_access(ID))
					authenticated = TRUE
					auth_id = "[ID.registered_name] ([ID.assignment]):"
					log_activity("[auth_id] logged in to the terminal")
					playsound(src, 'sound/machines/terminal/terminal_on.ogg', 50, FALSE)
				else
					auth_id = "[ID.registered_name] ([ID.assignment]):"
					log_activity("[auth_id] attempted to log into the terminal")
					playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
					say("ID rejected, access denied!")
				return
			auth_id = "Unknown (Unknown):"
			log_activity("[auth_id] attempted to log into the terminal")
		if("log-out")
			log_activity("[auth_id] logged out of the terminal")
			playsound(src, 'sound/machines/terminal/terminal_off.ogg', 50, FALSE)
			authenticated = FALSE
			auth_id = "\[NULL\]"
		if("toggle-logs")
			should_log = !should_log
			usr.log_message("set the logs of [src] [should_log ? "On" : "Off"].", LOG_GAME)
		if("restore-console")
			restoring = TRUE
			addtimer(CALLBACK(src, PROC_REF(restore_comp)), rand(3,5) * 9 SECONDS)
		if("access-apc")
			var/ref = params["ref"]
			playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)
			var/obj/machinery/power/apc/APC = locate(ref) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
			connect_apc(APC, usr)
		if("check-logs")
			log_activity("Checked Logs")
		if("check-apcs")
			log_activity("Checked APCs")
		if("toggle-minor")
			var/ref = params["ref"]
			var/type = params["type"]
			var/value = params["value"]
			var/obj/machinery/power/apc/target = locate(ref) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
			if(!target)
				return

			value = target.setsubsystem(text2num(value))
			switch(type) // Sanity check
				if("equipment", "lighting", "environ")
					target.vars[type] = value
				else
					message_admins("Warning: possible href exploit by [key_name(usr)] - attempted to set [html_encode(type)] on [target] to [html_encode(value)]")
					usr.log_message("possibly trying to href exploit - attempted to set [html_encode(type)] on [target] to [html_encode(value)]", LOG_ADMIN)
					return

			target.update_appearance()
			target.update()
			var/setTo = ""
			switch(target.vars[type])
				if(0)
					setTo = "Off"
				if(1)
					setTo = "Auto Off"
				if(2)
					setTo = "On"
				if(3)
					setTo = "Auto On"
			log_activity("Set APC [target.area.name] [type] to [setTo]")
			usr.log_message("set APC [target.area.name] [type] to [setTo]]", LOG_GAME)
		if("breaker")
			var/ref = params["ref"]
			var/obj/machinery/power/apc/target = locate(ref) in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
			target.toggle_breaker(usr)
			var/setTo = target.operating ? "On" : "Off"
			log_activity("Turned APC [target.area.name]'s breaker [setTo]")

/obj/machinery/computer/apc_control/ui_close(mob/user)
	. = ..()
	if(active_apc)
		disconnect_apc()

/obj/machinery/computer/apc_control/away
	req_access = list(ACCESS_AWAY_ENGINEERING)

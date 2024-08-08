/// List of all implants currently implanted into a mob
GLOBAL_LIST_EMPTY_TYPED(tracked_implants, /obj/item/implant)

/obj/machinery/computer/prisoner/management
	name = "prisoner management console"
	desc = "Used to modify prisoner IDs, as well as manage security implants placed inside convicts and parolees."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	light_color = COLOR_SOFT_RED
	circuit = /obj/item/circuitboard/computer/prisoner

/obj/machinery/computer/prisoner/management/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PrisonerManagement")
		ui.open()

/obj/machinery/computer/prisoner/management/ui_data(mob/user)
	var/list/data = list()

	data["authorized"] = (authenticated && isliving(user)) || HAS_SILICON_ACCESS(user)
	data["inserted_id"] = null
	if(!isnull(contained_id))
		data["inserted_id"] = list(
			"name" = contained_id.name,
			"points" = contained_id.points,
			"goal" = contained_id.goal,
		)

	var/list/implants = list()
	for(var/obj/item/implant/implant as anything in GLOB.tracked_implants)
		if(!implant.is_shown_on_console(src))
			continue
		var/list/implant_data = list()
		implant_data["info"] = implant.get_management_console_data()
		implant_data["buttons"] = implant.get_management_console_buttons()
		implant_data["category"] = initial(implant.name)
		implant_data["ref"] = REF(implant)
		UNTYPED_LIST_ADD(implants, implant_data)
	data["implants"] = implants

	return data

/obj/machinery/computer/prisoner/management/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!authenticated && action != "login")
		CRASH("[usr] potentially spoofed ui action [action] on prisoner console without the console being logged in.")

	if(isliving(usr))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

	switch(action)
		if("login")
			if(allowed(usr))
				authenticated = TRUE
				playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
			else
				playsound(src, 'sound/machines/terminal_error.ogg', 50, FALSE)
			return TRUE

		if("logout")
			authenticated = FALSE
			playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)
			return TRUE

		if("insert_id")
			id_insert(usr, usr.get_active_held_item())
			return TRUE

		if("eject_id")
			id_eject(usr)
			return TRUE

		if("set_id_goal")
			var/num = tgui_input_number(usr, "Enter the prisoner's goal", "Prisoner Management", 100, 1000, 1)
			if(!isnum(num) || QDELETED(src) || QDELETED(contained_id) || QDELETED(usr))
				return TRUE
			if(!is_operational || !usr.can_perform_action(src, NEED_DEXTERITY|ALLOW_SILICON_REACH))
				return TRUE

			contained_id.goal = num
			return TRUE

		if("reset_id")
			contained_id.points = 0
			return TRUE

		if("handle_implant")
			var/obj/item/implant/affected_implant = locate(params["implant_ref"]) in GLOB.tracked_implants
			if(affected_implant?.is_shown_on_console(src))
				affected_implant.handle_management_console_action(usr, params, src)
			return TRUE

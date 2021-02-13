#define CARDCON_DEPARTMENT_SERVICE "Service"
#define CARDCON_DEPARTMENT_SECURITY "Security"
#define CARDCON_DEPARTMENT_MEDICAL "Medical"
#define CARDCON_DEPARTMENT_SUPPLY "Supply"
#define CARDCON_DEPARTMENT_SCIENCE "Science"
#define CARDCON_DEPARTMENT_ENGINEERING "Engineering"
#define CARDCON_DEPARTMENT_COMMAND "Command"

/datum/computer_file/program/card_mod
	filename = "plexagonidwriter"
	filedesc = "Plexagon Access Management"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for programming employee ID cards to access parts of the station."
	transfer_access = ACCESS_HEADS
	requires_ntnet = 0
	size = 8
	tgui_id = "NtosCard"
	program_icon = "id-card"

	var/is_centcom = FALSE
	var/minor = FALSE
	/// The name/assignment combo of the ID card used to authenticate.
	var/authenticated_user
	var/list/region_access
	var/list/head_subordinates
	///Which departments this computer has access to. Defined as access regions. null = all departments
	var/target_dept

	//For some reason everything was exploding if this was static.
	var/list/sub_managers

/datum/computer_file/program/card_mod/New(obj/item/modular_computer/comp)
	. = ..()
	sub_managers = list(
		"[ACCESS_HOP]" = list(
			"department" = list(CARDCON_DEPARTMENT_SERVICE, CARDCON_DEPARTMENT_COMMAND),
			"region" = 1,
			"head" = "Head of Personnel"
		),
		"[ACCESS_HOS]" = list(
			"department" = CARDCON_DEPARTMENT_SECURITY,
			"region" = 2,
			"head" = "Head of Security"
		),
		"[ACCESS_CMO]" = list(
			"department" = CARDCON_DEPARTMENT_MEDICAL,
			"region" = 3,
			"head" = "Chief Medical Officer"
		),
		"[ACCESS_RD]" = list(
			"department" = CARDCON_DEPARTMENT_SCIENCE,
			"region" = 4,
			"head" = "Research Director"
		),
		"[ACCESS_CE]" = list(
			"department" = CARDCON_DEPARTMENT_ENGINEERING,
			"region" = 5,
			"head" = "Chief Engineer"
		)
	)

/datum/computer_file/program/card_mod/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if(!id_card)
		return

	region_access = list()
	if(!target_dept && (ACCESS_CHANGE_IDS in id_card.timberpoes_access))
		minor = FALSE
		authenticated_user = "[id_card.name]"
		update_static_data(user)
		return TRUE

	var/list/head_types = list()
	for(var/access_text in sub_managers)
		var/list/info = sub_managers[access_text]
		var/access = text2num(access_text)
		if((access in id_card.timberpoes_access) && ((info["region"] in target_dept) || !length(target_dept)))
			region_access += info["region"]
			//I don't even know what I'm doing anymore
			head_types += info["head"]

	head_subordinates = list()
	if(length(head_types))
		for(var/j in SSjob.occupations)
			var/datum/job/job = j
			for(var/head in head_types)//god why
				if(head in job.department_head)
					head_subordinates += job.title

	if(length(region_access))
		minor = TRUE
		authenticated_user = "[id_card.name] \[LIMITED ACCESS\]"
		update_static_data(user)
		return TRUE

	return FALSE

/datum/computer_file/program/card_mod/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/card_slot/card_slot2
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		card_slot = computer.all_components[MC_CARD]
		card_slot2 = computer.all_components[MC_CARD2]
		printer = computer.all_components[MC_PRINT]
		if(!card_slot || !card_slot2)
			return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = card_slot.stored_card
	var/obj/item/card/id/target_id_card = card_slot2.stored_card

	switch(action)
		// Log in.
		if("PRG_authenticate")
			if(!computer || !user_id_card)
				playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return TRUE
			if(authenticate(user, user_id_card))
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				return TRUE
		// Log out.
		if("PRG_logout")
			authenticated_user = null
			playsound(computer, 'sound/machines/terminal_off.ogg', 50, FALSE)
			return TRUE
		// Print a report.
		if("PRG_print")
			if(!computer || !printer)
				return TRUE
			if(!authenticated_user)
				return TRUE
			var/contents = {"<h4>Access Report</h4>
						<u>Prepared By:</u> [user_id_card?.registered_name ? user_id_card.registered_name : "Unknown"]<br>
						<u>For:</u> [target_id_card.registered_name ? target_id_card.registered_name : "Unregistered"]<br>
						<hr>
						<u>Assignment:</u> [target_id_card.assignment]<br>
						<u>Access:</u><br>
						"}

			var/known_access_rights = ALL_ACCESS_STATION
			for(var/A in target_id_card.timberpoes_access)
				if(A in known_access_rights)
					contents += "  [get_access_desc(A)]"

			if(!printer.print_text(contents,"access report"))
				to_chat(usr, "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>")
				return TRUE
			else
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				computer.visible_message("<span class='notice'>\The [computer] prints out a paper.</span>")
			return TRUE
		// Eject the ID used to log on to the ID app.
		if("PRG_ejectauthid")
			if(!computer || !card_slot)
				return TRUE
			if(user_id_card)
				return card_slot.try_eject(user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					return card_slot.try_insert(I, user)
		// Eject the ID being modified.
		if("PRG_ejectmodid")
			if(!computer || !card_slot2)
				return TRUE
			if(target_id_card)
				GLOB.data_core.manifest_modify(target_id_card.registered_name, target_id_card.assignment)
				return card_slot2.try_eject(user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					return card_slot2.try_insert(I, user)
			return TRUE
		// Used to fire someone. Wipes all access from their card and modifies their assignment.
		if("PRG_terminate")
			if(!computer || !authenticated_user)
				return TRUE
			if(minor)
				if(!(target_id_card.assignment in head_subordinates) && target_id_card.assignment != "Assistant")
					return TRUE

			// TIMBERTODO - DON'T FORGOT ABOUT THIS SHIT. MORE ELEGANT SOLUTION?
			target_id_card.clear_access()
			target_id_card.assignment = "Unassigned (Employment Terminated)"
			target_id_card.update_label()
			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		// Change ID card assigned name.
		if("PRG_edit")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
			// would not pass as a formal character name, but would still be valid on an ID card created by a player.
			var/new_name = sanitize(params["name"])
			// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
			new_name = reject_bad_name(new_name, allow_numbers = TRUE)

			if(!new_name)
				to_chat(usr, "<span class='notice'>Software error: The ID card rejected the new name as it contains prohibited characters.</span>")
				return TRUE

			target_id_card.registered_name = new_name
			target_id_card.update_label()
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		// Change age
		if("PRG_age")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			target_id_card.registered_age = params["id_age"]
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		// Change assignment
		if("PRG_assign")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			target_id_card.assignment = params["assignment"]
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		// Add/remove access.
		if("PRG_access")
			if(!computer || !authenticated_user)
				return TRUE
			playsound(computer, "terminal_type", 50, FALSE)
			var/access_type = params["access_target"]
			if(access_type in (is_centcom ? CENTCOM_ACCESS : ALL_ACCESS_STATION))
				if(access_type in target_id_card.timberpoes_access)
					target_id_card.remove_access(list(access_type))
					LOG_ID_ACCESS_CHANGE(user, target_id_card, "removed [get_access_desc(access_type)]")
					return TRUE

				if(!target_id_card.add_access(list(access_type)))
					to_chat(usr, "<span class='notice'>ID error: ID card rejected your attempted access.</span>")
					LOG_ID_ACCESS_CHANGE(user, target_id_card, "failed to add [get_access_desc(access_type)]")
					return TRUE

				if(access_type in ACCESS_ALERT_ADMINS)
					message_admins("[ADMIN_LOOKUPFLW(user)] just added [get_access_desc(access_type)] to an ID card [ADMIN_VV(target_id_card)] [(target_id_card.registered_name) ? "belonging to [target_id_card.registered_name]." : "with no registered name."]")
				LOG_ID_ACCESS_CHANGE(user, target_id_card, "added [get_access_desc(access_type)]")
			return TRUE


/datum/computer_file/program/card_mod/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()
	data["centcom_access"] = is_centcom
	data["minor"] = target_dept || minor ? TRUE : FALSE

	var/list/departments = target_dept
	if(is_centcom)
		departments = list("CentCom" = ALL_CENTCOM_JOBS_LIST)
	else if(isnull(departments))
		departments = list(
			CARDCON_DEPARTMENT_COMMAND = list("Captain"),//lol
			CARDCON_DEPARTMENT_ENGINEERING = GLOB.engineering_positions,
			CARDCON_DEPARTMENT_MEDICAL = GLOB.medical_positions,
			CARDCON_DEPARTMENT_SCIENCE = GLOB.science_positions,
			CARDCON_DEPARTMENT_SECURITY = GLOB.security_positions,
			CARDCON_DEPARTMENT_SUPPLY = GLOB.supply_positions,
			CARDCON_DEPARTMENT_SERVICE = GLOB.service_positions
		)

	var/list/regions = list()
	if(is_centcom)
		var/list/accesses = list()
		for(var/access in CENTCOM_ACCESS)
			if (get_centcom_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_centcom_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = "CentCom",
			"regid" = 0,
			"accesses" = accesses
		))
	else
		for(var/i in 1 to 7)
			if((minor || target_dept) && !(i in region_access))
				continue

			var/list/accesses = list()
			for(var/access in get_region_accesses(i))
				if (get_access_desc(access))
					accesses += list(list(
						"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
						"ref" = access,
					))

			regions += list(list(
				"name" = get_region_accesses_name(i),
				"regid" = i,
				"accesses" = accesses
			))

	data["regions"] = regions

	data["accessFlags"] = SSid_access.flags_by_access
	data["wildcardFlags"] = SSid_access.wildcard_flags_by_wildcard
	data["accessFlagNames"] = SSid_access.access_flag_string_by_flag

	return data

/datum/computer_file/program/card_mod/ui_data(mob/user)
	var/list/data = get_header_data()

	data["station_name"] = station_name()

	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/card_slot/card_slot2
	var/obj/item/computer_hardware/printer/printer

	if(computer)
		card_slot = computer.all_components[MC_CARD]
		card_slot2 = computer.all_components[MC_CARD2]
		printer = computer.all_components[MC_PRINT]
		data["have_auth_card"] = !!(card_slot)
		data["have_id_slot"] = !!(card_slot2)
		data["have_printer"] = !!(printer)
	else
		data["have_id_slot"] = FALSE
		data["have_printer"] = FALSE

	if(!card_slot2)
		return data //We're just gonna error out on the js side at this point anyway

	var/obj/item/card/id/auth_card = card_slot.stored_card
	data["hasAuthID"] = !!auth_card
	data["authIDName"] = auth_card ? auth_card.name : "-----"

	data["authenticatedUser"] = authenticated_user

	var/obj/item/card/id/id_card = card_slot2.stored_card
	data["has_id"] = !!id_card
	data["id_name"] = id_card ? id_card.name : "-----"
	if(id_card)
		data["id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card.registered_name ? id_card.registered_name : "-----"
		data["access_on_card"] = id_card.timberpoes_access
		data["wildcardSlots"] = id_card.wildcard_slots
		data["id_age"] = id_card.registered_age

		if(id_card.timberpoes_trim)
			var/datum/id_trim/card_trim = id_card.timberpoes_trim
			data["hasTrim"] = TRUE
			data["trimAssignment"] = card_trim.assignment ? card_trim.assignment : ""
			data["trimAccess"] = card_trim.access ? card_trim.access : null
		else
			data["hasTrim"] = FALSE
			data["trimAssignment"] = ""
			data["trimAccess"] = null

	return data

#undef CARDCON_DEPARTMENT_SERVICE
#undef CARDCON_DEPARTMENT_SECURITY
#undef CARDCON_DEPARTMENT_MEDICAL
#undef CARDCON_DEPARTMENT_SCIENCE
#undef CARDCON_DEPARTMENT_SUPPLY
#undef CARDCON_DEPARTMENT_ENGINEERING
#undef CARDCON_DEPARTMENT_COMMAND

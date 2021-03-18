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

	/// If TRUE, this program only modifies Centcom accesses.
	var/is_centcom = FALSE
	/// If TRUE, this program is authenticated with limited departmental access.
	var/minor = FALSE
	/// The name/assignment combo of the ID card used to authenticate.
	var/authenticated_user
	/// The regions this program has access to based on the authenticated ID.
	var/list/region_access = list()
	/// The list of accesses this program is verified to change based on the authenticated ID. Used for state checking against player input.
	var/list/valid_access = list()
	/// List of job templates that can be applied to ID cards from this program.
	var/list/job_templates = list()
	/// Which departments this program has access to. See region defines.
	var/target_dept

/**
 * Authenticates the program based on the specific ID card.
 *
 * If the card has ACCESS_CHANGE_IDs, it authenticates with all options.
 * Otherwise, it authenticates depending on SSid_access.sub_department_managers_tgui
 * compared to the access on the supplied ID card.
 * Arguments:
 * * user - Program's user.
 * * id_card - The ID card to attempt to authenticate under.
 */
/datum/computer_file/program/card_mod/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if(!id_card)
		return

	region_access.Cut()
	valid_access.Cut()
	job_templates.Cut()

	// If the program isn't locked to a specific department or is_centcom and we have ACCESS_CHANGE_IDS in our auth card, we're not minor.
	if((!target_dept || is_centcom) && (ACCESS_CHANGE_IDS in id_card.access))
		minor = FALSE
		authenticated_user = "[id_card.name]"
		job_templates = is_centcom ? SSid_access.centcom_job_templates.Copy() : SSid_access.station_job_templates.Copy()
		valid_access = is_centcom ? SSid_access.get_region_access_list(list(REGION_CENTCOM)) : SSid_access.get_region_access_list(list(REGION_ALL_STATION))
		update_static_data(user)
		return TRUE

	// Otherwise, we're minor and now we have to build a list of restricted departments we can change access for.
	var/list/managers = SSid_access.sub_department_managers_tgui
	for(var/access_as_text in managers)
		var/list/info = managers[access_as_text]
		var/access = text2num(access_as_text)
		if((access in id_card.access) && ((target_dept in info["regions"]) || !target_dept))
			region_access |= info["regions"]
			job_templates |= info["templates"]

	if(length(region_access))
		minor = TRUE
		valid_access |= SSid_access.get_region_access_list(region_access)
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

			var/list/known_access_rights = SSid_access.get_region_access_list(list(REGION_ALL_STATION))
			for(var/A in target_id_card.access)
				if(A in known_access_rights)
					contents += "  [SSid_access.get_access_desc(A)]"

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
				if(!(target_id_card.trim?.type in job_templates))
					to_chat(usr, "<span class='notice'>Software error: You do not have the necessary permissions to demote this card.</span>")
					return TRUE

			// Set the new assignment then remove the trim.
			target_id_card.assignment = is_centcom ? "Fired" : "Demoted"
			SSid_access.remove_trim_from_card(target_id_card)

			playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
			return TRUE
		// Change ID card assigned name.
		if("PRG_edit")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			var/old_name = target_id_card.registered_name

			// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
			// would not pass as a formal character name, but would still be valid on an ID card created by a player.
			var/new_name = sanitize(params["name"])

			if(!new_name)
				target_id_card.registered_name = null
				playsound(computer, "terminal_type", 50, FALSE)
				target_id_card.update_label()
				// We had a name before and now we have no name, so this will unassign the card and we update the icon.
				if(old_name)
					target_id_card.update_icon()
				return TRUE

			// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
			new_name = reject_bad_name(new_name, allow_numbers = TRUE)

			if(!new_name)
				to_chat(usr, "<span class='notice'>Software error: The ID card rejected the new name as it contains prohibited characters.</span>")
				return TRUE

			target_id_card.registered_name = new_name
			playsound(computer, "terminal_type", 50, FALSE)
			target_id_card.update_label()
			// Card wasn't assigned before and now it is, so update the icon accordingly.
			if(!old_name)
				target_id_card.update_icon()
			return TRUE
		// Change age
		if("PRG_age")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			var/new_age = params["id_age"]
			if(!isnum(new_age))
				stack_trace("[key_name(usr)] ([usr]) attempted to set invalid age \[[new_age]\] to [target_id_card]")
				return TRUE

			target_id_card.registered_age = new_age
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		// Change assignment
		if("PRG_assign")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			var/new_asignment = sanitize(params["assignment"])
			target_id_card.assignment = new_asignment
			playsound(computer, "terminal_type", 50, FALSE)
			target_id_card.update_label()
			return TRUE
		// Add/remove access.
		if("PRG_access")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			playsound(computer, "terminal_type", 50, FALSE)
			var/access_type = params["access_target"]
			var/try_wildcard = params["access_wildcard"]
			if(!(access_type in valid_access))
				stack_trace("[key_name(usr)] ([usr]) attempted to add invalid access \[[access_type]\] to [target_id_card]")
				return TRUE

			if(access_type in target_id_card.access)
				target_id_card.remove_access(list(access_type))
				LOG_ID_ACCESS_CHANGE(user, target_id_card, "removed [SSid_access.get_access_desc(access_type)]")
				return TRUE

			if(!target_id_card.add_access(list(access_type), try_wildcard))
				to_chat(usr, "<span class='notice'>ID error: ID card rejected your attempted access modification.</span>")
				LOG_ID_ACCESS_CHANGE(user, target_id_card, "failed to add [SSid_access.get_access_desc(access_type)][try_wildcard ? " with wildcard [try_wildcard]" : ""]")
				return TRUE

			if(access_type in ACCESS_ALERT_ADMINS)
				message_admins("[ADMIN_LOOKUPFLW(user)] just added [SSid_access.get_access_desc(access_type)] to an ID card [ADMIN_VV(target_id_card)] [(target_id_card.registered_name) ? "belonging to [target_id_card.registered_name]." : "with no registered name."]")
			LOG_ID_ACCESS_CHANGE(user, target_id_card, "added [SSid_access.get_access_desc(access_type)]")
			return TRUE
		// Apply template to ID card.
		if("PRG_template")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			playsound(computer, "terminal_type", 50, FALSE)
			var/template_name = params["name"]

			if(!template_name)
				return TRUE

			for(var/trim_path in job_templates)
				var/datum/id_trim/trim = SSid_access.trim_singletons_by_path[trim_path]
				if(trim.assignment != template_name)
					continue

				SSid_access.add_trim_access_to_card(target_id_card, trim_path)
				return TRUE

			stack_trace("[key_name(usr)] ([usr]) attempted to apply invalid template \[[template_name]\] to [target_id_card]")

			return TRUE

/datum/computer_file/program/card_mod/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()
	data["centcom_access"] = is_centcom
	data["minor"] = target_dept || minor ? TRUE : FALSE

	var/list/regions = list()
	var/list/tgui_region_data = SSid_access.all_region_access_tgui
	if(is_centcom)
		regions += tgui_region_data[REGION_CENTCOM]
	else
		for(var/region in SSid_access.station_regions)
			if((minor || target_dept) && !(region in region_access))
				continue
			regions += tgui_region_data[region]

	data["regions"] = regions


	data["accessFlags"] = SSid_access.flags_by_access
	data["wildcardFlags"] = SSid_access.wildcard_flags_by_wildcard
	data["accessFlagNames"] = SSid_access.access_flag_string_by_flag
	data["showBasic"] = TRUE
	data["templates"] = job_templates

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
	data["authIDName"] = auth_card ? auth_card.name : "-----"

	data["authenticatedUser"] = authenticated_user

	var/obj/item/card/id/id_card = card_slot2.stored_card
	data["has_id"] = !!id_card
	data["id_name"] = id_card ? id_card.name : "-----"
	if(id_card)
		data["id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card.registered_name ? id_card.registered_name : "-----"
		data["access_on_card"] = id_card.access
		data["wildcardSlots"] = id_card.wildcard_slots
		data["id_age"] = id_card.registered_age

		if(id_card.trim)
			var/datum/id_trim/card_trim = id_card.trim
			data["hasTrim"] = TRUE
			data["trimAssignment"] = card_trim.assignment ? card_trim.assignment : ""
			data["trimAccess"] = card_trim.access ? card_trim.access : list()
		else
			data["hasTrim"] = FALSE
			data["trimAssignment"] = ""
			data["trimAccess"] = list()

	return data

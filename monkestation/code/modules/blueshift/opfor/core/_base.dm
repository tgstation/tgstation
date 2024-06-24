/datum/opposing_force_selected_equipment
	/// Reference to the selected equipment datum.
	var/datum/opposing_force_equipment/opposing_force_equipment
	/// Why does the user need this?
	var/reason = ""
	/// What is the status of this item?
	var/status = OPFOR_EQUIPMENT_STATUS_NOT_REVIEWED
	/// If denied, why?
	var/denied_reason = ""
	/// How many does the user want?
	var/count = 1

/datum/opposing_force_selected_equipment/New(datum/opposing_force_equipment/opfor_equipment)
	if(opfor_equipment)
		opposing_force_equipment = opfor_equipment

/datum/opposing_force_selected_equipment/Destroy(force)
	opposing_force_equipment = null
	return ..()

/// Called when the gear is issued, use for unique services (e.g. a power outage) that don't have an item
/datum/opposing_force_equipment/proc/on_issue(mob/living/target)
	return

/datum/opposing_force_objective
	/// The name of the objective
	var/title = ""
	/// The actual objective.
	var/description = ""
	/// The reason for the objective.
	var/justification = ""
	/// Was this specific objective approved by the admins?
	var/status = OPFOR_OBJECTIVE_STATUS_NOT_REVIEWED
	/// Why was this objective denied? If a reason was specified.
	var/denied_reason = ""
	/// How intense is this goal?
	var/intensity = 1
	/// The text intensity of this goal
	var/text_intensity = OPFOR_OBJECTIVE_INTENSITY_1

/datum/opposing_force
	/// A list of objectives.
	var/list/objectives = list()
	/// Justification for wanting to do bad things.
	var/set_backstory = ""
	/// Has this been approved?
	var/status = OPFOR_STATUS_NOT_SUBMITTED
	/// Hard ref to our mind.
	var/datum/mind/mind_reference
	/// For logging stuffs
	var/list/modification_log = list()
	/// Can we edit things?
	var/can_edit = TRUE
	/// The reason we were denied.
	var/denied_reason = ""
	/// Have we been request update muted by an admin?
	var/request_updates_muted = FALSE
	/// A text list of the admin chat.
	var/list/admin_chat = list()
	/// Have we issued the player their equipment?
	var/equipment_issued = FALSE
	/// A list of equipment that the user has requested.
	var/list/selected_equipment = list()
	/// Are we blocked from submitting a new request?
	var/blocked = FALSE
	/// What admin has this request been assigned to?
	var/handling_admin = ""
	/// The ckey of the person that made this application
	var/ckey
	/// Corresponding stat() click button
	var/obj/effect/statclick/opfor_specific/stat_button
	/// If it is part of the ticket ping subsystem
	var/ticket_ping = FALSE

	COOLDOWN_DECLARE(static/request_update_cooldown)
	COOLDOWN_DECLARE(static/ping_cooldown)

/datum/opposing_force/New(datum/mind/mind_reference)
	src.mind_reference = mind_reference
	ckey = ckey(mind_reference.key)
	send_system_message("[ckey] created the application")
	stat_button = new()
	stat_button.opfor = src

/datum/opposing_force/Destroy(force)
	mind_reference.opposing_force = null
	mind_reference = null
	SSopposing_force.remove_opfor(src)
	QDEL_LIST(objectives)
	QDEL_LIST(admin_chat)
	QDEL_LIST(modification_log)
	QDEL_NULL(stat_button)
	return ..()

/datum/opposing_force/Topic(href, list/href_list)
	if(href_list["admin_pref"])
		if(!check_rights(R_ADMIN))
			CRASH("Opposing_force TOPIC: Detected possible HREF exploit! ([usr])")
		ui_interact(usr)
		return TRUE

/// Builds the HTML panel entry for the round end report
/datum/opposing_force/proc/build_html_panel_entry()
	var/list/opfor_entry = list("<b>[mind_reference.key]</b> - ")
	opfor_entry += "<a href='?priv_msg=[ckey(mind_reference.key)]'>PM</a> "
	if(mind_reference.current)
		opfor_entry += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(mind_reference?.current)]'>FLW</a> "
	opfor_entry += "<a href='?src=[REF(src)];admin_pref=show_panel'>Show OPFOR Panel</a>"
	return opfor_entry.Join()

/datum/opposing_force/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OpposingForcePanel")
		ui.open()

/datum/opposing_force/ui_state(mob/user)
	return GLOB.always_state

/datum/opposing_force/ui_data(mob/user)
	var/list/data = list()

	var/client/owner_client = GLOB.directory[ckey]
	data["admin_mode"] = check_rights_for(user.client, R_ADMIN) && user.client != owner_client

	data["creator_ckey"] = ckey

	data["owner_antag"] = (mind_reference.current in GLOB.current_living_antags)

	data["backstory"] = set_backstory

	data["raw_status"] = status

	data["status"] = get_status_string()

	data["can_submit"] = SSopposing_force.accepting_objectives && (status == OPFOR_STATUS_NOT_SUBMITTED || status == OPFOR_STATUS_CHANGES_REQUESTED)

	data["can_request_update"] = (status == OPFOR_STATUS_AWAITING_APPROVAL && COOLDOWN_FINISHED(src, request_update_cooldown))

	data["request_updates_muted"] = request_updates_muted

	data["blocked"] = blocked

	data["can_edit"] = can_edit

	data["approved"] = status == OPFOR_STATUS_APPROVED ? TRUE : FALSE

	data["denied"] = status == OPFOR_STATUS_DENIED ? TRUE : FALSE

	data["handling_admin"] = handling_admin

	data["equipment_issued"] = equipment_issued

	data["owner_mob"] = mind_reference.current ? mind_reference.current.name : "No mob!"

	data["owner_role"] = mind_reference.assigned_role ? mind_reference.assigned_role.title : "No role!"

	var/list/messages = list()
	for(var/message in admin_chat)
		messages.Add(list(list(
			"msg" = message
		)))
	data["messages"] = messages

	data["objectives"] = list()
	var/objective_num = 1
	for(var/datum/opposing_force_objective/opfor as anything in objectives)
		var/list/objective_data = list(
			"id" = objective_num,
			"ref" = REF(opfor),
			"title" = opfor.title,
			"description" = opfor.description,
			"intensity" = opfor.intensity,
			"text_intensity" = opfor.text_intensity,
			"justification" = opfor.justification,
			"approved" = opfor.status == OPFOR_OBJECTIVE_STATUS_APPROVED ? TRUE : FALSE,
			"status_text" = opfor.status,
			"denied_text" = opfor.denied_reason,
			)
		objective_num++
		data["objectives"] += list(objective_data)

	data["equipment_issued"] = equipment_issued

	data["equipment_list"] = list()
	for(var/equipment_category in SSopposing_force.equipment_list)
		var/category_items = list()
		for(var/datum/opposing_force_equipment/opfor_equipment as anything in SSopposing_force.equipment_list[equipment_category])
			category_items += list(list(
				"ref" = REF(opfor_equipment),
				"name" = opfor_equipment.name,
				"description" = opfor_equipment.description,
				"equipment_category" = opfor_equipment.category,
				"admin_note" = opfor_equipment.admin_note,
			))
		data["equipment_list"] += list(list(
			"category" = equipment_category,
			"items" = category_items,
		))

	data["selected_equipment"] = list()
	for(var/datum/opposing_force_selected_equipment/equipment as anything in selected_equipment)
		var/list/equipment_data = list(
			"ref" = REF(equipment),
			"name" = equipment.opposing_force_equipment.name,
			"description" = equipment.opposing_force_equipment.description,
			"item" = equipment.opposing_force_equipment.item_type,
			"status" = equipment.status,
			"approved" = equipment.status == OPFOR_EQUIPMENT_STATUS_APPROVED ? TRUE : FALSE,
			"reason" = equipment.reason,
			"denied_reason" = equipment.denied_reason,
			"count" = equipment.count,
			"admin_note" = equipment.opposing_force_equipment.admin_note,
			)
		data["selected_equipment"] += list(equipment_data)

	data["current_crew"] = generate_optin_crew_list()

	return data

/datum/opposing_force/ui_static_data(mob/user)
	var/list/data = list()

	data["opt_in_colors"] = GLOB.antag_opt_in_colors
	data["opt_in_enabled"] = (!CONFIG_GET(flag/disable_antag_opt_in_preferences))

	return data

/datum/opposing_force/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/opposing_force_objective/edited_objective
	if(params["objective_ref"])
		edited_objective = locate(params["objective_ref"]) in objectives
		if(!edited_objective)
			return

	switch(action)
		// General control
		if("set_backstory")
			set_backstory(usr, params["backstory"])
		if("request_update")
			request_update(usr)
		if("modify_request")
			modify_request(usr)
		if("close_application")
			close_application(usr)
		if("submit")
			submit_to_subsystem(usr)
		if("send_message")
			send_message(usr, params["message"])
			if(!handling_admin && check_rights_for(usr.client, R_ADMIN) && usr != mind_reference)
				handle(usr) // if an admin sends a message and it's not being handled, assign them as handling it
		// Objective control
		if("add_objective")
			add_objective(usr)
		if("remove_objective")
			remove_objective(usr, edited_objective)
		if("set_objective_title")
			set_objective_title(usr, edited_objective, params["title"])
		if("set_objective_description")
			set_objective_description(usr, edited_objective, params["new_desciprtion"])
		if("set_objective_justification")
			set_objective_justification(usr, edited_objective, params["new_justification"])
		if("set_objective_intensity")
			set_objective_intensity(usr, edited_objective, params["new_intensity_level"])
		// Equipment control
		if("select_equipment")
			var/datum/opposing_force_equipment/equipment
			for(var/category in SSopposing_force.equipment_list)
				equipment = locate(params["equipment_ref"]) in SSopposing_force.equipment_list[category]
				if(equipment)
					break
			if(!equipment)
				return
			select_equipment(usr, equipment)
		if("remove_equipment")
			var/datum/opposing_force_selected_equipment/equipment = locate(params["selected_equipment_ref"]) in selected_equipment
			if(!equipment)
				return
			remove_equipment(usr, equipment)
		if("set_equipment_reason")
			var/datum/opposing_force_selected_equipment/equipment = locate(params["selected_equipment_ref"]) in selected_equipment
			if(!equipment)
				return
			set_equipment_reason(usr, equipment, params["new_equipment_reason"])
		if("set_equipment_count")
			var/datum/opposing_force_selected_equipment/equipment = locate(params["selected_equipment_ref"]) in selected_equipment
			if(!equipment)
				return
			set_equipment_count(usr, equipment, params["new_equipment_count"])

		// JSON I/O control
		if("import_json")
			if(!length(SSopposing_force.equipment_list)) // sanity check
				return
			json_import(usr)
		if("export_json")
			json_export(usr)

		//Admin protected procs
		if("approve")
			if(!check_rights(R_ADMIN))
				return
			for(var/datum/opposing_force_objective/objective as anything in objectives)
				if(objective.status == OPFOR_OBJECTIVE_STATUS_NOT_REVIEWED)
					to_chat(usr, examine_block(span_command_headset(span_pink("OPFOR: ERROR, some objectives have not been reviewed. Please approve/deny all objectives."))))
					return
			for(var/datum/opposing_force_selected_equipment/equipment as anything in selected_equipment)
				if(equipment.status == OPFOR_EQUIPMENT_STATUS_NOT_REVIEWED)
					to_chat(usr, examine_block(span_command_headset(span_pink("OPFOR: ERROR, some equipment requests have not been reviewed. Please approve/deny all equipment requests."))))
					return
			SSopposing_force.approve(src, usr)
		if("approve_all")
			if(!check_rights(R_ADMIN))
				return
			approve_all(usr)
		if("handle")
			handle(usr)
		if("issue_gear")
			if(!check_rights(R_ADMIN))
				return
			issue_gear(usr)
		if("deny")
			if(!check_rights(R_ADMIN))
				return
			var/denied_reason = tgui_input_text(usr, "Denial Reason", "Enter a reason for denying this application:")
			// Checking to see if the user is spamming the button, async and all.
			if((status == OPFOR_STATUS_DENIED) || !denied_reason)
				return
			SSopposing_force.deny(src, denied_reason, usr)
		if("mute_request_updates")
			if(!check_rights(R_ADMIN))
				return
			mute_request_updates(usr)
		if("toggle_block")
			if(!check_rights(R_ADMIN))
				return
			toggle_block(usr)
		if("approve_objective")
			if(!check_rights(R_ADMIN))
				return
			approve_objective(usr, edited_objective)
		if("deny_objective")
			if(!check_rights(R_ADMIN))
				return
			var/denied_reason = tgui_input_text(usr, "Denial Reason", "Enter a reason for denying this objective:")
			if(!denied_reason)
				return
			deny_objective(usr, edited_objective, denied_reason)
		if("approve_equipment")
			var/datum/opposing_force_selected_equipment/equipment = locate(params["selected_equipment_ref"]) in selected_equipment
			if(!equipment)
				return
			if(!check_rights(R_ADMIN))
				return
			approve_equipment(usr, equipment)
		if("deny_equipment")
			var/datum/opposing_force_selected_equipment/equipment = locate(params["selected_equipment_ref"]) in selected_equipment
			if(!equipment)
				return
			if(!check_rights(R_ADMIN))
				return
			var/denied_reason = tgui_input_text(usr, "Denial Reason", "Enter a reason for denying this objective:")
			if(!denied_reason)
				return
			deny_equipment(usr, equipment, denied_reason)
		if("flw_user")
			if(!check_rights(R_ADMIN))
				return
			flw_user(usr)

/datum/opposing_force/proc/flw_user(mob/user)
	user.client?.admin_follow(mind_reference.current)

/datum/opposing_force/proc/set_equipment_count(mob/user, datum/opposing_force_selected_equipment/equipment, new_count)
	var/sanitized_newcount = sanitize_integer(new_count, 1, equipment.opposing_force_equipment.max_amount)
	equipment.count = new_count
	add_log(user.ckey, "Set equipment '[equipment.opposing_force_equipment.name] count to [sanitized_newcount]")

/datum/opposing_force/proc/handle(mob/user)
	if(handling_admin)
		var/choice = tgui_alert(user, "Another admin is currently handling this application, do you want to override them?", "Admin Handling", list("Yes", "No"))
		if(choice == "No")
			return
	handling_admin = get_admin_ckey(user)
	to_chat(mind_reference.current, examine_block(span_nicegreen("Your OPFOR application is now being handled by [handling_admin].")))
	send_admins_opfor_message("HANDLE: [ADMIN_LOOKUPFLW(user)] is handling [mind_reference.key]'s OPFOR application.")
	send_system_message("[handling_admin] has assigned themselves to this application")
	add_log(user.ckey, "Assigned self to application")

/datum/opposing_force/proc/mute_request_updates(mob/user, override = "none")
	if(override != "none")
		request_updates_muted = override
	else
		request_updates_muted = !request_updates_muted
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] [request_updates_muted ? "muted" : "unmuted"] the help requests function")
	add_log(user.ckey, "[request_updates_muted ? "Muted" : "Unmuted"] user from opposing force help requests.")

/datum/opposing_force/proc/toggle_block(mob/user, override = "none")
	if(override != "none")
		blocked = override
	else
		blocked = !blocked
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] blocked you from submitting new requests")
	add_log(user.ckey, "Blocked user from opposing force requests.")

/**
 * Equipment procs
 */

/datum/opposing_force/proc/deny_equipment(mob/user, datum/opposing_force_selected_equipment/incoming_equipment, denied_reason = "")
	if(incoming_equipment.status == OPFOR_EQUIPMENT_STATUS_DENIED)
		return
	incoming_equipment.status = OPFOR_EQUIPMENT_STATUS_DENIED
	incoming_equipment.denied_reason = denied_reason
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has denied equipment '[incoming_equipment.opposing_force_equipment.name]'[denied_reason ? " with the reason '[denied_reason]'" : ""]")
	add_log(user.ckey, "Denied equipment: [incoming_equipment.opposing_force_equipment.name] with reason: [denied_reason]")

/datum/opposing_force/proc/approve_equipment(mob/user, datum/opposing_force_selected_equipment/incoming_equipment)
	if(incoming_equipment.status == OPFOR_EQUIPMENT_STATUS_APPROVED)
		return
	incoming_equipment.status = OPFOR_EQUIPMENT_STATUS_APPROVED
	incoming_equipment.denied_reason = ""
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has approved equipment '[incoming_equipment.opposing_force_equipment.name]'")
	add_log(user.ckey, "Approved equipment: [incoming_equipment.opposing_force_equipment.name]")

/datum/opposing_force/proc/set_equipment_reason(mob/user, datum/opposing_force_selected_equipment/incoming_equipment, new_reason)
	if(!can_edit)
		return
	if(!incoming_equipment)
		CRASH("set_equipment_reason tried to update a non existent opfor equipment datum!")
	var/sanitized_reason = replacetext(STRIP_HTML_SIMPLE(new_reason, OPFOR_TEXT_LIMIT_DESCRIPTION), "\"", " ")
	add_log(user.ckey, "Updated equipment([incoming_equipment.opposing_force_equipment.name]) REASON from: [incoming_equipment.reason] to: [sanitized_reason]")
	incoming_equipment.reason = sanitized_reason
	return TRUE

/datum/opposing_force/proc/remove_equipment(mob/user, datum/opposing_force_selected_equipment/incoming_equipment)
	if(!can_edit)
		return
	add_log(user.ckey, "Removed equipment: [incoming_equipment.opposing_force_equipment.name]")
	selected_equipment -= incoming_equipment
	qdel(incoming_equipment)

/datum/opposing_force/proc/select_equipment(mob/user, datum/opposing_force_equipment/incoming_equipment, reason)
	if(!can_edit)
		return
	if(LAZYLEN(selected_equipment) >= OPFOR_EQUIPMENT_LIMIT)
		to_chat(user, span_warning("You have too many items, please remove one!"))
		return
	var/datum/opposing_force_selected_equipment/new_selected = new(incoming_equipment)
	selected_equipment += new_selected
	add_log(user.ckey, "Selected equipment: [incoming_equipment.name]")
	return new_selected

/datum/opposing_force/proc/issue_gear(mob/user)
	if(!selected_equipment.len || !isliving(mind_reference.current) || status != OPFOR_STATUS_APPROVED || equipment_issued)
		return
	var/mob/living/target = mind_reference.current
	for(var/datum/opposing_force_selected_equipment/iterating_equipment as anything in selected_equipment)
		if(iterating_equipment.status != OPFOR_EQUIPMENT_STATUS_APPROVED)
			continue
		for(var/i in 1 to iterating_equipment.count)
			if(!(iterating_equipment.opposing_force_equipment.item_type == /obj/effect/gibspawner/generic)) // This is what's used in place of an item in uplinks, so it's the same here
				new iterating_equipment.opposing_force_equipment.item_type(get_turf(target))
			iterating_equipment.opposing_force_equipment.on_issue(target)

	add_log(user.ckey, "Issued gear")
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has issued all approved equipment")
	equipment_issued = TRUE

/**
 * Control procs
 */

/datum/opposing_force/proc/request_update(mob/user)
	if(request_updates_muted)
		to_chat(user, span_warning("You are currently blocked from requesting updates!"))
		return
	if(status != OPFOR_STATUS_AWAITING_APPROVAL || !COOLDOWN_FINISHED(src, request_update_cooldown))
		return

	send_admins_opfor_message(span_command_headset("UPDATE REQUEST: [ADMIN_LOOKUPFLW(user)] has requested an update on their OPFOR application!"))
	add_log(user.ckey, "Requested an update")

	for(var/client/staff as anything in GLOB.admins)
		if(staff?.prefs?.toggles & SOUND_ADMINHELP)
			SEND_SOUND(staff, sound('sound/effects/adminhelp.ogg'))
		window_flash(staff)

	COOLDOWN_START(src, request_update_cooldown, OPFOR_REQUEST_UPDATE_COOLDOWN)

/datum/opposing_force/proc/submit_to_subsystem(mob/user)
	if(blocked)
		to_chat(user, span_warning("You are currently blocked from submitting new requests!"))
		return
	if(status != OPFOR_STATUS_NOT_SUBMITTED && status != OPFOR_STATUS_CHANGES_REQUESTED)
		return FALSE
	// Subsystem checks, no point in bloating the system if it's not accepting more.
	var/availability = SSopposing_force.check_availability()
	if(availability != OPFOR_SUBSYSTEM_READY)
		to_chat(usr, span_warning("Error, the OPFOR subsystem rejected your request. Reason: <b>[availability]</b>"))
		return FALSE

	var/queue_position = SSopposing_force.add_to_queue(src)

	for(var/client/staff as anything in GLOB.admins)
		if(staff?.prefs?.toggles & SOUND_ADMINHELP)
			SEND_SOUND(staff, sound('sound/effects/adminhelp.ogg'))
		window_flash(staff, ignorepref = TRUE)

	addtimer(CALLBACK(src, PROC_REF(add_to_ping_ss)), 2 MINUTES) // this is not responsible for the notification itself, but only for adding the ticket to the list of those to notify.
	status = OPFOR_STATUS_AWAITING_APPROVAL
	can_edit = FALSE
	add_log(user.ckey, "Submitted to the OPFOR subsystem")
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has submitted the application for review")
	send_admins_opfor_message(span_command_headset("SUBMISSION: [ADMIN_LOOKUPFLW(user)] has submitted their OPFOR application. They are number [queue_position] in the queue."))
	to_chat(usr, examine_block(span_nicegreen(("You have been added to the queue for the OPFOR subsystem. You are number <b>[queue_position]</b> in line."))))

/datum/opposing_force/proc/modify_request(mob/user)
	if(status == OPFOR_STATUS_CHANGES_REQUESTED)
		return
	var/choice = tgui_alert(user, "Are you sure you want to request changes? This will unapprove all objectives.", "Confirm", list("Yes", "No"))
	if(choice != "Yes")
		return
	if(status == OPFOR_STATUS_CHANGES_REQUESTED) // The alert is not async, so this could change, thus being spammed.
		return
	for(var/datum/opposing_force_objective/opfor in objectives)
		opfor.status = OPFOR_OBJECTIVE_STATUS_NOT_REVIEWED
	status = OPFOR_STATUS_CHANGES_REQUESTED
	SSopposing_force.modify_request(src)
	can_edit = TRUE

	add_log(user.ckey, "Modify request submitted")
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has requested modifications to the application")
	send_admins_opfor_message("CHANGES REQUESTED: [ADMIN_LOOKUPFLW(user)] has submitted a modify request, their application has been reset.")

/datum/opposing_force/proc/deny(mob/denier, reason = "")
	if(status == OPFOR_STATUS_DENIED)
		return
	status = OPFOR_STATUS_DENIED
	can_edit = FALSE
	denied_reason = reason

	for(var/datum/opposing_force_selected_equipment/iterating_equipment as anything in selected_equipment)
		iterating_equipment.status = OPFOR_EQUIPMENT_STATUS_DENIED
	for(var/datum/opposing_force_objective/opfor in objectives)
		opfor.status = OPFOR_OBJECTIVE_STATUS_DENIED
	SEND_SOUND(mind_reference.current, sound('monkestation/code/modules/blueshift/opfor/sound/denied.ogg'))
	add_log(denier.ckey, "Denied application")
	to_chat(mind_reference.current, examine_block(span_redtext("Your OPFOR application has been denied by [denier ? get_admin_ckey(denier) : "the OPFOR subsystem"]!")))
	send_system_message(get_admin_ckey(denier) + " has denied the application with the following reason: [reason]")
	send_admins_opfor_message("[span_red("DENIED")]: [ADMIN_LOOKUPFLW(denier)] has denied [ckey]'s application([reason ? reason : "No reason specified"])")
	//ticket_counter_add_handled(denier.key, 1)

/datum/opposing_force/proc/approve(mob/approver)
	if(status == OPFOR_STATUS_APPROVED)
		return
	status = OPFOR_STATUS_APPROVED
	can_edit = FALSE

	SEND_SOUND(mind_reference.current, sound('monkestation/code/modules/blueshift/opfor/sound/approved.ogg'))
	add_log(approver.ckey, "Approved application")
	var/objective_denied = FALSE
	for(var/datum/opposing_force_objective/opfor_obj as anything in objectives)
		if(!(opfor_obj.status == OPFOR_OBJECTIVE_STATUS_DENIED))
			continue
		objective_denied = TRUE
		break
	to_chat(mind_reference.current, examine_block(span_greentext("Your OPFOR application has been [objective_denied ? span_bold("partially approved (please view your OPFOR for details)") : span_bold("fully approved")] by [approver ? get_admin_ckey(approver) : "the OPFOR subsystem"]!")))
	send_system_message("[approver ? get_admin_ckey(approver) : "The OPFOR subsystem"] has approved the application")
	send_admins_opfor_message("[span_green("APPROVED")]: [ADMIN_LOOKUPFLW(approver)] has approved [ckey]'s application")
	//ticket_counter_add_handled(approver.key, 1)

/datum/opposing_force/proc/close_application(mob/user)
	if(status == OPFOR_STATUS_NOT_SUBMITTED)
		return
	var/choice = tgui_alert(user, "Are you sure you want withdraw your application?", "Confirm", list("Yes", "No"))
	if(choice != "Yes")
		return
	if(status == OPFOR_STATUS_NOT_SUBMITTED) // The alert is not async, so this could change, thus being spammed.
		return
	SSopposing_force.unsubmit_opfor(src)
	status = OPFOR_STATUS_NOT_SUBMITTED
	can_edit = TRUE

	for(var/datum/opposing_force_selected_equipment/iterating_equipment as anything in selected_equipment)
		iterating_equipment.status = OPFOR_EQUIPMENT_STATUS_NOT_REVIEWED
	for(var/datum/opposing_force_objective/opfor as anything in objectives)
		opfor.status = OPFOR_OBJECTIVE_STATUS_NOT_REVIEWED

	add_log(user.ckey, "Withdrew application")
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has closed the application")

/datum/opposing_force/proc/set_backstory(mob/user, incoming_backstory)
	if(!can_edit)
		return
	var/sanitized_backstory = STRIP_HTML_SIMPLE(incoming_backstory, OPFOR_TEXT_LIMIT_BACKSTORY)
	add_log(user.ckey, "Updated BACKSTORY from: [set_backstory] to: [sanitized_backstory]")
	set_backstory = sanitized_backstory
	return TRUE

/datum/opposing_force/proc/approve_all(mob/user)
	if(SSopposing_force.approve(src, user))
		for(var/datum/opposing_force_selected_equipment/iterating_equipment as anything in selected_equipment)
			iterating_equipment.status = OPFOR_EQUIPMENT_STATUS_APPROVED
		for(var/datum/opposing_force_objective/opfor as anything in objectives)
			opfor.status = OPFOR_OBJECTIVE_STATUS_APPROVED
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has approved the application and ALL objectives and equipment")
	add_log(user.ckey, "Approved application and all objectives and equipment")


/**
 * Objective procs
 */

/datum/opposing_force/proc/set_objective_intensity(mob/user, datum/opposing_force_objective/opposing_force_objective, new_intensity)
	if(!can_edit)
		return
	if(!opposing_force_objective)
		CRASH("set_objective_intensity tried to update a non existent opfor objective!")
	var/sanitized_intensity = sanitize_integer(new_intensity, 1, 500)
	switch(sanitized_intensity)
		if(0 to 100)
			opposing_force_objective.text_intensity = OPFOR_OBJECTIVE_INTENSITY_1
		if(101 to 200)
			opposing_force_objective.text_intensity = OPFOR_OBJECTIVE_INTENSITY_2
		if(201 to 300)
			opposing_force_objective.text_intensity = OPFOR_OBJECTIVE_INTENSITY_3
		if(301 to 400)
			opposing_force_objective.text_intensity = OPFOR_OBJECTIVE_INTENSITY_4
		if(401 to 501)
			opposing_force_objective.text_intensity = OPFOR_OBJECTIVE_INTENSITY_5
	add_log(user.ckey, "Set updated an objective intensity from [opposing_force_objective.intensity] to [sanitized_intensity].")
	opposing_force_objective.intensity = sanitized_intensity
	return TRUE

/datum/opposing_force/proc/set_objective_description(mob/user, datum/opposing_force_objective/opposing_force_objective, new_description)
	if(!can_edit)
		return
	if(!opposing_force_objective)
		CRASH("set_objective_description tried to update a non existent opfor objective!")
	var/sanitized_description = replacetext(STRIP_HTML_SIMPLE(new_description, OPFOR_TEXT_LIMIT_DESCRIPTION), "\"", " ")
	opposing_force_objective.description = sanitized_description
	add_log(user.ckey, "Updated objective([opposing_force_objective.title]) DESCRIPTION from: [opposing_force_objective.description] to: [sanitized_description]")
	return TRUE

/datum/opposing_force/proc/set_objective_justification(mob/user, datum/opposing_force_objective/opposing_force_objective, new_justification)
	if(!can_edit)
		return
	if(!opposing_force_objective)
		CRASH("set_objective_description tried to update a non existent opfor objective!")
	var/sanitize_justification = replacetext(STRIP_HTML_SIMPLE(new_justification, OPFOR_TEXT_LIMIT_JUSTIFICATION), "\"", " ")
	opposing_force_objective.justification = sanitize_justification
	add_log(user.ckey, "Updated objective([opposing_force_objective.title]) JUSTIFICATION from: [opposing_force_objective.justification] to: [sanitize_justification]")
	return TRUE

/datum/opposing_force/proc/remove_objective(mob/user, datum/opposing_force_objective/opposing_force_objective)
	if(!can_edit)
		return
	if(!opposing_force_objective)
		CRASH("set_objective_description tried to remove a non existent opfor objective!")
	objectives -= opposing_force_objective
	add_log(user.ckey, "Removed the following objective from their OPFOR application: [opposing_force_objective.title]")
	qdel(opposing_force_objective)
	return TRUE

/datum/opposing_force/proc/add_objective(mob/user)
	if(!can_edit)
		return
	if(LAZYLEN(objectives) >= OPFOR_MAX_OBJECTIVES)
		to_chat(user, span_warning("You have too many objectives, please remove one!"))
		return
	var/datum/opposing_force_objective/opfor_objective = new
	objectives += opfor_objective
	add_log(user.ckey, "Added a new blank objective")
	return opfor_objective

/datum/opposing_force/proc/set_objective_title(mob/user, datum/opposing_force_objective/opposing_force_objective, new_title)
	if(!can_edit)
		return
	var/sanitized_title = replacetext(STRIP_HTML_SIMPLE(new_title, OPFOR_TEXT_LIMIT_TITLE), "\"", " ")
	if(!opposing_force_objective)
		CRASH("set_objective_description tried to update a non existent opfor objective!")
	add_log(user.ckey, "Updated objective([opposing_force_objective.title]) TITLE from: [opposing_force_objective.title] to: [sanitized_title]")
	opposing_force_objective.title = sanitized_title
	return TRUE

/datum/opposing_force/proc/deny_objective(mob/user, datum/opposing_force_objective/opposing_force_objective, deny_reason)
	opposing_force_objective.status = OPFOR_OBJECTIVE_STATUS_DENIED
	opposing_force_objective.denied_reason = deny_reason
	add_log(user.ckey, "Denied objective([opposing_force_objective.title]) WITH REASON: [deny_reason]")
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has denied objective '[opposing_force_objective.title]' with the reason '[deny_reason]'")
	to_chat(mind_reference?.current, span_warning("Your OPFOR objective [span_bold("[opposing_force_objective.title]")] has been denied."))

/datum/opposing_force/proc/approve_objective(mob/user, datum/opposing_force_objective/opposing_force_objective)
	opposing_force_objective.status = OPFOR_OBJECTIVE_STATUS_APPROVED
	add_log(user.ckey, "Approved objective([opposing_force_objective.title])")
	send_system_message("[user ? get_admin_ckey(user) : "The OPFOR subsystem"] has approved objective '[opposing_force_objective.title]'")
	to_chat(mind_reference?.current, span_warning("Your OPFOR objective [span_bold("[opposing_force_objective.title]")] has been approved."))

/**
 * System procs
 */

/datum/opposing_force/proc/add_log(logger_ckey, new_log)
	var/msg = "OPFOR([ckey]): [logger_ckey ? logger_ckey : "SYSTEM"] - [new_log]"
	modification_log += msg
	log_admin(msg)

/datum/opposing_force/proc/send_admins_opfor_message(message)
	message = "[span_pink("OPFOR:")] [span_admin("[message] (<a href='?src=[REF(src)];admin_pref=show_panel'>Show Panel</a>)")]"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = message,
		confidential = TRUE)

/datum/opposing_force/proc/get_status_string()
	var/subsystem_status = SSopposing_force.check_availability()
	if(subsystem_status != OPFOR_SUBSYSTEM_READY)
		return subsystem_status
	switch(status)
		if(OPFOR_STATUS_AWAITING_APPROVAL)
			return "Awaiting approval, you are number [SSopposing_force.get_queue_position(src)] in the queue"
		if(OPFOR_STATUS_APPROVED)
			return "Approved, please check your objectives for specific approval"
		if(OPFOR_STATUS_DENIED)
			return "Denied, do not attempt any of your objectives"
		if(OPFOR_STATUS_CHANGES_REQUESTED)
			return "Changes requested, please review your application"
		if(OPFOR_STATUS_NOT_SUBMITTED)
			return OPFOR_STATUS_NOT_SUBMITTED
		else
			return "ERROR"

/datum/opposing_force/proc/get_admin_ckey(mob/user)
	if(user.client?.holder?.fakekey)
		return user.client.holder.fakekey
	return user.ckey

/datum/opposing_force/proc/broadcast_queue_change()
	var/queue_number = SSopposing_force.get_queue_position(src)
	to_chat(mind_reference.current, examine_block(span_nicegreen("Your OPFOR application is now number [queue_number] in the queue.")))
	send_system_message("Application is now number [queue_number] in the queue")

/datum/opposing_force/proc/send_message(mob/user, message)
	if(!message)
		return
	message = STRIP_HTML_SIMPLE(message, OPFOR_TEXT_LIMIT_MESSAGE)
	var/message_string
	var/real_round_time = world.timeofday - SSticker.round_start_time
	if(check_rights_for(user.client, R_ADMIN) && user != mind_reference)
		message_string = "[time2text(real_round_time, "hh:mm:ss", 0)] (ADMIN) [get_admin_ckey(user)]: " + message
	else
		message_string = "[time2text(real_round_time, "hh:mm:ss", 0)] (USER) [user.ckey]: " + message
	admin_chat += message_string

	// We support basic commands, see run_command for compatible commands, the operator is /
	if(findtext(message, "/", 1, 2))
		// We remove the command indentifier before we try running the command.
		var/command = replacetext(message, "/", "", 1, 2)
		run_command(user, command)

	add_log(user.ckey, "Sent message: [message]")


/datum/opposing_force/proc/send_system_message(message)
	var/real_round_time = world.timeofday - SSticker.round_start_time
	var/message_string = "[time2text(real_round_time, "hh:mm:ss", 0)] SYSTEM: " + message
	admin_chat += message_string

/datum/opposing_force/proc/run_command(mob/user, message)
	var/list/params = splittext(message, " ")

	var/command = params[1]

	switch(command)
		if("item")
			check_item(params[2])
		if("help")
			print_help(user)
		if("ping_admin")
			ping_admin(user)
		if("ping_user")
			ping_user(user)
		if("unlock_equipment")
			unlock_equipment(user) // Admin only proc
		else
			send_system_message("Unknown command: [command]")

/datum/opposing_force/proc/print_help(mob/user)
	send_system_message("Available commands:")
	send_system_message("/item 'item_name' - Check an items quick stats")
	send_system_message("/ping_admin - Ping the handling admin, if there is one.")
	send_system_message("/help - Print this help")
	// Admin commands.
	if(check_rights_for(user.client, R_ADMIN))
		send_system_message("Admin commands:")
		send_system_message("/unlock_equipment - Unlock all equipment, useful if you need to give the user more stuff.")
		send_system_message("/ping_user - Pings the user.")

/**
 * System commands
 */
/datum/opposing_force/proc/check_item(type)
	var/obj/item/processed_item = text2path(type)
	if(!processed_item)
		send_system_message("Unknown type: [type]")
		return
	if(!ispath(processed_item, /obj/item))
		send_system_message("Error: [processed_item] is not an item")
		return

	send_system_message("Here are the item specifications for [type]:")
	send_system_message("Name: [initial(processed_item.name)]")
	send_system_message("Description: [initial(processed_item.desc)]")
	send_system_message("Weight class: [initial(processed_item.w_class)]")
	send_system_message("Tool behaviour: [initial(processed_item.tool_behaviour)]")
	send_system_message("Weak against armor: [initial(processed_item.weak_against_armour) ? "Yes" : "No"]")
	send_system_message("Damage type: [initial(processed_item.damtype)]")
	send_system_message("Wound bonus: [initial(processed_item.wound_bonus)]")
	send_system_message("Bare wound bonus: [initial(processed_item.bare_wound_bonus)]")
	send_system_message("Force: [initial(processed_item.force)]")

/datum/opposing_force/proc/unlock_equipment(mob/user)
	if(!check_rights_for(user.client, R_ADMIN))
		send_system_message("ERROR: You do not have permission to do that.")
		return
	if(!equipment_issued)
		send_system_message("ERROR: Equipment not yet issued.")
		return
	equipment_issued = TRUE
	send_system_message("Equipment unlocked.")

/datum/opposing_force/proc/ping_admin(mob/user)
	if(!handling_admin)
		send_system_message("ERROR: No admin is handling the application.")
		return
	if(!COOLDOWN_FINISHED(src, ping_cooldown))
		send_system_message("ERROR: Ping is on cooldown.")
		return
	if(request_updates_muted)
		send_system_message("ERROR: You are muted.")
		return
	if(user.ckey != handling_admin && GLOB.directory[handling_admin])
		to_chat(GLOB.directory[handling_admin], span_pink("OPFOR: [user] has pinged their OPFOR admin chat! (<a href='?src=[REF(src)];admin_pref=show_panel'>Show Panel</a>)"))
		SEND_SOUND(GLOB.directory[handling_admin], sound('sound/misc/bloop.ogg'))
		send_system_message("Handling admin pinged.")
		COOLDOWN_START(src, ping_cooldown, OPFOR_PING_COOLDOWN)
	else
		send_system_message("ERROR: Ping failed.")

/datum/opposing_force/proc/ping_user(mob/user)
	if(!check_rights_for(user.client, R_ADMIN))
		send_system_message("ERROR: You do not have permission to do that.")
		return
	send_system_message("User pinged.")
	to_chat(mind_reference.current, span_pink("OPFOR: [get_admin_ckey(user)] has pinged your OPFOR chat, check it!"))
	SEND_SOUND(mind_reference.current, sound('sound/misc/bloop.ogg'))

/datum/opposing_force/proc/roundend_report()
	var/list/report = list("<br>")
	report += span_greentext(mind_reference.current?.real_name)

	if(set_backstory)
		report += "<b>Had an approved OPFOR application with the following backstory:</b><br>"
		report += "[set_backstory]<br>"

	if(objectives.len)
		report += "<b>And with the following objectives:</b><br>"
		for(var/datum/opposing_force_objective/opfor_objective in objectives)
			if(opfor_objective.status != OPFOR_OBJECTIVE_STATUS_APPROVED)
				continue
			report += "<b>Title:</b> [opfor_objective.title]<br>"
			report += "<b>Description:</b> [opfor_objective.description]<br>"
			report += "<br>"

	if(selected_equipment.len)
		report += "<b>And had the following approved equipment:</b><br>"
		for(var/datum/opposing_force_selected_equipment/opfor_equipment in selected_equipment)
			if(opfor_equipment.status != OPFOR_EQUIPMENT_STATUS_APPROVED)
				continue
			report += "</b>[opfor_equipment.opposing_force_equipment.name]<b><br>"
			report += "<br>"

	return report.Join("\n")

/// Adds the OPFOR in question to the ticket ping subsystem should it not be approved.
/datum/opposing_force/proc/add_to_ping_ss()
	if(status == OPFOR_STATUS_APPROVED)
		return
	ticket_ping = TRUE

/// Allows a user to import an OPFOR from json
/datum/opposing_force/proc/json_import(mob/importer)
	var/file_uploaded = input(importer, "Choose a .json file to upload. (This WILL override your inputted data)", "Upload JSON template") as null|file
	if(!file_uploaded)
		return
	if(copytext("[file_uploaded]", -5) != ".json") //5 == length(".json")
		to_chat(importer, span_warning("Filename must end in '.json': [file_uploaded]"))
		return

	QDEL_LIST(objectives)
	QDEL_LIST(selected_equipment)
	set_backstory = null

	add_log(importer.ckey, "Imported a json OPFOR.")

	try
		var/list/opfor_data = json_load(file_uploaded)
		for(var/category in opfor_data)
			switch(category)
				if("objectives")
					for(var/iter_num in opfor_data["objectives"])
						var/datum/opposing_force_objective/opfor_objective = add_objective(importer)
						if(!opfor_objective)
							continue

						var/list/iter_obj = opfor_data["objectives"][iter_num]

						set_objective_title(importer, opfor_objective, iter_obj["title"])
						set_objective_description(importer, opfor_objective, iter_obj["description"])
						set_objective_justification(importer, opfor_objective, iter_obj["justification"])
						set_objective_intensity(importer, opfor_objective, iter_obj["intensity"])

				if("backstory")
					set_backstory(importer, opfor_data["backstory"])

				if("selected_equipment")
					for(var/iter_num in opfor_data["selected_equipment"])
						// If there isn't category data / a given equipment type, OR if either of those don't fit within certain perameters, it continues
						var/list/equipment = opfor_data["selected_equipment"][iter_num]

						if(\
						!equipment["equipment_parent_category"]|| !(equipment["equipment_parent_category"] in SSopposing_force.equipment_list)\
						 || !equipment["equipment_parent_type"] || !ispath(text2path(equipment["equipment_parent_type"]), /datum/opposing_force_equipment))
							continue

						// creates a new selected equipment datum using a type gotten from the given equipment type via SSopposing_force.equipment_list
						var/datum/opposing_force_selected_equipment/opfor_equipment = select_equipment(importer, \
						locate(text2path(equipment["equipment_parent_type"])) in SSopposing_force.equipment_list[equipment["equipment_parent_category"]])

						if(!opfor_equipment)
							continue

						set_equipment_reason(importer, opfor_equipment, equipment["equipment_reason"])
						set_equipment_count(importer, opfor_equipment, equipment["equipment_count"])

	catch //taking 0 risk
		QDEL_LIST(objectives)
		QDEL_LIST(selected_equipment)
		set_backstory = null
		to_chat(importer, span_warning("JSON file is corrupted in some form. Please correct and reupload."))
		add_log(importer.ckey, "Attempted to upload a corrupted JSON, purging leftover data...")


/// Allows a user to export from an OPFOR into a json file
/datum/opposing_force/proc/json_export(mob/exporter)

	var/list/exported_data = list(
		"objectives" = list(),
		"backstory" = set_backstory,
		"selected_equipment" = list(),
	)

	for(var/datum/opposing_force_objective/iterating_objective as anything in objectives)
		exported_data["objectives"]["[objectives.Find(iterating_objective)]"] = list(
			"title" = iterating_objective.title,
			"description" = iterating_objective.description,
			"justification" = iterating_objective.justification,
			"intensity" = iterating_objective.intensity, //remember to use set_objective_number or whatever the proc is
		)

	for(var/datum/opposing_force_selected_equipment/iterating_equipment as anything in selected_equipment)
		exported_data["selected_equipment"]["[objectives.Find(iterating_equipment)]"] = list(
			"equipment_name" = iterating_equipment.opposing_force_equipment.name,
			"equipment_parent_category" = iterating_equipment.opposing_force_equipment.category,
			"equipment_parent_type" = iterating_equipment.opposing_force_equipment.type,
			"equipment_reason" = iterating_equipment.reason,
			"equipment_count" = iterating_equipment.count,
		)

	add_log(exporter.ckey, "Exported a json OPFOR.")

	var/to_write_file = "data/opfor_temp/[REF(src)].json"
	rustg_file_write(json_encode(exported_data), to_write_file)

	try
		usr << ftp(file(to_write_file), "exported_OPFOR.json")

	catch
		log_game("OPFOR by ckey: [exporter.ckey] attempted to export JSON data but ftp(file()) runtimed.")
		add_log(exporter.ckey, "Attempted to export JSON data but ftp(file()) runtimed.")

	fdel(to_write_file)


/datum/action/opfor
	name = "Open Opposing Force Panel"
	button_icon_state = "round_end"

/datum/action/opfor/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	owner.opposing_force()

/datum/action/opfor/IsAvailable(feedback = FALSE)
	if(!target)
		return FALSE
	return ..()

/obj/effect/statclick/opfor_specific
	var/datum/opposing_force/opfor

/obj/effect/statclick/opfor_specific/Destroy()
	opfor = null
	. = ..()

/obj/effect/statclick/opfor_specific/Click()
	if (!usr.client?.holder)
		message_admins("[key_name_admin(usr)] non-holder clicked on an OPFOR statclick! ([src])")
		log_game("[key_name(usr)] non-holder clicked on an OPFOR statclick! ([src])")
		return

	opfor.ui_interact(usr)

/proc/generate_optin_crew_list()
	var/list/output = list()

	for (var/datum/record/locked/iterated_record as anything in GLOB.manifest.locked)
		var/datum/mind/mind_datum = iterated_record.mind_ref.resolve()
		if (!istype(mind_datum))
			continue
		var/name = iterated_record.name
		var/rank = iterated_record.rank

		var/opt_in_status = mind_datum.get_effective_opt_in_level()
		var/ideal_opt_in_status = mind_datum.ideal_opt_in_level

		output += list(list(
			"name" = name,
			"rank" = rank,
			"opt_in_status" = GLOB.antag_opt_in_strings["[opt_in_status]"],
			"ideal_opt_in_status" = GLOB.antag_opt_in_strings["[ideal_opt_in_status]"]
		))

	return output

/datum/controller/subsystem/ticker/proc/opfor_report()
	var/list/result = list()

	result += "<span class='header'>Opposing Force Report:</span><br>"

	if(!SSopposing_force.approved_applications.len)
		result += span_red("No applications were approved.")
	else
		for(var/datum/opposing_force/opfor in SSopposing_force.approved_applications)
			result += opfor.roundend_report()

	return "<div class='panel stationborder'>[result.Join()]</div>"

/datum/mind
	var/datum/opposing_force/opposing_force

/datum/mind/Destroy()
	QDEL_NULL(opposing_force)
	return ..()

/mob/verb/opposing_force()
	set name = "Opposing Force"
	set category = "OOC"
	set desc = "View your opposing force panel, or request one."
	// Mind checks
	if(!mind)
		var/fail_message = "You have no mind!"
		if(isobserver(src))
			fail_message += " You have to be in the current round at some point to have one."
		to_chat(src, span_warning(fail_message))
		return

	if(is_banned_from(ckey, BAN_OPFOR))
		to_chat(src, span_warning("You are OPFOR banned!"))
		return

	if(!mind.opposing_force)
		var/datum/opposing_force/opposing_force = new(mind)
		mind.opposing_force = opposing_force
		SSopposing_force.new_opfor(opposing_force)
	mind.opposing_force.ui_interact(usr)

GLOBAL_DATUM_INIT(ticket_manager, /datum/ticket_manager, new)
GLOBAL_VAR_INIT(ticket_manager_ref, REF(GLOB.ticket_manager))

/datum/ticket_manager
	/// The set of all available emojis
	var/list/emojis
	/// The set of all  tickets
	var/alist/all_tickets

/datum/ticket_manager/New()
	emojis = icon_states(EMOJI_SET)
	// SDMM doesn't recognise this function as built-in alist initializer and treats it as regular proc,
	// so it's not allowed to call it in datum definition
	all_tickets = alist()

/datum/ticket_manager/ui_state()
	return GLOB.always_state

/datum/ticket_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketManager")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ticket_manager/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/chat),
	)

/datum/ticket_manager/ui_data(mob/user)
	var/list/data = list()
	data["allTickets"] = get_tickets_data(user)
	return data

/datum/ticket_manager/ui_static_data(mob/user)
	var/list/data = list()
	var/client/user_client = user.client
	data["emojis"] = emojis
	data["userKey"] = user_client.key
	data["isAdmin"] = check_rights_for(user_client, R_ADMIN)
	data["isMentor"] = check_rights_for(user_client, R_MENTOR)
	data["userType"] = get_user_type(user_client)
	data["ticketToOpen"] = user_client.ticket_to_open
	data["maxMessageLength"] = MAX_MESSAGE_LEN
	data["replyCooldown"] = TICKET_REPLY_COOLDOWN
	return data

/datum/ticket_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/client/user = ui.user.client
	var/ticket_id = params["ticketId"]
	if(!ticket_id)
		CRASH("Called ticket_manager ui_act() without a ticket number!")

	var/datum/help_ticket/needed_ticket = get_help_ticket_by_id(ticket_id)
	if(!needed_ticket)
		CRASH("Requested ticket not found in all tickets list!")

	// Can be used by anyone
	switch(action)
		if("start_writing")
			if(!can_send_message(user, needed_ticket))
				return FALSE

			add_to_ticket_writers(user, needed_ticket)
			return TRUE

		if("stop_writing")
			remove_from_ticket_writers(user, needed_ticket)
			return TRUE

		if("reply")
			if(!can_send_message(user, needed_ticket))
				return FALSE

			if(!params["message"])
				return FALSE

			var/trimmed_message = trim(params["message"], MAX_MESSAGE_LEN)
			if(!trimmed_message)
				return

			add_ticket_message(user, needed_ticket, trimmed_message)
			return TRUE

	if(!needed_ticket.has_staff_access(user))
		return FALSE

	switch(action)
		if("reopen")
			set_ticket_state(user, needed_ticket, TICKET_OPEN)
			return TRUE

		if("close")
			set_ticket_state(user, needed_ticket, TICKET_CLOSED)
			return TRUE

		if("resolve")
			set_ticket_state(user, needed_ticket, TICKET_RESOLVED)
			return TRUE

		if("unlink")
			unlink_admin_from_ticket(user, needed_ticket)
			return TRUE

		if("convert")
			convert_ticket(user, needed_ticket)
			return FALSE

	var/client/ticket_holder = needed_ticket.get_initiator_client()
	if(!ticket_holder)
		to_chat(user, span_danger("Владелец тикета оффлайн!"))
		return FALSE

	switch(action)
		if("follow")
			if(!isobserver(user.mob))
				return

			user.admin_follow(ticket_holder.mob)
			return TRUE

		if("logs")
			show_individual_logging_panel(ticket_holder.mob)
			return TRUE

		if("smite")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_smite, ticket_holder.mob)
			return TRUE

		if("subtlepm")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/cmd_admin_subtle_message, ticket_holder.mob)
			return TRUE

		if("view_variables")
			user.debug_variables(ticket_holder.mob)
			return TRUE

		if("traitor_panel")
			if(!SSticker.HasRoundStarted())
				tgui_alert(user, "Игра ещё не началась!")
				return FALSE

			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/show_traitor_panel, ticket_holder.mob)
			return TRUE

		if("player_panel")
			SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/show_player_panel, ticket_holder.mob)
			return TRUE

		if("popup")
			if(user.key in needed_ticket.writers)
				return // Already typing

			add_to_ticket_writers(user, needed_ticket)
			var/message = tgui_input_text(user, "Игроку на экран выведется надпись, а так же будет отправлено сообщение в его тикет. Какое сообщение должно быть?", "Popup", max_length = MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)
			if(!message)
				remove_from_ticket_writers(user, needed_ticket)
				return FALSE

			if(!needed_ticket.get_initiator_client())
				to_chat(user, span_notice("Кажется игрок покинул сервер..."))
				return FALSE

			give_admin_popup(needed_ticket.get_initiator_client(), user, message)
			return TRUE

	return FALSE

/datum/ticket_manager/ui_close(mob/user)
	. = ..()
	if(!user || !user.client)
		return

	var/datum/help_ticket/current_ticket = user.client.persistent_client.current_help_ticket
	if(current_ticket)
		remove_from_ticket_writers(user.client, current_ticket)

	user.client.ticket_to_open = null

/datum/ticket_manager/proc/get_tickets_data(mob/user)
	var/list/tickets = list()
	for(var/key,value in all_tickets)
		var/datum/help_ticket/ticket = value
		if(!ticket.has_user_access(user.client))
			continue

		UNTYPED_LIST_ADD(tickets, ticket.ui_data(user))

	return tickets

/datum/ticket_manager/proc/get_user_type(client/user)
	if(check_rights_for(user, R_ADMIN))
		return TICKET_MANAGER_USER_TYPE_ADMIN

	if(check_rights_for(user, R_MENTOR))
		return TICKET_MANAGER_USER_TYPE_MENTOR

	return TICKET_MANAGER_USER_TYPE_PLAYER

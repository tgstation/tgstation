/datum/ticket_manager/Topic(href, href_list)
	..()

	if(href_list["open_ticket_manager"])
		topic_open_ticket_manager(usr)
	else if(href_list["open_ticket"])
		topic_open_ticket(usr, text2num(href_list["ticket_id"]))
	else if(href_list["reply_ticket"])
		topic_reply_ticket(usr.client, text2num(href_list["ticket_id"]))
	else if(href_list["resolve_ticket"])
		topic_resolve_ticket(usr.client, text2num(href_list["ticket_id"]))
	else if(href_list["close_ticket"])
		topic_close_ticket(usr.client, text2num(href_list["ticket_id"]))

/datum/ticket_manager/proc/topic_open_ticket_manager(mob/user)
	ui_interact(user)

/datum/ticket_manager/proc/topic_open_ticket(mob/user, ticket_id)
	if(!user_has_user_access_to_ticket(user, ticket_id))
		return

	var/client/user_client = user.client
	user_client.ticket_to_open = ticket_id
	ui_interact(user)

/datum/ticket_manager/proc/topic_reply_ticket(client/user, ticket_id)
	var/datum/help_ticket/needed_ticket = get_help_ticket_by_id(ticket_id)
	if(isnull(needed_ticket))
		return

	if(!can_send_message(user, needed_ticket))
		return

	if(user.key in needed_ticket.writers)
		return

	add_to_ticket_writers(user, needed_ticket)
	var/message = tgui_input_text(user, null, "Ответ на тикет #[ticket_id]", max_length = MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)
	if(!message)
		remove_from_ticket_writers(user, needed_ticket)
		return

	add_ticket_message(user, needed_ticket, message)

/datum/ticket_manager/proc/topic_resolve_ticket(client/user, ticket_id)
	close_or_resolve_ticket(user, ticket_id, resolve = TRUE)

/datum/ticket_manager/proc/topic_close_ticket(client/user, ticket_id)
	close_or_resolve_ticket(user, ticket_id, resolve = FALSE)

/datum/ticket_manager/proc/close_or_resolve_ticket(client/user, ticket_id, resolve = TRUE)
	var/datum/help_ticket/needed_ticket = get_help_ticket_by_id(ticket_id)
	if(isnull(needed_ticket))
		return

	if(!needed_ticket.has_staff_access(user))
		to_chat(user, "Вы не можете изменять статус этого тикета!")
		message_admins("[key_name(user)] попытался закрыть/решить тикет #[ticket_id], с которым не имеет права взаимодействовать. Возможен href эксплоит!")
		stack_trace("Possible HREF exploit attempt by [key_name(user)]! Tried to interact with ticket #[ticket_id].")
		return

	if(needed_ticket.state != TICKET_OPEN)
		to_chat(user, span_danger("Тикет уже закрыт или решён!"))
		return

	set_ticket_state(user, needed_ticket, resolve ? TICKET_RESOLVED : TICKET_CLOSED)

/datum/ticket_manager/proc/user_has_user_access_to_ticket(mob/user, ticket_id)
	if(isnull(user?.client) || isnull(ticket_id))
		return FALSE

	var/datum/help_ticket/needed_ticket = get_help_ticket_by_id(ticket_id)
	if(isnull(needed_ticket))
		return FALSE

	if(!needed_ticket.has_user_access(user.client))
		to_chat(user, custom_boxed_message("red_box", "Вы не можете взаимодействовать с этим тикетом!"))
		message_admins("[key_name(user)] попытался взаимодействовать с тикетом #[ticket_id]], с которым не имеет права взаимодействовать. Возможен href эксплоит!")
		return FALSE

	return TRUE

/datum/ticket_manager/proc/stat_entry(client/target)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	var/list/active_tickets = list()
	var/list/other_tickets = list()
	for(var/key,value in all_tickets)
		var/datum/help_ticket/ticket = value
		if(!ticket.has_user_access(target))
			continue

		if(ticket.state == TICKET_OPEN)
			active_tickets += ticket
		else
			other_tickets += ticket

	var/list/stat_info = list()
	UNTYPED_LIST_ADD(stat_info, \
		list("Активные тикеты:", "[length(active_tickets)]", null, "[GLOB.ticket_manager_ref];open_ticket_manager=1") \
	)

	for(var/datum/help_ticket/ticket as anything in active_tickets)

		UNTYPED_LIST_ADD(stat_info, \
			list("\[[copytext_char(ticket.get_ticket_type().name, 1, 2)]\] Тикет #[ticket.id]:", "[ticket.stat_name]", null, "[GLOB.ticket_manager_ref];ticket_id=[ticket.id];open_ticket=[ticket.id]") \
		)

	UNTYPED_LIST_ADD(stat_info, \
		list("Закрытые тикеты:", "[length(other_tickets)]", null, "[GLOB.ticket_manager_ref];open_ticket_manager=1") \
	)
	return stat_info


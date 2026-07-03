GLOBAL_LIST_INIT_TYPED(help_ticket_types, /datum/help_ticket_type, initialize_help_ticket_types())

/proc/initialize_help_ticket_types()
	var/list/help_ticket_types = list()
	for(var/datum/help_ticket_type/path as anything in subtypesof(/datum/help_ticket_type))
		help_ticket_types[path::id] = new path

	return help_ticket_types

/datum/help_ticket_type
	/// Ticket type id. Used in `/datum/help_ticket`
	var/id = "no id"
	/// Ticket type name. Used in various UIs
	var/name
	/// Permissions required to see `/datum/help_ticket` with this type
	var/required_permissions
	/// Tickets can be converted to other tickets. It's the type it will be converted to
	var/type_to_convert_to
	/// Boxed message class used in chat messages related to ticket
	var/boxed_message_class = ""
	/// Text span class class used in chat messages related to ticket
	var/text_span_class = ""

/datum/help_ticket_type/admin
	id = TICKET_TYPE_ADMIN
	name = "Админ"
	required_permissions = R_ADMIN
	type_to_convert_to = TICKET_TYPE_MENTOR
	boxed_message_class = "red_box"
	text_span_class = "adminhelp"

/datum/help_ticket_type/mentor
	id = TICKET_TYPE_MENTOR
	name = "Ментор"
	required_permissions = R_MENTOR
	type_to_convert_to = TICKET_TYPE_ADMIN
	boxed_message_class = "blue_box"
	text_span_class = "mentorhelp"

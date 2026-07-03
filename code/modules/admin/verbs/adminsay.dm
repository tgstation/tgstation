ADMIN_VERB(cmd_admin_say, R_ADMIN, "ASay", "Send a message to other admins", ADMIN_CATEGORY_HIDDEN, message as text) // BANDASTATION EDIT: Original - ADMIN_CATEGORY_MAIN
	// BANDASTATION EDIT: START
	send_message_to_admin_related_chat(
		user,
		message,
		"ADMIN",
		MESSAGE_TYPE_ADMINCHAT,
		"adminsay",
		LOG_ASAY,
		permissions
	)
	BLACKBOX_LOG_ADMIN_VERB("Asay")
	// BANDASTATION EDIT: END

ADMIN_VERB(cmd_mentor_say, R_MENTOR, "MSay", "Send a message to other mentors", ADMIN_CATEGORY_HIDDEN, message as text) // BANDASTATION EDIT: Original - ADMIN_CATEGORY_MAIN
	send_message_to_admin_related_chat(
		user,
		message,
		"MENTOR",
		MESSAGE_TYPE_MENTORCHAT,
		"mentorsay",
		LOG_MSAY,
		permissions
	)
	BLACKBOX_LOG_ADMIN_VERB("Msay")

/proc/send_message_to_admin_related_chat(
	client/user,
	message,
	message_prefix,
	message_type,
	message_span_class,
	log_talk_message_type,
	target_permissions
)

	message = emoji_parse(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return FALSE

	message = notify_linked_in_chat(message, target_permissions)

	user.mob.log_talk(message, log_talk_message_type)
	message = keywords_lookup(message)
	var/asay_color = CONFIG_GET(flag/allow_admin_asaycolor) \
		? (user.prefs.read_preference(/datum/preference/color/asay_color) || DEFAULT_ASAY_COLOR) \
		: DEFAULT_ASAY_COLOR

	var/custom_asay_color = "<font color=[asay_color]>"
	message = "[span_class(message_span_class, "[span_prefix("[message_prefix]:")] <EM>[key_name_admin(user)]</EM> [ADMIN_FLW(user.mob)]: [custom_asay_color]<span class='message linkify'>[message]")]</span>[custom_asay_color ? "</font>":null]"
	var/holders = get_holders_with_rights(target_permissions)
	for(var/holder in holders)
		to_chat(
			target = holder,
			type = message_type,
			html = message,
			avoid_highlighting = (holder == user),
			confidential = TRUE,
		)

	return TRUE

/client/proc/get_admin_say()
	var/msg = input(src, null, "asay \"text\"") as text|null
	SSadmin_verbs.dynamic_invoke_verb(src, /datum/admin_verb/cmd_admin_say, msg)

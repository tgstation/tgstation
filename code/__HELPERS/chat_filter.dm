// [2] is the group index of the blocked term when it is not using word bounds.
// This is sanity checked by unit tests.
#define GET_MATCHED_GROUP(regex) (LOWER_TEXT(regex.group[2] || regex.match))

/// Given a text, will return what word is on the IC filter, with the reason.
/// Returns null if the message is OK.
/proc/is_ic_filtered(message)
	if (config.ic_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.ic_filter_regex)
		return list(
			matched_group,
			config.ic_filter_reasons[matched_group] || config.ic_outside_pda_filter_reasons[matched_group] || config.shared_filter_reasons[matched_group],
		)

	return null

/// Given a text, will return what word is on the soft IC filter, with the reason.
/// Returns null if the message is OK.
/proc/is_soft_ic_filtered(message)
	if (config.soft_ic_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.soft_ic_filter_regex)
		return list(
			matched_group,
			config.soft_ic_filter_reasons[matched_group] || config.soft_ic_outside_pda_filter_reasons[matched_group] || config.soft_shared_filter_reasons[matched_group],
		)

	return null

/// Given a text, will return what word is on the OOC filter, with the reason.
/// Returns null if the message is OK.
/proc/is_ooc_filtered(message)
	if (config.ooc_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.ooc_filter_regex)
		return list(matched_group, config.shared_filter_reasons[matched_group])

	return null

/// Given a text, will return that word is on the soft OOC filter, with the reason.
/// Returns null if the message is OK.
/proc/is_soft_ooc_filtered(message)
	if (config.soft_ooc_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.soft_ooc_filter_regex)
		return list(matched_group, config.soft_shared_filter_reasons[matched_group])

	return null

/// Checks a PDA message against the IC/Soft IC filter. Returns TRUE if the message should be sent.
/// Notifies the user passed in arguments if the message matched either filter.
/proc/check_pda_message_against_filter(message, mob/user)
	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered_for_pdas(message)
	if (filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return FALSE

	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered_for_pdas(message)
	if (soft_filter_result)
		if(tgui_alert(user, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to send it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[message]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term in PDA messages. Message: \"[message]\"")

	return TRUE

/// Given a text, will return what word is on the IC filter, ignoring words allowed on the PDA, with the reason.
/// Returns null if the message is OK.
/proc/is_ic_filtered_for_pdas(message)
	if (config.ic_outside_pda_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.ic_outside_pda_filter_regex)
		return list(
			matched_group,
			config.ic_filter_reasons[matched_group] || config.shared_filter_reasons[matched_group],
		)

	return null

/// Given a text, will return what word is on the soft IC filter, ignoring words allowed on the PDA, with the reason.
/// Returns null if the message is OK.
/proc/is_soft_ic_filtered_for_pdas(message)
	if (config.soft_ic_outside_pda_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.soft_ic_outside_pda_filter_regex)
		return list(
			matched_group,
			config.soft_ic_filter_reasons[matched_group] || config.soft_shared_filter_reasons[matched_group],
		)

	return null

///Given a pda message, will replace any match in the message with grawlixs.
/proc/censor_ic_filter_for_pdas(message)
	if(config.ic_outside_pda_filter_regex)
		message = config.ic_outside_pda_filter_regex.Replace(message, GLOBAL_PROC_REF(grawlix))
	if(config.soft_ic_outside_pda_filter_regex)
		message = config.soft_ic_outside_pda_filter_regex.Replace(message, GLOBAL_PROC_REF(grawlix))
	return message

/// Logs to the filter log with the given message, match, and scope
/proc/log_filter(scope, message, filter_result)
	log_filter_raw("[scope] filter:\n\tMessage: [message]\n\tFilter match: [filter_result[CHAT_FILTER_INDEX_WORD]]")

#undef GET_MATCHED_GROUP

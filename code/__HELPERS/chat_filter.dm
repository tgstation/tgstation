// [2] is the group index of the blocked term when it is not using word bounds.
// This is sanity checked by unit tests.
#define GET_MATCHED_GROUP(regex) (lowertext(regex.group[2] || regex.match))

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

/// Given a text, will return what word is on the OOC filter, with the reason.
/// Returns null if the message is OK.
/proc/is_ooc_filtered(message)
	if (config.ooc_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.ooc_filter_regex)
		return list(matched_group, config.shared_filter_reasons[matched_group])

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

///Given a text, will return that word is on the soft OOC filter, with the reason.
/// Returns null if the message is OK.
/proc/is_soft_ooc_filtered(message)
	if (config.soft_ooc_filter_regex?.Find(message))
		var/matched_group = GET_MATCHED_GROUP(config.soft_ooc_filter_regex)
		return list(matched_group, config.soft_shared_filter_reasons[matched_group])

	return null

#undef GET_MATCHED_GROUP

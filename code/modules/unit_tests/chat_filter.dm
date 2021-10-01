#define BLOCKED_IC "This message is not allowed IC, please use a different weird test phrase."
#define BLOCKED_IC_OUTSIDE_PDA "Kirby dancing is strictly prohibited on this server."
#define BLOCKED_SHARED "This message is not allowed anywhere, please use a different weird test phrase."

/// Tests the sanity of the chat filter, ensuring it properly blocks words and gives the reason
/datum/unit_test/chat_filter_sanity

/datum/unit_test/chat_filter_sanity/Run()
	// Update the chat filters to only have test phrases, just in case the toml is different
	config.shared_filter_reasons = list("blockedinshared" = BLOCKED_SHARED)
	config.ic_filter_reasons = list("blockedinic" = BLOCKED_IC)
	config.ic_outside_pda_filter_reasons = list("<(0_0<)" = BLOCKED_IC_OUTSIDE_PDA)
	config.update_chat_filter_regexes()

	test_filter(
		"this message is blockedinic, AND has a comma (which needs word bounds)",
		"blockedinic",
		BLOCKED_IC,
		BLOCKED_IC,
		null,
	)

	test_filter(
		"these words have filtered words in them: ablockedinic blockedinicbbbb aablockedinicbb",
		null,
		null,
		null,
		null,
	)

	test_filter(
		"<(0_0<) <(0_0)> (>0_0)> KIRBY DANCE!!!",
		"<(0_0<)",
		BLOCKED_IC_OUTSIDE_PDA,
		null,
		null,
	)

	test_filter(
		"This message is blockedinshared, meaning it's banned EVERYWHERE",
		"blockedinshared",
		BLOCKED_SHARED,
		BLOCKED_SHARED,
		BLOCKED_SHARED,
	)

/datum/unit_test/chat_filter_sanity/proc/test_filter(
	message,
	blocked_word,
	ic_filter_result,
	pda_filter_result,
	ooc_filter_result,
)
	var/ic_filter = is_ic_filtered(message)
	var/pda_filter = is_ic_filtered_for_pdas(message)
	var/ooc_filter = is_ooc_filtered(message)

	test_filter_result("IC", message, ic_filter, ic_filter_result, blocked_word)
	test_filter_result("PDA", message, pda_filter, pda_filter_result, blocked_word)
	test_filter_result("OOC", message, ooc_filter, ooc_filter_result, blocked_word)

/datum/unit_test/chat_filter_sanity/proc/test_filter_result(
	filter_type,
	message,
	outcome,
	expected_reason,
	expected_blocked_word,
)
	if (isnull(outcome) && isnull(expected_reason))
		return

	if (isnull(outcome))
		Fail("[message] was not blocked on the [filter_type] filter when it was expected to")
		return

	if (isnull(expected_reason))
		Fail("[message] was blocked on the [filter_type] filter when it wasn't expected to: [json_encode(outcome)]")
		return

	if (outcome[CHAT_FILTER_INDEX_WORD] != expected_blocked_word)
		Fail("[message] was blocked on the [filter_type] filter, but for a different word: \"[outcome[CHAT_FILTER_INDEX_WORD]]\" (instead of [expected_blocked_word])")
		return

	if (outcome[CHAT_FILTER_INDEX_REASON] != expected_reason)
		Fail("[message] was blocked on the [filter_type] filter, but for a different reason: \"[outcome[CHAT_FILTER_INDEX_REASON]]\" (instead of [expected_reason])")

#undef BLOCKED_IC
#undef BLOCKED_IC_OUTSIDE_PDA
#undef BLOCKED_SHARED

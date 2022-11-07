/// Apparently, spritesheets (or maybe how the CSS backend works) do not respond well to icon_state names that are just pure numbers (which was a behavior in emoji.dmi).
/// In case we add more emoji, let's just make sure that we don't have any pure numbers in the emoji.dmi file if we ever add more.
/datum/unit_test/verify_emoji_names

/datum/unit_test/verify_emoji_names/Run()
	var/static/list/emoji_list = icon_states(icon(EMOJI_SET))
	for(var/checkable in emoji_list)
		if(isnum(text2num(checkable)))
			TEST_FAIL("Emoji name [checkable] in [EMOJI_SET] is a pure number. This will cause issues with the CSS backend via Spritesheets. Please rename it to something else.")
			continue

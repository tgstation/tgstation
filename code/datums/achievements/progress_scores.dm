
/datum/award/score/progress/fish
	name = "Fish Species Caught"
	desc = "How many different species of fish you've caught so far. Gotta fish 'em all."
	database_id = FISH_SCORE
	var/list/early_entries_to_validate = list()

/datum/award/score/progress/fish/New()
	. = ..()
	RegisterSignal(SSfishing, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(validate_early_joiners))

/datum/award/score/progress/fish/get_table()
	return "fish_progress"

/datum/award/score/progress/fish/proc/validate_early_joiners(datum/source)
	for(var/client/client as anything in GLOB.clients)
		var/datum/achievement_data/holder = client.persistent_client.achievements
		if(!holder?.initialized)
			continue

		var/list/entries = holder.data[/datum/award/score/progress/fish]
		var/list_copied = FALSE
		for(var/fish_id in entries)
			if(SSfishing.catchable_fish[fish_id])
				continue

			//make a new list, unbound from the cached awards data, so that the score can be updated at the end of the round.
			if(!list_copied)
				entries = entries.Copy()
				holder.data[/datum/award/score/progress/fish] = entries
				list_copied = TRUE
			entries -= fish_id

/datum/award/score/progress/fish/validate_entries(list/entries, list/validated_entries)
	. = ..()
	if(!SSfishing.initialized)
		return
	for(var/fish_id in validated_entries)
		if(!(SSfishing.catchable_fish[fish_id]))
			validated_entries -= fish_id
			. = FALSE

/datum/award/score/progress/fish/get_progress(datum/achievement_data/holder)
	var/list/data = list(
		"name" = "Fishdex",
		"percent" = 0,
		"value_text" = "Subsystems still initializing...",
		"entries" = list(),
	)
	if(!SSfishing.initialized)
		return data
	var/list/catched_fish = holder.data[type]
	var/catched_len = length(catched_fish)
	var/catchable_len = length(SSfishing.catchable_fish)
	data["percent"] = catched_len/catchable_len
	data["value_text"] = "[catched_len] / [catchable_len]"
	var/index = 1
	var/max_zeros = round(log(10, catchable_len))
	for(var/fish_id in SSfishing.catchable_fish)
		var/obj/item/fish/fish = SSfishing.catchable_fish[fish_id]
		var/catched = (fish_id in catched_fish)
		var/entry_name = "◦[prefix_zeros_to_number(index, max_zeros)]◦ [catched ? full_capitalize(initial(fish.name)) : "??????" ]"
		var/list/icon_dimensions = get_icon_dimensions(initial(fish.icon))
		data["entries"] += list(list(
			"name" = entry_name,
			"icon" = catched ? SSfishing.cached_fish_icons[fish] : SSfishing.cached_unknown_fish_icons[fish],
			"height" = icon_dimensions["height"] * 2,
			"width" = icon_dimensions["width"] * 2,
		))
		index++
	return data

/datum/award/score/progress/fish/get_progress_string(progress_string)
	return span_greenannounce("This is the first time you've caught a <B>[progress_string]</B>!")

/datum/award/score/progress/pda_themes
	name = "Unlocked PDA Themes"
	desc = "Any special PDA theme that you've installed on your PDA, which will then be added to your roundstart PDA on future rounds as well."
	database_id = PDA_THEMES_SCORE
	track_high_scores = FALSE //This is purely personal progress
	var/list/cheevo_icons
	var/list/unlockable_themes

/datum/award/score/progress/pda_themes/New()
	unlockable_themes = valid_subtypesof(/datum/computer_file/program/maintenance/theme)

	cheevo_icons = list()
	for(var/datum/computer_file/program/maintenance/theme/theme as anything in unlockable_themes)
		cheevo_icons[theme] = icon2base64(icon(theme::icon_file, theme::icon))
	cheevo_icons["unknown"] = icon2base64(icon(PDA_THEMES_PROGRESS_SET, "unknown"))

/datum/award/score/progress/pda_themes/get_table()
	return "pda_themes_progress"

/datum/award/score/progress/pda_themes/get_progress_string(progress_string)
	return span_greenannounce(span_tooltip("You can now select it on future rounds without having to install it again", "New PDA theme unlocked : <B>[progress_string]!</B>"))

/datum/award/score/progress/pda_themes/get_progress(datum/achievement_data/holder)
	var/list/data = list(
		"name" = "PDA Themes",
		"entries" = list(),
	)


	var/list/unlocked_themes = holder.data[type]
	var/unlocked_len = length(unlocked_themes)
	var/unlockable_len = length(unlockable_themes)
	data["percent"] = unlocked_len/unlockable_len
	data["value_text"] = "[unlocked_len] / [unlockable_len]"
	for(var/datum/computer_file/program/maintenance/theme/theme as anything in unlockable_themes)
		var/unlocked = (theme::theme_id in unlocked_themes)
		var/list/dimensions = get_icon_dimensions(unlocked ? theme::icon_file : PDA_THEMES_PROGRESS_SET)
		var/entry_name = "[unlocked ? full_capitalize(theme::theme_name) : "??????" ]"
		data["entries"] += list(list(
			"name" = entry_name,
			"icon" = unlocked ? cheevo_icons[theme] : cheevo_icons["unknown"],
			"height" = dimensions["height"],
			"width" = dimensions["width"],
		))
	return data

/datum/award/score/progress/pda_themes/validate_entries(list/entries, list/validated_entries)
	. = ..()
	var/static/list/valid_themes
	if(!valid_themes)
		valid_themes = list()
		for(var/datum/computer_file/program/maintenance/theme/theme as anything in unlockable_themes)
			valid_themes[theme::theme_id] = TRUE
	for(var/id in validated_entries)
		if(!valid_themes[id])
			validated_entries -= id
			. = FALSE

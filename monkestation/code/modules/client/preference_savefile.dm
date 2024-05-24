/**
 * This is a cheap replica of the standard savefile version, only used for characters for now.
 * You can't really use the non-modular version, least you eventually want asinine merge
 * conflicts and/or potentially disastrous issues to arise, so here's your own.
 */
#define MODULAR_SAVEFILE_VERSION_MAX 3

#define MODULAR_SAVEFILE_UP_TO_DATE -1



/datum/preferences/proc/load_character_monkestation(list/save_data)
	if(!save_data)
		save_data = list()

	var/list/save_loadout = SANITIZE_LIST(save_data["loadout_list"])
	for(var/loadout in save_loadout)
		var/entry = save_loadout[loadout]
		save_loadout -= loadout

		if(istext(loadout))
			loadout = _text2path(loadout)
		save_loadout[loadout] = entry

	var/list/special_save_loadout = SANITIZE_LIST(save_data["special_loadout_list"])

	var/list/texted_special_save_loadouts = list()
	for(var/header as anything in special_save_loadout)
		texted_special_save_loadouts |= header
		texted_special_save_loadouts[header] = list()
		for(var/num as anything in special_save_loadout[header])
			texted_special_save_loadouts[header] |= "[num]"

	for(var/loadout in special_save_loadout["unusual"])
		special_save_loadout["unusual"] -= loadout

		if(istext(loadout))
			loadout = _text2num(loadout)
		special_save_loadout["unusual"] += loadout

	alt_job_titles = save_data["alt_job_titles"]
	loadout_list = sanitize_loadout_list(save_loadout)
	special_loadout_list = texted_special_save_loadouts

	if(needs_update >= 0)
		update_character_monkestation(needs_update, save_data) // needs_update == savefile_version if we need an update (positive integer)


/// Brings a savefile up to date with modular preferences. Called if savefile_needs_update_monkestation() returned a value higher than 0
/datum/preferences/proc/update_character_monkestation(current_version, list/save_data)
	return


/// Saves the modular customizations of a character on the savefile
/datum/preferences/proc/save_character_monkestation(list/save_data)
	save_data["loadout_list"] = loadout_list
	save_data["special_loadout_list"] = special_loadout_list
	save_data["modular_version"] = MODULAR_SAVEFILE_VERSION_MAX
	save_data["alt_job_titles"] = alt_job_titles

/datum/preferences/proc/save_preferences_monkestation()
	write_jobxp_preferences()
	savefile.set_entry("channel_volume", channel_volume)
	savefile.set_entry("saved_tokens", saved_tokens)
	savefile.set_entry("extra_stat_inventory", extra_stat_inventory)
	if(token_month)
		savefile.set_entry("token_month", token_month)
	savefile.set_entry("lootboxes_owned", lootboxes_owned)
	savefile.set_entry("antag_rep", antag_rep)

/datum/preferences/proc/load_preferences_monkestation()
	load_jobxp_preferences()
	channel_volume = savefile.get_entry("channel_volume", channel_volume)
	channel_volume = SANITIZE_LIST(channel_volume)

	saved_tokens = savefile.get_entry("saved_tokens", saved_tokens)
	saved_tokens = SANITIZE_LIST(saved_tokens)

	extra_stat_inventory = savefile.get_entry("extra_stat_inventory", extra_stat_inventory)
	extra_stat_inventory = SANITIZE_LIST(extra_stat_inventory)

	token_month = savefile.get_entry("token_month", token_month)
	lootboxes_owned = savefile.get_entry("lootboxes_owned", lootboxes_owned)
	antag_rep = savefile.get_entry("antag_rep", antag_rep)


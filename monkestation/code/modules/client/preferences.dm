/datum/preferences
	/// Loadout prefs. Assoc list of [typepaths] to [associated list of item info].
	var/list/loadout_list

	var/needs_update = TRUE

	///list of all items in inventory
	var/list/inventory = list()

	///the amount of metacoins currently possessed
	var/metacoins

	///sound storage
	var/datum/ui_module/volume_mixer/pref_mixer

	var/list/channel_volume = list(
		"1019" = 100,
	)

	var/list/saved_tokens = list(
		"high_threat" = 0,
		"medium_threat" = 0,
		"low_threat" = 0,
	)

	///amount of metaconis you can earn per shift
	var/max_round_coins = 1000

	///Alternative job titles stored in preferences. Assoc list, ie. alt_job_titles["Scientist"] = "Cytologist"
	var/list/alt_job_titles = list()
	/// the month we used our last donator token on
	var/token_month = 0

	///how many event tokens we currently have
	var/event_tokens = 0
	///the month we last used event tokens on
	var/event_token_month = 0
	///what token event do we currently have queued
	var/datum/twitch_event/queued_token_event

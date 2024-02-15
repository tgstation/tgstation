/datum/preferences
	/// Loadout prefs. Assoc list of [typepaths] to [associated list of item info].
	var/list/loadout_list
	///list of specially handled loadout items as array indexes for the extra_stat_inventory
	var/list/special_loadout_list = list(
		"unusual" = list(),
		"single-use" = list(),
		"generic" = list(),
	)
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
		"event_tokens" = 0,
		"event_token_month" = 0,
	)

	///amount of metaconis you can earn per shift
	var/max_round_coins = 1000

	///Alternative job titles stored in preferences. Assoc list, ie. alt_job_titles["Scientist"] = "Cytologist"
	var/list/alt_job_titles = list()
	/// the month we used our last donator token on
	var/token_month = 0
	/// these are inventory items that require external data to load correctly
	var/list/extra_stat_inventory = list(
		"unusual" = list(),
		"single-use" = list(),
		"generic" = list(),
		)
	///amount of lootboxes owned
	var/lootboxes_owned = 0

	///our current antag rep (base is 10)
	var/antag_rep = 10

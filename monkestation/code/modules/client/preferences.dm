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


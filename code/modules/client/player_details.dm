
///assoc list of ckey -> /datum/player_details
GLOBAL_LIST_EMPTY(player_details)

/// Tracks information about a client between log in and log outs
/datum/player_details
	/// Action datums assigned to this player
	var/list/datum/action/player_actions = list()
	/// Tracks client action logging
	var/list/logging = list()
	/// Callbacks invoked when this client logs in again
	var/list/post_login_callbacks = list()
	/// Callbacks invoked when this client logs out
	var/list/post_logout_callbacks = list()
	/// List of names this key played under this round
	/// assoc list of name -> mob tag
	var/list/played_names = list()
	/// Lazylist of preference slots this client has joined the round under
	/// Numbers are stored as strings
	var/list/joined_as_slots
	/// Version of byond this client is using
	var/byond_version = "Unknown"
	/// Tracks achievements they have earned
	var/datum/achievement_data/achievements
	/// World.time this player last died
	var/time_of_death = 0

/datum/player_details/New(key)
	achievements = new(key)

/// Writes all of the `played_names` into an HTML-escaped string.
/datum/player_details/proc/get_played_names()
	var/list/previous_names = list()
	for(var/previous_name in played_names)
		previous_names += html_encode("[previous_name] ([played_names[previous_name]])")
	return previous_names.Join("; ")

/// Adds the new names to the player's played_names list on their /datum/player_details for use of admins.
/// `ckey` should be their ckey, and `data` should be an associative list with the keys being the names they played under and the values being the unique mob ID tied to that name.
/proc/log_played_names(ckey, data)
	if(!ckey)
		return

	var/datum/player_details/writable = GLOB.player_details[ckey]
	if(isnull(writable))
		return

	for(var/name in data)
		if(!name)
			continue
		var/mob_tag = data[name]
		var/encoded_name = html_encode(name)
		if(writable.played_names.Find("[encoded_name]"))
			continue

		writable.played_names += list("[encoded_name]" = mob_tag)

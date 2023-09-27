
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

/proc/log_played_names(ckey, ...)
	if(!ckey)
		return
	if(args.len < 2)
		return
	var/list/names = args.Copy(2)
	var/datum/player_details/P = GLOB.player_details[ckey]
	if(P)
		for(var/name in names)
			if(name)
				P.played_names |= name

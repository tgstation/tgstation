
///assoc list of ckey -> /datum/player_details
GLOBAL_LIST_EMPTY(player_details)

/datum/player_details
	var/list/player_actions = list()
	var/list/logging = list()
	/// List of login callbacks, will be passed the mob as the first argument
	var/list/post_login_callbacks = list()
	/// List of logout callbacks, will be passed the mob as the first argument
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	var/datum/achievement_data/achievements

/datum/player_details/New(key)
	achievements = new(key)

/datum/player_details/proc/do_login(mob/mob)
	for(var/datum/callback/callback as anything in post_login_callbacks)
		callback.Invoke(mob)

/datum/player_details/proc/do_logout(mob/mob)
	for(var/datum/callback/callback as anything in post_logout_callbacks)
		callback.Invoke(mob)

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

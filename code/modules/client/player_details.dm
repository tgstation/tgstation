/datum/player_details
	var/list/player_actions = list()
	var/list/logging = list()
	var/list/post_login_callbacks = list()
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	var/datum/achievement_data/achievements
	var/ghost_role_respawn_timer = 1 MINUTES
	var/can_ghost_role_respawn = TRUE

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

/datum/player_details/proc/respawn_timer()
	can_ghost_role_respawn = FALSE
	addtimer(CALLBACK(src, .proc/allow_player_respawn), ghost_role_respawn_timer)

/datum/player_details/proc/allow_player_respawn()
	can_ghost_role_respawn = TRUE

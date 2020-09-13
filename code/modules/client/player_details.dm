/datum/player_details
	var/list/player_actions = list()
	var/list/logging = list()
	var/list/post_login_callbacks = list()
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	var/datum/achievement_data/achievements

	/// Associated list. Keys are type paths. Values are lists of strings and restrictions associated with them. Lazylist as most players never accept ghost roles.
	var/list/ghost_roles_respawn_checks

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

/**
  * Checks the ghost_roles_respawn_checks for whether a player can spawn as a type of mob, and returns
  * an error message if relevant.
  *
  * Returns a specific error message string if the player cannot respawn as this mob type, FALSE if they can.
  * Arguments:
  * * mob_type - Type path to the mob the user is attempting to spawn as.
  * * max_lives - The maximum number of lives to check against.
  */
/datum/player_details/proc/get_respawn_error(mob_type, max_lives = 0)
	var/lives_used = LAZYACCESSASSOC(ghost_roles_respawn_checks, mob_type, "lives_lost")
	if(lives_used > max_lives)
		return "You have used all available lives for this role and cannot spawn as it."

	var/respawn_at = LAZYACCESSASSOC(ghost_roles_respawn_checks, mob_type, "respawn_at")
	if(respawn_at > world.time)
		return "You must wait [respawn_at - world.time * 0.1] seconds before you can spawn as this role again."

/**
  * Modifies the lives lost counter for the mob_type by the amount in life_change.
  *
  * Arguments:
  * * mob_type - Type path to the mob the user is attempting to spawn as.
  * * life_change - Number of lives to lose. If negative, number of lives to gain.
  */
/datum/player_details/proc/modify_lost_lives(mob_type, life_change)
	// if we've not got a list, init it. This also handles all of our checks for the lists existing.
	LAZYINITLIST(ghost_roles_respawn_checks)
	LAZYINITLIST(ghost_roles_respawn_checks[mob_type])

	if(ghost_roles_respawn_checks[mob_type]["lives_lost"])
		ghost_roles_respawn_checks[mob_type]["lives_lost"] += life_change
	else
		ghost_roles_respawn_checks[mob_type]["lives_lost"] = life_change

/datum/player_details/proc/set_respawn_in(mob_type, respawn_time)
	// if we've not got a list, init it. This also handles all of our checks for the lists existing.
	LAZYINITLIST(ghost_roles_respawn_checks)
	LAZYINITLIST(ghost_roles_respawn_checks[mob_type])

	ghost_roles_respawn_checks[mob_type]["respawn_at"] = world.time + respawn_time

/datum/player_details/proc/get_lost_lives(mob_type)
	return LAZYACCESSASSOC(ghost_roles_respawn_checks, mob_type, "lives_lost")

/datum/player_details/proc/get_respawn_in(mob_type)
	var/respawn_at = LAZYACCESSASSOC(ghost_roles_respawn_checks, mob_type, "respawn_at")
	var/respawn_in = max(respawn_at - world.time, 0)
	return respawn_in

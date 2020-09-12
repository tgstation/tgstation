/datum/player_details
	var/list/player_actions = list()
	var/list/logging = list()
	var/list/post_login_callbacks = list()
	var/list/post_logout_callbacks = list()
	var/list/played_names = list() //List of names this key played under this round
	var/byond_version = "Unknown"
	var/datum/achievement_data/achievements
	var/list/ghost_roles_respawn_checks = list(/mob/living/simple_animal/hostile/poison/giant_spider = list("lives_available" = 5,
																											"respawn_cooldown" = 3 MINUTES,
																											"can_respawn" = TRUE
																											))

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

/datum/player_details/proc/respawn_timer(mob_type)
	ghost_roles_respawn_checks[mob_type]["can_respawn"] = FALSE
	addtimer(CALLBACK(src, .proc/allow_player_respawn, mob_type), ghost_roles_respawn_checks[mob_type]["respawn_cooldown"])

/datum/player_details/proc/allow_player_respawn(mob_type)
	ghost_roles_respawn_checks[mob_type]["can_respawn"] = TRUE

/datum/player_details/proc/decrease_lives_available(mob_type)
	ghost_roles_respawn_checks[mob_type]["lives_available"] -= 1
	if(ghost_roles_respawn_checks[mob_type]["lives_available"] == 0)
		ghost_roles_respawn_checks[mob_type]["can_respawn"] = FALSE

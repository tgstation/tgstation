


// Called from game mode pre_setup()
/datum/game_mode/proc/assign_monster_hunters(monster_count = 4, guaranteed_hunters = FALSE)

	// Not all game modes GUARANTEE a hunter!
	if (!guaranteed_hunters && rand(0,2) > 0)
		return

	var/list/no_hunter_jobs = list("AI","Cyborg")

	// Set Restricted Jobs
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		no_hunter_jobs += list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		no_hunter_jobs += "Assistant"

	// Find Valid Hunters
	var/list/datum/mind/hunter_candidates = get_players_for_role(ROLE_MONSTERHUNTER)


	// Assign Hunters (as many as vamps, plus one)
	for(var/i = 1, i < monster_count, i++) // Start at 1 so we skip Hunters if there's only one sucker.
		if (!hunter_candidates.len)
			break
		var/datum/mind/hunter = pick(hunter_candidates)
		hunter_candidates.Remove(hunter) // Remove Either Way
		// Already Antag? Skip
		if (hunter.antag_datums.len)
			i --
			continue
		// Otherwise, Hunter
		vamphunters += hunter
		hunter.restricted_roles = no_hunter_jobs
		log_game("[hunter.key] (ckey) has been selected as a Hunter.")

// Called from game mode post_setup()
/datum/game_mode/proc/finalize_monster_hunters(monster_count = 4)
	var/amEvil = TRUE // First hunter is always an evil boi
	for(var/datum/mind/hunter in vamphunters)
		var/datum/antagonist/vamphunter/A = new ANTAG_DATUM_HUNTER(hunter)
		A.bad_dude = amEvil
		hunter.add_antag_datum(A)
		amEvil = FALSE  // Every other hunter is just a boring greytider

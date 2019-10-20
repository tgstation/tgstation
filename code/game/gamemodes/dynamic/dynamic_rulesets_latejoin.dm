//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	for(var/mob/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role) // Are they connected?
			candidates.Remove(P)
			continue
		if(!mode.check_age(P.client, minimum_required_age))
			candidates.Remove(P)
			continue
		if(antag_flag_override)
			if(!(antag_flag_override in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag_override, ROLE_SYNDICATE)))
				candidates.Remove(P)
				continue
		else 
			if(!(antag_flag in P.client.prefs.be_special) || is_banned_from(P.ckey, list(antag_flag, ROLE_SYNDICATE)))
				candidates.Remove(P)
				continue
		if (P.mind.assigned_role in restricted_roles) // Does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_roles.len > 0) && !(P.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in mode.current_players[CURRENT_LIVING_PLAYERS])
				if (M.stat == DEAD)
					continue // Dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
					job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/execute()
	var/mob/M = pick(candidates)
	assigned += M.mind
	M.mind.special_role = antag_flag
	M.mind.add_antag_datum(antag_datum)
	return TRUE

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/infiltrator
	name = "Syndicate Infiltrator"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_TRAITOR
	protected_roles = list("Security Officer", "Warden", "Head of Personnel", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI","Cyborg")
	required_candidates = 1
	weight = 7
	cost = 5
	requirements = list(40,30,20,10,10,10,10,10,10,10)
	high_population_requirement = 10
	repeatable = TRUE
	flags = TRAITOR_RULESET

//////////////////////////////////////////////
//                                          //
//       REVOLUTIONARY PROVOCATEUR          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/provocateur
	name = "Provocateur"
	antag_datum = /datum/antagonist/rev/head
	antag_flag = ROLE_REV_HEAD
	antag_flag_override = ROLE_REV
	restricted_roles = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director")
	enemy_roles = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 2
	cost = 20
	requirements = list(101,101,70,40,30,20,20,20,20,20)
	high_population_requirement = 50
	flags = HIGHLANDER_RULESET
	var/required_heads = 3

/datum/dynamic_ruleset/latejoin/provocateur/ready(forced=FALSE)
	if (forced)
		required_heads = 1
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.current_players[CURRENT_LIVING_PLAYERS])
		if (player.mind.assigned_role in GLOB.command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/latejoin/provocateur/execute()
	var/mob/M = pick(candidates)
	assigned += M.mind
	M.mind.special_role = antag_flag
	var/datum/antagonist/rev/head/new_head = new()
	new_head.give_flash = TRUE
	new_head.give_hud = TRUE
	new_head.remove_clumsy = TRUE
	new_head = M.mind.add_antag_datum(new_head)
	new_head.rev_team.max_headrevs = 1 // Only one revhead if it is latejoin.
	return TRUE

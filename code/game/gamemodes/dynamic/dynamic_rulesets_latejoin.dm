//////////////////////////////////////////////
//                                          //
//            LATEJOIN RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/trim_candidates()
	var/role_name = initial(antag_flag)
	for(var/mob/dead/new_player/P in candidates)
		if (!P.client || !P.mind || !P.mind.assigned_role)//are they connected?
			candidates.Remove(P)
			continue
		if (role_name in P.client.prefs.be_special || is_banned_from(P.ckey, list(role_name, ROLE_SYNDICATE)) || (antag_flag_override && is_banned_from(P.ckey, list(antag_flag_override))))//are they willing and not antag-banned?
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in protected_roles)
			candidates.Remove(P)
			continue
		if (P.mind.assigned_role in restricted_roles)//does their job allow for it?
			candidates.Remove(P)
			continue
		if ((exclusive_roles.len > 0) && !(P.mind.assigned_role in exclusive_roles))//is the rule exclusive to their job?
			candidates.Remove(P)
			continue

/datum/dynamic_ruleset/latejoin/ready(var/forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in mode.living_players)
				if (M.stat == DEAD)
					continue//dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
					job_check++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return FALSE
	return ..()


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

/datum/dynamic_ruleset/latejoin/infiltrator/execute()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	M.mind.add_antag_datum(new antag_datum())
	return TRUE


//////////////////////////////////////////////
//                                          //
//             WIZARD (LATEJOIN)            //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/wizard
	name = "Latejoin Wizard"
	antag_datum = /datum/antagonist/wizard
	antag_flag = ROLE_WIZARD
	enemy_roles = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/wizard/ready(var/forced = 0)
	if(GLOB.wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE

	return ..()

/datum/dynamic_ruleset/latejoin/wizard/execute()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	M.mind.add_antag_datum(new antag_datum())
	M.forceMove(pick(GLOB.wizardstart))
	return TRUE


//////////////////////////////////////////////
//                                          //
//               SPACE NINJA                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/ninja
	name = "Space Ninja"
	antag_datum = /datum/antagonist/ninja
	antag_flag = ROLE_NINJA
	enemy_roles = list("Security Officer","Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 4
	cost = 10
	requirements = list(90,90,60,20,10,10,10,10,10,10)
	high_population_requirement = 20

	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/ninja/execute()
	var/mob/M = pick(candidates)
	assigned += M
	candidates -= M
	M.mind.add_antag_datum(new antag_datum())
	return TRUE

//////////////////////////////////////////////
//                                          //
//       REVOLUTIONARY PROVOCATEUR          //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/latejoin/provocateur
	name = "Provocateur"
	antag_datum = /datum/antagonist/rev/head
	antag_flag = ROLE_REV_HEAD
	restricted_roles = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director")
	enemy_roles = list("AI", "Cyborg", "Security Officer","Detective","Head of Security", "Captain", "Warden")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 2
	cost = 20
	var/required_heads = 3
	requirements = list(101,101,70,40,30,20,20,20,20,20)
	high_population_requirement = 50
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/latejoin/provocateur/ready(var/forced=FALSE)
	if (forced)
		required_heads = 1
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.living_players)
		if (player.mind.assigned_role in GLOB.command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/latejoin/provocateur/execute()
	var/mob/M = pick(candidates)
	assigned += M
	spawn(1 SECONDS)
		M.mind.add_antag_datum(new antag_datum())
	return TRUE

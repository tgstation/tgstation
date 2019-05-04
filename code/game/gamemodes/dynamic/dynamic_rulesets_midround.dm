//////////////////////////////////////////////
//                                          //
//            MIDROUND RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround//Can be drafted once in a while during a round
	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

/datum/dynamic_ruleset/midround/from_ghosts/
	weight = 0
	var/makeBody = TRUE

/datum/dynamic_ruleset/midround/trim_candidates()
	//unlike the previous two types, these rulesets are not meant for /mob/dead/new_player
	//and since I want those rulesets to be as flexible as possible, I'm not gonna put much here,
	//but be sure to check dynamic_rulesets_debug.dm for an example.
	//
	//all you need to know is that here, the candidates list contains 4 lists itself, indexed with the following defines:
	//candidates = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	//so for example you can get the list of all current dead players with var/list/dead_players = candidates[CURRENT_DEAD_PLAYERS]
	//make sure to properly typecheck the mobs in those lists, as the dead_players list could contain ghosts, or dead players still in their bodies.
	//we're still gonna trim the obvious (mobs without clients, jobbanned players, etc)
	living_players = trim_list(candidates[CURRENT_LIVING_PLAYERS])
	living_antags = trim_list(candidates[CURRENT_LIVING_ANTAGS])
	dead_players = trim_list(candidates[CURRENT_DEAD_PLAYERS])
	list_observers = trim_list(candidates[CURRENT_OBSERVERS])

/datum/dynamic_ruleset/midround/proc/trim_list(var/list/L = list())
	var/list/trimmed_list = L.Copy()
	var/antag_name = initial(antag_flag)
	for(var/mob/M in trimmed_list)
		if (!M.client)//are they connected?
			trimmed_list.Remove(M)
			continue
		if (!(antag_name in M.client.prefs.be_special) || is_banned_from(M.ckey, list(antag_name, ROLE_SYNDICATE)))//are they willing and not antag-banned?
			trimmed_list.Remove(M)
			continue
		if (M.mind)
			if (M.mind.assigned_role in restricted_roles)//does their job allow for it?
				trimmed_list.Remove(M)
				continue
			if (M.mind.assigned_role in protected_roles)
				candidates.Remove(M)
			if ((exclusive_roles.len > 0) && !(M.mind.assigned_role in exclusive_roles))//is the rule exclusive to their job?
				trimmed_list.Remove(M)
				continue
	return trimmed_list

//You can then for example prompt dead players in execute() to join as strike teams or whatever
//Or autotator someone

//IMPORTANT, since /datum/dynamic_ruleset/midround may accept candidates from both living, dead, and even antag players, you need to manually check whether there are enough candidates
// (see /datum/dynamic_ruleset/midround/autotraitor/ready(var/forced = 0) for example)
/datum/dynamic_ruleset/midround/ready(var/forced = 0)
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in living_players)
				if (M.stat == DEAD)
					continue//dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
					job_check++//checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = round(mode.threat_level/10)
		if (job_check < required_enemies[threat])
			return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/execute()
	var/list/possible_candidates = list()
	possible_candidates.Add(dead_players)
	possible_candidates.Add(list_observers)
	send_applications(possible_candidates)
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/review_applications()
	message_admins("Applicant list: [english_list(applicants)]")
	for (var/i = required_candidates, i > 0, i--)
		if(applicants.len <= 0)
			if(i == required_candidates)
				//We have found no candidates so far and we are out of applicants.
				mode.refund_threat(cost)
				mode.threat_log += "[worldtime2text()]: Rule [name] refunded [cost] (all applications invalid)"
				mode.executed_rules -= src
			break
		var/mob/applicant = pick(applicants)
		applicants -= applicant
		if(!isobserver(applicant))
			if(applicant.stat == DEAD) //Not an observer? If they're dead, make them one.
				applicant = applicant.ghostize(FALSE)
			else //Not dead? Disregard them, pick a new applicant
				message_admins("[name]: Rule could not use [applicant], not dead.")
				i++
				continue

		if(!applicant)
			message_admins("[name]: Applicant was null. This may be caused if the mind changed bodies after applying.")
			i++
			continue
		message_admins("DEBUG: Selected [applicant] for rule.")

		var/mob/living/carbon/human/new_character = applicant

		if (makeBody)
			new_character = generate_ruleset_body(applicant)

		finish_setup(new_character, i)

	applicants.Cut()

/datum/dynamic_ruleset/midround/from_ghosts/proc/generate_ruleset_body(mob/applicant)
	var/mob/living/carbon/human/new_character = makeBody(applicant)
	new_character.dna.remove_all_mutations()
	return new_character

/datum/dynamic_ruleset/midround/from_ghosts/proc/finish_setup(var/mob/new_character, var/index)
	var/datum/antagonist/new_role = new antag_datum()
	new_character.mind.add_antag_datum(new_role)
	setup_role(new_role)

/datum/dynamic_ruleset/midround/from_ghosts/proc/setup_role(var/datum/antagonist/new_role)
	return

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_TRAITOR
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Cyborg")
	restricted_roles = list("AI")
	required_candidates = 1
	weight = 7
	cost = 10
	requirements = list(50,40,30,20,10,10,10,10,10,10)
	repeatable = TRUE
	high_population_requirement = 10
	flags = TRAITOR_RULESET

/datum/dynamic_ruleset/midround/autotraitor/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))//adding traitors if the antag population is getting low
		return ..()
	else
		return FALSE

/datum/dynamic_ruleset/midround/autotraitor/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(isAI(player))
			living_players -= player //Your assigned role doesn't change when you are turned into a MoMMI or AI
			continue
		if(is_centcom_level(player.z))
			living_players -= player//we don't autotator people on Z=2
			continue
		if(player.mind && (player.mind.special_role))
			living_players -= player//we don't autotator people with roles already

/datum/dynamic_ruleset/midround/autotraitor/ready(var/forced = 0)
	if (required_candidates > living_players.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/autotraitor/execute()
	var/mob/M = pick(living_players)
	assigned += M
	living_players -= M
	var/datum/antagonist/traitor/newTraitor = new
	M.mind.add_antag_datum(newTraitor)
	return TRUE


//////////////////////////////////////////////
//                                          //
//         Malfunctioning AI                //
//                              		    //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/malf
	name = "Malfunctioning AI"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_MALF
	enemy_roles = list("Security Officer", "Warden","Detective","Head of Security", "Captain", "Scientist", "Chemist", "Research Director", "Chief Engineer")
	exclusive_roles = list("AI")
	required_enemies = list(4,4,4,4,4,4,2,2,2,0)
	required_candidates = 1
	weight = 1
	cost = 35
	requirements = list(101,101,80,70,60,60,50,50,40,40)
	high_population_requirement = 65
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/midround/malf/trim_candidates()
	..()
	candidates = candidates[CURRENT_LIVING_PLAYERS]
	for(var/mob/living/player in candidates)
		if(!isAI(player))
			candidates -= player
			continue
		if(is_centcom_level(player.z))
			candidates -= player//we don't autotator people on Z=2
			continue
		if(player.mind && player.mind.special_role)
			candidates -= player//we don't autotator people with roles already

/datum/dynamic_ruleset/midround/malf/execute()
	if(!candidates || !candidates.len)
		return FALSE
	var/mob/living/silicon/ai/M = pick(candidates)
	assigned += M
	candidates -= M
	var/datum/antagonist/traitor/AI = new
	M.mind.add_antag_datum(AI)
	return TRUE

//////////////////////////////////////////////
//                                          //
//              WIZARD (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/wizard
	name = "Wizard"
	antag_datum = /datum/antagonist/wizard
	antag_flag = ROLE_WIZARD
	enemy_roles = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 20
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 50
	repeatable = TRUE

/datum/dynamic_ruleset/midround/from_ghosts/wizard/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return FALSE
	if(GLOB.wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()


//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/nuclear
	name = "Nuclear Assault"
	antag_datum = /datum/antagonist/nukeop
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 5
	weight = 5
	cost = 35
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	high_population_requirement = 60
	var/operative_cap = list(2,2,3,3,4,5,5,5,5,5)
	var/datum/team/nuclear/nuke_team
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/acceptable(var/population=0,var/threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return FALSE //unavailable if nuke ops were already sent at roundstart
	var/indice_pop = min(10,round(living_players.len/5)+1)
	required_candidates = operative_cap[indice_pop]
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/finish_setup(var/mob/new_character, var/index)
	if (index == 1) // Our first guy is the leader
		var/datum/antagonist/nukeop/leader/new_role = new
		new_character.mind.add_antag_datum(new_role)
		setup_role(new_role)
	else
		return ..()

//////////////////////////////////////////////
//                                          //
//            REVSQUAD (MIDROUND)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/revsquad
	name = "Revolutionary Squad"
	antag_datum = /datum/antagonist/rev/head
	antag_flag = ROLE_REV_HEAD
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 3
	weight = 5
	cost = 45
	requirements = list(101,101,90,60,45,45,45,45,45,45)
	high_population_requirement = 50
	flags = HIGHLANDER_RULESET

	var/required_heads = 3

/datum/dynamic_ruleset/midround/from_ghosts/revsquad/ready(var/forced = 0)
	if(forced)
		required_heads = 1
	if (required_candidates > (dead_players.len + list_observers.len))
		return FALSE
	if(!..())
		return FALSE
	var/head_check = 0
	for(var/mob/player in mode.living_players)
		if(!player.mind)
			continue
		if(player.mind.assigned_role in GLOB.command_positions)
			head_check++
	return (head_check >= required_heads)

//////////////////////////////////////////////
//                                          //
//         SPACE NINJA (MIDROUND)           //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/ninja
	name = "Space Ninja Attack"
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

/datum/dynamic_ruleset/midround/from_ghosts/ninja/acceptable(var/population=0,var/threat=0)
	var/player_count = mode.living_players.len
	var/antag_count = mode.living_antags.len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(mode.threat_level))
		return ..()
	else
		return FALSE

/datum/dynamic_ruleset/midround/from_ghosts/ninja/ready(var/forced = 0)
	if (required_candidates > (dead_players.len + list_observers.len))
		return FALSE
	return ..()


//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	persistent = 1
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor/
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_roles = list("Cyborg")
	enemy_roles = list("Security Officer","Detective","Head of Security", "Captain")
	required_candidates = 1
	weight = 5
	cost = 10
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	high_population_requirement = 10
	var/autotraitor_cooldown = 450//15 minutes (ticks once per 2 sec)

/datum/dynamic_ruleset/roundstart/traitor/pre_execute()
	var/traitor_scaling_coeff = 10 - max(0,round(mode.threat_level/10)-5)//above 50 threat level, coeff goes down by 1 for every 10 levels
	var/num_traitors = min(round(mode.candidates.len / traitor_scaling_coeff) + 1, candidates.len)
	for (var/i = 1 to num_traitors)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		M.mind.special_role = antag_flag
		M.mind.restricted_roles = restricted_roles
	return TRUE

/datum/dynamic_ruleset/roundstart/traitor/process()
	if (autotraitor_cooldown)
		autotraitor_cooldown--
	else
		autotraitor_cooldown = 450//15 minutes
		message_admins("Dynamic Mode: Checking if we can turn someone into a traitor...")
		mode.picking_specific_rule(/datum/dynamic_ruleset/midround/autotraitor)

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	antag_flag = ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	restricted_roles = list("AI", "Cyborg")
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	enemy_roles = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 30
	requirements = list(80,70,60,50,40,20,20,10,10,10)
	high_population_requirement = 30

/datum/dynamic_ruleset/roundstart/changeling/pre_execute()
	var/num_changelings = min(round(mode.candidates.len / 10) + 1, candidates.len)
	for (var/i = 1 to num_changelings)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		M.mind.special_role = ROLE_CHANGELING
		M.mind.restricted_roles = restricted_roles
	return TRUE

/datum/dynamic_ruleset/roundstart/changeling/execute()
	var/list/team_objectives = subtypesof(/datum/objective/changeling_team_objective)
	var/list/possible_team_objectives = list()
	for(var/T in team_objectives)
		var/datum/objective/changeling_team_objective/CTO = T

		if(assigned.len >= initial(CTO.min_lings))
			possible_team_objectives += T

	if(possible_team_objectives.len && prob(20*assigned.len))
		GLOB.changeling_team_objective_type = pick(possible_team_objectives)

	for(var/datum/mind/changeling in assigned)
		var/datum/antagonist/changeling/new_antag = new antag_datum()
		new_antag.team_mode = TRUE
		changeling.add_antag_datum(new_antag)

	return TRUE

//////////////////////////////////////////////
//                                          //
//               WIZARDS                    //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	antag_flag = ROLE_WIZARD
	antag_datum = /datum/antagonist/wizard
	restricted_roles = list("Head of Security", "Captain")//just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_roles = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(4,4,2,2,2,1,1,1,1,0)
	required_candidates = 1
	weight = 3
	cost = 30
	requirements = list(90,90,70,40,30,20,10,10,10,10)
	high_population_requirement = 40
	var/list/roundstart_wizards = list()

/datum/dynamic_ruleset/roundstart/wizard/acceptable(var/population=0,var/threat=0)
	if(GLOB.wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/wizard/pre_execute()
	if(GLOB.wizardstart.len == 0)
		return FALSE
	
	var/mob/M = pick(candidates)
	if (M)
		assigned += M
		candidates -= M
		M.mind.assigned_role = ROLE_WIZARD
		M.mind.special_role = ROLE_WIZARD
	
	return TRUE

/datum/dynamic_ruleset/roundstart/wizard/execute()
	for(var/mob/M in assigned)
		M.mind.current.forceMove(pick(GLOB.wizardstart))
		M.mind.add_antag_datum(new antag_datum())
	return TRUE
	
//////////////////////////////////////////////
//                                          //
//                BLOOD CULT                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/bloodcult
	name = "Blood Cult"
	antag_flag = ROLE_CULTIST
	antag_datum = /datum/antagonist/cult
	restricted_roles = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel")
	enemy_roles = list("Security Officer","Warden", "Detective","Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 4
	weight = 3
	cost = 30
	requirements = list(90,80,60,30,20,10,10,10,10,10)
	high_population_requirement = 40
	flags = HIGHLANDER_RULESET
	var/cultist_cap = list(2,2,3,4,4,4,4,4,4,4)
	var/datum/team/cult/main_cult

/datum/dynamic_ruleset/roundstart/bloodcult/ready(var/forced = 0)
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	required_candidates = cultist_cap[indice_pop]
	. = ..()

/datum/dynamic_ruleset/roundstart/bloodcult/pre_execute()
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	var/cultists = cultist_cap[indice_pop]

	for(var/cultists_number = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		M.mind.special_role = ROLE_CULTIST
		M.mind.restricted_roles = restricted_roles

	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	main_cult = new
	for(var/mob/M in assigned)
		var/datum/antagonist/cult/new_cultist = new antag_datum()
		new_cultist.give_equipment = TRUE
		M.mind.add_antag_datum(new_cultist)	
	main_cult.setup_objectives()
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/round_result()
	..()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	/var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	restricted_roles = list("Head of Security", "Captain")//just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,3,3,3,2,1,1,0,0)
	required_candidates = 5
	weight = 3
	cost = 40
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	high_population_requirement = 60
	flags = HIGHLANDER_RULESET
	var/operative_cap = list(2,2,3,3,4,5,5,5,5,5)
	var/datum/team/nuclear/nuke_team


/datum/dynamic_ruleset/roundstart/nuclear/ready(var/forced = 0)
	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	required_candidates = operative_cap[indice_pop]
	. = ..()

/datum/dynamic_ruleset/roundstart/nuclear/pre_execute()
	//if ready() did its job, candidates should have 5 or more members in it

	var/indice_pop = min(10,round(mode.roundstart_pop_ready/5)+1)
	var/operatives = operative_cap[indice_pop]
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
	return TRUE

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	var/leader = TRUE
	for(var/mob/M in assigned)
		M.mind.assigned_role = "Nuclear Operative"
		M.mind.special_role = "Nuclear Operative"
		if (leader)
			leader = FALSE
			var/datum/antagonist/nukeop/leader/new_op = new antag_leader_datum()
			nuke_team = new_op.nuke_team
			M.mind.add_antag_datum(new_op)
		else
			var/datum/antagonist/nukeop/new_op = new antag_datum()
			M.mind.add_antag_datum(new_op)

/datum/dynamic_ruleset/roundstart/nuclear/round_result()
	var result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

//////////////////////////////////////////////
//                                          //
//               EXTENDED                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	antag_flag = null
	antag_datum = null
	restricted_roles = list()
	enemy_roles = list()
	required_enemies = list(0,0,0,0,0,0,0,0,0,0)
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101) // So that's not possible to roll it naturally
	high_population_requirement = 101

/datum/dynamic_ruleset/roundstart/extended/pre_execute()
	message_admins("Starting a round of extended.")
	log_admin("Starting a round of extended.")
	return TRUE

//////////////////////////////////////////////
//                                          //
//               REVS		                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/delayed/revs
	name = "Revolution"
	antag_flag = ROLE_REV_HEAD
	antag_datum = /datum/antagonist/rev/head
	restricted_roles = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director")
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Detective", "Head of Security", "Captain", "Warden")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 3
	weight = 2
	cost = 35
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	high_population_requirement = 50
	delay = 5 MINUTES
	flags = HIGHLANDER_RULESET
	var/required_heads = 3
	var/datum/team/revolution/revolution
	var/finished = 0

/datum/dynamic_ruleset/roundstart/delayed/revs/ready(var/forced = 0)
	if (forced)
		required_heads = 1
		required_candidates = 1
	if (!..())
		return FALSE
	var/head_check = 0
	for (var/mob/dead/new_player/player in GLOB.player_list)
		if (player.mind.assigned_role in GLOB.command_positions)
			head_check++
	return (head_check >= required_heads)

/datum/dynamic_ruleset/roundstart/delayed/revs/pre_execute()
	var/max_canditates = 4
	revolution = new()
	for(var/i = 1 to max_canditates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = antag_flag

	return TRUE	

/datum/dynamic_ruleset/roundstart/delayed/revs/execute()
	for(var/mob/M in assigned)
		var/datum/antagonist/rev/head/new_head = new antag_datum()
		new_head.give_flash = TRUE
		new_head.give_hud = TRUE
		new_head.remove_clumsy = TRUE
		M.mind.add_antag_datum(new_head,revolution)

	revolution.update_objectives()
	revolution.update_heads()
	SSshuttle.registerHostileEnvironment(src)

	return TRUE
	
/datum/dynamic_ruleset/roundstart/delayed/revs/rule_process()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return FALSE

/datum/dynamic_ruleset/roundstart/delayed/revs/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in revolution.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/delayed/revs/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in revolution.head_revolutionaries())
		var/turf/T = get_turf(rev_mind.current)
		if(!considered_afk(rev_mind) && considered_alive(rev_mind) && is_station_level(T.z))
			if(ishuman(rev_mind.current) || ismonkey(rev_mind.current))
				return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/delayed/revs/round_result()
	if(finished == 1)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if(finished == 2)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE

//////////////////////////////////////////////
//                                          //
//               HIVEMIND                   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/hivemind
	name = "Hivemind"
	antag_flag = ROLE_HIVE
	antag_datum = /datum/antagonist/hivemind
	restricted_roles = list("Cyborg", "AI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	enemy_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_enemies = list(4,4,2,2,2,1,1,1,1,0)
	required_candidates = 3
	weight = 3
	cost = 30
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	high_population_requirement = 50

/datum/dynamic_ruleset/roundstart/hivemind/pre_execute()
	var/num_hosts = max( 1 , rand(0,1) + min(8, round(num_players() / 8) ) )
	for(var/i = 1 to num_hosts)
		var/mob/M = pick(candidates)
		assigned += M
		candidates -= M
		M.mind.special_role = ROLE_HIVE
		M.mind.restricted_roles = restricted_roles
		log_game("[key_name(M)] has been selected as a hivemind host")
	return TRUE

/datum/dynamic_ruleset/roundstart
	// We can pick multiple of a roundstart ruleset to "scale up" (spawn more of the same type of antag)
	// Set this to FALSE if you DON'T want this ruleset to "scale up"
	repeatable = TRUE
	/// If TRUE, the ruleset will be the only one selected for roundstart
	var/solo = FALSE

/datum/dynamic_ruleset/roundstart/is_valid_candidate(mob/candidate, client/candidate_client)
	if(isnull(candidate.mind))
		return FALSE
	// Checks that any other roundstart ruleset hasn't already picked this guy
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in SSdynamic.queued_rulesets)
		if(candidate.mind in ruleset.selected_minds)
			return FALSE
	return ..()

/// Helpful proc - to use if your ruleset forces a job - which ensures a candidate can play the passed job typepath
/datum/dynamic_ruleset/roundstart/proc/ruleset_forced_job_check(mob/candidate, client/candidate_client, datum/job/job_typepath)
	// Malf AI can only go to people who want to be AI
	if(!candidate_client.prefs.job_preferences[job_typepath::title])
		return FALSE
	// And only to people who can actually be AI this round
	if(SSjob.check_job_eligibility(candidate, SSjob.get_job_type(job_typepath), "[name] Candidacy") != JOB_AVAILABLE)
		return FALSE
	// (Something else forced us to play a job that isn't AI)
	var/forced_job = LAZYACCESS(SSjob.forced_occupations, candidate)
	if(forced_job && forced_job != job_typepath)
		return FALSE
	// (Something else forced us NOT to play AI)
	if(job_typepath::title in LAZYACCESS(SSjob.prevented_occupations, candidate))
		return FALSE
	return TRUE

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	config_tag = "Roundstart Traitor"
	preview_antag_datum = /datum/antagonist/traitor
	pref_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	max_antag_cap = list("denominator" = 38)

/datum/dynamic_ruleset/roundstart/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/roundstart/malf_ai
	name = "Malfunctioning AI"
	config_tag = "Roundstart Malfunctioning AI"
	pref_flag = ROLE_MALF
	preview_antag_datum = /datum/antagonist/malf_ai
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	max_antag_cap = 1
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/malf_ai/get_always_blacklisted_roles()
	return list()

/datum/dynamic_ruleset/roundstart/malf_ai/is_valid_candidate(mob/candidate, client/candidate_client)
	return ..() && ruleset_forced_job_check(candidate, candidate_client, /datum/job/ai)

/datum/dynamic_ruleset/roundstart/malf_ai/prepare_for_role(datum/mind/candidate)
	LAZYSET(SSjob.forced_occupations, candidate, /datum/job/ai)

/datum/dynamic_ruleset/roundstart/malf_ai/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/malf_ai)

/datum/dynamic_ruleset/roundstart/malf_ai/can_be_selected()
	return ..() && !HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI)

/datum/dynamic_ruleset/roundstart/blood_brother
	name = "Blood Brothers"
	config_tag = "Roundstart Blood Brothers"
	preview_antag_datum = /datum/antagonist/brother
	pref_flag = ROLE_BROTHER
	weight = 5
	max_antag_cap = list("denominator" = 29)
	min_pop = 10

/datum/dynamic_ruleset/roundstart/blood_brother/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/brother)

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	config_tag = "Roundstart Changeling"
	preview_antag_datum = /datum/antagonist/changeling
	pref_flag = ROLE_CHANGELING
	weight = 3
	min_pop = 15
	max_antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/roundstart/heretic
	name = "Heretics"
	config_tag = "Roundstart Heretics"
	preview_antag_datum = /datum/antagonist/heretic
	pref_flag = ROLE_HERETIC
	weight = 3
	max_antag_cap = list("denominator" = 24)
	min_pop = 30 // Ensures good spread of sacrifice targets

/datum/dynamic_ruleset/roundstart/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	config_tag = "Roundstart Wizard"
	preview_antag_datum = /datum/antagonist/wizard
	pref_flag = ROLE_WIZARD
	ruleset_flags = RULESET_INVADER|RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 1,
		DYNAMIC_TIER_HIGH = 2,
	)
	max_antag_cap = 1
	min_pop = 30
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_WIZARDDEN)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/wizard/prepare_for_role(datum/mind/candidate)
	LAZYSET(SSjob.forced_occupations, candidate, /datum/job/space_wizard)

/datum/dynamic_ruleset/roundstart/wizard/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/wizard) // moves to lair for us

/datum/dynamic_ruleset/roundstart/wizard/round_result()
	for(var/datum/mind/wiz as anything in selected_minds)
		if(considered_alive(wiz) && !considered_exiled(wiz))
			return FALSE

	SSticker.news_report = WIZARD_KILLED
	return TRUE

/datum/dynamic_ruleset/roundstart/blood_cult
	name = "Blood Cult"
	config_tag = "Roundstart Blood Cult"
	preview_antag_datum = /datum/antagonist/cult
	pref_flag = ROLE_CULTIST
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)
	min_antag_cap = list("denominator" = 20, "offset" = 1)
	repeatable = FALSE
	/// Ratio of cultists getting on the shuttle to be considered a minor win
	var/ratio_to_be_considered_escaped = 0.5

/datum/dynamic_ruleset/roundstart/blood_cult/get_always_blacklisted_roles()
	return ..() | JOB_CHAPLAIN

/datum/dynamic_ruleset/roundstart/blood_cult/create_execute_args()
	return list(
		new /datum/team/cult(),
		get_most_experienced(selected_minds, pref_flag),
	)

/datum/dynamic_ruleset/roundstart/blood_cult/execute()
	. = ..()
	// future todo, find a cleaner way to get this from execute args
	var/datum/team/cult/main_cult = locate() in GLOB.antagonist_teams
	main_cult.setup_objectives()

/datum/dynamic_ruleset/roundstart/blood_cult/assign_role(datum/mind/candidate, datum/team/cult/cult, datum/mind/most_experienced)
	var/datum/antagonist/cult/cultist = new()
	cultist.give_equipment = TRUE
	candidate.add_antag_datum(cultist, cult)
	if(most_experienced == candidate)
		cultist.make_cult_leader()

/datum/dynamic_ruleset/roundstart/blood_cult/round_result()
	var/datum/team/cult/main_cult = locate() in GLOB.antagonist_teams
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
		return TRUE

	var/num_cultists = main_cult.size_at_maximum || 100
	var/ratio_to_be_considered_escaped = 0.5
	var/escaped_cultists = 0
	for(var/datum/mind/escapee as anything in main_cult.members)
		if(considered_escaped(escapee))
			escaped_cultists++

	SSticker.mode_result = "loss - staff stopped the cult"
	SSticker.news_report = (escaped_cultists / num_cultists) >= ratio_to_be_considered_escaped ? CULT_ESCAPE : CULT_FAILURE
	return TRUE

/datum/dynamic_ruleset/roundstart/nukies
	name = "Nuclear Operatives"
	config_tag = "Roundstart Nukeops"
	preview_antag_datum = /datum/antagonist/nukeop
	pref_flag = ROLE_OPERATIVE
	ruleset_flags = RULESET_INVADER|RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = list("denominator" = 18, "offset" = 1)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NUKIEBASE)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/nukies/prepare_for_role(datum/mind/candidate)
	LAZYSET(SSjob.forced_occupations, candidate, /datum/job/nuclear_operative)

/datum/dynamic_ruleset/roundstart/nukies/create_execute_args()
	return list(
		new /datum/team/nuclear(),
		get_most_experienced(selected_minds, pref_flag),
	)

/datum/dynamic_ruleset/roundstart/nukies/assign_role(datum/mind/candidate, datum/team/nuke_team, datum/mind/most_experienced)
	if(most_experienced == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader, nuke_team)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop, nuke_team)

/datum/dynamic_ruleset/roundstart/nukies/round_result()
	var/datum/antagonist/nukeop/nukie = selected_minds[1].has_antag_datum(/datum/antagonist/nukeop)
	var/datum/team/nuclear/nuke_team = nukie.get_team()
	var/result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_DESTROYED_NUKE
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_DESTROYED_NUKE
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

/datum/dynamic_ruleset/roundstart/nukies/clown
	name = "Clown Operatives"
	config_tag = "Roundstart Clownops"
	preview_antag_datum = /datum/antagonist/nukeop/clownop
	pref_flag = ROLE_CLOWN_OPERATIVE
	weight = 0

/datum/dynamic_ruleset/roundstart/nukies/clown/prepare_for_role(datum/mind/candidate)
	LAZYSET(SSjob.forced_occupations, candidate, /datum/job/nuclear_operative/clown_operative)

/datum/dynamic_ruleset/roundstart/nukies/clown/assign_role(datum/mind/candidate, datum/team/nuke_team, datum/mind/most_experienced)
	if(most_experienced == candidate)
		candidate.add_antag_datum(/datum/antagonist/nukeop/leader/clownop)
	else
		candidate.add_antag_datum(/datum/antagonist/nukeop/clownop)

/datum/dynamic_ruleset/roundstart/revolution
	name = "Revolution"
	config_tag = "Roundstart Revolution"
	preview_antag_datum = /datum/antagonist/rev/head
	pref_flag = ROLE_REV_HEAD
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = 1
	max_antag_cap = 3
	repeatable = FALSE
	/// If we have fewer heads of staff than this 7 minutes into the round, we'll cancel the revolution
	var/heads_necessary = 2

/datum/dynamic_ruleset/roundstart/revolution/get_always_blacklisted_roles()
	. = ..()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(job.job_flags & JOB_HEAD_OF_STAFF)
			. |= job.title

/datum/dynamic_ruleset/roundstart/revolution/assign_role(datum/mind/candidate)
	LAZYADD(candidate.special_roles, "Dormant Head Revolutionary")
	addtimer(CALLBACK(src, PROC_REF(reveal_head), candidate), 7 MINUTES, TIMER_DELETE_ME)

/// Reveals the headrev after a set amount of time
/datum/dynamic_ruleset/roundstart/revolution/proc/reveal_head(datum/mind/candidate)
	LAZYREMOVE(candidate.special_roles, "Dormant Head Revolutionary")

	var/head_check = 0
	for(var/mob/player as anything in get_active_player_list(alive_check = TRUE, afk_check = TRUE))
		if(player.mind?.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			head_check++

	if(head_check < heads_necessary)
		log_dynamic("[config_tag]: Not enough heads of staff were present to start a revolution.")
		addtimer(CALLBACK(src, PROC_REF(revs_execution_failed)), 1 MINUTES, TIMER_UNIQUE|TIMER_DELETE_ME)
		return

	if(!can_be_headrev(candidate))
		log_dynamic("[config_tag]: [key_name(candidate)] was not eligible to be a headrev after the timer expired - finding a replacement.")
		find_another_headrev()
		return

	GLOB.revolution_handler ||= new()
	var/datum/antagonist/rev/head/new_head = new()
	new_head.give_flash = TRUE
	new_head.give_hud = TRUE
	new_head.remove_clumsy = TRUE
	candidate.add_antag_datum(new_head, GLOB.revolution_handler.revs)
	GLOB.revolution_handler.start_revolution()

/datum/dynamic_ruleset/roundstart/revolution/proc/find_another_headrev()
	for(var/mob/living/carbon/human/upstanding_citizen in GLOB.player_list)
		if(!can_be_headrev(upstanding_citizen.mind))
			continue
		reveal_head(upstanding_citizen.mind)
		log_dynamic("[config_tag]: [key_name(upstanding_citizen)] was selected as a replacement headrev.")
		return

	log_dynamic("[config_tag]: Failed to find a replacement headrev.")
	addtimer(CALLBACK(src, PROC_REF(revs_execution_failed)), 1 MINUTES, TIMER_UNIQUE|TIMER_DELETE_ME)

/datum/dynamic_ruleset/roundstart/revolution/proc/revs_execution_failed()
	if(GLOB.revolution_handler)
		return
	// Execution is effectively cancelled by this point, but it's not like we can go back and refund it
	SSdynamic.unreported_rulesets += src
	name += " (Canceled)"
	log_dynamic("[config_tag]: All headrevs were ineligible after the timer expired, and no replacements could be found. Ruleset canceled.")
	message_admins("[config_tag]: All headrevs were ineligible after the timer expired, and no replacements could be found. Ruleset canceled.")

/datum/dynamic_ruleset/roundstart/spies
	name = "Spies"
	config_tag = "Roundstart Spies"
	preview_antag_datum = /datum/antagonist/spy
	pref_flag = ROLE_SPY
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 10
	min_antag_cap = list("denominator" = 20, "offset" = 1)

/datum/dynamic_ruleset/roundstart/spies/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/spy)

/datum/dynamic_ruleset/roundstart/extended
	name = "Extended"
	config_tag = "Extended"
	weight = 0
	min_antag_cap = 0
	repeatable = FALSE
	solo = TRUE

/datum/dynamic_ruleset/roundstart/extended/execute()
	// No midrounds no latejoins
	for(var/category in SSdynamic.rulesets_to_spawn)
		SSdynamic.rulesets_to_spawn[category] = 0

/datum/dynamic_ruleset/roundstart/meteor
	name = "Meteor"
	config_tag = "Meteor"
	weight = 0
	min_antag_cap = 0
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/meteor/execute()
	GLOB.meteor_mode ||= new()
	GLOB.meteor_mode.start_meteor()

/datum/dynamic_ruleset/roundstart/nations
	name = "Nations"
	config_tag = "Nations"
	weight = 0
	min_antag_cap = 0
	repeatable = FALSE
	solo = TRUE

/datum/dynamic_ruleset/roundstart/nations/execute()
	// No midrounds no latejoins
	for(var/category in SSdynamic.rulesets_to_spawn)
		SSdynamic.rulesets_to_spawn[category] = 0

	//notably assistant is not in this list to prevent the round turning into BARBARISM instantly, and silicon is in this list for UN
	var/list/department_types = list(
		/datum/job_department/silicon, //united nations
		/datum/job_department/cargo,
		/datum/job_department/engineering,
		/datum/job_department/medical,
		/datum/job_department/science,
		/datum/job_department/security,
		/datum/job_department/service,
	)

	for(var/department_type in department_types)
		create_separatist_nation(department_type, announcement = FALSE, dangerous = FALSE, message_admins = FALSE)

	GLOB.round_default_lawset = /datum/ai_laws/united_nations

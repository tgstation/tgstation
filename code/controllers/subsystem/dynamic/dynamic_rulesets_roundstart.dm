GLOBAL_VAR_INIT(revolutionary_win, FALSE)

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	antag_flag = ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	minimum_required_age = 0
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	required_candidates = 1
	weight = 5
	cost = 8 // Avoid raising traitor threat above this, as it is the default low cost ruleset.
	scaling_cost = 9
	requirements = list(8,8,8,8,8,8,8,8,8,8)
	antag_cap = list("denominator" = 38)
	var/autotraitor_cooldown = (15 MINUTES)

/datum/dynamic_ruleset/roundstart/traitor/pre_execute(population)
	. = ..()
	for (var/i in 1 to get_antag_cap_scaling_included(population))
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_TRAITOR
		M.mind.restricted_roles = restricted_roles
		GLOB.pre_setup_antags += M.mind
	return TRUE

//////////////////////////////////////////////
//                                          //
//            MALFUNCTIONING AI             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/malf_ai
	name = "Malfunctioning AI"
	antag_flag = ROLE_MALF
	antag_datum = /datum/antagonist/malf_ai
	minimum_required_age = 14
	exclusive_roles = list(JOB_AI)
	required_candidates = 1
	weight = 3
	cost = 18
	requirements = list(101,101,101,80,60,50,30,20,10,10)
	antag_cap = 1
	flags = HIGH_IMPACT_RULESET

/datum/dynamic_ruleset/roundstart/malf_ai/ready(forced)
	var/datum/job/ai_job = SSjob.get_job_type(/datum/job/ai)

	// If we're not forced, we're going to make sure we can actually have an AI in this shift,
	if(!forced && min(ai_job.total_positions - ai_job.current_positions, ai_job.spawn_positions) <= 0)
		log_dynamic("FAIL: [src] could not run, because there is nobody who wants to be an AI")
		return FALSE

	return ..()

/datum/dynamic_ruleset/roundstart/malf_ai/pre_execute(population)
	. = ..()

	var/datum/job/ai_job = SSjob.get_job_type(/datum/job/ai)
	// Maybe a bit too pedantic, but there should never be more malf AIs than there are available positions, spawn positions or antag cap allocations.
	var/num_malf = min(get_antag_cap(population), min(ai_job.total_positions - ai_job.current_positions, ai_job.spawn_positions))
	for (var/i in 1 to num_malf)
		if(candidates.len <= 0)
			break
		var/mob/new_malf = pick_n_take(candidates)
		assigned += new_malf.mind
		new_malf.mind.special_role = ROLE_MALF
		GLOB.pre_setup_antags += new_malf.mind
		// We need an AI for the malf roundstart ruleset to execute. This means that players who get selected as malf AI get priority, because antag selection comes before role selection.
		LAZYADDASSOC(SSjob.dynamic_forced_occupations, new_malf, "AI")
	return TRUE

//////////////////////////////////////////
//                                      //
//           BLOOD BROTHERS             //
//                                      //
//////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/traitorbro
	name = "Blood Brothers"
	antag_flag = ROLE_BROTHER
	antag_datum = /datum/antagonist/brother
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	weight = 5
	cost = 8
	scaling_cost = 15
	requirements = list(40,30,30,20,20,15,15,15,10,10)
	antag_cap = 1

/datum/dynamic_ruleset/roundstart/traitorbro/pre_execute(population)
	. = ..()

	for (var/i in 1 to get_antag_cap_scaling_included(population))
		var/mob/candidate = pick_n_take(candidates)
		if (isnull(candidate))
			break

		assigned += candidate.mind
		candidate.mind.restricted_roles = restricted_roles
		candidate.mind.special_role = ROLE_BROTHER
		GLOB.pre_setup_antags += candidate.mind

	return TRUE

/datum/dynamic_ruleset/roundstart/traitorbro/execute()
	for (var/datum/mind/mind in assigned)
		new /datum/team/brother_team(mind)
		GLOB.pre_setup_antags -= mind

	return TRUE

//////////////////////////////////////////////
//                                          //
//               CHANGELINGS                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	antag_flag = ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 10
	requirements = list(70,70,60,50,40,20,20,10,10,10)
	antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/pre_execute(population)
	. = ..()
	for (var/i in 1 to get_antag_cap_scaling_included(population))
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = ROLE_CHANGELING
		GLOB.pre_setup_antags += M.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/changeling/execute()
	for(var/datum/mind/changeling in assigned)
		var/datum/antagonist/changeling/new_antag = new antag_datum()
		changeling.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= changeling
	return TRUE

//////////////////////////////////////////////
//                                          //
//                 HERETICS                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/heretics
	name = "Heretics"
	antag_flag = ROLE_HERETIC
	antag_datum = /datum/antagonist/heretic
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	required_candidates = 1
	weight = 3
	cost = 16
	scaling_cost = 9
	requirements = list(101,101,60,30,30,25,20,15,10,10)
	antag_cap = list("denominator" = 24)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE)


/datum/dynamic_ruleset/roundstart/heretics/pre_execute(population)
	. = ..()
	var/num_ecult = get_antag_cap(population) * (scaled_times + 1)

	for (var/i = 1 to num_ecult)
		if(candidates.len <= 0)
			break
		var/mob/picked_candidate = pick_n_take(candidates)
		assigned += picked_candidate.mind
		picked_candidate.mind.restricted_roles = restricted_roles
		picked_candidate.mind.special_role = ROLE_HERETIC
		GLOB.pre_setup_antags += picked_candidate.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/heretics/execute()

	for(var/c in assigned)
		var/datum/mind/cultie = c
		var/datum/antagonist/heretic/new_antag = new antag_datum()
		cultie.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= cultie

	return TRUE


//////////////////////////////////////////////
//                                          //
//               WIZARDS                    //
//                                          //
//////////////////////////////////////////////

// Dynamic is a wonderful thing that adds wizards to every round and then adds even more wizards during the round.
/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	antag_flag = ROLE_WIZARD
	antag_datum = /datum/antagonist/wizard
	ruleset_category = parent_type::ruleset_category |  RULESET_CATEGORY_NO_WITTING_CREW_ANTAGONISTS
	flags = HIGH_IMPACT_RULESET
	minimum_required_age = 14
	restricted_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
	) // Just to be sure that a wizard getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 1
	weight = 2
	cost = 20
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_WIZARDDEN)

/datum/dynamic_ruleset/roundstart/wizard/ready(forced = FALSE)
	if(!check_candidates())
		return FALSE
	if(!length(GLOB.wizardstart))
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/roundstart/wizard/round_result()
	for(var/datum/antagonist/wizard/wiz in GLOB.antagonists)
		var/mob/living/real_wiz = wiz.owner?.current
		if(isnull(real_wiz))
			continue

		var/turf/wiz_location = get_turf(real_wiz)
		// If this wiz is alive AND not in an away level, then we know not all wizards are dead and can leave entirely
		if(considered_alive(wiz.owner) && wiz_location && !is_away_level(wiz_location.z))
			return

	SSticker.news_report = WIZARD_KILLED

/datum/dynamic_ruleset/roundstart/wizard/pre_execute()
	. = ..()
	if(GLOB.wizardstart.len == 0)
		return FALSE
	var/mob/M = pick_n_take(candidates)
	if (M)
		assigned += M.mind
		M.mind.set_assigned_role(SSjob.get_job_type(/datum/job/space_wizard))
		M.mind.special_role = ROLE_WIZARD

	return TRUE

/datum/dynamic_ruleset/roundstart/wizard/execute()
	for(var/datum/mind/M in assigned)
		M.current.forceMove(pick(GLOB.wizardstart))
		M.add_antag_datum(new antag_datum())
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
	minimum_required_age = 14
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHAPLAIN,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_candidates = 2
	weight = 3
	cost = 20
	requirements = list(100,90,80,60,40,30,10,10,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 20, "offset" = 1)
	var/datum/team/cult/main_cult

/datum/dynamic_ruleset/roundstart/bloodcult/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	return ..()

/datum/dynamic_ruleset/roundstart/bloodcult/pre_execute(population)
	. = ..()
	var/cultists = get_antag_cap(population)
	for(var/cultists_number = 1 to cultists)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_CULTIST
		M.mind.restricted_roles = restricted_roles
		GLOB.pre_setup_antags += M.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/execute()
	main_cult = new
	for(var/datum/mind/M in assigned)
		var/datum/antagonist/cult/new_cultist = new antag_datum()
		new_cultist.cult_team = main_cult
		new_cultist.give_equipment = TRUE
		M.add_antag_datum(new_cultist)
		GLOB.pre_setup_antags -= M
	main_cult.setup_objectives()
	var/datum/mind/most_experienced = get_most_experienced(assigned, antag_flag)
	if(!most_experienced)
		most_experienced = assigned[1]
	var/datum/antagonist/cult/leader = most_experienced.has_antag_datum(/datum/antagonist/cult)
	leader.make_cult_leader()
	return TRUE

/datum/dynamic_ruleset/roundstart/bloodcult/round_result()
	if(main_cult.check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
		return

	SSticker.mode_result = "loss - staff stopped the cult"

	if(main_cult.size_at_maximum == 0)
		CRASH("Cult team existed with a size_at_maximum of 0 at round end!")

	// If more than a certain ratio of our cultists have escaped, give the "cult escape" resport.
	// Otherwise, give the "cult failure" report.
	var/ratio_to_be_considered_escaped = 0.5
	var/escaped_cultists = 0
	for(var/datum/mind/escapee as anything in main_cult.members)
		if(considered_escaped(escapee))
			escaped_cultists++

	SSticker.news_report = (escaped_cultists / main_cult.size_at_maximum) >= ratio_to_be_considered_escaped ? CULT_ESCAPE : CULT_FAILURE

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Emergency"
	antag_flag = ROLE_OPERATIVE
	ruleset_category = parent_type::ruleset_category |  RULESET_CATEGORY_NO_WITTING_CREW_ANTAGONISTS
	antag_datum = /datum/antagonist/nukeop
	var/datum/antagonist/antag_leader_datum = /datum/antagonist/nukeop/leader
	minimum_required_age = 14
	restricted_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_SECURITY,
	) // Just to be sure that a nukie getting picked won't ever imply a Captain or HoS not getting drafted
	required_candidates = 5
	weight = 3
	cost = 20
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 18, "offset" = 1)
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_NUKIEBASE)
	var/required_role = ROLE_NUCLEAR_OPERATIVE
	var/datum/team/nuclear/nuke_team
	///The job type to dress up our nuclear operative as.
	var/datum/job/job_type = /datum/job/nuclear_operative

/datum/dynamic_ruleset/roundstart/nuclear/ready(population, forced = FALSE)
	required_candidates = get_antag_cap(population)
	return ..()

/datum/dynamic_ruleset/roundstart/nuclear/pre_execute(population)
	. = ..()
	// If ready() did its job, candidates should have 5 or more members in it
	var/operatives = get_antag_cap(population)
	for(var/operatives_number = 1 to operatives)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.set_assigned_role(SSjob.get_job_type(job_type))
		M.mind.special_role = required_role
	return TRUE

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	var/datum/mind/most_experienced = get_most_experienced(assigned, required_role)
	if(!most_experienced)
		most_experienced = assigned[1]
	var/datum/antagonist/nukeop/leader/leader = most_experienced.add_antag_datum(antag_leader_datum)
	nuke_team = leader.nuke_team
	for(var/datum/mind/assigned_player in assigned)
		if(assigned_player == most_experienced)
			continue
		var/datum/antagonist/nukeop/new_op = new antag_datum()
		assigned_player.add_antag_datum(new_op)
	return TRUE

/datum/dynamic_ruleset/roundstart/nuclear/round_result()
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

//////////////////////////////////////////////
//                                          //
//               REVS                       //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/revs
	name = "Revolution"
	persistent = TRUE
	antag_flag = ROLE_REV_HEAD
	antag_flag_override = ROLE_REV_HEAD
	antag_datum = /datum/antagonist/rev/head
	minimum_required_age = 14
	restricted_roles = list(
		JOB_AI,
		JOB_CAPTAIN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CYBORG,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	required_candidates = 3
	weight = 3
	delay = 7 MINUTES
	cost = 20
	requirements = list(101,101,70,40,30,20,10,10,10,10)
	antag_cap = 3
	flags = HIGH_IMPACT_RULESET
	blocking_rules = list(/datum/dynamic_ruleset/latejoin/provocateur)
	// I give up, just there should be enough heads with 35 players...
	minimum_players = 15
	var/datum/team/revolution/revolution
	var/finished = FALSE

/datum/dynamic_ruleset/roundstart/revs/pre_execute(population)
	. = ..()
	var/max_candidates = get_antag_cap(population)
	for(var/i = 1 to max_candidates)
		if(candidates.len <= 0)
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.restricted_roles = restricted_roles
		M.mind.special_role = antag_flag
		GLOB.pre_setup_antags += M.mind
	return TRUE

/datum/dynamic_ruleset/roundstart/revs/execute()
	revolution = new()
	for(var/datum/mind/M in assigned)
		GLOB.pre_setup_antags -= M
		if(check_eligible(M))
			var/datum/antagonist/rev/head/new_head = new antag_datum()
			new_head.give_flash = TRUE
			new_head.give_hud = TRUE
			new_head.remove_clumsy = TRUE
			M.add_antag_datum(new_head,revolution)
		else
			assigned -= M
			log_dynamic("[ruletype] [name] discarded [M.name] from head revolutionary due to ineligibility.")
	if(revolution.members.len)
		revolution.update_objectives()
		revolution.update_rev_heads()
		SSshuttle.registerHostileEnvironment(revolution)
		return TRUE
	log_dynamic("[ruletype] [name] failed to get any eligible headrevs. Refunding [cost] threat.")
	return FALSE

/datum/dynamic_ruleset/roundstart/revs/clean_up()
	qdel(revolution)
	..()

/datum/dynamic_ruleset/roundstart/revs/rule_process()
	var/winner = revolution.process_victory()
	if (isnull(winner))
		return

	finished = winner

	if(winner == REVOLUTION_VICTORY)
		GLOB.revolutionary_win = TRUE

	return RULESET_STOP_PROCESSING

/// Checks for revhead loss conditions and other antag datums.
/datum/dynamic_ruleset/roundstart/revs/proc/check_eligible(datum/mind/M)
	var/turf/T = get_turf(M.current)
	if(!considered_afk(M) && considered_alive(M) && is_station_level(T.z) && !M.antag_datums?.len && !HAS_MIND_TRAIT(M.current, TRAIT_UNCONVERTABLE))
		return TRUE
	return FALSE

/datum/dynamic_ruleset/roundstart/revs/round_result()
	revolution.round_result(finished)

// Admin only rulesets. The threat requirement is 101 so it is not possible to roll them.

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
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET

/datum/dynamic_ruleset/roundstart/extended/pre_execute()
	. = ..()
	message_admins("Starting a round of extended.")
	log_game("Starting a round of extended.")
	SSdynamic.spend_roundstart_budget(SSdynamic.round_start_budget)
	SSdynamic.spend_midround_budget(SSdynamic.mid_round_budget)
	SSdynamic.threat_log += "[gameTimestamp()]: Extended ruleset set threat to 0."
	return TRUE

//////////////////////////////////////////////
//                                          //
//               CLOWN OPS                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops
	name = "Clown Operatives"
	antag_datum = /datum/antagonist/nukeop/clownop
	antag_flag = ROLE_CLOWN_OPERATIVE
	antag_flag_override = ROLE_OPERATIVE
	ruleset_category = parent_type::ruleset_category |  RULESET_CATEGORY_NO_WITTING_CREW_ANTAGONISTS
	antag_leader_datum = /datum/antagonist/nukeop/leader/clownop
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	required_role = ROLE_CLOWN_OPERATIVE
	job_type = /datum/job/clown_operative

/datum/dynamic_ruleset/roundstart/nuclear/clown_ops/pre_execute()
	. = ..()
	if(!.)
		return

	var/list/nukes = SSmachines.get_machines_by_type(/obj/machinery/nuclearbomb/syndicate)
	for(var/obj/machinery/nuclearbomb/syndicate/nuke as anything in nukes)
		new /obj/machinery/nuclearbomb/syndicate/bananium(nuke.loc)
		qdel(nuke)

//////////////////////////////////////////////
//                                          //
//               METEOR                     //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/roundstart/meteor
	name = "Meteor"
	persistent = TRUE
	required_candidates = 0
	weight = 3
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET
	var/meteordelay = 2000
	var/nometeors = FALSE
	var/rampupdelta = 5

/datum/dynamic_ruleset/roundstart/meteor/rule_process()
	if(nometeors || meteordelay > world.time - SSticker.round_start_time)
		return

	var/list/wavetype = GLOB.meteors_normal
	var/meteorminutes = (world.time - SSticker.round_start_time - meteordelay) / 10 / 60

	if (prob(meteorminutes))
		wavetype = GLOB.meteors_threatening

	if (prob(meteorminutes/2))
		wavetype = GLOB.meteors_catastrophic

	var/ramp_up_final = clamp(round(meteorminutes/rampupdelta), 1, 10)

	spawn_meteors(ramp_up_final, wavetype)

/// Ruleset for Nations
/datum/dynamic_ruleset/roundstart/nations
	name = "Nations"
	required_candidates = 0
	weight = 0 //admin only (and for good reason)
	cost = 0
	flags = LONE_RULESET | ONLY_RULESET

/datum/dynamic_ruleset/roundstart/nations/execute()
	. = ..()
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

/datum/dynamic_ruleset/roundstart/spies
	name = "Spies"
	antag_flag = ROLE_SPY
	antag_datum = /datum/antagonist/spy
	minimum_required_age = 0
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL, // AA = bad
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	required_candidates = 3 // lives or dies by there being a few spies
	weight = 5
	cost = 8
	scaling_cost = 4
	minimum_players = 5
	antag_cap = list("denominator" = 20, "offset" = 1)
	requirements = list(8, 8, 8, 8, 8, 8, 8, 8, 8, 8)
	/// What fraction is added to the antag cap for each additional scale
	var/fraction_per_scale = 0.2

/datum/dynamic_ruleset/roundstart/spies/pre_execute(population)
	for(var/i in 1 to get_antag_cap_scaling_included(population))
		if(length(candidates) <= 0)
			break
		var/mob/picked_player = pick_n_take(candidates)
		assigned += picked_player.mind
		picked_player.mind.special_role = ROLE_SPY
		picked_player.mind.restricted_roles = restricted_roles
		GLOB.pre_setup_antags += picked_player.mind
	return TRUE

// Scaling adds a fraction of the amount of additional spies rather than the full amount.
/datum/dynamic_ruleset/roundstart/spies/get_scaling_antag_cap(population)
	return ceil(..() * fraction_per_scale)

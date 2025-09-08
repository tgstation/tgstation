/datum/dynamic_ruleset/latejoin
	min_antag_cap = 1
	max_antag_cap = 1
	repeatable = TRUE

/datum/dynamic_ruleset/latejoin/set_config_value(nvar, nval)
	if(nvar == NAMEOF(src, min_antag_cap) || nvar == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, min_antag_cap) || var_name == NAMEOF(src, max_antag_cap))
		return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/is_valid_candidate(mob/candidate, client/candidate_client)
	if(isnull(candidate.mind))
		return FALSE
	if(candidate.mind.assigned_role.title in get_blacklisted_roles())
		return FALSE
	return ..()

/datum/dynamic_ruleset/latejoin/traitor
	name = "Traitor"
	config_tag = "Latejoin Traitor"
	preview_antag_datum = /datum/antagonist/traitor
	pref_flag = ROLE_SYNDICATE_INFILTRATOR
	jobban_flag = ROLE_TRAITOR
	weight = 10
	min_pop = 3
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/traitor/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor)

/datum/dynamic_ruleset/latejoin/heretic
	name = "Heretic"
	config_tag = "Latejoin Heretic"
	preview_antag_datum = /datum/antagonist/heretic
	pref_flag = ROLE_HERETIC_SMUGGLER
	jobban_flag = ROLE_HERETIC
	weight = 3
	min_pop = 30 // Ensures good spread of sacrifice targets
	ruleset_lazy_templates = list(LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE)
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)

/datum/dynamic_ruleset/latejoin/changeling
	name = "Changeling"
	config_tag = "Latejoin Changeling"
	preview_antag_datum = /datum/antagonist/changeling
	pref_flag = ROLE_STOWAWAY_CHANGELING
	jobban_flag = ROLE_CHANGELING
	weight = 3
	min_pop = 15
	blacklisted_roles = list(
		JOB_HEAD_OF_PERSONNEL,
	)

/datum/dynamic_ruleset/latejoin/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/latejoin/revolution
	name = "Revolution"
	config_tag = "Latejoin Revolution"
	preview_antag_datum = /datum/antagonist/rev/head
	pref_flag = ROLE_PROVOCATEUR
	jobban_flag = ROLE_REV_HEAD
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = 1
	min_pop = 30
	repeatable = FALSE
	/// How many heads of staff are required to be on the station for this to be selected
	var/heads_necessary = 3

/datum/dynamic_ruleset/latejoin/revolution/can_be_selected()
	if(GLOB.revolution_handler)
		return FALSE
	var/head_check = 0
	for(var/mob/player as anything in get_active_player_list(alive_check = TRUE, afk_check = TRUE))
		if (player.mind.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			head_check++
	return head_check >= heads_necessary

/datum/dynamic_ruleset/latejoin/revolution/get_always_blacklisted_roles()
	. = ..()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(job.job_flags & JOB_HEAD_OF_STAFF)
			. |= job.title

/datum/dynamic_ruleset/latejoin/revolution/assign_role(datum/mind/candidate)
	LAZYADD(candidate.special_roles, "Dormant Head Revolutionary")
	addtimer(CALLBACK(src, PROC_REF(reveal_head), candidate), 1 MINUTES, TIMER_DELETE_ME)

/datum/dynamic_ruleset/latejoin/revolution/proc/reveal_head(datum/mind/candidate)
	LAZYREMOVE(candidate.special_roles, "Dormant Head Revolutionary")

	var/head_check = 0
	for(var/mob/player as anything in get_active_player_list(alive_check = TRUE, afk_check = TRUE))
		if(player.mind?.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
			head_check++

	if(head_check < heads_necessary - 1) // little bit of leeway
		SSdynamic.unreported_rulesets += src
		name += " (Canceled)"
		log_dynamic("[config_tag]: Not enough heads of staff were present to start a revolution.")
		return

	if(!can_be_headrev(candidate))
		SSdynamic.unreported_rulesets += src
		name += " (Canceled)"
		log_dynamic("[config_tag]: [key_name(candidate)] was ineligible after the timer expired. Ruleset canceled.")
		message_admins("[config_tag]: [key_name(candidate)] was ineligible after the timer expired. Ruleset canceled.")
		return

	GLOB.revolution_handler ||= new()
	var/datum/antagonist/rev/head/new_head = new()
	new_head.give_flash = TRUE
	new_head.give_hud = TRUE
	new_head.remove_clumsy = TRUE
	candidate.add_antag_datum(new_head, GLOB.revolution_handler.revs)
	GLOB.revolution_handler.start_revolution()

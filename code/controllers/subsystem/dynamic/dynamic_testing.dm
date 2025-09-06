
/// Verb to open the create command report window and send command reports.
ADMIN_VERB(dynamic_tester, R_DEBUG, "Dynamic Tester", "See dynamic probabilities.", ADMIN_CATEGORY_DEBUG)
	BLACKBOX_LOG_ADMIN_VERB("Dynamic Tester")
	var/datum/dynamic_tester/tgui = new()
	tgui.ui_interact(user.mob)

/datum/dynamic_tester
	/// Instances of every roundstart ruleset
	var/list/roundstart_rulesets = list()
	/// Instances of every midround ruleset
	var/list/midround_rulesets = list()

	/// A formatted report of the weights of each roundstart ruleset, refreshed occasionally and sent to the UI.
	var/list/roundstart_ruleset_report = list()
	/// A formatted report of the weights of each midround ruleset, refreshed occasionally and sent to the UI.
	var/list/midround_ruleset_report = list()

	/// What is the tier we are testing?
	var/tier = 1
	/// How many players are we testing with?
	var/num_players = 10

/datum/dynamic_tester/New()
	for(var/datum/dynamic_ruleset/rtype as anything in subtypesof(/datum/dynamic_ruleset/roundstart))
		if(!initial(rtype.config_tag))
			continue
		var/datum/dynamic_ruleset/roundstart/created = new rtype(SSdynamic.get_config())
		roundstart_rulesets += created
		// snowflake so we can see headrev stats
		if(istype(created, /datum/dynamic_ruleset/roundstart/revolution))
			var/datum/dynamic_ruleset/roundstart/revolution/revs = created
			revs.heads_necessary = 0

	for(var/datum/dynamic_ruleset/rtype as anything in subtypesof(/datum/dynamic_ruleset/midround))
		if(!initial(rtype.config_tag))
			continue
		var/datum/dynamic_ruleset/midround/created = new rtype(SSdynamic.get_config())
		midround_rulesets += created

	update_reports()

/datum/dynamic_tester/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/dynamic_tester/ui_close()
	qdel(src)

/datum/dynamic_tester/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DynamicTester")
		ui.open()

/datum/dynamic_tester/ui_static_data(mob/user)
	var/list/data = list()

	data["tier"] = tier
	data["num_players"] = num_players
	data["roundstart_ruleset_report"] = flatten_list(roundstart_ruleset_report)
	data["midround_ruleset_report"] = flatten_list(midround_ruleset_report)

	return data

/datum/dynamic_tester/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_num_players")
			var/old_num = num_players
			num_players = max(text2num(params["num_players"]), 1)
			if(old_num != num_players)
				update_reports()
			return TRUE

		if("set_tier")
			var/old_tier = tier
			tier = max(text2num(params["tier"]), 1)
			if(old_tier != tier)
				update_reports()
			return TRUE

/datum/dynamic_tester/proc/update_reports()
	roundstart_ruleset_report.Cut()
	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in roundstart_rulesets)
		var/comment = ""
		if(istype(ruleset, /datum/dynamic_ruleset/roundstart/revolution))
			var/datum/dynamic_ruleset/roundstart/revolution/revs = ruleset
			comment = " (Assuming [initial(revs.heads_necessary)] heads of staff)"

		roundstart_ruleset_report[ruleset] = list(
			"name" = ruleset.name,
			"weight" = ruleset.get_weight(num_players, tier),
			"max_candidates" = ruleset.get_antag_cap(num_players, ruleset.max_antag_cap || ruleset.min_antag_cap),
			"min_candidates" = ruleset.get_antag_cap(num_players, ruleset.min_antag_cap),
			"comment" = comment,
		)

	midround_ruleset_report.Cut()
	for(var/datum/dynamic_ruleset/midround/ruleset as anything in midround_rulesets)
		midround_ruleset_report[ruleset] = list(
			"name" = ruleset.name,
			"weight" = ruleset.get_weight(num_players, tier),
			"max_candidates" = ruleset.get_antag_cap(num_players, ruleset.max_antag_cap || ruleset.min_antag_cap),
			"min_candidates" = ruleset.get_antag_cap(num_players, ruleset.min_antag_cap),
			"comment" = ruleset.midround_type,
		)

	update_static_data_for_all_viewers()

#define CURRENT_LIVING_PLAYERS	1
#define CURRENT_LIVING_ANTAGS	2
#define CURRENT_DEAD_PLAYERS	3
#define CURRENT_OBSERVERS	    4

#define HIGHLANDER_RULESET 1
#define TRAITOR_RULESET    2
#define MINOR_RULESET      4

#define RULESET_STOP_PROCESSING 1

 // -- Injection delays
GLOBAL_VAR_INIT(dynamic_latejoin_delay_min, (5 MINUTES))
GLOBAL_VAR_INIT(dynamic_latejoin_delay_max, (25 MINUTES))

GLOBAL_VAR_INIT(dynamic_midround_delay_min, (15 MINUTES))
GLOBAL_VAR_INIT(dynamic_midround_delay_max, (35 MINUTES))

GLOBAL_VAR_INIT(dynamic_no_stacking, TRUE)
GLOBAL_VAR_INIT(dynamic_curve_centre, 0)
GLOBAL_VAR_INIT(dynamic_curve_width, 1.8)
GLOBAL_VAR_INIT(dynamic_classic_secret, FALSE)
GLOBAL_VAR_INIT(dynamic_high_pop_limit, 60)
GLOBAL_VAR_INIT(dynamic_forced_extended, FALSE)
GLOBAL_VAR_INIT(dynamic_stacking_limit, 90)
GLOBAL_LIST_EMPTY(dynamic_forced_roundstart_ruleset)

/datum/game_mode/dynamic
	name = "dynamic mode"
	config_tag = "dynamic"
	report_type = "dynamic"

	announce_span = "danger"
	announce_text = "Dynamic mode!" // This needs to be changed maybe

	reroll_friendly = FALSE;
	
	// Threat logging vars
	var/threat_level = 0 // The "threat cap", threat shouldn't normally go above this and is used in ruleset calculations
	var/threat = 0 // Set at the beginning of the round. Spent by the mode to "purchase" rules.
	var/list/threat_log = list() // Running information about the threat. Can store text or datum entries.

	var/list/roundstart_rules = list()
	var/list/latejoin_rules = list()
	var/list/midround_rules = list()
	// Pop range per requirement. If this is the default five, the pop range for requirements are:
	// 0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	var/pop_per_requirement = 5
	// Second and third rule requirements are the threat level requirements per pop range, see pop_per_requirement for pop range.
	var/list/second_rule_req = list(100,100,80,70,60,40,20,0,0,0)
	var/list/third_rule_req = list(100,100,100,90,80,70,50,30,10,0)
	var/high_pop_second_rule_req = 50
	var/high_pop_third_rule_req = 70
	var/roundstart_pop_ready = 0
	var/list/candidates = list()
	var/list/current_rules = list()
	var/list/executed_rules = list()

	var/list/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)

	var/latejoin_injection_cooldown = 0
	var/midround_injection_cooldown = 0
	var/forced_injection = FALSE

	var/datum/dynamic_ruleset/latejoin/forced_latejoin_rule = null

	var/pop_last_updated = 0

	var/relative_threat = 0 // Relative threat, Lorentz-distributed.

	var/peaceful_percentage = 50

/datum/game_mode/dynamic/AdminPanel()
	var/list/dat = list("<html><head><title>Game Mode Panel</title></head><body><h1><B>Game Mode Panel</B></h1>")
	dat += "Dynamic Mode <a href='?_src_=vars;[HrefToken()];Vars=[REF(src)]'>\[VV\]</A><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Threat to Spend: <b>[threat]</b> <a href='?src=\ref[src];[HrefToken()];adjustthreat=1'>\[Adjust\]</A> <a href='?src=\ref[src];[HrefToken()];threatlog=1'>\[View Log\]</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [GLOB.dynamic_curve_centre] ; width = [GLOB.dynamic_curve_width].<br/>"
	dat += "<i>On average, <b>[peaceful_percentage]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "Forced extended: <a href='?src=\ref[src];[HrefToken()];forced_extended=1'><b>[GLOB.dynamic_forced_extended ? "On" : "Off"]</b></a><br/>"
	dat += "Classic secret (only autotraitor): <a href='?src=\ref[src];[HrefToken()];classic_secret=1'><b>[GLOB.dynamic_classic_secret ? "On" : "Off"]</b></a><br/>"
	dat += "No stacking (only one round-ender): <a href='?src=\ref[src];[HrefToken()];no_stacking=1'><b>[GLOB.dynamic_no_stacking ? "On" : "Off"]</b></a><br/>"
	dat += "Stacking limit: [GLOB.dynamic_stacking_limit] <a href='?src=\ref[src];[HrefToken()];stacking_limit=1'>\[Adjust\]</A>"
	dat += "<br/>"
	dat += "Executed rulesets: "
	if (executed_rules.len > 0)
		dat += "<br/>"
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			dat += "[DR.ruletype] - <b>[DR.name]</b><br>"
	else
		dat += "none.<br>"
	dat += "<br>Injection Timers: (<b>[GetInjectionChance(TRUE)]%</b> chance)<BR>"
	dat += "Latejoin: [latejoin_injection_cooldown>60*10 ? "[round(latejoin_injection_cooldown/60/10,0.1)] minutes" : "[latejoin_injection_cooldown] seconds"] <a href='?src=\ref[src];[HrefToken()];injectlate=1'>\[Now!\]</a><BR>"
	dat += "Midround: [midround_injection_cooldown>60*10 ? "[round(midround_injection_cooldown/60/10,0.1)] minutes" : "[midround_injection_cooldown] seconds"] <a href='?src=\ref[src];[HrefToken()];injectmid=2'>\[Now!\]</a><BR>"
	usr << browse(dat.Join(), "window=gamemode_panel;size=500x500")

/datum/game_mode/dynamic/Topic(href, href_list)
	if (..()) // Sanity, maybe ?
		return
	if(!check_rights(R_ADMIN))
		message_admins("[usr.key] has attempted to override the game mode panel!")
		log_admin("[key_name(usr)] tried to use the game mode panel without authorization.")
		return
	if (href_list["forced_extended"])
		GLOB.dynamic_forced_extended = !GLOB.dynamic_forced_extended
	else if (href_list["no_stacking"])
		GLOB.dynamic_no_stacking = !GLOB.dynamic_no_stacking
	else if (href_list["classic_secret"])
		GLOB.dynamic_classic_secret = !GLOB.dynamic_classic_secret
	else if (href_list["adjustthreat"])
		var/threatadd = input("Specify how much threat to add (negative to subtract). This can inflate the threat level.", "Adjust Threat", 0) as null|num
		if(!threatadd)
			return
		if(threatadd > 0)
			create_threat(threatadd)
		else
			spend_threat(-threatadd)
	else if (href_list["injectlate"])
		latejoin_injection_cooldown = 0
		forced_injection = TRUE
	else if (href_list["injectmid"])
		midround_injection_cooldown = 0
		forced_injection = TRUE
	else if (href_list["threatlog"])
		show_threatlog(usr)
	else if (href_list["stacking_limit"])
		GLOB.dynamic_stacking_limit = input(usr,"Change the threat limit at which round-endings rulesets will start to stack.", "Change stacking limit", null) as num
	
	AdminPanel() // Refreshes the window

// This needs to be changed to take the result from the ruleset that ended the game mode
/datum/game_mode/dynamic/set_round_result()
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(rule.flags == HIGHLANDER_RULESET)
			if(rule.check_finished()) // Only the rule that actually finished the round sets round result.
				return rule.round_result()
	// If it got to this part, just pick one highlander if it exists
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(rule.flags == HIGHLANDER_RULESET)
			return rule.round_result()
	return ..()

/datum/game_mode/dynamic/send_intercept()
	. = "<b><i>Central Command Status Summary</i></b><hr>"
	switch(round(threat_level))
		if(0 to 19)
			update_playercounts()
			if(!current_players[CURRENT_LIVING_ANTAGS].len)
				. += "<b>Peaceful Waypoint</b></center><BR>"
				. += "Your station orbits deep within controlled, core-sector systems and serves as a waypoint for routine traffic through Nanotrasen's trade empire. Due to the combination of high security, interstellar traffic, and low strategic value, it makes any direct threat of violence unlikely. Your primary enemies will be incompetence and bored crewmen: try to organize team-building events to keep staffers interested and productive."
			else
				. += "<b>Core Territory</b></center><BR>"
				. += "Your station orbits within reliably mundane, secure space. Although Nanotrasen has a firm grip on security in your region, the valuable resources and strategic position aboard your station make it a potential target for infiltrations. Monitor crew for non-loyal behavior, but expect a relatively tame shift free of large-scale destruction. We expect great things from your station."
		if(20 to 39)
			. += "<b>Anomalous Exogeology</b></center><BR>"
			. += "Although your station lies within what is generally considered Nanotrasen-controlled space, the course of its orbit has caused it to cross unusually close to exogeological features with anomalous readings. Although these features offer opportunities for our research department, it is known that these little understood readings are often correlated with increased activity from competing interstellar organizations and individuals, among them the Wizard Federation and Cult of the Geometer of Blood - all known competitors for Anomaly Type B sites. Exercise elevated caution."
		if(40 to 65)
			. += "<b>Contested System</b></center><BR>"
			. += "Your station's orbit passes along the edge of Nanotrasen's sphere of influence. While subversive elements remain the most likely threat against your station, hostile organizations are bolder here, where our grip is weaker. Exercise increased caution against elite Syndicate strike forces, or Executives forbid, some kind of ill-conceived unionizing attempt."
		if(66 to 79)
			. += "<b>Uncharted Space</b></center><BR>"
			. += "Congratulations and thank you for participating in the NT 'Frontier' space program! Your station is actively orbiting a high value system far from the nearest support stations. Little is known about your region of space, and the opportunity to encounter the unknown invites greater glory. You are encouraged to elevate security as necessary to protect Nanotrasen assets."
		if(80 to 99)
			. += "<b>Black Orbit</b></center><BR>"
			. += "As part of a mandatory security protocol, we are required to inform you that as a result of your orbital pattern directly behind an astrological body (oriented from our nearest observatory), your station will be under decreased monitoring and support. It is anticipated that your extreme location and decreased surveillance could pose security risks. Avoid unnecessary risks and attempt to keep your station in one piece."
		if(100)
			. += "<b>Impending Doom</b></center><BR>"
			. += "Your station is somehow in the middle of hostile territory, in clear view of any enemy of the corporation. Your likelihood to survive is low, and station destruction is expected and almost inevitable. Secure any sensitive material and neutralize any enemy you will come across. It is important that you at least try to maintain the station.<BR>"
			. += "Good luck."

	if(station_goals.len)
		. += "<hr><b>Special Orders for [station_name()]:</b>"
		for(var/datum/station_goal/G in station_goals)
			G.on_report()
			. += G.get_report()

	print_command_report(., "Central Command Status Summary", announce=FALSE)
	priority_announce("A summary has been copied and printed to all communications consoles.", "Security level elevated.", 'sound/ai/intercept.ogg')
	if(GLOB.security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)

// Yes, this is copy pasted from game_mode
/datum/game_mode/dynamic/check_finished(force_ending)
	if(!SSticker.setup_done || !gamemode_ready)
		return FALSE
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(rule.flags == HIGHLANDER_RULESET)
			return rule.check_finished()

/datum/game_mode/dynamic/proc/show_threatlog(mob/admin)
	if(!SSticker.HasRoundStarted())
		alert("The round hasn't started yet!")
		return

	if(!check_rights(R_ADMIN))
		return

	var/list/out = list("<TITLE>Threat Log</TITLE><B><font size='3'>Threat Log</font></B><br><B>Starting Threat:</B> [threat_level]<BR>")

	for(var/entry in threat_log)
		if(istext(entry))
			out += "[entry]<BR>"

	out += "<B>Remaining threat/threat_level:</B> [threat]/[threat_level]"

	usr << browse(out.Join(), "window=threatlog;size=700x500")

/datum/game_mode/dynamic/proc/generate_threat()
	relative_threat = LORENTZ_DISTRIBUTION(GLOB.dynamic_curve_centre, GLOB.dynamic_curve_width)
	threat_level = round(lorentz2threat(relative_threat), 0.1)

	peaceful_percentage = round(LORENTZ_CUMULATIVE_DISTRIBUTION(relative_threat, GLOB.dynamic_curve_centre, GLOB.dynamic_curve_width), 0.01)*100

	threat = threat_level

/datum/game_mode/dynamic/can_start()
	message_admins("Dynamic mode parameters for the round:")
	message_admins("Centre is [GLOB.dynamic_curve_centre], Width is [GLOB.dynamic_curve_width], Forced extended is [GLOB.dynamic_forced_extended ? "Enabled" : "Disabled"], No stacking is [GLOB.dynamic_no_stacking ? "Enabled" : "Disabled"].")
	message_admins("Stacking limit is [GLOB.dynamic_stacking_limit], Classic secret is [GLOB.dynamic_classic_secret ? "Enabled" : "Disabled"], High population limit is [GLOB.dynamic_high_pop_limit].")
	log_game("DYNAMIC: Dynamic mode parameters for the round:")
	log_game("DYNAMIC: Centre is [GLOB.dynamic_curve_centre], Width is [GLOB.dynamic_curve_width], Forced extended is [GLOB.dynamic_forced_extended ? "Enabled" : "Disabled"], No stacking is [GLOB.dynamic_no_stacking ? "Enabled" : "Disabled"].")
	log_game("DYNAMIC: Stacking limit is [GLOB.dynamic_stacking_limit], Classic secret is [GLOB.dynamic_classic_secret ? "Enabled" : "Disabled"], High population limit is [GLOB.dynamic_high_pop_limit].")
	generate_threat()

	var/latejoin_injection_cooldown_middle = 0.5*(GLOB.dynamic_latejoin_delay_max + GLOB.dynamic_latejoin_delay_min)
	latejoin_injection_cooldown = round(CLAMP(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), GLOB.dynamic_latejoin_delay_min, GLOB.dynamic_latejoin_delay_max)) + world.time

	var/midround_injection_cooldown_middle = 0.5*(GLOB.dynamic_midround_delay_max + GLOB.dynamic_midround_delay_min)
	midround_injection_cooldown = round(CLAMP(EXP_DISTRIBUTION(midround_injection_cooldown_middle), GLOB.dynamic_midround_delay_min, GLOB.dynamic_midround_delay_max)) + world.time
	message_admins("Dynamic Mode initialized with a Threat Level of... [threat_level]!")
	log_game("DYNAMIC: Dynamic Mode initialized with a Threat Level of... [threat_level]!")
	return TRUE

/datum/game_mode/dynamic/pre_setup()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart) - /datum/dynamic_ruleset/roundstart/delayed/)
		roundstart_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/latejoin))
		latejoin_rules += new rule()
	for (var/rule in subtypesof(/datum/dynamic_ruleset/midround))
		var/datum/dynamic_ruleset/midround/DR = rule
		if (initial(DR.weight))
			midround_rules += new rule()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			roundstart_pop_ready++
			candidates.Add(player)
	log_game("DYNAMIC: Listing [roundstart_rules.len] round start rulesets, and [candidates.len] players ready.")
	if (candidates.len <= 0)
		return TRUE
	if (roundstart_rules.len <= 0)
		return TRUE
	
	if(GLOB.dynamic_forced_roundstart_ruleset.len > 0)
		rigged_roundstart()
	else 
		roundstart()

	var/starting_rulesets = ""
	for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
		starting_rulesets += "[DR.name], "
	candidates.Cut()
	return TRUE

/datum/game_mode/dynamic/post_setup(report)
	update_playercounts()

	for(var/datum/dynamic_ruleset/roundstart/rule in executed_rules)
		rule.candidates.Cut() // The rule should not use candidates at this point as they all are null.
		if(!rule.execute())
			stack_trace("The starting rule \"[rule.name]\" failed to execute.")
	
	..()

/datum/game_mode/dynamic/proc/rigged_roundstart()
	message_admins("[GLOB.dynamic_forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	log_game("DYNAMIC: [GLOB.dynamic_forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	for (var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
		message_admins("Drafting players for forced ruleset [rule.name].")
		log_game("DYNAMIC: Drafting players for forced ruleset [rule.name].")
		rule.mode = src
		if (rule.ready(TRUE)) // Ignoring enemy job requirements
			picking_roundstart_rule(list(rule))

/datum/game_mode/dynamic/proc/roundstart()
	if (GLOB.dynamic_forced_extended)
		log_game("DYNAMIC: Starting a round of forced extended.")
		return TRUE
	var/list/drafted_rules = list()
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (threat < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
			if(rule.flags == HIGHLANDER_RULESET && check_for_highlander(drafted_rules))
				continue
		if (rule.acceptable(roundstart_pop_ready,threat_level) && threat >= rule.cost)	// If we got the population and threat required
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready())
				drafted_rules[rule] = rule.weight

	var/indice_pop = min(10,round(roundstart_pop_ready/pop_per_requirement)+1)
	var/extra_rulesets_amount = 0
	if (GLOB.dynamic_classic_secret)
		extra_rulesets_amount = 0
	else
		if (roundstart_pop_ready > GLOB.dynamic_high_pop_limit)
			message_admins("High Population Override is in effect! Threat Level will have more impact on which roles will appear, and player population less.")
			log_game("DYNAMIC: High Population Override is in effect! Threat Level will have more impact on which roles will appear, and player population less.")
			if (threat_level > high_pop_second_rule_req)
				extra_rulesets_amount++
				if (threat_level > high_pop_third_rule_req)
					extra_rulesets_amount++
		else
			if (threat_level >= second_rule_req[indice_pop])
				extra_rulesets_amount++
				if (threat_level >= third_rule_req[indice_pop])
					extra_rulesets_amount++

	if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
		if (extra_rulesets_amount > 0) // We've got enough population and threat for a second rulestart rule
			for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
				if (rule.cost > threat)
					drafted_rules -= rule
			if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
				if (extra_rulesets_amount > 1) // We've got enough population and threat for a third rulestart rule
					for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
						if (rule.cost > threat)
							drafted_rules -= rule
					picking_roundstart_rule(drafted_rules)
	else
		return FALSE
	return TRUE

/datum/game_mode/dynamic/proc/picking_roundstart_rule(list/drafted_rules = list())
	var/datum/dynamic_ruleset/roundstart/starting_rule = pickweight(drafted_rules)

	if (starting_rule)
		message_admins("Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset [starting_rule.name]")
		log_game("DYNAMIC: Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset [starting_rule.name]")

		roundstart_rules -= starting_rule
		drafted_rules -= starting_rule

		if (istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/))
			var/datum/dynamic_ruleset/roundstart/delayed/rule = starting_rule
			spend_threat(rule.cost)
			addtimer(CALLBACK(src, .proc/execute_delayed, rule), rule.delay)

		spend_threat(starting_rule.cost)
		threat_log += "[worldtime2text()]: Roundstart [starting_rule.name] spent [starting_rule.cost]"
		starting_rule.trim_candidates()
		if (starting_rule.pre_execute())
			executed_rules += starting_rule
			if (starting_rule.persistent)
				current_rules += starting_rule
			for(var/mob/M in starting_rule.assigned)
				for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
					if (!rule.ready())
						drafted_rules -= rule // And removing rules that are no longer elligible
			return TRUE
		else
			stack_trace("The starting rule \"[starting_rule.name]\" failed to pre_execute.")
	return FALSE

/datum/game_mode/dynamic/proc/execute_delayed(datum/dynamic_ruleset/roundstart/delayed/rule)
	rule.candidates = GLOB.player_list.Copy()
	rule.trim_candidates()
	if(rule.execute())
		executed_rules += rule
		if (rule.persistent)
			current_rules += rule
		return TRUE
	
/datum/game_mode/dynamic/proc/picking_latejoin_rule(list/drafted_rules = list())
	var/datum/dynamic_ruleset/latejoin/latejoin_rule = pickweight(drafted_rules)
	if (latejoin_rule)
		if (!latejoin_rule.repeatable)
			latejoin_rules = remove_rule(latejoin_rules,latejoin_rule.type)
		spend_threat(latejoin_rule.cost)
		threat_log += "[worldtime2text()]: Latejoin [latejoin_rule.name] spent [latejoin_rule.cost]"
		if (latejoin_rule.execute())
			var/mob/M = pick(latejoin_rule.assigned)
			message_admins("[key_name(M)] joined the station, and was selected by the [latejoin_rule.name] ruleset.")
			log_game("DYNAMIC: [key_name(M)] joined the station, and was selected by the [latejoin_rule.name] ruleset.")
			executed_rules += latejoin_rule
			if (latejoin_rule.persistent)
				current_rules += latejoin_rule
			return TRUE
		else
			stack_trace("The latejoin rule \"[latejoin_rule.name]\" failed to execute.")
	return FALSE

/datum/game_mode/dynamic/proc/picking_midround_rule(list/drafted_rules = list())
	var/datum/dynamic_ruleset/midround/midround_rule = pickweight(drafted_rules)
	if (midround_rule)
		if (!midround_rule.repeatable)
			midround_rules = remove_rule(midround_rules,midround_rule.type)
		spend_threat(midround_rule.cost)
		threat_log += "[worldtime2text()]: Midround [midround_rule.name] spent [midround_rule.cost]"
		if (midround_rule.execute())
			message_admins("Injecting midround rule [midround_rule.name]")
			log_game("DYNAMIC: Injecting some threats...[midround_rule.name]!")
			executed_rules += midround_rule
			if (midround_rule.persistent)
				current_rules += midround_rule
			return TRUE
		else
			stack_trace("The midround rule \"[midround_rule.name]\" failed to execute.")
	return FALSE

/datum/game_mode/dynamic/proc/picking_specific_rule(ruletype, forced=0) // An experimental proc to allow admins to call rules on the fly or have rules call other rules
	var/datum/dynamic_ruleset/midround/new_rule
	if(ispath(ruletype))
		new_rule = new ruletype() // You should only use it to call midround rules though.
	else if(istype(ruletype,/datum/dynamic_ruleset))
		new_rule = ruletype
	else
		return FALSE
	update_playercounts()
	if (new_rule && (forced || (new_rule.acceptable(current_players[CURRENT_LIVING_PLAYERS].len,threat_level) && new_rule.cost <= threat)))
		new_rule.candidates = current_players.Copy()
		new_rule.trim_candidates()
		if (new_rule.ready(forced))
			spend_threat(new_rule.cost)
			threat_log += "[worldtime2text()]: Forced rule [new_rule.name] spent [new_rule.cost]"
			if (new_rule.execute()) // This should never fail since ready() returned 1
				log_game("DYNAMIC: Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				if (new_rule.persistent)
					current_rules += new_rule
				return TRUE
		else if (forced)
			log_game("DYNAMIC: The ruleset [new_rule.name] couldn't be executed due to lack of elligible players.")
	return FALSE

/datum/game_mode/dynamic/process()
	if (pop_last_updated < world.time - (60 SECONDS))
		pop_last_updated = world.time
		update_playercounts()

	for (var/datum/dynamic_ruleset/rule in current_rules)
		if(rule.rule_process() == RULESET_STOP_PROCESSING) // If rule_process() returns 1 (RULESET_STOP_PROCESSING), stop processing.
			current_rules -= rule

	if (midround_injection_cooldown < world.time)
		if (GLOB.dynamic_forced_extended)
			return
		// Time to inject some threat into the round
		if(EMERGENCY_ESCAPED_OR_ENDGAMED) // Unless the shuttle is gone
			return

		log_game("DYNAMIC: Checking state of the round.")

		update_playercounts()

		if (prob(GetInjectionChance()))
			var/list/drafted_rules = list()
			for (var/datum/dynamic_ruleset/midround/rule in midround_rules)
				if (rule.acceptable(current_players[CURRENT_LIVING_PLAYERS].len,threat_level) && threat >= rule.cost)
					// Classic secret : only autotraitor/minor roles
					if (GLOB.dynamic_classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))
						continue
					// No stacking : only one round-enter, unless > stacking_limit threat.
					if (threat < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
						if(rule.flags == HIGHLANDER_RULESET && check_for_highlander(drafted_rules))
							continue
					rule.candidates = list()
					rule.candidates = current_players.Copy()
					rule.trim_candidates()
					if (rule.ready())
						drafted_rules[rule] = rule.get_weight()

			if (drafted_rules.len > 0)
				picking_midround_rule(drafted_rules)
		var/midround_injection_cooldown_middle = 0.5*(GLOB.dynamic_midround_delay_max + GLOB.dynamic_midround_delay_min)
		midround_injection_cooldown = round(CLAMP(EXP_DISTRIBUTION(midround_injection_cooldown_middle), GLOB.dynamic_midround_delay_min, GLOB.dynamic_midround_delay_max)) + world.time

/datum/game_mode/dynamic/proc/update_playercounts()
	current_players[CURRENT_LIVING_PLAYERS] = list()
	current_players[CURRENT_LIVING_ANTAGS] = list()
	current_players[CURRENT_DEAD_PLAYERS] = list()
	current_players[CURRENT_OBSERVERS] = list()
	for (var/mob/M in GLOB.player_list)
		if (istype(M, /mob/dead/new_player))
			continue
		if (M.stat != DEAD)
			current_players[CURRENT_LIVING_PLAYERS].Add(M)
			if (M.mind && (M.mind.special_role || M.mind.antag_datums?.len > 0))
				current_players[CURRENT_LIVING_ANTAGS].Add(M)
		else
			if (istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if (O.started_as_observer) // Observers
					current_players[CURRENT_OBSERVERS].Add(M)
					continue
			current_players[CURRENT_DEAD_PLAYERS].Add(M) // Players who actually died (and admins who ghosted, would be nice to avoid counting them somehow)

/datum/game_mode/dynamic/proc/GetInjectionChance(dry_run = FALSE)
	if(forced_injection)
		forced_injection = !dry_run
		return 100
	var/chance = 0
	// If the high pop override is in effect, we reduce the impact of population on the antag injection chance
	var/high_pop_factor = (current_players[CURRENT_LIVING_PLAYERS].len >= GLOB.dynamic_high_pop_limit)
	var/max_pop_per_antag = max(5,15 - round(threat_level/10) - round(current_players[CURRENT_LIVING_PLAYERS].len/(high_pop_factor ? 10 : 5))) // https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=2053826290
	if (!current_players[CURRENT_LIVING_ANTAGS].len)
		chance += 50 // No antags at all? let's boost those odds!
	else
		var/current_pop_per_antag = current_players[CURRENT_LIVING_PLAYERS].len / current_players[CURRENT_LIVING_ANTAGS].len
		if (current_pop_per_antag > max_pop_per_antag)
			chance += min(50, 25+10*(current_pop_per_antag-max_pop_per_antag))
		else
			chance += 25-10*(max_pop_per_antag-current_pop_per_antag)
	if (current_players[CURRENT_DEAD_PLAYERS].len > current_players[CURRENT_LIVING_PLAYERS].len)
		chance -= 30 // More than half the crew died? ew, let's calm down on antags
	if (threat > 70)
		chance += 15
	if (threat < 30)
		chance -= 15
	return round(max(0,chance))

/datum/game_mode/dynamic/proc/remove_rule(list/rule_list, rule_type)
	for(var/datum/dynamic_ruleset/DR in rule_list)
		if(istype(DR,rule_type))
			rule_list -= DR
	return rule_list

/datum/game_mode/dynamic/make_antag_chance(mob/living/carbon/human/newPlayer)
	if (GLOB.dynamic_forced_extended)
		return
	if(EMERGENCY_ESCAPED_OR_ENDGAMED) // No more rules after the shuttle has left
		return

	update_playercounts()

	if (forced_latejoin_rule)
		forced_latejoin_rule.candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		log_game("DYNAMIC: Forcing ruleset [forced_latejoin_rule]")
		if (forced_latejoin_rule.ready(TRUE))
			picking_latejoin_rule(list(forced_latejoin_rule))
		forced_latejoin_rule = null

	else if (latejoin_injection_cooldown < world.time && prob(GetInjectionChance()))
		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (rule.acceptable(current_players[CURRENT_LIVING_PLAYERS].len,threat_level) && threat >= rule.cost)
				// Classic secret : only autotraitor/minor roles
				if (GLOB.dynamic_classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))
					continue
				// No stacking : only one round-enter, unless > stacking_limit threat.
				if (threat < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
					if(rule.flags == HIGHLANDER_RULESET && check_for_highlander(drafted_rules))
						continue
					
				rule.candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && picking_latejoin_rule(drafted_rules))
			var/latejoin_injection_cooldown_middle = 0.5*(GLOB.dynamic_latejoin_delay_max + GLOB.dynamic_latejoin_delay_min)
			latejoin_injection_cooldown = round(CLAMP(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), GLOB.dynamic_latejoin_delay_min, GLOB.dynamic_latejoin_delay_max)) + world.time

// Regenerate threat, but no more than our original threat level.
/datum/game_mode/dynamic/proc/refund_threat(regain)
	threat = min(threat_level,threat+regain)

// Generate threat and increase the threat_level if it goes beyond, capped at 100
/datum/game_mode/dynamic/proc/create_threat(gain)
	threat = min(100, threat+gain)
	if(threat>threat_level)
		threat_level = threat

// Expend threat, but do not fall below 0.
/datum/game_mode/dynamic/proc/spend_threat(cost)
	threat = max(threat-cost,0)

/datum/game_mode/dynamic/proc/check_for_highlander(list/drafted_rules)
	for (var/datum/dynamic_ruleset/roundstart/DR in drafted_rules)
		if (DR.flags == HIGHLANDER_RULESET)
			return TRUE

/datum/game_mode/dynamic/proc/lorentz2threat(x)
	switch (x)
		if (-INFINITY to -20)
			return rand(0, 10)
		if (-20 to -10)
			return RULE_OF_THREE(-40, -20, x) + 50
		if (-10 to -5)
			return RULE_OF_THREE(-30, -10, x) + 50
		if (-5 to -2.5)
			return RULE_OF_THREE(-20, -5, x) + 50
		if (-2.5 to -0)
			return RULE_OF_THREE(-10, -2.5, x) + 50
		if (0 to 2.5)
			return RULE_OF_THREE(10, 2.5, x) + 50
		if (2.5 to 5)
			return RULE_OF_THREE(20, 5, x) + 50
		if (5 to 10)
			return RULE_OF_THREE(30, 10, x) + 50
		if (10 to 20)
			return RULE_OF_THREE(40, 20, x) + 50
		if (20 to INFINITY)
			return rand(90, 100)

// These defines are here because they are pretty much only used here
#define CURRENT_LIVING_PLAYERS	"living"
#define CURRENT_LIVING_ANTAGS	"antags"
#define CURRENT_DEAD_PLAYERS	"dead"
#define CURRENT_OBSERVERS	"observers"

#define HIGHLANDER_RULESET 1
#define TRAITOR_RULESET 2
#define MINOR_RULESET 4

#define BASE_SOLO_REFUND 10

/datum/game_mode/dynamic
	name = "Dynamic"
	config_tag = "Dynamic"
	report_type = "Dynamic"

	announce_span = "danger"
	announce_text = "Dynamic mode!"

	//Threat logging vars
	var/threat_level = 0//the "threat cap", threat shouldn't normally go above this and is used in ruleset calculations
	var/starting_threat = 0 //threat_level's initially rolled value. Threat_level isn't changed by many things.
	var/threat = 0//set at the beginning of the round. Spent by the mode to "purchase" rules.
	var/list/threat_log = list() //Running information about the threat. Can store text or datum entries.

	var/list/roundstart_rules = list()
	var/list/latejoin_rules = list()
	var/list/midround_rules = list()
	var/list/second_rule_req = list(100,100,100,80,60,40,20,0,0,0)//requirements for extra round start rules
	var/list/third_rule_req = list(100,100,100,100,100,70,50,30,10,0)
	var/roundstart_pop_ready = 0
	var/list/candidates = list()
	var/list/current_rules = list()
	var/list/executed_rules = list()

	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()

	var/latejoin_injection_cooldown = 0
	var/midround_injection_cooldown = 0

	var/datum/dynamic_ruleset/latejoin/forced_latejoin_rule = null

	var/pop_last_updated = 0

	var/relative_threat = 0 // Relative threat, Lorentz-distributed.
	var/curve_centre = 0
	var/curve_width = 1.8

	var/peaceful_percentage = 50

	// -- Special tweaks --
	var/no_stacking = 1
	var/classic_secret = 0
	var/high_pop_limit = 45
	var/forced_extended = 0
	var/stacking_limit = 90

	var/list/threat_by_job = list(
		"Captain" = 12,
		"Head of Security" = 10,
		"Head of Personnel" = 8,
		"Warden" = 8,
		"Security Officer" = 4,
		"Detective" = 3,
	)

/datum/game_mode/dynamic/AdminPanelEntry()
	var/dat = list()
	dat += "Dynamic Mode <a href='?_src_=vars;Vars=\ref[src]'>\[VV\]</A><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Threat to Spend: <b>[threat]</b> <a href='?_src_=holder;adjustthreat=1'>\[Adjust\]</A> <a href='?_src_=holder;threatlog=1'>\[View Log\]</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [curve_centre] ; width = [curve_width].<br/>"
	dat += "<i>On average, <b>[peaceful_percentage]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "Forced extended: <a href='?src=\ref[src];forced_extended=1'><b>[forced_extended ? "On" : "Off"]</b></a><br/>"
	dat += "No stacking (only one round-ender): <a href='?src=\ref[src];no_stacking=1'><b>[no_stacking ? "On" : "Off"]</b></a><br/>"
	dat += "Classic secret (only autotraitor): <a href='?src=\ref[src];classic_secret=1'><b>[classic_secret ? "On" : "Off"]</b></a><br/>"
	dat += "Stacking limit: <a href='?src=\ref[usr.client.holder];stacking_limit=1'>[stacking_limit]</a>"
	dat += "<br/>"
	dat += "Executed rulesets: "
	if (executed_rules.len > 0)
		dat += "<br/>"
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			var/ruletype = ""
			if (istype (DR, /datum/dynamic_ruleset/roundstart))
				ruletype = "Roundstart"
			if (istype (DR, /datum/dynamic_ruleset/latejoin))
				ruletype = "Latejoin"
			if (istype (DR, /datum/dynamic_ruleset/midround))
				ruletype = "Midround"
			dat += "[ruletype] - <b>[DR.name]</b><br>"
	else
		dat += "none.<br>"
	dat += "<br>Injection Timers: (<b>[GetInjectionChance()]%</b> chance)<BR>"
	dat += "Latejoin: [latejoin_injection_cooldown>60 ? "[round(latejoin_injection_cooldown/60,0.1)] minutes" : "[latejoin_injection_cooldown] seconds"] <a href='?_src_=holder;injectnow=1'>\[Now!\]</A><BR>"
	dat += "Midround: [midround_injection_cooldown>60 ? "[round(midround_injection_cooldown/60,0.1)] minutes" : "[midround_injection_cooldown] seconds"] <a href='?_src_=holder;injectnow=2'>\[Now!\]</A><BR>"
	return jointext(dat, "")

/datum/game_mode/dynamic/Topic(href, href_list)
	if (..()) // Sanity, maybe ?
		return
	if(!usr.client || !check_rights(R_ADMIN))
		return
	if (href_list["forced_extended"])
		forced_extended =! forced_extended
	else if (href_list["no_stacking"])
		no_stacking =! no_stacking
	else if (href_list["classic_secret"])
		classic_secret =! classic_secret

	usr.client.holder.check_antagonists() // Refreshes the window

/datum/game_mode/dynamic/set_round_result()
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(rule.flags == HIGHLANDER_RULESET)
			return rule.round_result()
	return ..()

/datum/game_mode/dynamic/proc/show_threatlog(mob/admin)
	if(!SSticker.HasRoundStarted())
		alert("The round hasn't started yet!", "Alert")
		return

	if(!check_rights(R_ADMIN))
		return

	var/out = "<TITLE>Threat Log</TITLE><B><font size='3'>Threat Log</font></B><br><B>Starting Threat:</B> [starting_threat]<BR>"

	for(var/entry in threat_log)
		if(istext(entry))
			out += "[entry]<BR>"

	out += "<B>Remaining threat/threat_level:</B> [threat]/[threat_level]"

	usr << browse(out, "window=threatlog;size=700x500")

/datum/game_mode/dynamic/proc/generate_threat()
	relative_threat = lorentz_distribution(curve_centre, curve_width)
	threat_level = lorentz2threat(relative_threat)
	threat = round(threat, 0.1)

	peaceful_percentage = round(lorentz_cummulative_distribution(relative_threat, curve_centre, curve_width), 0.01)*100

	threat = threat_level
	starting_threat = threat_level

/datum/game_mode/dynamic/can_start()
	message_admins("Dynamic mode parameters for the round: centre = [curve_centre], width is [curve_width]. Extended : [forced_extended], no stacking : [no_stacking], classic secret: [classic_secret].")

	generate_threat()

	latejoin_injection_cooldown = rand(330,510)
	midround_injection_cooldown = rand(600,1050)
	message_admins("Dynamic Mode initialized with a Threat Level of... [threat_level]!")

	if (GLOB.player_list.len >= high_pop_limit)
		message_admins("High Population Override is in effect! Threat Level will have more impact on which roles will appear, and player population less.")

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
	if (candidates.len <= 0)
		return TRUE
	if (roundstart_rules.len <= 0)
		return TRUE
	
	roundstart()

	var/starting_rulesets = ""
	for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
		starting_rulesets += "[DR.name], "
	return TRUE

/datum/game_mode/dynamic/post_setup(report)
	for(var/datum/dynamic_ruleset/roundstart/rule in executed_rules)
		if(rule.execute())
			continue
		else

/datum/game_mode/dynamic/proc/roundstart()
	if (forced_extended)
		return TRUE
	var/list/drafted_rules = list()
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		var/skip_ruleset = 0
		for (var/datum/dynamic_ruleset/roundstart/DR in drafted_rules)
			if ((DR.flags & HIGHLANDER_RULESET) && (rule.flags & HIGHLANDER_RULESET))
				skip_ruleset = 1
				break
		if (skip_ruleset)
			continue
		if (rule.acceptable(roundstart_pop_ready,threat_level) && threat >= rule.cost)	//if we got the population and threat required
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			if (rule.ready())
				drafted_rules[rule] = rule.weight

	var/indice_pop = min(10,round(roundstart_pop_ready/5)+1)
	var/extra_rulesets_amount = 0

	if (classic_secret) // Classic secret experience : one & only one roundstart ruleset
		extra_rulesets_amount = 0
	else
		if (GLOB.player_list.len > high_pop_limit)
			if (threat_level > 50)
				extra_rulesets_amount++
				if (threat_level > 75)
					extra_rulesets_amount++
		else
			if (threat_level >= second_rule_req[indice_pop])
				extra_rulesets_amount++
				if (threat_level >= third_rule_req[indice_pop])
					extra_rulesets_amount++

	if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
		if (extra_rulesets_amount > 0)//we've got enough population and threat for a second rulestart rule
			for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
				if (rule.cost > threat)
					drafted_rules -= rule
			if (drafted_rules.len > 0 && picking_roundstart_rule(drafted_rules))
				if (extra_rulesets_amount > 1)//we've got enough population and threat for a third rulestart rule
					for (var/datum/dynamic_ruleset/roundstart/rule in drafted_rules)
						if (rule.cost > threat)
							drafted_rules -= rule
	else
		return FALSE
	return TRUE

/datum/game_mode/dynamic/proc/picking_roundstart_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/roundstart/starting_rule = pickweight(drafted_rules)

	if (starting_rule)
		log_admin("Picking a [istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/) ? " delayed " : ""] ruleset...<font size='3'>[starting_rule.name]</font>!")

		roundstart_rules -= starting_rule
		drafted_rules -= starting_rule

		if (istype(starting_rule, /datum/dynamic_ruleset/roundstart/delayed/))
			spend_threat(starting_rule.cost)
			return pick_delay(starting_rule)

		spend_threat(starting_rule.cost)
		threat_log += "[worldtime2text()]: Roundstart [starting_rule.name] spent [starting_rule.cost]"
		if (starting_rule.pre_execute())//this should never fail since ready() returned 1
			executed_rules += starting_rule
			if (starting_rule.persistent)
				current_rules += starting_rule
			for(var/mob/M in starting_rule.assigned)
				candidates -= M
				for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
					rule.candidates -= M//removing the assigned players from the candidates for the other rules
					if (!rule.ready())
						drafted_rules -= rule//and removing rules that are no longer elligible
			return TRUE
	return FALSE

/datum/game_mode/dynamic/proc/pick_delay(var/datum/dynamic_ruleset/roundstart/delayed/rule)
	rule.candidates = GLOB.player_list.Copy()
	rule.trim_candidates()
	if(!rule.pre_execute())
		return FALSE
	addtimer(CALLBACK(src, .proc/execute_delayed, rule), rule.delay)
	return TRUE

/datum/game_mode/dynamic/proc/execute_delayed(var/datum/dynamic_ruleset/roundstart/delayed/rule)
	if(rule.execute())
		executed_rules += rule
		if (rule.persistent)
			current_rules += rule
		return TRUE
	
/datum/game_mode/dynamic/proc/picking_latejoin_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/latejoin/latejoin_rule = pickweight(drafted_rules)
	if (latejoin_rule)
		if (!latejoin_rule.repeatable)
			latejoin_rules = remove_rule(latejoin_rules,latejoin_rule.type)
		spend_threat(latejoin_rule.cost)
		threat_log += "[worldtime2text()]: Latejoin [latejoin_rule.name] spent [latejoin_rule.cost]"
		if (latejoin_rule.execute())//this should never fail since ready() returned 1
			var/mob/M = pick(latejoin_rule.assigned)
			log_admin("[key_name(M)] joined the station, and was selected by the [latejoin_rule.name] ruleset.")
			executed_rules += latejoin_rule
			if (latejoin_rule.persistent)
				current_rules += latejoin_rule
			return TRUE
	return FALSE

/datum/game_mode/dynamic/proc/picking_midround_rule(var/list/drafted_rules = list())
	var/datum/dynamic_ruleset/midround/midround_rule = pickweight(drafted_rules)
	if (midround_rule)
		if (!midround_rule.repeatable)
			midround_rules = remove_rule(midround_rules,midround_rule.type)
		spend_threat(midround_rule.cost)
		threat_log += "[worldtime2text()]: Midround [midround_rule.name] spent [midround_rule.cost]"
		if (midround_rule.execute())//this should never fail since ready() returned 1
			log_admin("Injecting some threats...[midround_rule.name]!")
			executed_rules += midround_rule
			if (midround_rule.persistent)
				current_rules += midround_rule
			return TRUE
	return FALSE

/datum/game_mode/dynamic/proc/picking_specific_rule(var/ruletype,var/forced=0)//an experimental proc to allow admins to call rules on the fly or have rules call other rules
	var/datum/dynamic_ruleset/midround/new_rule
	if(ispath(ruletype))
		new_rule = new ruletype()//you should only use it to call midround rules though.
	else if(istype(ruletype,/datum/dynamic_ruleset))
		new_rule = ruletype
	else
		return
	update_playercounts()
	var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
	current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
	current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
	current_players[CURRENT_OBSERVERS] = list_observers.Copy()
	if (new_rule && (forced || (new_rule.acceptable(living_players.len,threat_level) && new_rule.cost <= threat)))
		new_rule.candidates = current_players.Copy()
		new_rule.trim_candidates()
		if (new_rule.ready(forced))
			spend_threat(new_rule.cost)
			threat_log += "[worldtime2text()]: Forced rule [new_rule.name] spent [new_rule.cost]"
			if (new_rule.execute())//this should never fail since ready() returned 1
				log_admin("Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				if (new_rule.persistent)
					current_rules += new_rule
				return TRUE
		else if (forced)
			log_admin("The ruleset couldn't be executed due to lack of elligible players.")
	return FALSE

/datum/game_mode/dynamic/process()
	. = ..() // Doing the roles process.

	if (pop_last_updated < world.time - (60 SECONDS))
		pop_last_updated = world.time
		update_playercounts()

	if (latejoin_injection_cooldown)
		latejoin_injection_cooldown--

	for (var/datum/dynamic_ruleset/rule in current_rules)
		rule.rule_process()

	if (midround_injection_cooldown)
		midround_injection_cooldown--
	else
		if (forced_extended)
			return
		//time to inject some threat into the round
		if(EMERGENCY_ESCAPED_OR_ENDGAMED)//unless the shuttle is gone
			return

		log_admin("DYNAMIC MODE: Checking state of the round.")

		update_playercounts()

		if (prob(GetInjectionChance()))
			midround_injection_cooldown = rand(600,1050)//20 to 35 minutes inbetween midround threat injections attempts
			var/list/drafted_rules = list()
			var/list/current_players = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
			current_players[CURRENT_LIVING_PLAYERS] = living_players.Copy()
			current_players[CURRENT_LIVING_ANTAGS] = living_antags.Copy()
			current_players[CURRENT_DEAD_PLAYERS] = dead_players.Copy()
			current_players[CURRENT_OBSERVERS] = list_observers.Copy()
			for (var/datum/dynamic_ruleset/midround/rule in midround_rules)
				if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
					// Classic secret : only autotraitor/minor roles
					if (classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))
						continue
					// No stacking : only one round-enter, unless > stacking_limit threat.
					if (threat < stacking_limit && no_stacking)
						var/skip_ruleset = 0
						for (var/datum/dynamic_ruleset/DR in executed_rules)
							if ((DR.flags & HIGHLANDER_RULESET) && (rule.flags & HIGHLANDER_RULESET))
								skip_ruleset = 1
								break
						if (skip_ruleset)
							continue
					rule.candidates = list()
					rule.candidates = current_players.Copy()
					rule.trim_candidates()
					if (rule.ready())
						drafted_rules[rule] = rule.get_weight()

			if (drafted_rules.len > 0)
				picking_midround_rule(drafted_rules)
		else
			midround_injection_cooldown = rand(600,1050)


/datum/game_mode/dynamic/proc/update_playercounts()
	living_players = list()
	living_antags = list()
	dead_players = list()
	list_observers = list()
	for (var/mob/M in GLOB.player_list)
		if (!M.client)
			continue
		if (istype(M,/mob/dead/new_player))
			continue
		if (M.stat != DEAD)
			living_players.Add(M)
			if (M.mind && (M.mind.special_role))
				living_antags.Add(M)
		else
			if (istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if (O.started_as_observer)//Observers
					list_observers.Add(M)
					continue
				if (O.mind && O.mind.current)//Cultists
					living_players.Add(M)//yes we're adding a ghost to "living_players", so make sure to properly check for type when testing midround rules
					continue
			dead_players.Add(M)//Players who actually died (and admins who ghosted, would be nice to avoid counting them somehow)

/datum/game_mode/dynamic/proc/GetInjectionChance()
	var/chance = 0
	//if the high pop override is in effect, we reduce the impact of population on the antag injection chance
	var/high_pop_factor = (GLOB.player_list.len >= high_pop_limit)
	var/max_pop_per_antag = max(5,15 - round(threat_level/10) - round(living_players.len/(high_pop_factor ? 10 : 5)))//https://docs.google.com/spreadsheets/d/1QLN_OBHqeL4cm9zTLEtxlnaJHHUu0IUPzPbsI-DFFmc/edit#gid=2053826290
	if (!living_antags.len)
		chance += 50//no antags at all? let's boost those odds!
	else
		var/current_pop_per_antag = living_players.len / living_antags.len
		if (current_pop_per_antag > max_pop_per_antag)
			chance += min(50, 25+10*(current_pop_per_antag-max_pop_per_antag))
		else
			chance += 25-10*(max_pop_per_antag-current_pop_per_antag)
	if (dead_players.len > living_players.len)
		chance -= 30//more than half the crew died? ew, let's calm down on antags
	if (threat > 70)
		chance += 15
	if (threat < 30)
		chance -= 15
	return round(max(0,chance))

/datum/game_mode/dynamic/proc/remove_rule(var/list/rule_list,var/rule_type)
	for(var/datum/dynamic_ruleset/DR in rule_list)
		if(istype(DR,rule_type))
			rule_list -= DR
	return rule_list

/datum/game_mode/dynamic/make_antag_chance(mob/living/carbon/human/newPlayer)
	if (forced_extended)
		return
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)//no more rules after the shuttle has left
		return

	update_playercounts()

	if (forced_latejoin_rule)
		forced_latejoin_rule.candidates = list(newPlayer)
		forced_latejoin_rule.trim_candidates()
		if (forced_latejoin_rule.ready(1))
			picking_latejoin_rule(list(forced_latejoin_rule))
		forced_latejoin_rule = null

	else if (!latejoin_injection_cooldown && prob(GetInjectionChance()))
		var/list/drafted_rules = list()
		for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
			if (rule.acceptable(living_players.len,threat_level) && threat >= rule.cost)
				// Classic secret : only autotraitor/minor roles
				if (classic_secret && !((rule.flags & TRAITOR_RULESET) || (rule.flags & MINOR_RULESET)))
					continue
				// No stacking : only one round-enter, unless > stacking_limit threat.
				if (threat < stacking_limit && no_stacking)
					var/skip_ruleset = 0
					for (var/datum/dynamic_ruleset/DR in executed_rules)
						if ((DR.flags & HIGHLANDER_RULESET) && (rule.flags & HIGHLANDER_RULESET))
							skip_ruleset = 1
							break
					if (skip_ruleset)
						continue
				rule.candidates = list(newPlayer)
				rule.trim_candidates()
				if (rule.ready())
					drafted_rules[rule] = rule.get_weight()

		if (drafted_rules.len > 0 && picking_latejoin_rule(drafted_rules))
			latejoin_injection_cooldown = rand(330,510)//11 to 17 minutes inbetween antag latejoiner rolls

	// -- No injection, we'll just update the threat
	else
		var/jobthreat = threat_by_job[newPlayer.mind.assigned_role]
		if(jobthreat)
			refund_threat(jobthreat)
			threat_log += "[worldtime2text()]: [newPlayer] refunded [jobthreat] by joining as [newPlayer.mind.assigned_role]."

//Regenerate threat, but no more than our original threat level.
/datum/game_mode/dynamic/proc/refund_threat(var/regain)
	threat = min(threat_level,threat+regain)

//Generate threat and increase the threat_level if it goes beyond, capped at 100
/datum/game_mode/dynamic/proc/create_threat(var/gain)
	threat = min(100, threat+gain)
	if(threat>threat_level)
		threat_level = threat

//Expend threat, but do not fall below 0.
/datum/game_mode/dynamic/proc/spend_threat(var/cost)
	threat = max(threat-cost,0)

// -- For the purpose of testing & simulation.
/datum/game_mode/dynamic/proc/simulate_roundstart(var/mob/user = usr)
	// Picking part
	var/done = 0
	var/list/rules_to_simulate = list()
	var/list/choices = list()
	for (var/datum/dynamic_ruleset/roundstart/DR in roundstart_rules)
		choices[DR.name] = DR
	choices["None"] = null
	while (!done)
		var/choice = input(user, "Which rule to you want to add to the simulated list? It has currently [rules_to_simulate.len] items.", "Midround rules to simulate") as null|anything in choices
		if (!choice || choice == "None")
			done = 1
		var/datum/dynamic_ruleset/to_test = choices[choice]
		if (threat < stacking_limit && no_stacking)
			var/skip_ruleset = 0
			for (var/datum/dynamic_ruleset/roundstart/DR in rules_to_simulate)
				if ((DR.flags & HIGHLANDER_RULESET) && (to_test.flags & HIGHLANDER_RULESET))
					skip_ruleset = 1
					break
			if (!skip_ruleset)
				rules_to_simulate += to_test
		else 
			rules_to_simulate += to_test

/datum/game_mode/dynamic/proc/simulate_midround_injection(var/mob/user = usr)
	// Picking part
	var/done = 0
	var/list/rules_to_simulate = list()
	var/list/choices_a = list()
	for (var/datum/dynamic_ruleset/DR in midround_rules + roundstart_rules)
		choices_a[DR.name] = DR
	choices_a["None"] = null
	while (!done)
		var/choice = input(user, "Which rule to you want to add to the simulated list? It has currently [rules_to_simulate.len] items.", "Midround rules to simulate") as null|anything in choices_a
		if (!choice || choice == "None")
			done = 1
		else
			rules_to_simulate += choices_a[choice]

	var/list/choices_b = list()
	for (var/datum/dynamic_ruleset/midround/DR in midround_rules)
		choices_b[DR.name] = DR
	choices_b["None"] = null

	var/name_to_test = input(user, "What rule to you want to test?", "Midround rule to test") as null|anything in choices_b
	if (!name_to_test || name_to_test == "None")
		return

	var/datum/dynamic_ruleset/midround/to_test = choices_b[name_to_test]

	// Concrete testing

	if (classic_secret && !((to_test.flags & TRAITOR_RULESET) || (to_test.flags & MINOR_RULESET)))
		return
	// No stacking : only one round-enter, unless > stacking_limit threat.
	if (threat < stacking_limit && no_stacking)
		var/skip_ruleset = 0
		for (var/datum/dynamic_ruleset/DR in rules_to_simulate)
			if ((DR.flags & HIGHLANDER_RULESET) && (to_test.flags & HIGHLANDER_RULESET))
				skip_ruleset = 1
			if (skip_ruleset)
				return
	
/datum/game_mode/dynamic/proc/simulate_latejoin_injection(var/mob/user = usr)
	// Picking part
	var/done = 0
	var/list/rules_to_simulate = list()
	var/list/choices_a = list()
	for (var/datum/dynamic_ruleset/DR in midround_rules + roundstart_rules)
		choices_a[DR.name] = DR
	choices_a["None"] = null
	while (!done)
		var/choice = input(user, "Which rule to you want to add to the simulated list? It has currently [rules_to_simulate.len] items.", "Midround rules to simulate") as null|anything in choices_a
		if (!choice || choice == "None")
			done = 1
		else
			rules_to_simulate += choices_a[choice]

	var/list/choices_b = list()
	for (var/datum/dynamic_ruleset/latejoin/DR in latejoin_rules)
		choices_b[DR.name] = DR
	choices_b["None"] = null

	var/name_to_test = input(user, "What rule to you want to test?", "Midround rule to test") as null|anything in choices_b
	if (!name_to_test || name_to_test == "None")
		return

	var/datum/dynamic_ruleset/latejoin/to_test = choices_b[name_to_test]

	// Concrete testing

	if (classic_secret && !((to_test.flags & TRAITOR_RULESET) || (to_test.flags & MINOR_RULESET)))
		return
	// No stacking : only one round-enter, unless > stacking_limit threat.
	if (threat < stacking_limit && no_stacking)
		var/skip_ruleset = 0
		for (var/datum/dynamic_ruleset/DR in rules_to_simulate)
			if ((DR.flags & HIGHLANDER_RULESET) && (to_test.flags & HIGHLANDER_RULESET))
				skip_ruleset = 1
				break
		if (skip_ruleset)
			return

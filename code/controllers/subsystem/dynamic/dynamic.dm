// Are HIGH_IMPACT_RULESETs allowed to stack?
GLOBAL_VAR_INIT(dynamic_no_stacking, TRUE)
// If enabled does not accept or execute any rulesets.
GLOBAL_VAR_INIT(dynamic_forced_extended, FALSE)
// How high threat is required for HIGH_IMPACT_RULESETs stacking.
// This is independent of dynamic_no_stacking.
GLOBAL_VAR_INIT(dynamic_stacking_limit, 90)
// List of forced roundstart rulesets.
GLOBAL_LIST_EMPTY(dynamic_forced_roundstart_ruleset)
// Forced threat level, setting this to zero or higher forces the roundstart threat to the value.
GLOBAL_VAR_INIT(dynamic_forced_threat_level, -1)
/// Modify the threat level for station traits before dynamic can be Initialized. List(instance = threat_reduction)
GLOBAL_LIST_EMPTY(dynamic_station_traits)
/// Rulesets which have been forcibly enabled or disabled
GLOBAL_LIST_EMPTY(dynamic_forced_rulesets)
/// Bitflags used during init by Dynamic to determine which rulesets we're allowed to use, used by station traits for gamemode-esque experiences
GLOBAL_VAR_INIT(dynamic_ruleset_categories, RULESET_CATEGORY_DEFAULT)

SUBSYSTEM_DEF(dynamic)
	name = "Dynamic"
	flags = SS_NO_INIT
	wait = 1 SECONDS

	// Threat logging vars
	/// The "threat cap", threat shouldn't normally go above this and is used in ruleset calculations
	var/threat_level = 0

	/// Set at the beginning of the round. Spent by the mode to "purchase" rules. Everything else goes in the postround budget.
	var/round_start_budget = 0

	/// Set at the beginning of the round. Spent by midrounds and latejoins.
	var/mid_round_budget = 0

	/// The initial round start budget for logging purposes, set once at the beginning of the round.
	var/initial_round_start_budget = 0

	/// Running information about the threat. Can store text or datum entries.
	var/list/threat_log = list()
	/// Threat log shown on the roundend report. Should only list player-made edits.
	var/list/roundend_threat_log = list()
	/// List of latejoin rules used for selecting the rules.
	var/list/latejoin_rules
	/// List of midround rules used for selecting the rules.
	var/list/midround_rules
	/** # Pop range per requirement.
	  * If the value is five the range is:
	  * 0-4, 5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-54, 45+
	  * If it is six the range is:
	  * 0-5, 6-11, 12-17, 18-23, 24-29, 30-35, 36-41, 42-47, 48-53, 54+
	  * If it is seven the range is:
	  * 0-6, 7-13, 14-20, 21-27, 28-34, 35-41, 42-48, 49-55, 56-62, 63+
	  */
	var/pop_per_requirement = 6
	/// Number of players who were ready on roundstart.
	var/roundstart_pop_ready = 0
	/// List of candidates used on roundstart rulesets.
	var/list/candidates = list()
	/// Rules that are processed, rule_process is called on the rules in this list.
	var/list/current_rules = list()
	/// List of executed rulesets.
	var/list/executed_rules = list()
	/// If TRUE, the next player to latejoin will guarantee roll for a random latejoin antag
	/// (this does not guarantee they get said antag roll, depending on preferences and circumstances)
	var/late_forced_injection = FALSE
	/// If TRUE, a midround ruleset will be rolled
	var/mid_forced_injection = FALSE
	/// Forced ruleset to be executed for the next latejoin.
	var/datum/dynamic_ruleset/latejoin/forced_latejoin_rule = null
	/// How many percent of the rounds are more peaceful.
	var/peaceful_percentage = 50
	/// If a high impact ruleset was executed. Only one will run at a time in most circumstances.
	var/high_impact_ruleset_executed = FALSE
	/// If a only ruleset has been executed.
	var/only_ruleset_executed = FALSE
	/// Dynamic configuration, loaded on pre_setup
	var/list/configuration = null

	/// When world.time is over this number the mode tries to inject a latejoin ruleset.
	var/latejoin_injection_cooldown = 0

	/// The minimum time the recurring latejoin ruleset timer is allowed to be.
	var/latejoin_delay_min = (5 MINUTES)

	/// The maximum time the recurring latejoin ruleset timer is allowed to be.
	var/latejoin_delay_max = (25 MINUTES)

	/// The low bound for the midround roll time splits.
	/// This number influences where to place midround rolls, making this smaller
	/// will make midround rolls more frequent, and vice versa.
	/// A midround will never be able to roll before this.
	var/midround_lower_bound = 10 MINUTES

	/// The upper bound for the midround roll time splits.
	/// This number influences where to place midround rolls, making this larger
	/// will make midround rolls less frequent, and vice versa.
	/// A midround will never be able to roll farther than this.
	var/midround_upper_bound = 100 MINUTES

	/// The distance between the chosen midround roll point (which is deterministic),
	/// and when it can actually roll.
	/// Basically, if this is set to 5 minutes, and a midround roll point is decided to be at 20 minutes,
	/// then it can roll anywhere between 15 and 25 minutes.
	var/midround_roll_distance = 3 MINUTES

	/// The amount of threat per midround roll.
	/// Basically, if this is set to 5, then for every 5 threat, one midround roll will be added.
	/// The equation this is used in rounds up, meaning that if this is set to 5, and you have 6
	/// threat, then you will get 2 midround rolls.
	var/threat_per_midround_roll = 7

	/// A number between -5 and +5.
	/// A negative value will give a more peaceful round and
	/// a positive value will give a round with higher threat.
	var/threat_curve_centre = 0

	/// A number between 0.5 and 4.
	/// Higher value will favour extreme rounds and
	/// lower value rounds closer to the average.
	var/threat_curve_width = 1.8

	/// A number between -5 and +5.
	/// Equivalent to threat_curve_centre, but for the budget split.
	/// A negative value will weigh towards midround rulesets, and a positive
	/// value will weight towards roundstart ones.
	var/roundstart_split_curve_centre = 1

	/// A number between 0.5 and 4.
	/// Equivalent to threat_curve_width, but for the budget split.
	/// Higher value will favour more variance in splits and
	/// lower value rounds closer to the average.
	var/roundstart_split_curve_width = 1.8

	/// The minimum amount of time for antag random events to be hijacked.
	var/random_event_hijack_minimum = 10 MINUTES

	/// The maximum amount of time for antag random events to be hijacked.
	var/random_event_hijack_maximum = 18 MINUTES

	/// What is the lower bound of when the roundstart announcement is sent out?
	var/waittime_l = 600

	/// What is the higher bound of when the roundstart announcement is sent out?
	var/waittime_h = 1800

	/// A number between 0 and 100. The maximum amount of threat allowed to generate.
	var/max_threat_level = 100

	/// The extra chance multiplier that a heavy impact midround ruleset will run next time.
	/// For example, if this is set to 50, then the next heavy roll will be about 50% more likely to happen.
	var/hijacked_random_event_injection_chance_modifier = 50

	/// Any midround before this point is guaranteed to be light
	var/midround_light_upper_bound = 25 MINUTES

	/// Any midround after this point is guaranteed to be heavy
	var/midround_heavy_lower_bound = 55 MINUTES

	/// If there are less than this many players readied, threat level will be lowered.
	/// This number should be kept fairly low, as there are other measures that population
	/// impacts Dynamic, such as the requirements variable on rulesets.
	var/low_pop_player_threshold = 20

	/// The maximum threat that can roll with *zero* players.
	/// As the number of players approaches `low_pop_player_threshold`, the maximum
	/// threat level will increase.
	/// For example, if `low_pop_maximum_threat` is 50, `low_pop_player_threshold` is 20,
	/// and the number of readied players is 10, then the highest threat that can roll is
	/// lerp(50, 100, 10 / 20), AKA 75.
	var/low_pop_maximum_threat = 40

	/// The chance for latejoins to roll when ready
	var/latejoin_roll_chance = 50

	// == EVERYTHING BELOW THIS POINT SHOULD NOT BE CONFIGURED ==

	/// A list of recorded "snapshots" of the round, stored in the dynamic.json log
	var/list/datum/dynamic_snapshot/snapshots

	/// The time when the last midround injection was attempted, whether or not it was successful
	var/last_midround_injection_attempt = 0

	/// Whether or not a random event has been hijacked this midround cycle
	var/random_event_hijacked = HIJACKED_NOTHING

	/// The timer ID for the cancellable midround rule injection
	var/midround_injection_timer_id

	/// The last drafted midround rulesets (without the current one included).
	/// Used for choosing different midround injections.
	var/list/current_midround_rulesets

	VAR_PRIVATE/next_midround_injection

/datum/controller/subsystem/dynamic/proc/admin_panel()
	var/list/dat = list()
	dat += "Dynamic Mode <a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(src)]'>VV</a><a href='byond://?src=[text_ref(src)];[HrefToken()]'>Refresh</a><BR>"
	dat += "Threat Level: <b>[threat_level]</b><br/>"
	dat += "Budgets (Roundstart/Midrounds): <b>[initial_round_start_budget]/[threat_level - initial_round_start_budget]</b><br/>"

	dat += "Midround budget to spend: <b>[mid_round_budget]</b> <a href='byond://?src=[text_ref(src)];[HrefToken()];adjustthreat=1'>Adjust</a><a href='byond://?src=[text_ref(src)];[HrefToken()];threatlog=1'>View Log</a><br/>"
	dat += "<br/>"
	dat += "Parameters: centre = [threat_curve_centre] ; width = [threat_curve_width].<br/>"
	dat += "Split parameters: centre = [roundstart_split_curve_centre] ; width = [roundstart_split_curve_width].<br/>"
	dat += "<i>On average, <b>[clamp(peaceful_percentage, 1, 99)]</b>% of the rounds are more peaceful.</i><br/>"
	dat += "Forced extended: <a href='byond://?src=[text_ref(src)];[HrefToken()];forced_extended=1'><b>[GLOB.dynamic_forced_extended ? "On" : "Off"]</b></a><br/>"
	dat += "No stacking (only one round-ender): <a href='byond://?src=[text_ref(src)];[HrefToken()];no_stacking=1'><b>[GLOB.dynamic_no_stacking ? "On" : "Off"]</b></a><br/>"
	dat += "Stacking limit: [GLOB.dynamic_stacking_limit] <a href='byond://?src=[text_ref(src)];[HrefToken()];stacking_limit=1'>Adjust</a>"
	dat += "<br/>"
	dat += "<A href='byond://?src=[text_ref(src)];[HrefToken()];force_latejoin_rule=1'>Force Next Latejoin Ruleset</A><br>"
	if (forced_latejoin_rule)
		dat += {"<A href='byond://?src=[text_ref(src)];[HrefToken()];clear_forced_latejoin=1'>-> [forced_latejoin_rule.name] <-</A><br>"}
	dat += "<A href='byond://?src=[text_ref(src)];[HrefToken()];force_midround_rule=1'>Execute Midround Ruleset</A><br>"
	dat += "<br />"
	dat += "Executed rulesets: "
	if (executed_rules.len > 0)
		dat += "<br/>"
		for (var/datum/dynamic_ruleset/DR in executed_rules)
			dat += "[DR.ruletype] - <b>[DR.name]</b><br>"
	else
		dat += "none.<br>"
	dat += "<br>Injection Timers: (<b>[get_heavy_midround_injection_chance(dry_run = TRUE)]%</b> heavy midround chance)<BR>"
	dat += "Latejoin: [DisplayTimeText(latejoin_injection_cooldown-world.time)] <a href='byond://?src=[text_ref(src)];[HrefToken()];injectlate=1'>Now!</a><BR>"

	var/next_injection = next_midround_injection()
	if (next_injection == INFINITY)
		dat += "All midrounds have been exhausted."
	else
		dat += "Midround: [DisplayTimeText(next_injection - world.time)] <a href='byond://?src=[text_ref(src)];[HrefToken()];injectmid=1'>Now!</a><BR>"

	var/datum/browser/browser = new(usr, "gamemode_panel", "Game Mode Panel", 500, 500)
	browser.set_content(dat.Join())
	browser.open()

/datum/controller/subsystem/dynamic/Topic(href, href_list)
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
	else if (href_list["adjustthreat"])
		var/threatadd = input("Specify how much threat to add (negative to subtract). This can inflate the threat level.", "Adjust Threat", 0) as null|num
		if(!threatadd)
			return
		if(threatadd > 0)
			create_threat(threatadd, threat_log, "[worldtime2text()]: increased by [key_name(usr)]")
		else
			spend_midround_budget(-threatadd, threat_log, "[worldtime2text()]: decreased by [key_name(usr)]")
	else if (href_list["injectlate"])
		latejoin_injection_cooldown = 0
		late_forced_injection = TRUE
		message_admins("[key_name(usr)] forced a latejoin injection.")
	else if (href_list["injectmid"])
		mid_forced_injection = TRUE
		message_admins("[key_name(usr)] forced a midround injection.")
		try_midround_roll()
	else if (href_list["threatlog"])
		show_threatlog(usr)
	else if (href_list["stacking_limit"])
		GLOB.dynamic_stacking_limit = input(usr,"Change the threat limit at which round-endings rulesets will start to stack.", "Change stacking limit", null) as num
	else if(href_list["force_latejoin_rule"])
		var/added_rule = input(usr,"What ruleset do you want to force upon the next latejoiner? This will bypass threat level and population restrictions.", "Rigging Latejoin", null) as null|anything in sort_names(init_rulesets(/datum/dynamic_ruleset/latejoin))
		if (!added_rule)
			return
		forced_latejoin_rule = added_rule
		log_admin("[key_name(usr)] set [added_rule] to proc on the next latejoin.")
		message_admins("[key_name(usr)] set [added_rule] to proc on the next valid latejoin.")
	else if(href_list["clear_forced_latejoin"])
		forced_latejoin_rule = null
		log_admin("[key_name(usr)] cleared the forced latejoin ruleset.")
		message_admins("[key_name(usr)] cleared the forced latejoin ruleset.")
	else if(href_list["force_midround_rule"])
		var/added_rule = input(usr,"What ruleset do you want to force right now? This will bypass threat level and population restrictions.", "Execute Ruleset", null) as null|anything in sort_names(init_rulesets(/datum/dynamic_ruleset/midround))
		if (!added_rule)
			return
		log_admin("[key_name(usr)] executed the [added_rule] ruleset.")
		message_admins("[key_name(usr)] executed the [added_rule] ruleset.")
		picking_specific_rule(added_rule, TRUE)
	else if(href_list["cancelmidround"])
		admin_cancel_midround(usr, href_list["cancelmidround"])
		return
	else if (href_list["differentmidround"])
		admin_different_midround(usr, href_list["differentmidround"])
		return

	admin_panel() // Refreshes the window

// Set result and news report here
/datum/controller/subsystem/dynamic/proc/set_round_result()
	// If it got to this part, just pick one high impact ruleset if it exists
	for(var/datum/dynamic_ruleset/rule in executed_rules)
		if(rule.flags & HIGH_IMPACT_RULESET)
			rule.round_result()
			// One was set, so we're done here
			if(SSticker.news_report)
				return

	SSticker.mode_result = "undefined"

	// Something nuked the station - it wasn't nuke ops (they set their own via their rulset)
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_NUKED

	if(SSsupermatter_cascade.cascade_initiated)
		SSticker.news_report = SUPERMATTER_CASCADE

	// Only show this one if we have nothing better to show
	if(EMERGENCY_ESCAPED_OR_ENDGAMED && !SSticker.news_report)
		SSticker.news_report = SSshuttle.emergency?.is_hijacked() ? SHUTTLE_HIJACK : STATION_EVACUATED

/datum/controller/subsystem/dynamic/proc/send_intercept()
	if(GLOB.communications_controller.block_command_report) //If we don't want the report to be printed just yet, we put it off until it's ready
		addtimer(CALLBACK(src, PROC_REF(send_intercept)), 10 SECONDS)
		return

	. = "<b><i>Nanotrasen Department of Intelligence Threat Advisory, Spinward Sector, TCD [time2text(world.realtime, "DDD, MMM DD")], [CURRENT_STATION_YEAR]:</i></b><hr>"
	. += generate_advisory_level()

	var/min_threat = 100
	for(var/datum/dynamic_ruleset/ruleset as anything in init_rulesets(/datum/dynamic_ruleset))
		if(ruleset.weight <= 0 || ruleset.cost <= 0)
			continue
		min_threat = min(ruleset.cost, min_threat)

	var/greenshift = GLOB.dynamic_forced_extended || (threat_level < min_threat) //if threat is below any ruleset, its extended time
	SSstation.generate_station_goals(greenshift ? INFINITY : CONFIG_GET(number/station_goal_budget))

	var/list/datum/station_goal/goals = SSstation.get_station_goals()
	if(length(goals))
		var/list/texts = list("<hr><b>Special Orders for [station_name()]:</b><br>")
		for(var/datum/station_goal/station_goal as anything in goals)
			station_goal.on_report()
			texts += station_goal.get_report()
		. += texts.Join("<hr>")

	var/list/trait_list_strings = list()
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_list_strings += "[station_trait.get_report()]<BR>"
	if(trait_list_strings.len > 0)
		. += "<hr><b>Identified shift divergencies:</b><BR>" + trait_list_strings.Join()

	if(length(GLOB.communications_controller.command_report_footnotes))
		var/footnote_pile = ""

		for(var/datum/command_footnote/footnote in GLOB.communications_controller.command_report_footnotes)
			footnote_pile += "[footnote.message]<BR>"
			footnote_pile += "<i>[footnote.signature]</i><BR>"
			footnote_pile += "<BR>"

		. += "<hr><b>Additional Notes: </b><BR><BR>" + footnote_pile

#ifndef MAP_TEST
	print_command_report(., "[command_name()] Status Summary", announce=FALSE)
	if(greenshift)
		priority_announce("Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. All station construction projects have been authorized. Have a secure shift!", "Security Report", SSstation.announcer.get_rand_report_sound(), color_override = "green")
	else
		if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_BLUE)
			SSsecurity_level.set_level(SEC_LEVEL_BLUE, announce = FALSE)
		priority_announce("[SSsecurity_level.current_security_level.elevating_to_announcement]\n\nA summary has been copied and printed to all communications consoles.", "Security level elevated.", ANNOUNCER_INTERCEPT, color_override = SSsecurity_level.current_security_level.announcement_color)
#endif

	return .

/// Generate the advisory level depending on the shown threat level.
/datum/controller/subsystem/dynamic/proc/generate_advisory_level()
	var/advisory_string = ""
	switch(round(threat_level))
		if(0 to 65)
			advisory_string += "Advisory Level: <b>Yellow Star</b></center><BR>"
			advisory_string += "Your sector's advisory level is Yellow Star. Surveillance shows a credible risk of enemy attack against our assets in the Spinward Sector. We advise a heightened level of security alongside maintaining vigilance against potential threats."
		if(66 to 79)
			advisory_string += "Advisory Level: <b>Red Star</b></center><BR>"
			advisory_string += "Your sector's advisory level is Red Star. The Department of Intelligence has decrypted Cybersun communications suggesting a high likelihood of attacks on Nanotrasen assets within the Spinward Sector. Stations in the region are advised to remain highly vigilant for signs of enemy activity and to be on high alert."
		if(80 to 99)
			advisory_string += "Advisory Level: <b>Black Orbit</b></center><BR>"
			advisory_string += "Your sector's advisory level is Black Orbit. Your sector's local communications network is currently undergoing a blackout, and we are therefore unable to accurately judge enemy movements within the region. However, information passed to us by GDI suggests a high amount of enemy activity in the sector, indicative of an impending attack. Remain on high alert and vigilant against any other potential threats."
		if(100)
			advisory_string += "Advisory Level: <b>Midnight Sun</b></center><BR>"
			advisory_string += "Your sector's advisory level is Midnight Sun. Credible information passed to us by GDI suggests that the Syndicate is preparing to mount a major concerted offensive on Nanotrasen assets in the Spinward Sector to cripple our foothold there. All stations should remain on high alert and prepared to defend themselves."

	return advisory_string

/datum/controller/subsystem/dynamic/proc/show_threatlog(mob/admin)
	if(!SSticker.HasRoundStarted())
		tgui_alert(usr, "The round hasn't started yet!")
		return

	if(!check_rights(R_ADMIN))
		return

	var/list/out = list("<TITLE>Threat Log</TITLE><B><font size='3'>Threat Log</font></B><br><B>Starting Threat:</B> [threat_level]<BR>")

	for(var/entry in threat_log)
		if(istext(entry))
			out += "[entry]<BR>"

	out += "<B>Remaining threat/threat_level:</B> [mid_round_budget]/[threat_level]"

	usr << browse(out.Join(), "window=threatlog;size=700x500")

/// Generates the threat level using lorentz distribution and assigns peaceful_percentage.
/datum/controller/subsystem/dynamic/proc/generate_threat()
	// At lower pop levels we run a Liner Interpolation against the max threat based proportionally on the number
	// of players ready. This creates a balanced lorentz curve within a smaller range than 0 to max_threat_level.
	var/calculated_max_threat = (SSticker.totalPlayersReady < low_pop_player_threshold) ? LERP(low_pop_maximum_threat, max_threat_level, SSticker.totalPlayersReady / low_pop_player_threshold) : max_threat_level
	log_dynamic("Calculated maximum threat level based on player count of [SSticker.totalPlayersReady]: [calculated_max_threat]")

	threat_level = lorentz_to_amount(threat_curve_centre, threat_curve_width, calculated_max_threat)

	for(var/datum/station_trait/station_trait in GLOB.dynamic_station_traits)
		threat_level = max(threat_level - GLOB.dynamic_station_traits[station_trait], 0)
		log_dynamic("Threat reduced by [GLOB.dynamic_station_traits[station_trait]]. Source: [type].")

	peaceful_percentage = (threat_level/max_threat_level)*100

/// Generates the midround and roundstart budgets
/datum/controller/subsystem/dynamic/proc/generate_budgets()
	round_start_budget = lorentz_to_amount(roundstart_split_curve_centre, roundstart_split_curve_width, threat_level, 0.1)
	initial_round_start_budget = round_start_budget
	mid_round_budget = threat_level - round_start_budget

/datum/controller/subsystem/dynamic/proc/setup_parameters()
	log_dynamic("Dynamic mode parameters for the round:")
	log_dynamic("Centre is [threat_curve_centre], Width is [threat_curve_width], Forced extended is [GLOB.dynamic_forced_extended ? "Enabled" : "Disabled"], No stacking is [GLOB.dynamic_no_stacking ? "Enabled" : "Disabled"].")
	log_dynamic("Stacking limit is [GLOB.dynamic_stacking_limit].")
	if(GLOB.dynamic_forced_threat_level >= 0)
		threat_level = round(GLOB.dynamic_forced_threat_level, 0.1)
	else
		generate_threat()
	generate_budgets()
	set_cooldowns()
	log_dynamic("Dynamic Mode initialized with a Threat Level of... [threat_level]! ([round_start_budget] round start budget)")
	SSblackbox.record_feedback(
		"associative",
		"dynamic_threat",
		1,
		list(
			"server_name" = CONFIG_GET(string/serversqlname),
			"forced_threat_level" = GLOB.dynamic_forced_threat_level,
			"threat_level" = threat_level,
			"max_threat" = (SSticker.totalPlayersReady < low_pop_player_threshold) ? LERP(low_pop_maximum_threat, max_threat_level, SSticker.totalPlayersReady / low_pop_player_threshold) : max_threat_level,
			"player_count" = SSticker.totalPlayersReady,
			"round_start_budget" = round_start_budget,
			"parameters" = list(
				"threat_curve_centre" = threat_curve_centre,
				"threat_curve_width" = threat_curve_width,
				"forced_extended" = GLOB.dynamic_forced_extended,
				"no_stacking" = GLOB.dynamic_no_stacking,
				"stacking_limit" = GLOB.dynamic_stacking_limit,
			),
		),
	)
	return TRUE


/datum/controller/subsystem/dynamic/proc/set_cooldowns()
	var/latejoin_injection_cooldown_middle = 0.5*(latejoin_delay_max + latejoin_delay_min)
	latejoin_injection_cooldown = round(clamp(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), latejoin_delay_min, latejoin_delay_max)) + world.time

// Called BEFORE everyone is equipped with their job
/datum/controller/subsystem/dynamic/proc/pre_setup()
	if(CONFIG_GET(flag/dynamic_config_enabled))
		var/json_file = file("[global.config.directory]/dynamic.json")
		if(fexists(json_file))
			configuration = json_decode(file2text(json_file))
			if(configuration["Dynamic"])
				for(var/variable in configuration["Dynamic"])
					if(!(variable in vars))
						stack_trace("Invalid dynamic configuration variable [variable] in game mode variable changes.")
						continue
					vars[variable] = configuration["Dynamic"][variable]

	configure_station_trait_costs()
	setup_parameters()
	setup_hijacking()
	setup_rulesets()

	//We do this here instead of with the midround rulesets and such because these rules can hang refs
	//To new_player and such, and we want the datums to just free when the roundstart work is done
	var/list/roundstart_rules = init_rulesets(/datum/dynamic_ruleset/roundstart)

	SSjob.divide_occupations(pure = TRUE, allow_all = TRUE)
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind && player.check_preferences())
			if(is_unassigned_job(player.mind.assigned_role))
				var/list/job_data = list()
				var/job_prefs = player.client.prefs.job_preferences
				for(var/job in job_prefs)
					var/priority = job_prefs[job]
					job_data += "[job]: [SSjob.job_priority_level_to_string(priority)]"
				to_chat(player, span_danger("You were unable to qualify for any roundstart antagonist role this round because your job preferences presented a high chance of all of your selected jobs being unavailable, along with 'return to lobby if job is unavailable' enabled. Increase the number of roles set to medium or low priority to reduce the chances of this happening."))
				log_admin("[player.ckey] failed to qualify for any roundstart antagonist role because their job preferences presented a high chance of all of their selected jobs being unavailable, along with 'return to lobby if job is unavailable' enabled and has [player.client.prefs.be_special.len] antag preferences enabled. They will be unable to qualify for any roundstart antagonist role. These are their job preferences - [job_data.Join(" | ")]")
			else
				roundstart_pop_ready++
				candidates.Add(player)
	SSjob.reset_occupations()
	log_dynamic("Listing [roundstart_rules.len] round start rulesets, and [candidates.len] players ready.")
	if (candidates.len <= 0)
		log_dynamic("[candidates.len] candidates.")
		return TRUE

	if(GLOB.dynamic_forced_roundstart_ruleset.len > 0)
		rigged_roundstart()
	else
		roundstart(roundstart_rules)

	log_dynamic("[round_start_budget] round start budget was left, donating it to midrounds.")
	threat_log += "[worldtime2text()]: [round_start_budget] round start budget was left, donating it to midrounds."
	mid_round_budget += round_start_budget

	var/starting_rulesets = ""
	for (var/datum/dynamic_ruleset/roundstart/DR in executed_rules)
		starting_rulesets += "[DR.name], "
	log_dynamic("Picked the following roundstart rules: [starting_rulesets]")
	candidates.Cut()
	return TRUE

// Called AFTER everyone is equipped with their job
/datum/controller/subsystem/dynamic/proc/post_setup(report)
	for(var/datum/dynamic_ruleset/roundstart/rule in executed_rules)
		rule.candidates.Cut() // The rule should not use candidates at this point as they all are null.
		addtimer(CALLBACK(src, PROC_REF(execute_roundstart_rule), rule), rule.delay)

	if (!CONFIG_GET(flag/no_intercept_report))
		addtimer(CALLBACK(src, PROC_REF(send_intercept)), rand(waittime_l, waittime_h))

		addtimer(CALLBACK(src, PROC_REF(display_roundstart_logout_report)), ROUNDSTART_LOGOUT_REPORT_TIME)

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles))
		var/delay = CONFIG_GET(number/reopen_roundstart_suicide_roles_delay)
		if(delay)
			delay *= (1 SECONDS)
		else
			delay = (4 MINUTES) //default to 4 minutes if the delay isn't defined.
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reopen_roundstart_suicide_roles)), delay)

	if(SSdbcore.Connect())
		var/list/to_set = list()
		var/arguments = list()
		if(GLOB.revdata.originmastercommit)
			to_set += "commit_hash = :commit_hash"
			arguments["commit_hash"] = GLOB.revdata.originmastercommit
		if(to_set.len)
			arguments["round_id"] = GLOB.round_id
			var/datum/db_query/query_round_game_mode = SSdbcore.NewQuery(
				"UPDATE [format_table_name("round")] SET [to_set.Join(", ")] WHERE id = :round_id",
				arguments
			)
			query_round_game_mode.Execute()
			qdel(query_round_game_mode)
	return TRUE

/datum/controller/subsystem/dynamic/proc/display_roundstart_logout_report()
	var/list/msg = list("[span_boldnotice("Roundstart logout report")]\n\n")
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/mob/living/carbon/C = L
		if (istype(C) && !C.last_mind)
			continue  // never had a client

		if(L.ckey && !GLOB.directory[L.ckey])
			msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			var/failed = FALSE
			if(L.client.inactivity >= ROUNDSTART_LOGOUT_AFK_THRESHOLD) //Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				failed = TRUE //AFK client
			if(!failed && L.stat)
				if(HAS_TRAIT(L, TRAIT_SUICIDED)) //Suicider
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] ([span_bolddanger("Suicide")])\n"
					failed = TRUE //Disconnected client
				if(!failed && (L.stat == UNCONSCIOUS || L.stat == HARD_CRIT))
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dying)\n"
					failed = TRUE //Unconscious
				if(!failed && L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dead)\n"
					failed = TRUE //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(HAS_TRAIT(L, TRAIT_SUICIDED)) //Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_bolddanger("Suicide")])\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_bolddanger("Ghosted")])\n"
						continue //Ghosted while alive

	var/concatenated_message = msg.Join()
	log_admin(concatenated_message)
	to_chat(GLOB.admins, concatenated_message)

/// Initializes the internal ruleset variables
/datum/controller/subsystem/dynamic/proc/setup_rulesets()
	midround_rules = init_rulesets(/datum/dynamic_ruleset/midround)
	latejoin_rules = init_rulesets(/datum/dynamic_ruleset/latejoin)

/// Returns a list of the provided rulesets.
/// Configures their variables to match config.
/datum/controller/subsystem/dynamic/proc/init_rulesets(ruleset_subtype)
	var/list/rulesets = list()

	for (var/datum/dynamic_ruleset/ruleset_type as anything in subtypesof(ruleset_subtype))
		if (initial(ruleset_type.name) == "")
			continue

		if (initial(ruleset_type.weight) == 0)
			continue

		var/ruleset = new ruleset_type
		configure_ruleset(ruleset)
		rulesets += ruleset

	return rulesets

/// A simple roundstart proc used when dynamic_forced_roundstart_ruleset has rules in it.
/datum/controller/subsystem/dynamic/proc/rigged_roundstart()
	message_admins("[GLOB.dynamic_forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	log_dynamic("[GLOB.dynamic_forced_roundstart_ruleset.len] rulesets being forced. Will now attempt to draft players for them.")
	for (var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
		configure_ruleset(rule)
		message_admins("Drafting players for forced ruleset [rule.name].")
		log_dynamic("Drafting players for forced ruleset [rule.name].")
		rule.acceptable(roundstart_pop_ready, threat_level) // Assigns some vars in the modes, running it here for consistency
		rule.candidates = candidates.Copy()
		rule.trim_candidates()
		rule.load_templates()
		if (rule.ready(roundstart_pop_ready, TRUE))
			var/cost = rule.cost
			var/scaled_times = 0
			if (rule.scaling_cost)
				scaled_times = round(max(round_start_budget - cost, 0) / rule.scaling_cost)
				cost += rule.scaling_cost * scaled_times

			spend_roundstart_budget(picking_roundstart_rule(rule, scaled_times, forced = TRUE))

/datum/controller/subsystem/dynamic/proc/roundstart(list/roundstart_rules)
	if (GLOB.dynamic_forced_extended)
		log_dynamic("Starting a round of forced extended.")
		return TRUE
	var/list/drafted_rules = list()
	for (var/datum/dynamic_ruleset/roundstart/rule in roundstart_rules)
		if (!rule.weight)
			continue
		if (rule.acceptable(roundstart_pop_ready, threat_level) && round_start_budget >= rule.cost) // If we got the population and threat required
			rule.candidates = candidates.Copy()
			rule.trim_candidates()
			rule.load_templates()
			if (rule.ready(roundstart_pop_ready) && rule.candidates.len > 0)
				drafted_rules[rule] = rule.weight

	var/list/rulesets_picked = list()

	// Kept in case a ruleset can't be initialized for whatever reason, we want to be able to only spend what we can use.
	var/round_start_budget_left = round_start_budget

	while (round_start_budget_left > 0)
		var/datum/dynamic_ruleset/roundstart/ruleset = pick_weight(drafted_rules)
		if (isnull(ruleset))
			log_dynamic("No more rules can be applied, stopping with [round_start_budget] left.")
			break

		var/cost = (ruleset in rulesets_picked) ? ruleset.scaling_cost : ruleset.cost
		if (cost == 0)
			stack_trace("[ruleset] cost 0, this is going to result in an infinite loop.")
			drafted_rules[ruleset] = null
			continue

		if (cost > round_start_budget_left)
			drafted_rules[ruleset] = null
			continue

		if (check_blocking(ruleset.blocking_rules, rulesets_picked))
			drafted_rules[ruleset] = null
			continue

		round_start_budget_left -= cost

		rulesets_picked[ruleset] += 1

		if (ruleset.flags & HIGH_IMPACT_RULESET)
			for (var/_other_ruleset in drafted_rules)
				var/datum/dynamic_ruleset/other_ruleset = _other_ruleset
				if (other_ruleset.flags & HIGH_IMPACT_RULESET)
					drafted_rules[other_ruleset] = null

		if (ruleset.flags & LONE_RULESET)
			drafted_rules[ruleset] = null

	for (var/ruleset in rulesets_picked)
		spend_roundstart_budget(picking_roundstart_rule(ruleset, rulesets_picked[ruleset] - 1))

	update_log()

/// Initializes the round start ruleset provided to it. Returns how much threat to spend.
/datum/controller/subsystem/dynamic/proc/picking_roundstart_rule(datum/dynamic_ruleset/roundstart/ruleset, scaled_times = 0, forced = FALSE)
	log_dynamic("Picked a ruleset: [ruleset.name], scaled [scaled_times] times")

	ruleset.trim_candidates()
	var/added_threat = ruleset.scale_up(roundstart_pop_ready, scaled_times)

	if(ruleset.pre_execute(roundstart_pop_ready))
		threat_log += "[worldtime2text()]: Roundstart [ruleset.name] spent [ruleset.cost + added_threat]. [ruleset.scaling_cost ? "Scaled up [ruleset.scaled_times]/[scaled_times] times." : ""]"
		if(ruleset.flags & ONLY_RULESET)
			only_ruleset_executed = TRUE
		if(ruleset.flags & HIGH_IMPACT_RULESET)
			high_impact_ruleset_executed = TRUE
		executed_rules += ruleset
		return ruleset.cost + added_threat
	else
		stack_trace("The starting rule \"[ruleset.name]\" failed to pre_execute.")
	return 0

/// Mainly here to facilitate delayed rulesets. All roundstart rulesets are executed with a timered callback to this proc.
/datum/controller/subsystem/dynamic/proc/execute_roundstart_rule(sent_rule)
	var/datum/dynamic_ruleset/rule = sent_rule
	if(rule.execute())
		if(rule.persistent)
			current_rules += rule
		new_snapshot(rule)
		rule.forget_startup()
		return TRUE
	rule.clean_up() // Refund threat, delete teams and so on.
	rule.forget_startup()
	executed_rules -= rule
	stack_trace("The starting rule \"[rule.name]\" failed to execute.")
	return FALSE

/// An experimental proc to allow admins to call rules on the fly or have rules call other rules.
/datum/controller/subsystem/dynamic/proc/picking_specific_rule(ruletype, forced = FALSE, ignore_cost = FALSE)
	var/datum/dynamic_ruleset/midround/new_rule
	if(ispath(ruletype))
		new_rule = new ruletype() // You should only use it to call midround rules though.
		configure_ruleset(new_rule) // This makes sure the rule is set up properly.
	else if(istype(ruletype, /datum/dynamic_ruleset))
		new_rule = ruletype
	else
		return FALSE

	if(!new_rule)
		return FALSE

	if(!forced)
		if(only_ruleset_executed)
			return FALSE
		// Check if a blocking ruleset has been executed.
		else if(check_blocking(new_rule.blocking_rules, executed_rules))
			return FALSE
		// Check if the ruleset is high impact and if a high impact ruleset has been executed
		else if(new_rule.flags & HIGH_IMPACT_RULESET)
			if(threat_level < GLOB.dynamic_stacking_limit && GLOB.dynamic_no_stacking)
				if(high_impact_ruleset_executed)
					return FALSE

	var/population = GLOB.alive_player_list.len
	if((new_rule.acceptable(population, threat_level) && (ignore_cost || new_rule.cost <= mid_round_budget)) || forced)
		new_rule.trim_candidates()
		new_rule.load_templates()
		if (new_rule.ready(forced))
			if (!ignore_cost)
				spend_midround_budget(new_rule.cost, threat_log, "[worldtime2text()]: Forced rule [new_rule.name]")
			new_rule.pre_execute(population)
			if (new_rule.execute()) // This should never fail since ready() returned 1
				if(new_rule.flags & HIGH_IMPACT_RULESET)
					high_impact_ruleset_executed = TRUE
				else if(new_rule.flags & ONLY_RULESET)
					only_ruleset_executed = TRUE
				log_dynamic("Making a call to a specific ruleset...[new_rule.name]!")
				executed_rules += new_rule
				if (new_rule.persistent)
					current_rules += new_rule
				new_rule.forget_startup()
				return TRUE
		else if (forced)
			log_dynamic("The ruleset [new_rule.name] couldn't be executed due to lack of elligible players.")
	new_rule.forget_startup()
	return FALSE

/datum/controller/subsystem/dynamic/fire()
	for (var/datum/dynamic_ruleset/rule in current_rules)
		if(rule.rule_process() == RULESET_STOP_PROCESSING) // If rule_process() returns 1 (RULESET_STOP_PROCESSING), stop processing.
			current_rules -= rule

	try_midround_roll()

/// Removes type from the list
/datum/controller/subsystem/dynamic/proc/remove_from_list(list/type_list, type)
	for(var/I in type_list)
		if(istype(I, type))
			type_list -= I
	return type_list

/// Checks if a type in blocking_list is in rule_list.
/datum/controller/subsystem/dynamic/proc/check_blocking(list/blocking_list, list/rule_list)
	if(blocking_list.len > 0)
		for(var/blocking in blocking_list)
			for(var/_executed in rule_list)
				var/datum/executed = _executed
				if(blocking == executed.type)
					log_dynamic("FAIL: check_blocking - [blocking] conflicts with [executed.type]")
					return TRUE
	return FALSE

/// Handles late-join antag assignments
/datum/controller/subsystem/dynamic/proc/make_antag_chance(mob/living/carbon/human/newPlayer)
	if (GLOB.dynamic_forced_extended)
		return
	if(EMERGENCY_ESCAPED_OR_ENDGAMED) // No more rules after the shuttle has left
		return

	if (forced_latejoin_rule)
		log_dynamic("Forcing specific [forced_latejoin_rule.ruletype] ruleset [forced_latejoin_rule].")
		if(!handle_executing_latejoin(forced_latejoin_rule, newPlayer, forced = TRUE))
			message_admins("The forced latejoin ruleset [forced_latejoin_rule.name] couldn't be executed \
				as the most recent latejoin did not fulfill the ruleset's requirements.")
		forced_latejoin_rule = null
		return

	if(!late_forced_injection)
		if(latejoin_injection_cooldown >= world.time)
			return
		if(!prob(latejoin_roll_chance))
			return

	var/was_forced = late_forced_injection
	late_forced_injection = FALSE
	var/list/possible_latejoin_rules = list()
	for (var/datum/dynamic_ruleset/latejoin/rule in latejoin_rules)
		if(!rule.weight)
			continue
		if(mid_round_budget < rule.cost)
			continue
		if(!rule.acceptable(GLOB.alive_player_list.len, threat_level))
			continue
		possible_latejoin_rules[rule] = rule.get_weight()

	if(!length(possible_latejoin_rules))
		log_dynamic("FAIL: [newPlayer] was selected to roll for a latejoin ruleset, but there were no valid rulesets.")
		return

	log_dynamic("[newPlayer] was selected to roll for a latejoin ruleset from the following list: [english_list(possible_latejoin_rules)].")
	// You get one shot at becoming a latejoin antag, if it fails the next guy will try.
	var/datum/dynamic_ruleset/latejoin/picked_rule = pick_ruleset(possible_latejoin_rules, max_allowed_attempts = 1)
	if(isnull(picked_rule))
		log_dynamic("FAIL: No valid rulset was selected for [newPlayer]'s latejoin[was_forced ? "" : ", the next player will be checked instead"].")
		return
	if(was_forced)
		log_dynamic("Forcing random [picked_rule.ruletype] ruleset [picked_rule].")
	handle_executing_latejoin(picked_rule, newPlayer, forced = was_forced)

/**
 * This proc handles the execution of a latejoin ruleset, including removing it from latejoin rulesets if not repeatable,
 * upping the injection cooldown, and starting a timer to execute the ruleset on delay.
 */
/datum/controller/subsystem/dynamic/proc/handle_executing_latejoin(datum/dynamic_ruleset/ruleset, mob/living/carbon/human/only_candidate, forced = FALSE)
	ruleset.candidates = list(only_candidate)
	ruleset.trim_candidates()
	ruleset.load_templates()
	if (!ruleset.ready(forced))
		log_dynamic("FAIL: [only_candidate] was selected to latejoin with the [ruleset] ruleset, \
			but the ruleset failed to execute[length(ruleset.candidates) ? "":" as they were not a valid candiate"].")
		return FALSE
	if (!ruleset.repeatable)
		latejoin_rules = remove_from_list(latejoin_rules, ruleset.type)
	addtimer(CALLBACK(src, PROC_REF(execute_midround_latejoin_rule), ruleset), ruleset.delay)

	if(!forced)
		var/latejoin_injection_cooldown_middle = 0.5 * (latejoin_delay_max + latejoin_delay_min)
		latejoin_injection_cooldown = round(clamp(EXP_DISTRIBUTION(latejoin_injection_cooldown_middle), latejoin_delay_min, latejoin_delay_max)) + world.time
		log_dynamic("A latejoin rulset triggered successfully, the next latejoin injection will happen at [latejoin_injection_cooldown] round time.")

	return TRUE

/// Apply configurations to rule.
/datum/controller/subsystem/dynamic/proc/configure_ruleset(datum/dynamic_ruleset/ruleset)
	var/rule_conf = LAZYACCESSASSOC(configuration, ruleset.ruletype, ruleset.name)
	for(var/variable in rule_conf)
		if(!(variable in ruleset.vars))
			stack_trace("Invalid dynamic configuration variable [variable] in [ruleset.ruletype] [ruleset.name].")
			continue
		ruleset.vars[variable] = rule_conf[variable]
	ruleset.restricted_roles |= SSstation.antag_restricted_roles
	if(length(ruleset.protected_roles)) //if we care to protect any role, we should protect station trait roles too
		ruleset.protected_roles |= SSstation.antag_protected_roles
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		ruleset.restricted_roles |= ruleset.protected_roles
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		ruleset.restricted_roles |= JOB_ASSISTANT
	if(!(ruleset.ruleset_category & GLOB.dynamic_ruleset_categories))
		ruleset.requirements = list(101,101,101,101,101,101,101,101,101,101)

/// Get station traits and call for their config
/datum/controller/subsystem/dynamic/proc/configure_station_trait_costs()
	if(!CONFIG_GET(flag/dynamic_config_enabled))
		return
	for(var/datum/station_trait/station_trait as anything in GLOB.dynamic_station_traits)
		configure_station_trait(station_trait)

/// Apply configuration for station trait costs
/datum/controller/subsystem/dynamic/proc/configure_station_trait(datum/station_trait/station_trait)
	var/list/station_trait_config = LAZYACCESSASSOC(configuration, "Station", station_trait.dynamic_threat_id)
	var/cost = station_trait_config["cost"]

	if(isnull(cost)) //0 is valid so check for null specifically
		return

	if(cost != GLOB.dynamic_station_traits[station_trait])
		log_dynamic("Config set [station_trait.dynamic_threat_id] cost from [station_trait.threat_reduction] to [cost]")

	GLOB.dynamic_station_traits[station_trait] = cost

/// Refund threat, but no more than threat_level.
/datum/controller/subsystem/dynamic/proc/refund_threat(regain)
	mid_round_budget = min(threat_level, mid_round_budget + regain)

/// Generate threat and increase the threat_level if it goes beyond, capped at 100
/datum/controller/subsystem/dynamic/proc/create_threat(gain, list/threat_log, reason)
	mid_round_budget = min(100, mid_round_budget + gain)
	if(mid_round_budget > threat_level)
		threat_level = mid_round_budget
	for(var/list/logs in threat_log)
		log_threat(gain, logs, reason)

/datum/controller/subsystem/dynamic/proc/log_threat(threat_change, list/threat_log, reason)
	var/gain_or_loss = "+"
	if(threat_change < 0)
		gain_or_loss = "-"
	threat_log += "Threat [gain_or_loss][abs(threat_change)] - [reason]."

/// Expend round start threat, can't fall under 0.
/datum/controller/subsystem/dynamic/proc/spend_roundstart_budget(cost, list/threat_log, reason)
	round_start_budget = max(round_start_budget - cost,0)
	if (!isnull(threat_log))
		log_threat(-cost, threat_log, reason)

/// Expend midround threat, can't fall under 0.
/datum/controller/subsystem/dynamic/proc/spend_midround_budget(cost, list/threat_log, reason)
	mid_round_budget = max(mid_round_budget - cost,0)
	if (!isnull(threat_log))
		log_threat(-cost, threat_log, reason)

#define MAXIMUM_DYN_DISTANCE 5

/**
 * Returns the comulative distribution of threat centre and width, and a random location of -5 to 5
 * plus or minus the otherwise unattainable lower and upper percentiles. All multiplied by the maximum
 * threat and then rounded to the nearest interval.
 * rand() calls without arguments returns a value between 0 and 1, allowing for smaller intervals.
 */
/datum/controller/subsystem/dynamic/proc/lorentz_to_amount(centre = 0, scale = 1.8, max_threat = 100, interval = 1)
	var/location = RANDOM_DECIMAL(-MAXIMUM_DYN_DISTANCE, MAXIMUM_DYN_DISTANCE) * rand()
	var/lorentz_result = LORENTZ_CUMULATIVE_DISTRIBUTION(centre, location, scale)
	var/std_threat = lorentz_result * max_threat
	///Without these, the amount won't come close to hitting 0% or 100% of the max threat.
	var/lower_deviation = max(std_threat * (location-centre)/MAXIMUM_DYN_DISTANCE, 0)
	var/upper_deviation = max((max_threat - std_threat) * (centre-location)/MAXIMUM_DYN_DISTANCE, 0)
	return clamp(round(std_threat + upper_deviation - lower_deviation, interval), 0, 100)

/proc/reopen_roundstart_suicide_roles()
	var/include_command = CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_positions)
	var/list/reopened_jobs = list()

	for(var/mob/living/quitter in GLOB.suicided_mob_list)
		var/datum/job/job = SSjob.get_job(quitter.job)
		if(!job || !(job.job_flags & JOB_REOPEN_ON_ROUNDSTART_LOSS))
			continue
		if(!include_command && job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			continue
		job.current_positions = max(job.current_positions - 1, 0)
		reopened_jobs += quitter.job

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_report))
		if(reopened_jobs.len)
			var/reopened_job_report_positions
			for(var/dead_dudes_job in reopened_jobs)
				reopened_job_report_positions = "[reopened_job_report_positions ? "[reopened_job_report_positions]\n":""][dead_dudes_job]"

			var/suicide_command_report = {"
				<font size = 3><b>[command_name()] Human Resources Board</b><br>
				Notice of Personnel Change</font><hr>
				To personnel management staff aboard [station_name()]:<br><br>
				Our medical staff have detected a series of anomalies in the vital sensors
				of some of the staff aboard your station.<br><br>
				Further investigation into the situation on our end resulted in us discovering
				a series of rather... unforturnate decisions that were made on the part of said staff.<br><br>
				As such, we have taken the liberty to automatically reopen employment opportunities for the positions of the crew members
				who have decided not to partake in our research. We will be forwarding their cases to our employment review board
				to determine their eligibility for continued service with the company (and of course the
				continued storage of cloning records within the central medical backup server.)<br><br>
				<i>The following positions have been reopened on our behalf:<br><br>
				[reopened_job_report_positions]</i>
			"}

			print_command_report(suicide_command_report, "Central Command Personnel Update")


#undef MAXIMUM_DYN_DISTANCE

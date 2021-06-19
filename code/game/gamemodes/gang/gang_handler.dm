#define LOWPOP_FAMILIES_COUNT 50

#define TWO_STARS_HIGHPOP 11
#define THREE_STARS_HIGHPOP 16
#define FOUR_STARS_HIGHPOP 21
#define FIVE_STARS_HIGHPOP 31

#define TWO_STARS_LOW 6
#define THREE_STARS_LOW 9
#define FOUR_STARS_LOW 12
#define FIVE_STARS_LOW 15

#define CREW_SIZE_MIN 4
#define CREW_SIZE_MAX 8


GLOBAL_VAR_INIT(deaths_during_shift, 0)

/**
 * # Families gamemode / dynamic ruleset handler
 *
 * A special datum used by the families gamemode and dynamic rulesets to centralize code. "Family" and "gang" used interchangeably in code.
 *
 * This datum centralizes code used for the families gamemode / dynamic rulesets. Families incorporates a significant
 * amount of unique processing; without this datum, that could would be duplicated. To ensure the maintainability
 * of the families gamemode / rulesets, the code was moved to this datum. The gamemode / rulesets instance this
 * datum, pass it lists (lists are passed by reference; removing candidates here removes candidates in the gamemode),
 * and call its procs. Additionally, the families antagonist datum and families induction package also
 * contain vars that reference this datum, allowing for new families / family members to add themselves
 * to this datum's lists thereof (primarily used for point calculation). Despite this, the basic team mechanics
 * themselves should function regardless of this datum's instantiation, should a player have the gang or cop
 * antagonist datum added to them through methods external to the families gamemode / rulesets.
 *
 */
/datum/gang_handler
	/// A counter used to minimize the overhead of computationally intensive, periodic family point gain checks. Used and set internally.
	var/check_counter = 0
	/// The time, in deciseconds, that the datum's pre_setup() occured at. Used in end_time. Used and set internally.
	var/start_time = null
	/// The time, in deciseconds, that the space cops will arrive at. Calculated based on wanted level and start_time. Used and set internally.
	var/end_time = null
	/// Whether the gamemode-announcing announcement has been sent. Used and set internally.
	var/sent_announcement = FALSE
	/// Whether the "5 minute warning" announcement has been sent. Used and set internally.
	var/sent_second_announcement = FALSE
	/// Whether the space cops have arrived. Set internally; used internally, and for updating the wanted HUD.
	var/cops_arrived = FALSE
	/// The current wanted level. Set internally; used internally, and for updating the wanted HUD.
	var/wanted_level
	/// List of all /datum/team/gang. Used internally; added to externally by /datum/antagonist/gang when it generates a new /datum/team/gang.
	var/list/gangs = list()
	/// List of all family member minds. Used internally; added to internally, and externally by /obj/item/gang_induction_package when used to induct a new family member.
	var/list/gangbangers = list()
	/// List of all undercover cop minds. Used and set internally.
	var/list/undercover_cops = list()
	/// The number of families (and 1:1 corresponding undercover cops) that should be generated. Can be set externally; used internally.
	var/gangs_to_generate = 3
	/// The number of family members more that a family may have over other active families. Can be set externally; used internally.
	var/gang_balance_cap = 5
	/// Whether the handler corresponds to a ruleset that does not trigger at round start. Should be set externally only if applicable; used internally.
	var/midround_ruleset = FALSE
	/// Whether we want to use the 30 to 15 minute timer instead of the 60 to 30 minute timer, for Dynamic.
	var/use_dynamic_timing = FALSE
	/// Keeps track of the amount of deaths since the calling of pre_setup_analogue() if this is a midround handler. Used to prevent a high wanted level due to a large amount of deaths during the shift prior to the activation of this handler / the midround ruleset.
	var/deaths_during_shift_at_beginning = 0

	/// List of all eligible starting family members / undercover cops. Set externally (passed by reference) by gamemode / ruleset; used internally. Note that dynamic uses a list of mobs to handle candidates while game_modes use lists of minds! Don't be fooled!
	var/list/antag_candidates = list()
	/// List of jobs not eligible for starting family member / undercover cop. Set externally (passed by reference) by gamemode / ruleset; used internally.
	var/list/restricted_jobs

/**
 * Sets antag_candidates and restricted_jobs.
 *
 * Sets the antag_candidates and restricted_jobs lists to the equivalent
 * lists of its instantiating game_mode / dynamic_ruleset datum. As lists
 * are passed by reference, the variable set in this datum and the passed list
 * list used to set it are literally the same; changes to one affect the other.
 * Like all New() procs, called when the datum is first instantiated.
 * There's an annoying caveat here, though -- dynamic rulesets don't have
 * lists of minds for candidates, they have lists of mobs. Ghost mobs, before
 * the round has started. But we still want to preserve the structure of the candidates
 * list by not duplicating it and making sure to remove the candidates as we use them.
 * So there's a little bit of boilerplate throughout to preserve the sanctity of this reference.
 * Arguments:
 * * given_candidates - The antag_candidates list or equivalent of the datum instantiating this one.
 * * revised_restricted - The restricted_jobs list or equivalent of the datum instantiating this one.
 */
/datum/gang_handler/New(list/given_candidates, list/revised_restricted)
	antag_candidates = given_candidates
	restricted_jobs = revised_restricted

/**
 * pre_setup() or pre_execute() equivalent.
 *
 * This proc is always called externally, by the instantiating game_mode / dynamic_ruleset.
 * This is done during the pre_setup() or pre_execute() phase, after first instantiation
 * and the modification of gangs_to_generate, gang_balance_cap, and midround_ruleset.
 * It is intended to take the place of the code that would normally occupy the pre_setup()
 * or pre_execute() proc, were the code localized to the game_mode or dynamic_ruleset datum respectively
 * as opposed to this handler. As such, it picks players to be chosen for starting familiy members
 * or undercover cops prior to assignment to jobs. Sets start_time, default end_time,
 * and the current value of deaths_during_shift, to ensure the wanted level only cares about
 * the deaths since this proc has been called.
 * Takes no arguments.
 */
/datum/gang_handler/proc/pre_setup_analogue()
	for(var/j = 0, j < gangs_to_generate, j++)
		if (!antag_candidates.len)
			break
		var/taken = pick_n_take(antag_candidates) // original used antag_pick, but that's local to game_mode and rulesets use pick_n_take so this is fine maybe
		var/datum/mind/gangbanger
		if(istype(taken, /mob))
			var/mob/T = taken
			gangbanger = T.mind
		else
			gangbanger = taken
		gangbangers += gangbanger
		gangbanger.restricted_roles = restricted_jobs
		log_game("[key_name(gangbanger)] has been selected as a starting gangster!")
		if(!midround_ruleset)
			GLOB.pre_setup_antags += gangbanger
	for(var/j = 0, j < gangs_to_generate, j++)
		if(!antag_candidates.len)
			break
		var/taken = pick_n_take(antag_candidates)
		var/datum/mind/undercover_cop
		if(istype(taken, /mob))
			var/mob/T = taken
			undercover_cop = T.mind
		else
			undercover_cop = taken
		undercover_cops += undercover_cop
		undercover_cop.restricted_roles = restricted_jobs
		log_game("[key_name(undercover_cop)] has been selected as a starting undercover cop!")
		if(!midround_ruleset)
			GLOB.pre_setup_antags += undercover_cop
	deaths_during_shift_at_beginning = GLOB.deaths_during_shift // don't want to mix up pre-families and post-families deaths
	start_time = world.time
	end_time = start_time + ((60 MINUTES) / (midround_ruleset ? 2 : 1)) // midround families rounds end quicker
	return TRUE

/**
 * post_setup() or execute() equivalent.
 *
 * This proc is always called externally, by the instantiating game_mode / dynamic_ruleset.
 * This is done during the post_setup() or execute() phase, after the pre_setup() / pre_execute() phase.
 * It is intended to take the place of the code that would normally occupy the pre_setup()
 * or pre_execute() proc. As such, it ensures that all prospective starting family members /
 * undercover cops are eligible, and picks replacements if there were ineligible cops / family members.
 * It then assigns gear to the finalized family members and undercover cops, adding them to its lists,
 * and sets the families announcement proc (that does the announcing) to trigger in five minutes.
 * Additionally, if given the argument TRUE, it will return FALSE if there are no eligible starting family members.
 * This is only to be done if the instantiating datum is a dynamic_ruleset, as these require returns
 * while a game_mode is not expected to return early during this phase.
 * Arguments:
 * * return_if_no_gangs - Boolean that determines if the proc should return FALSE should it find no eligible family members. Should be used for dynamic only.
 */
/datum/gang_handler/proc/post_setup_analogue(return_if_no_gangs = FALSE)
	var/replacement_gangsters = 0
	var/replacement_cops = 0
	for(var/datum/mind/gangbanger in gangbangers)
		if(!ishuman(gangbanger.current))
			if(!midround_ruleset)
				GLOB.pre_setup_antags -= gangbanger
			gangbangers.Remove(gangbanger)
			log_game("[gangbanger] was not a human, and thus has lost their gangster role.")
			replacement_gangsters++
	if(replacement_gangsters)
		for(var/j = 0, j < replacement_gangsters, j++)
			if(!antag_candidates.len)
				log_game("Unable to find more replacement gangsters. Not all of the gangs will spawn.")
				break
			var/taken = pick_n_take(antag_candidates)
			var/datum/mind/gangbanger
			if(istype(taken, /mob)) // boilerplate needed because antag_candidates might not contain minds
				var/mob/T = taken
				gangbanger = T.mind
			else
				gangbanger = taken
			gangbangers += gangbanger
			log_game("[key_name(gangbanger)] has been selected as a replacement gangster!")
	for(var/datum/mind/undercover_cop in undercover_cops)
		if(!ishuman(undercover_cop.current))
			undercover_cops.Remove(undercover_cop)
			if(!midround_ruleset)
				GLOB.pre_setup_antags -= undercover_cop
			log_game("[undercover_cop] was not a human, and thus has lost their undercover cop role.")
			replacement_cops++
	if(replacement_cops)
		for(var/j = 0, j < replacement_cops, j++)
			if(!antag_candidates.len)
				log_game("Unable to find more replacement undercover cops. Not all of the cops will spawn.")
				break
			var/taken = pick_n_take(antag_candidates)
			var/datum/mind/undercover_cop
			if(istype(taken, /mob))
				var/mob/T = taken
				undercover_cop = T.mind
			else
				undercover_cop = taken
			undercover_cops += undercover_cop
			log_game("[key_name(undercover_cop)] has been selected as a replacement undercover cop!")

	if(!gangbangers.len)
		if(return_if_no_gangs)
			return FALSE // ending early is bad if we're not in dynamic

	for(var/datum/mind/undercover_cop in undercover_cops)
		var/datum/antagonist/ert/families/undercover_cop/one_eight_seven_on_an_undercover_cop = new()
		undercover_cop.add_antag_datum(one_eight_seven_on_an_undercover_cop)

	var/list/gangs_to_use = subtypesof(/datum/antagonist/gang)
	for(var/datum/mind/gangbanger in gangbangers)
		var/gang_to_use = pick_n_take(gangs_to_use)
		var/datum/antagonist/gang/new_gangster = new gang_to_use()
		new_gangster.handler = src
		new_gangster.starter_gangster = TRUE
		gangbanger.add_antag_datum(new_gangster)
		// see /datum/antagonist/gang/create_team() for how the gang team datum gets instantiated and added to our gangs list

	addtimer(CALLBACK(src, .proc/announce_gang_locations), 5 MINUTES)
	SSshuttle.registerHostileEnvironment(src)
	return TRUE

/**
 * process() or rule_process() equivalent.
 *
 * This proc is always called externally, by the instantiating game_mode / dynamic_ruleset.
 * This is done during the process() or rule_process() phase, after post_setup() or
 * execute() and at regular intervals thereafter. process() and rule_process() are optional
 * for a game_mode / dynamic_ruleset, but are important for this gamemode. It is of central
 * importance to the gamemode's flow, calculating wanted level updates, family point gain,
 * and announcing + executing the arrival of the space cops, achieved through calling internal procs.
 * Takes no arguments.
 */
/datum/gang_handler/proc/process_analogue()
	check_wanted_level()
	check_counter++
	if(check_counter >= 5)
		if(world.time > (end_time - 5 MINUTES) && !sent_second_announcement)
			five_minute_warning()
			addtimer(CALLBACK(src, .proc/send_in_the_fuzz), 5 MINUTES)

		check_counter = 0

		check_tagged_turfs()
		check_gang_clothes()
		check_rollin_with_crews()

/**
 * set_round_result() or round_result() equivalent.
 *
 * This proc is always called externally, by the instantiating game_mode / dynamic_ruleset.
 * This is done by the set_round_result() or round_result() procs, at roundend.
 * Sets the ticker subsystem to the correct result based off of the relative populations
 * of space cops and family members.
 * Takes no arguments.
 */
/datum/gang_handler/proc/set_round_result_analogue()
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/datum/mind/gangbanger in gangbangers)
		if(!ishuman(gangbanger.current))
			continue
		var/mob/living/carbon/human/H = gangbanger.current
		if(H.stat)
			continue
		alive_gangsters++
	for(var/datum/mind/bacon in get_antag_minds(/datum/antagonist/ert/families))
		if(!ishuman(bacon.current)) // always returns false
			continue
		var/mob/living/carbon/human/H = bacon.current
		if(H.stat)
			continue
		alive_cops++
	if(alive_gangsters > alive_cops)
		SSticker.mode_result = "win - gangs survived"
		SSticker.news_report = GANG_OPERATING
		return TRUE
	SSticker.mode_result = "loss - police destroyed the gangs"
	SSticker.news_report = GANG_DESTROYED
	return FALSE

/// Internal. Announces the presence of families to the entire station and sets sent_announcement to true to allow other checks to occur.
/datum/gang_handler/proc/announce_gang_locations()
	var/list/readable_gang_names = list()
	for(var/GG in gangs)
		var/datum/team/gang/G = GG
		readable_gang_names += "[G.name]"
	var/finalized_gang_names = english_list(readable_gang_names)
	priority_announce("Julio G coming to you live from Radio Los Spess! We've been hearing reports of gang activity on [station_name()], with the [finalized_gang_names] duking it out, looking for fresh territory and drugs to sling! Stay safe out there for the [use_dynamic_timing ? "half-hour" : "hour"] 'till the space cops get there, and keep it cool, yeah?\n\n The local jump gates are shut down for about an hour due to some maintenance troubles, so if you wanna split from the area you're gonna have to wait [use_dynamic_timing ? "thirty minutes" : "an hour"]. \n Play music, not gunshots, I say. Peace out!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')
	sent_announcement = TRUE
	check_wanted_level() // i like it when the wanted level updates at the same time as the announcement

/// Internal. Announces that space cops will arrive in 5 minutes and sets sent_second_announcement to true to freeze
/datum/gang_handler/proc/five_minute_warning()
	priority_announce("Julio G coming to you live from Radio Los Spess! The space cops are closing in on [station_name()] and will arrive in about 5 minutes! Better clear on out of there if you don't want to get hurt!", "Radio Los Spess", 'sound/voice/beepsky/radio.ogg')
	sent_second_announcement = TRUE

/// Internal. Checks if our wanted level has changed; calls update_wanted_level. Only updates wanted level post the initial announcement and until the cops show up. After that, it's locked.
/datum/gang_handler/proc/check_wanted_level()
	if(cops_arrived)
		update_wanted_level(wanted_level) // at this point, we still want to update people's star huds, even though they're mostly locked, because not everyone is around for the last update before the rest of this proc gets shut off forever, and that's when the wanted bar switches from gold stars to red / blue to signify the arrival of the space cops
		return
	if(!sent_announcement)
		return
	var/new_wanted_level
	if(GLOB.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		switch(GLOB.deaths_during_shift - deaths_during_shift_at_beginning) // if this is a midround ruleset, we only care about the deaths since the families were activated, not since shiftstart
			if(0 to TWO_STARS_HIGHPOP-1)
				new_wanted_level = 1
			if(TWO_STARS_HIGHPOP to THREE_STARS_HIGHPOP-1)
				new_wanted_level = 2
			if(THREE_STARS_HIGHPOP to FOUR_STARS_HIGHPOP-1)
				new_wanted_level = 3
			if(FOUR_STARS_HIGHPOP to FIVE_STARS_HIGHPOP-1)
				new_wanted_level = 4
			if(FIVE_STARS_HIGHPOP to INFINITY)
				new_wanted_level = 5
	else
		switch(GLOB.deaths_during_shift - deaths_during_shift_at_beginning)
			if(0 to TWO_STARS_LOW-1)
				new_wanted_level = 1
			if(TWO_STARS_LOW to THREE_STARS_LOW-1)
				new_wanted_level = 2
			if(THREE_STARS_LOW to FOUR_STARS_LOW-1)
				new_wanted_level = 3
			if(FOUR_STARS_LOW to FIVE_STARS_LOW-1)
				new_wanted_level = 4
			if(FIVE_STARS_LOW to INFINITY)
				new_wanted_level = 5
	update_wanted_level(new_wanted_level)

/// Internal. Updates the icon states for everyone, and calls procs that send out announcements / change the end_time if the wanted level has changed.
/datum/gang_handler/proc/update_wanted_level(newlevel)
	if(newlevel > wanted_level)
		on_gain_wanted_level(newlevel)
	else if (newlevel < wanted_level)
		on_lower_wanted_level(newlevel)
	wanted_level = newlevel
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(!M.hud_used?.wanted_lvl)
			continue
		var/datum/hud/H = M.hud_used
		H.wanted_lvl.level = newlevel
		H.wanted_lvl.cops_arrived = cops_arrived
		H.wanted_lvl.update_appearance()

/// Internal. Updates the end_time and sends out an announcement if the wanted level has increased. Called by update_wanted_level().
/datum/gang_handler/proc/on_gain_wanted_level(newlevel)
	var/announcement_message
	switch(newlevel)
		if(2)
			if(!sent_second_announcement) // when you hear that they're "arriving in 5 minutes," that's a goddamn guarantee
				end_time = start_time + ((50 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "Small amount of police vehicles have been spotted en route towards [station_name()]."
		if(3)
			if(!sent_second_announcement)
				end_time = start_time + ((40 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "A large detachment police vehicles have been spotted en route towards [station_name()]."
		if(4)
			if(!sent_second_announcement)
				end_time = start_time + ((35 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "A detachment of top-trained agents has been spotted on their way to [station_name()]."
		if(5)
			if(!sent_second_announcement)
				end_time = start_time + ((30 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "The fleet enroute to [station_name()] now consists of national guard personnel."
	if(!midround_ruleset) // stops midround rulesets from announcing janky ass times
		announcement_message += "  They will arrive at the [(end_time - start_time) / (1 MINUTES)] minute mark."
	if(newlevel == 1) // specific exception to stop the announcement from triggering right after the families themselves are announced because aesthetics
		return
	priority_announce(announcement_message, "Station Spaceship Detection Systems")

/// Internal. Updates the end_time and sends out an announcement if the wanted level has decreased. Called by update_wanted_level().
/datum/gang_handler/proc/on_lower_wanted_level(newlevel)
	var/announcement_message
	switch(newlevel)
		if(1)
			if(!sent_second_announcement)
				end_time = start_time + ((60 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "There are now only a few police vehicle headed towards [station_name()]."
		if(2)
			if(!sent_second_announcement)
				end_time = start_time + ((50 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "There seem to be fewer police vehicles headed towards [station_name()]."
		if(3)
			if(!sent_second_announcement)
				end_time = start_time + ((40 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "There are no longer top-trained agents in the fleet headed towards [station_name()]."
		if(4)
			if(!sent_second_announcement)
				end_time = start_time + ((35 MINUTES) / (use_dynamic_timing ? 2 : 1))
			announcement_message = "The convoy enroute to [station_name()] seems to no longer consist of national guard personnel."
	if(!midround_ruleset)
		announcement_message += "  They will arrive at the [(end_time - start_time) / (1 MINUTES)] minute mark."
	priority_announce(announcement_message, "Station Spaceship Detection Systems")

/// Internal. Polls ghosts and sends in a team of space cops according to the wanted level, accompanied by an announcement. Will let the shuttle leave 10 minutes after sending. Freezes the wanted level.
/datum/gang_handler/proc/send_in_the_fuzz()
	var/team_size
	var/cops_to_send
	var/announcement_message = "PUNK ASS BALLA BITCH"
	var/announcer = "Spinward Stellar Coalition"
	if(GLOB.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		switch(wanted_level)
			if(1)
				team_size = 8
				cops_to_send = /datum/antagonist/ert/families/beatcop
				announcement_message = "Hello, crewmembers of [station_name()]! We've received a few calls about some potential violent gang activity on board your station, so we're sending some beat cops to check things out. Nothing extreme, just a courtesy call. However, while they check things out for about 10 minutes, we're going to have to ask that you keep your escape shuttle parked.\n\nHave a pleasant day!"
				announcer = "Spinward Stellar Coalition Police Department"
			if(2)
				team_size = 9
				cops_to_send = /datum/antagonist/ert/families/beatcop/armored
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of violent gang activity from your station. We are dispatching some armed officers to help keep the peace and investigate matters. Do not get in their way, and comply with any and all requests from them. We have blockaded the local warp gate, and your shuttle cannot depart for another 10 minutes.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(3)
				team_size = 10
				cops_to_send = /datum/antagonist/ert/families/beatcop/swat
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of extreme gang activity from your station resulting in heavy civilian casualties. The Spinward Stellar Coalition does not tolerate abuse towards our citizens, and we will be responding in force to keep the peace and reduce civilian casualties. We have your station surrounded, and all gangsters must drop their weapons and surrender peacefully.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(4)
				team_size = 11
				cops_to_send = /datum/antagonist/ert/families/beatcop/fbi
				announcement_message = "We are dispatching our top agents to [station_name()] at the request of the Spinward Stellar Coalition government due to an extreme terrorist level threat against this Nanotrasen owned station. All gangsters must surrender IMMEDIATELY. Failure to comply can and will result in death. We have blockaded your warp gates and will not allow any escape until the situation is resolved within our standard response time of 10 minutes.\n\nSurrender now or face the consequences of your actions."
				announcer = "Federal Bureau of Investigation"
			if(5)
				team_size = 12
				cops_to_send = /datum/antagonist/ert/families/beatcop/military
				announcement_message = "Due to an insane level of civilian casualties aboard [station_name()], we have dispatched the National Guard to curb any and all gang activity on board the station. We have heavy cruisers watching the shuttle. Attempt to leave before we allow you to, and we will obliterate your station and your escape shuttle.\n\nYou brought this on yourselves by murdering so many civilians."
				announcer = "Spinward Stellar Coalition National Guard"
	else
		switch(wanted_level)
			if(1)
				team_size = 5
				cops_to_send = /datum/antagonist/ert/families/beatcop
				announcement_message = "Hello, crewmembers of [station_name()]! We've received a few calls about some potential violent gang activity on board your station, so we're sending some beat cops to check things out. Nothing extreme, just a courtesy call. However, while they check things out for about 10 minutes, we're going to have to ask that you keep your escape shuttle parked.\n\nHave a pleasant day!"
				announcer = "Spinward Stellar Coalition Police Department"
			if(2)
				team_size = 6
				cops_to_send = /datum/antagonist/ert/families/beatcop/armored
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of violent gang activity from your station. We are dispatching some armed officers to help keep the peace and investigate matters. Do not get in their way, and comply with any and all requests from them. We have blockaded the local warp gate, and your shuttle cannot depart for another 10 minutes.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(3)
				team_size = 7
				cops_to_send = /datum/antagonist/ert/families/beatcop/swat
				announcement_message = "Crewmembers of [station_name()]. We have received confirmed reports of extreme gang activity from your station resulting in heavy civilian casualties. The Spinward Stellar Coalition does not tolerate abuse towards our citizens, and we will be responding in force to keep the peace and reduce civilian casualties. We have your station surrounded, and all gangsters must drop their weapons and surrender peacefully.\n\nHave a secure day."
				announcer = "Spinward Stellar Coalition Police Department"
			if(4)
				team_size = 8
				cops_to_send = /datum/antagonist/ert/families/beatcop/fbi
				announcement_message = "We are dispatching our top agents to [station_name()] at the request of the Spinward Stellar Coalition government due to an extreme terrorist level threat against this Nanotrasen owned station. All gangsters must surrender IMMEDIATELY. Failure to comply can and will result in death. We have blockaded your warp gates and will not allow any escape until the situation is resolved within our standard response time of 10 minutes.\n\nSurrender now or face the consequences of your actions."
				announcer = "Federal Bureau of Investigation"
			if(5)
				team_size = 10
				cops_to_send = /datum/antagonist/ert/families/beatcop/military
				announcement_message = "Due to an insane level of civilian casualties aboard [station_name()], we have dispatched the National Guard to curb any and all gang activity on board the station. We have heavy cruisers watching the shuttle. Attempt to leave before we allow you to, and we will obliterate your station and your escape shuttle.\n\nYou brought this on yourselves by murdering so many civilians."
				announcer = "Spinward Stellar Coalition National Guard"

	priority_announce(announcement_message, announcer, 'sound/effects/families_police.ogg')
	var/list/candidates = pollGhostCandidates("Do you want to help clean up crime on this station?", "deathsquad", null)


	if(candidates.len)
		//Pick the (un)lucky players
		var/numagents = min(team_size,candidates.len)

		var/list/spawnpoints = GLOB.emergencyresponseteamspawn
		var/index = 0
		while(numagents && candidates.len)
			var/spawnloc = spawnpoints[index+1]
			//loop through spawnpoints one at a time
			index = (index + 1) % spawnpoints.len
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/cop = new(spawnloc)
			chosen_candidate.client.prefs.copy_to(cop)
			cop.key = chosen_candidate.key

			//Give antag datum
			var/datum/antagonist/ert/families/ert_antag = new cops_to_send

			cop.mind.add_antag_datum(ert_antag)
			cop.mind.assigned_role = ert_antag.name
			SSjob.SendToLateJoin(cop)

			//Logging and cleanup
			log_game("[key_name(cop)] has been selected as an [ert_antag.name]")
			numagents--
	cops_arrived = TRUE
	update_wanted_level(wanted_level) // gotta make sure everyone's wanted level display looks nice
	addtimer(CALLBACK(src, .proc/end_hostile_sit), 10 MINUTES)
	return TRUE

/// Internal. Clears the hostile environment, letting the shuttle leave.
/datum/gang_handler/proc/end_hostile_sit()
	SSshuttle.clearHostileEnvironment(src)

/// Internal. Assigns points to families according to gang tags.
/datum/gang_handler/proc/check_tagged_turfs()
	for(var/T in GLOB.gang_tags)
		var/obj/effect/decal/cleanable/crayon/gang/tag = T
		if(tag.my_gang)
			tag.my_gang.adjust_points(50)
		CHECK_TICK

/// Internal. Assigns points to families according to clothing of all currently living humans.
/datum/gang_handler/proc/check_gang_clothes() // TODO: make this grab the sprite itself, average out what the primary color would be, then compare how close it is to the gang color so I don't have to manually fill shit out for 5 years for every gang type
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.mind || !H.client)
			continue
		var/datum/antagonist/gang/is_gangster = H.mind.has_antag_datum(/datum/antagonist/gang)
		for(var/clothing in list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.back, H.gloves, H.shoes, H.belt, H.s_store, H.glasses, H.ears, H.wear_id))
			if(is_gangster)
				if(is_type_in_list(clothing, is_gangster.acceptable_clothes))
					is_gangster.add_gang_points(10)
			else
				for(var/G in gangs)
					var/datum/team/gang/gang_clothes = G
					if(is_type_in_list(clothing, gang_clothes.acceptable_clothes))
						gang_clothes.adjust_points(5)

		CHECK_TICK

/// Internal. Assigns points to families according to groups of nearby family members.
/datum/gang_handler/proc/check_rollin_with_crews()
	var/list/areas_to_check = list()
	for(var/G in gangbangers)
		var/datum/mind/gangster = G
		areas_to_check += get_area(gangster.current)
	for(var/AA in areas_to_check)
		var/area/A = AA
		var/list/gang_members = list()
		for(var/mob/living/carbon/human/H in A)
			if(H.stat || !H.mind || !H.client)
				continue
			var/datum/antagonist/gang/is_gangster = H.mind.has_antag_datum(/datum/antagonist/gang)
			if(is_gangster)
				gang_members[is_gangster.my_gang]++
			CHECK_TICK
		if(gang_members.len)
			for(var/datum/team/gang/gangsters in gang_members)
				if(gang_members[gangsters] >= CREW_SIZE_MIN)
					if(gang_members[gangsters] >= CREW_SIZE_MAX)
						gangsters.adjust_points(5) // Discourage larger clumps, spread ur people out
					else
						gangsters.adjust_points(10)


/// Hijacks the space cops' roundend results to say if cops / a gang won the round. Included in the same file as the gang_handler as it's far more related to the gamemode than it is to the beat cop datum; it's kind of hacky.
/datum/antagonist/ert/families/beatcop/roundend_report_footer()
	var/list/all_gangs = list()
	for(var/datum/team/gang/G in GLOB.antagonist_teams)
		all_gangs += G
	if(!all_gangs.len)
		return ..()
	var/list/all_gangsters = get_antag_minds(/datum/antagonist/gang)
	var/list/all_cops = get_antag_minds(/datum/antagonist/ert/families)
	var/report
	var/highest_point_value = 0
	var/highest_gang = "Leet Like Jeff K"
	var/objective_failures = TRUE

	for(var/G in all_gangs)
		var/datum/team/gang/GG = G
		if(GG.my_gang_datum.check_gang_objective())
			objective_failures = FALSE
			break
	for(var/G in all_gangs)
		var/datum/team/gang/GG = G
		if(!objective_failures)
			if(GG.points >= highest_point_value && GG.members.len && GG.my_gang_datum.check_gang_objective())
				highest_point_value = GG.points
				highest_gang = GG.name
		else
			if(GG.points >= highest_point_value && GG.members.len)
				highest_point_value = GG.points
				highest_gang = GG.name
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/M in all_gangsters)
		var/datum/mind/gangbanger = M
		if(gangbanger.current)
			if(!ishuman(gangbanger.current))
				continue
			var/mob/living/carbon/human/H = gangbanger.current
			if(H.stat)
				continue
			alive_gangsters++
	for(var/M in all_cops)
		var/datum/mind/bacon = M
		if(bacon.current)
			if(!ishuman(bacon.current)) // always returns false
				continue
			var/mob/living/carbon/human/H = bacon.current
			if(H.stat)
				continue
			alive_cops++

	if(alive_gangsters > alive_cops)
		if(!objective_failures)
			report = "<span class='header greentext'>[highest_gang] won the round by completing their objective and having the most points!</span>"
		else
			report = "<span class='header greentext'>[highest_gang] won the round by having the most points!</span>"
	else if(alive_gangsters == alive_cops)
		report = "<span class='header redtext'>Legend has it the police and the families are still duking it out to this day!</span>"
	else
		report = "<span class='header greentext'>The police put the boots to the families, medium style!</span>"

	return "</div><div class='panel redborder'>[report]" // </div> at the front not the back because this proc is intended for normal text not a whole new panel

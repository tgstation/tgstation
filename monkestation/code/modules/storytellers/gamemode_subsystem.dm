#define INIT_ORDER_GAMEMODE 70
///how many storytellers can be voted for along with always_votable ones
#define DEFAULT_STORYTELLER_VOTE_OPTIONS 4
///amount of players we can have before no longer running votes for storyteller
#define MAX_POP_FOR_STORYTELLER_VOTE 25

SUBSYSTEM_DEF(gamemode)
	name = "Gamemode"
	init_order = INIT_ORDER_GAMEMODE
	runlevels = RUNLEVEL_GAME
	flags = SS_BACKGROUND | SS_KEEP_TIMING
	wait = 2 SECONDS

	/// List of our event tracks for fast access during for loops.
	var/list/event_tracks = EVENT_TRACKS
	/// Our storyteller. They progresses our trackboards and picks out events
	var/datum/storyteller/storyteller
	/// Result of the storyteller vote/pick. Defaults to the guide.
	var/selected_storyteller = /datum/storyteller/guide
	/// List of all the storytellers. Populated at init. Associative from type
	var/list/storytellers = list()
	/// Next process for our storyteller. The wait time is STORYTELLER_WAIT_TIME
	var/next_storyteller_process = 0
	/// Associative list of even track points.
	var/list/event_track_points = list(
		EVENT_TRACK_MUNDANE = 0,
		EVENT_TRACK_MODERATE = 0,
		EVENT_TRACK_MAJOR = 0,
		EVENT_TRACK_ROLESET = 0,
		EVENT_TRACK_OBJECTIVES = 0
		)
	/// Last point amount gained of each track. Those are recorded for purposes of estimating how long until next event.
	var/list/last_point_gains = list(
		EVENT_TRACK_MUNDANE = 0,
		EVENT_TRACK_MODERATE = 0,
		EVENT_TRACK_MAJOR = 0,
		EVENT_TRACK_ROLESET = 0,
		EVENT_TRACK_OBJECTIVES = 0
		)
	/// Point thresholds at which the events are supposed to be rolled, it is also the base cost for events.
	var/list/point_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POINT_THRESHOLD,
		EVENT_TRACK_MODERATE = MODERATE_POINT_THRESHOLD,
		EVENT_TRACK_MAJOR = MAJOR_POINT_THRESHOLD,
		EVENT_TRACK_ROLESET = ROLESET_POINT_THRESHOLD,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_POINT_THRESHOLD
		)

	/// Minimum population thresholds for the tracks to fire off events.
	var/list/min_pop_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_MIN_POP,
		EVENT_TRACK_MODERATE = MODERATE_MIN_POP,
		EVENT_TRACK_MAJOR = MAJOR_MIN_POP,
		EVENT_TRACK_ROLESET = ROLESET_MIN_POP,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_MIN_POP
		)

	/// Configurable multipliers for point gain over time.
	var/list/point_gain_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	/// Configurable multipliers for roundstart points.
	var/list/roundstart_point_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1
		)
	/// Whether we allow pop scaling. This is configured by config, or the storyteller UI
	var/allow_pop_scaling = TRUE

	/// Associative list of pop scale thresholds.
	var/list/pop_scale_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POP_SCALE_THRESHOLD,
		EVENT_TRACK_MODERATE = MODERATE_POP_SCALE_THRESHOLD,
		EVENT_TRACK_MAJOR = MAJOR_POP_SCALE_THRESHOLD,
		EVENT_TRACK_ROLESET = ROLESET_POP_SCALE_THRESHOLD,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_POP_SCALE_THRESHOLD
		)

	/// Associative list of pop scale penalties.
	var/list/pop_scale_penalties = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POP_SCALE_PENALTY,
		EVENT_TRACK_MODERATE = MODERATE_POP_SCALE_PENALTY,
		EVENT_TRACK_MAJOR = MAJOR_POP_SCALE_PENALTY,
		EVENT_TRACK_ROLESET = ROLESET_POP_SCALE_PENALTY,
		EVENT_TRACK_OBJECTIVES = OBJECTIVES_POP_SCALE_PENALTY
		)

	/// Associative list of active multipliers from pop scale penalty.
	var/list/current_pop_scale_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1,
		)



	/// Associative list of control events by their track category. Compiled in Init
	var/list/event_pools = list()

	/// Events that we have scheduled to run in the nearby future
	var/list/scheduled_events = list()

	/// Associative list of tracks to forced event controls. For admins to force events (though they can still invoke them freely outside of the track system)
	var/list/forced_next_events = list()

	var/list/control = list() //list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/running = list() //list of all existing /datum/round_event
	var/list/round_end_data = list() //list of all reports that need to add round end reports
	var/list/currentrun = list()

	/// List of all uncategorized events, because they were wizard or holiday events
	var/list/uncategorized = list()

	var/list/holidays //List of all holidays occuring today or null if no holidays

	/// Event frequency multiplier, it exists because wizard, eugh.
	var/event_frequency_multiplier = 1

	/// Current preview page for the statistics UI.
	var/statistics_track_page = EVENT_TRACK_MUNDANE
	/// Page of the UI panel.
	var/panel_page = GAMEMODE_PANEL_MAIN
	/// Whether we are viewing the roundstart events or not
	var/roundstart_event_view = TRUE

	/// Whether the storyteller has been halted
	var/halted_storyteller = FALSE

	/// Ready players for roundstart events.
	var/ready_players = 0
	var/active_players = 0
	var/head_crew = 0
	var/eng_crew = 0
	var/sec_crew = 0
	var/med_crew = 0

	/// Is storyteller secret or not
	var/secret_storyteller = FALSE

	/// List of new player minds we currently want to give our roundstart antag to
	var/list/roundstart_antag_minds = list()

	var/wizardmode = FALSE //refactor this into just being a unique storyteller

	/// What is our currently desired/selected roundstart event
	var/datum/round_event_control/antagonist/solo/current_roundstart_event
	var/list/last_round_events = list()
	var/ran_roundstart = FALSE
	var/list/triggered_round_events = list()

	var/total_valid_antags = 0

/datum/controller/subsystem/gamemode/Initialize(time, zlevel)
	// Populate event pools
	for(var/track in event_tracks)
		event_pools[track] = list()

	// Populate storytellers
	for(var/type in subtypesof(/datum/storyteller))
		storytellers[type] = new type()

	for(var/datum/round_event_control/event_type as anything in typesof(/datum/round_event_control))
		if(!event_type::typepath || !event_type::name)
			continue
		var/datum/round_event_control/event = new event_type
		if(!event.valid_for_map())
			qdel(event)
			continue // event isn't good for this map no point in trying to add it to the list
		control += event //add it to the list of all events (controls)
	getHoliday()

	load_config_vars()
	load_event_config_vars()

	///Seeding events into track event pools needs to happen after event config vars are loaded
	for(var/datum/round_event_control/event as anything in control)
		if(event.holidayID || event.wizardevent)
			uncategorized += event
			continue
		event_pools[event.track] += event //Add it to the categorized event pools

	load_roundstart_data()
	if(CONFIG_GET(flag/disable_storyteller)) // we're just gonna disable firing but still initialize, so we don't have any weird runtimes
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	return SS_INIT_SUCCESS


/datum/controller/subsystem/gamemode/fire(resumed = FALSE)
	if(!resumed)
		src.currentrun = running.Copy()

	///Handle scheduled events
	for(var/datum/scheduled_event/sch_event in scheduled_events)
		if(world.time >= sch_event.start_time)
			sch_event.try_fire()
		else if(!sch_event.alerted_admins && world.time >= sch_event.start_time - 1 MINUTES)
			///Alert admins 1 minute before running and allow them to cancel or refund the event, once again.
			sch_event.alerted_admins = TRUE
			message_admins("Scheduled Event: [sch_event.event] will run in [(sch_event.start_time - world.time) / 10] seconds. (<a href='?src=[REF(sch_event)];action=cancel'>CANCEL</a>) (<a href='?src=[REF(sch_event)];action=refund'>REFUND</a>)")

	if(!halted_storyteller && next_storyteller_process <= world.time && storyteller)
		// We update crew information here to adjust population scalling and event thresholds for the storyteller.
		update_crew_infos()
		next_storyteller_process = world.time + STORYTELLER_WAIT_TIME
		storyteller.process(STORYTELLER_WAIT_TIME * 0.1)

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process(wait * 0.1)
		else
			running.Remove(thing)
		if (MC_TICK_CHECK)
			return

/// Gets the number of antagonists the antagonist injection events will stop rolling after.
/datum/controller/subsystem/gamemode/proc/get_antag_cap()
	var/total_number = get_correct_popcount() + (sec_crew * 2)
	var/cap = FLOOR((total_number / ANTAG_CAP_DENOMINATOR), 1) + ANTAG_CAP_FLAT
	return cap

/// Whether events can inject more antagonists into the round
/datum/controller/subsystem/gamemode/proc/can_inject_antags()
	total_valid_antags = 0
	for(var/mob/checked_mob in GLOB.mob_list)
		if(!checked_mob.mind)
			continue
		if(!checked_mob.mind.special_role)
			continue
		if(checked_mob.stat == DEAD)
			continue
		total_valid_antags++


	return (get_antag_cap() > total_valid_antags)

/// Gets candidates for antagonist roles.
/datum/controller/subsystem/gamemode/proc/get_candidates(be_special, job_ban, observers, ready_newplayers, living_players, required_time, inherit_required_time = TRUE, midround_antag_pref, no_antags = TRUE, list/restricted_roles, list/required_roles)
	var/list/candidates = list()
	var/list/candidate_candidates = list() //lol

	for(var/mob/player as anything in GLOB.player_list)
		if(ready_newplayers && isnewplayer(player))
			var/mob/dead/new_player/new_player = player
			if(new_player.ready == PLAYER_READY_TO_PLAY && new_player.mind && new_player.check_preferences())
				candidate_candidates += player
		else if(observers && isobserver(player))
			candidate_candidates += player
		else if(living_players && isliving(player))
			if(!ishuman(player) && !isAI(player))
				continue
			// I split these checks up to make the code more readable ~Lucy
			var/is_on_station = is_station_level(player.z)
			var/is_late_arrival = HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && istype(get_area(player), /area/shuttle/arrival)
			if(!is_on_station && !is_late_arrival)
				continue
			candidate_candidates += player

	for(var/mob/candidate as anything in candidate_candidates)
		if(QDELETED(candidate) || !candidate.key || !candidate.client || (!observers && !candidate.mind))
			continue
		if(!observers)
			if(!ready_players && !isliving(candidate))
				continue
			if(no_antags && !isnull(candidate.mind.antag_datums))
				var/real = FALSE
				for(var/datum/antagonist/antag_datum as anything in candidate.mind.antag_datums)
					if(antag_datum.count_against_dynamic_roll_chance && !(antag_datum.antag_flags & FLAG_FAKE_ANTAG))
						real = TRUE
						break
				if(real)
					continue
			if(restricted_roles && (candidate.mind.assigned_role.title in restricted_roles))
				continue
			if(length(required_roles) && !(candidate.mind.assigned_role.title in required_roles))
				continue

		if(be_special)
			if(!(candidate.client.prefs) || !(be_special in candidate.client.prefs.be_special))
				continue

			var/time_to_check
			if(required_time)
				time_to_check = required_time
			else if(inherit_required_time)
				time_to_check = GLOB.special_roles[be_special]

			if(time_to_check && candidate.client.get_remaining_days(time_to_check) > 0)
				continue

		//if(midround_antag_pref)
			//continue

		if(job_ban && is_banned_from(candidate.ckey, list(job_ban, ROLE_SYNDICATE)))
			continue
		candidates += candidate
	return candidates

/// Gets the correct popcount, returning READY people if roundstart, and active people if not.
/datum/controller/subsystem/gamemode/proc/get_correct_popcount()
	if(SSticker.HasRoundStarted())
		update_crew_infos()
		return active_players
	else
		calculate_ready_players()
		return ready_players

/// Refunds and removes a scheduled event.
/datum/controller/subsystem/gamemode/proc/refund_scheduled_event(datum/scheduled_event/refunded)
	if(refunded.cost)
		var/track_type = refunded.event.track
		event_track_points[track_type] += refunded.cost
	remove_scheduled_event(refunded)

/// Removes a scheduled event.
/datum/controller/subsystem/gamemode/proc/remove_scheduled_event(datum/scheduled_event/removed)
	scheduled_events -= removed
	qdel(removed)

/// We need to calculate ready players for the sake of roundstart events becoming eligible.
/datum/controller/subsystem/gamemode/proc/calculate_ready_players()
	ready_players = 0
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY)
			ready_players++

/// We roll points to be spent for roundstart events, including antagonists.
/datum/controller/subsystem/gamemode/proc/roll_pre_setup_points()
	if(storyteller.disable_distribution || halted_storyteller)
		return
	/// Distribute points
	for(var/track in event_track_points)
		var/base_amt
		var/gain_amt
		switch(track)
			if(EVENT_TRACK_MUNDANE)
				base_amt = ROUNDSTART_MUNDANE_BASE
				gain_amt = ROUNDSTART_MUNDANE_GAIN
			if(EVENT_TRACK_MODERATE)
				base_amt = ROUNDSTART_MODERATE_BASE
				gain_amt = ROUNDSTART_MODERATE_GAIN
			if(EVENT_TRACK_MAJOR)
				base_amt = ROUNDSTART_MAJOR_BASE
				gain_amt = ROUNDSTART_MAJOR_GAIN
			if(EVENT_TRACK_ROLESET)
				base_amt = ROUNDSTART_ROLESET_BASE
				gain_amt = ROUNDSTART_ROLESET_GAIN
			if(EVENT_TRACK_OBJECTIVES)
				base_amt = ROUNDSTART_OBJECTIVES_BASE
				gain_amt = ROUNDSTART_OBJECTIVES_GAIN
		var/calc_value = base_amt + (gain_amt * ready_players)
		calc_value *= roundstart_point_multipliers[track]
		calc_value *= storyteller.starting_point_multipliers[track]
		calc_value *= (rand(100 - storyteller.roundstart_points_variance,100 + storyteller.roundstart_points_variance)/100)
		event_track_points[track] = round(calc_value)

	/// If the storyteller guarantees an antagonist roll, add points to make it so.
	if(storyteller.guarantees_roundstart_roleset && event_track_points[EVENT_TRACK_ROLESET] < point_thresholds[EVENT_TRACK_ROLESET])
		event_track_points[EVENT_TRACK_ROLESET] = point_thresholds[EVENT_TRACK_ROLESET]

	/// If we have any forced events, ensure we get enough points for them
	for(var/track in event_tracks)
		if(forced_next_events[track] && event_track_points[track] < point_thresholds[track])
			event_track_points[track] = point_thresholds[track]

/// At this point we've rolled roundstart events and antags and we handle leftover points here.
/datum/controller/subsystem/gamemode/proc/handle_post_setup_points()
//	for(var/track in event_track_points) //Just halve the points for now.
//		event_track_points[track] *= 0.5 TESTING HOW THINGS GO WITHOUT THIS HALVING OF POINTS
	return

/// Because roundstart events need 2 steps of firing for purposes of antags, here is the first step handled, happening before occupation division.
/datum/controller/subsystem/gamemode/proc/handle_pre_setup_roundstart_events()
	if(storyteller.disable_distribution)
		return
	if(halted_storyteller)
		message_admins("WARNING: Didn't roll roundstart events (including antagonists) due to the storyteller being halted.")
		return
	while(TRUE)
		if(!storyteller.handle_tracks())
			break

/// Second step of handlind roundstart events, happening after people spawn.
/datum/controller/subsystem/gamemode/proc/handle_post_setup_roundstart_events()
	/// Start all roundstart events on post_setup immediately
	for(var/datum/round_event/event as anything in running)
		if(!event.control.roundstart)
			continue
		ASYNC
			event.try_start()
		INVOKE_ASYNC(event, TYPE_PROC_REF(/datum/round_event, try_start))

/// Schedules an event to run later.
/datum/controller/subsystem/gamemode/proc/schedule_event(datum/round_event_control/passed_event, passed_time, passed_cost, passed_ignore, passed_announce, _forced = FALSE)
	if(_forced)
		passed_ignore = TRUE
	var/datum/scheduled_event/scheduled = new (passed_event, world.time + passed_time, passed_cost, passed_ignore, passed_announce)
	var/round_started = SSticker.HasRoundStarted()
	if(round_started)
		message_admins("Event: [passed_event] has been scheduled to run in [passed_time / 10] seconds. (<a href='?src=[REF(scheduled)];action=cancel'>CANCEL</a>) (<a href='?src=[REF(scheduled)];action=refund'>REFUND</a>)")
	else //Only roundstart events can be scheduled before round start
		message_admins("Event: [passed_event] has been scheduled to run on roundstart. (<a href='?src=[REF(scheduled)];action=cancel'>CANCEL</a>)")
	scheduled_events += scheduled

/datum/controller/subsystem/gamemode/proc/update_crew_infos()
	// Very similar logic to `get_active_player_count()`
	active_players = 0
	head_crew = 0
	eng_crew = 0
	med_crew = 0
	sec_crew = 0
	for(var/mob/player_mob as anything in GLOB.player_list)
		if(!player_mob.client)
			continue
		if(player_mob.stat) //If they're alive
			continue
		if(player_mob.client.is_afk()) //If afk
			continue
		if(!ishuman(player_mob))
			continue
		active_players++
		if(player_mob.mind?.assigned_role)
			var/datum/job/player_role = player_mob.mind.assigned_role
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
				head_crew++
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)
				eng_crew++
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
				med_crew++
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
				sec_crew++
	update_pop_scaling()

/datum/controller/subsystem/gamemode/proc/update_pop_scaling()
	for(var/track in event_tracks)
		var/low_pop_bound = min_pop_thresholds[track]
		var/high_pop_bound = pop_scale_thresholds[track]
		var/scale_penalty = pop_scale_penalties[track]

		var/perceived_pop = min(max(low_pop_bound, active_players), high_pop_bound)

		var/divisor = high_pop_bound - low_pop_bound
		/// If the bounds are equal, we'd be dividing by zero or worse, if upper is smaller than lower, we'd be increasing the factor, just make it 1 and continue.
		/// this is only a problem for bad configs
		if(divisor <= 0)
			current_pop_scale_multipliers[track] = 1
			continue
		var/scalar = (perceived_pop - low_pop_bound) / divisor
		var/penalty = scale_penalty - (scale_penalty * scalar)
		var/calculated_multiplier = 1 - (penalty / 100)

		current_pop_scale_multipliers[track] = calculated_multiplier

/datum/controller/subsystem/gamemode/proc/TriggerEvent(datum/round_event_control/event, forced = FALSE)
	. = event.preRunEvent(forced)
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		event.max_occurrences = 0
	else if(. == EVENT_READY)
		event.run_event(random = TRUE, admin_forced = forced) // fallback to dynamic

///Resets frequency multiplier.
/datum/controller/subsystem/gamemode/proc/resetFrequency()
	event_frequency_multiplier = 1

/client/proc/forceEvent()
	set name = "Trigger Event"
	set category = "Admin.Events"
	if(!holder ||!check_rights(R_FUN))
		return
	holder.forceEvent(usr)

/datum/admins/proc/forceEvent(mob/user)
	SSgamemode.event_panel(user)

/client/proc/forceGamemode()
	set name = "Open Gamemode Panel"
	set category = "Admin.Events"
	if(!holder ||!check_rights(R_FUN))
		return
	holder.forceGamemode(usr)

/datum/admins/proc/forceGamemode(mob/user)
	SSgamemode.admin_panel(user)


//////////////
// HOLIDAYS //
//////////////
//Uncommenting ALLOW_HOLIDAYS in config.txt will enable holidays

//It's easy to add stuff. Just add a holiday datum in code/modules/holiday/holidays.dm
//You can then check if it's a special day in any code in the game by doing if(SSgamemode.holidays["Groundhog Day"])

//You can also make holiday random events easily thanks to Pete/Gia's system.
//simply make a random event normally, then assign it a holidayID string which matches the holiday's name.
//Anything with a holidayID, which isn't in the holidays list, will never occur.

//Please, Don't spam stuff up with stupid stuff (key example being april-fools Pooh/ERP/etc),
//And don't forget: CHECK YOUR CODE!!!! We don't want any zero-day bugs which happen only on holidays and never get found/fixed!

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//ALSO, MOST IMPORTANTLY: Don't add stupid stuff! Discuss bonus content with Project-Heads first please!//
//////////////////////////////////////////////////////////////////////////////////////////////////////////


//sets up the holidays and holidays list
/datum/controller/subsystem/gamemode/proc/getHoliday()
	if(!CONFIG_GET(flag/allow_holidays))
		return // Holiday stuff was not enabled in the config!
	for(var/H in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new H()
		var/delete_holiday = TRUE
		for(var/timezone in holiday.timezones)
			var/time_in_timezone = world.realtime + timezone HOURS

			var/YYYY = text2num(time2text(time_in_timezone, "YYYY")) // get the current year
			var/MM = text2num(time2text(time_in_timezone, "MM")) // get the current month
			var/DD = text2num(time2text(time_in_timezone, "DD")) // get the current day
			var/DDD = time2text(time_in_timezone, "DDD") // get the current weekday

			if(holiday.shouldCelebrate(DD, MM, YYYY, DDD))
				holiday.celebrate()
				LAZYSET(holidays, holiday.name, holiday)
				delete_holiday = FALSE
				break
		if(delete_holiday)
			qdel(holiday)

	if(holidays)
		holidays = shuffle(holidays)
		// regenerate station name because holiday prefixes.
		set_station_name(new_station_name())
		world.update_status()

/datum/controller/subsystem/gamemode/proc/toggleWizardmode()
	wizardmode = !wizardmode //TODO: decide what to do with wiz events
	message_admins("Summon Events has been [wizardmode ? "enabled, events will occur [SSgamemode.event_frequency_multiplier] times as fast" : "disabled"]!")
	log_game("Summon Events was [wizardmode ? "enabled" : "disabled"]!")

///Attempts to select players for special roles the mode might have.
/datum/controller/subsystem/gamemode/proc/pre_setup()
	calculate_ready_players()
	roll_pre_setup_points()
	//handle_pre_setup_roundstart_events()
	return TRUE

///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/controller/subsystem/gamemode/proc/post_setup(report) //Gamemodes can override the intercept report. Passing TRUE as the argument will force a report.
	if(!report)
		report = !CONFIG_GET(flag/no_intercept_report)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(display_roundstart_logout_report)), ROUNDSTART_LOGOUT_REPORT_TIME)

	if(CONFIG_GET(flag/reopen_roundstart_suicide_roles))
		var/delay = CONFIG_GET(number/reopen_roundstart_suicide_roles_delay)
		if(delay)
			delay = (delay SECONDS)
		else
			delay = (4 MINUTES) //default to 4 minutes if the delay isn't defined.
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(reopen_roundstart_suicide_roles)), delay)

	if(SSdbcore.Connect())
		var/list/to_set = list()
		var/arguments = list()
		if(storyteller)
			to_set += "game_mode = :game_mode"
			arguments["game_mode"] = storyteller.name
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
	generate_station_goals()
	handle_post_setup_roundstart_events()
	handle_post_setup_points()
	roundstart_event_view = FALSE
	return TRUE


///Handles late-join antag assignments
/datum/controller/subsystem/gamemode/proc/make_antag_chance(mob/living/carbon/human/character)
	return

/datum/controller/subsystem/gamemode/proc/check_finished(force_ending) //to be called by SSticker
	if(!SSticker.setup_done)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE

/*
 * Generate a list of station goals available to purchase to report to the crew.
 *
 * Returns a formatted string all station goals that are available to the station.
 */
/datum/controller/subsystem/gamemode/proc/generate_station_goal_report()
	if(!GLOB.station_goals.len)
		return
	. = "<hr><b>Special Orders for [station_name()]:</b><BR>"
	for(var/datum/station_goal/station_goal as anything in GLOB.station_goals)
		station_goal.on_report()
		. += station_goal.get_report()
	return

/*
 * Generate a list of active station traits to report to the crew.
 *
 * Returns a formatted string of all station traits (that are shown) affecting the station.
 */
/datum/controller/subsystem/gamemode/proc/generate_station_trait_report()
	if(!SSstation.station_traits.len)
		return
	. = "<hr><b>Identified shift divergencies:</b><BR>"
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		. += "[station_trait.get_report()]<BR>"
	return

/* /proc/reopen_roundstart_suicide_roles()
	var/include_command = CONFIG_GET(flag/reopen_roundstart_suicide_roles_command_positions)
	var/list/reopened_jobs = list()
	for(var/mob/living/quitter in GLOB.suicided_mob_list)
		var/datum/job/job = SSjob.GetJob(quitter.job)
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
			var/suicide_command_report = "<font size = 3><b>Central Command Human Resources Board</b><br>\
								Notice of Personnel Change</font><hr>\
								To personnel management staff aboard [station_name()]:<br><br>\
								Our medical staff have detected a series of anomalies in the vital sensors \
								of some of the staff aboard your station.<br><br>\
								Further investigation into the situation on our end resulted in us discovering \
								a series of rather... unforturnate decisions that were made on the part of said staff.<br><br>\
								As such, we have taken the liberty to automatically reopen employment opportunities for the positions of the crew members \
								who have decided not to partake in our research. We will be forwarding their cases to our employment review board \
								to determine their eligibility for continued service with the company (and of course the \
								continued storage of cloning records within the central medical backup server.)<br><br>\
								<i>The following positions have been reopened on our behalf:<br><br>\
								[reopened_job_report_positions]</i>"
			print_command_report(suicide_command_report, "Central Command Personnel Update") */

//////////////////////////
//Reports player logouts//
//////////////////////////
/* /proc/display_roundstart_logout_report()
	var/list/msg = list("[SPAN_BOLDNOTICE("Roundstart logout report")]\n\n")
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/mob/living/carbon/C = L
		if (istype(C) && !C.last_mind)
			continue  // never had a client
		if(L.ckey && !GLOB.directory[L.ckey])
			msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"
		if(L.ckey && L.client)
			var/failed = FALSE
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2)) //Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				failed = TRUE //AFK client
			if(!failed && L.stat)
				if(L.suiciding) //Suicider
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] ([SPAN_BOLDANNOUNCE("Suicide")])\n"
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
					if(L.suiciding) //Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([SPAN_BOLDANNOUNCE("Suicide")])\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([SPAN_BOLDANNOUNCE("Ghosted")])\n"
						continue //Ghosted while alive
	for (var/C in GLOB.admins)
		to_chat(C, msg.Join()) */

/datum/controller/subsystem/gamemode/proc/generate_station_goals()
	var/list/possible = subtypesof(/datum/station_goal)
	var/goal_weights = 0
	while(possible.len && goal_weights < 1) // station goal budget is 1
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		GLOB.station_goals += new picked

//Set result and news report here
/datum/controller/subsystem/gamemode/proc/set_round_result()
	SSticker.mode_result = "undefined"
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_DESTROYED_NUKE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		SSticker.news_report = STATION_EVACUATED
		if(SSshuttle.emergency.is_hijacked())
			SSticker.news_report = SHUTTLE_HIJACK

/// Loads json event config values from events.txt
/datum/controller/subsystem/gamemode/proc/load_event_config_vars()
	var/json_file = file("[global.config.directory]/events.json")
	if(!fexists(json_file))
		return
	var/list/decoded = json_decode(file2text(json_file))
	for(var/event_text_path in decoded)
		var/event_path = text2path(event_text_path)
		var/datum/round_event_control/event
		for(var/datum/round_event_control/iterated_event as anything in control)
			if(iterated_event.type == event_path)
				event = iterated_event
				break
		if(!event)
			continue
		var/list/var_list = decoded[event_text_path]
		for(var/variable in var_list)
			var/value = var_list[variable]
			switch(variable)
				if("weight")
					event.weight = value
				if("min_players")
					event.min_players = value
				if("max_occurrences")
					event.max_occurrences = value
				if("earliest_start")
					event.earliest_start = value * (1 MINUTES)
				if("track")
					if(value in event_tracks)
						event.track = value
				if("cost")
					event.cost = value
				if("reoccurence_penalty_multiplier")
					event.reoccurence_penalty_multiplier = value
				if("shared_occurence_type")
					if(!isnull(value))
						value = "[value]"
					event.shared_occurence_type = value

/// Loads config values from game_options.txt
/datum/controller/subsystem/gamemode/proc/load_config_vars()
	point_gain_multipliers[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_OBJECTIVES] = CONFIG_GET(number/objectives_point_gain_multiplier)

	roundstart_point_multipliers[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_roundstart_point_multiplier)
	roundstart_point_multipliers[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_roundstart_point_multiplier)
	roundstart_point_multipliers[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_roundstart_point_multiplier)
	roundstart_point_multipliers[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_roundstart_point_multiplier)
	roundstart_point_multipliers[EVENT_TRACK_OBJECTIVES] = CONFIG_GET(number/objectives_roundstart_point_multiplier)

	min_pop_thresholds[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_min_pop)
	min_pop_thresholds[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_min_pop)
	min_pop_thresholds[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_min_pop)
	min_pop_thresholds[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_min_pop)
	min_pop_thresholds[EVENT_TRACK_OBJECTIVES] = CONFIG_GET(number/objectives_min_pop)

	point_thresholds[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_point_threshold)
	point_thresholds[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_point_threshold)
	point_thresholds[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_point_threshold)
	point_thresholds[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_point_threshold)
	point_thresholds[EVENT_TRACK_OBJECTIVES] = CONFIG_GET(number/objectives_point_threshold)

/datum/controller/subsystem/gamemode/proc/handle_picking_stroyteller()
	if(length(GLOB.clients) > MAX_POP_FOR_STORYTELLER_VOTE)
		secret_storyteller = TRUE
		selected_storyteller = pick_weight(get_valid_storytellers(TRUE))
		return
	SSvote.initiate_vote(/datum/vote/storyteller, "pick round storyteller", forced = TRUE)

/datum/controller/subsystem/gamemode/proc/storyteller_vote_choices()
	var/list/final_choices = list()
	var/list/pick_from = list()
	for(var/datum/storyteller/storyboy in get_valid_storytellers())
		if(storyboy.always_votable)
			final_choices[storyboy.name] = 0
		else
			pick_from[storyboy.name] = storyboy.weight //might be able to refactor this to be slightly better due to get_valid_storytellers returning a weighted list

	var/added_storytellers = 0
	while(added_storytellers < DEFAULT_STORYTELLER_VOTE_OPTIONS && length(pick_from))
		added_storytellers++
		var/picked_storyteller = pick_weight(pick_from)
		final_choices[picked_storyteller] = 0
		pick_from -= picked_storyteller
	return final_choices

/datum/controller/subsystem/gamemode/proc/storyteller_desc(storyteller_name)
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.name != storyteller_name)
			continue
		return storyboy.desc


/datum/controller/subsystem/gamemode/proc/storyteller_vote_result(winner_name)
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.name == winner_name)
			selected_storyteller = storyteller_type
			break

///return a weighted list of all storytellers that are currently valid to roll, if return_types is set then we will return types instead of instances
/datum/controller/subsystem/gamemode/proc/get_valid_storytellers(return_types = FALSE)
	var/client_amount = length(GLOB.clients)
	var/list/valid_storytellers = list()
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.restricted || (storyboy.population_min && storyboy.population_min > client_amount) || (storyboy.population_max && storyboy.population_max < client_amount))
			continue

		valid_storytellers[return_types ? storyboy.type : storyboy] = storyboy.weight
	return valid_storytellers

/datum/controller/subsystem/gamemode/proc/init_storyteller()
	set_storyteller(selected_storyteller)

/datum/controller/subsystem/gamemode/proc/set_storyteller(passed_type)
	if(!storytellers[passed_type])
		message_admins("Attempted to set an invalid storyteller type: [passed_type], force setting to guide instead.")
		storyteller = storytellers[/datum/storyteller/guide] //if we dont have any then we brick, lets not do that
		CRASH("Attempted to set an invalid storyteller type: [passed_type].")
	storyteller = storytellers[passed_type]
	if(!secret_storyteller)
		send_to_playing_players(span_notice("<b>Storyteller is [storyteller.name]!</b>"))
		send_to_playing_players(span_notice("[storyteller.welcome_text]"))
	else
		send_to_observers(span_boldbig("<b>Storyteller is [storyteller.name]!</b>")) //observers still get to know

/// Panel containing information, variables and controls about the gamemode and scheduled event
/datum/controller/subsystem/gamemode/proc/admin_panel(mob/user)
	update_crew_infos()
	total_valid_antags = 0
	for(var/mob/checked_mob in GLOB.mob_list)
		if(!checked_mob.mind)
			continue
		if(!checked_mob.mind.special_role)
			continue
		if(checked_mob.stat == DEAD)
			continue
		total_valid_antags++

	var/round_started = SSticker.HasRoundStarted()
	var/list/dat = list()
	dat += "Storyteller: [storyteller ? "[storyteller.name]" : "None"] "
	dat += " <a href='?src=[REF(src)];panel=main;action=halt_storyteller' [halted_storyteller ? "class='linkOn'" : ""]>HALT Storyteller</a> <a href='?src=[REF(src)];panel=main;action=open_stats'>Event Panel</a> <a href='?src=[REF(src)];panel=main;action=set_storyteller'>Set Storyteller</a> <a href='?src=[REF(src)];panel=main'>Refresh</a>"
	dat += "<BR><font color='#888888'><i>Storyteller determines points gained, event chances, and is the entity responsible for rolling events.</i></font>"
	dat += "<BR>Active Players: [active_players]   (Head: [head_crew], Sec: [sec_crew], Eng: [eng_crew], Med: [med_crew])"
	dat += "<BR>Antagonist Count vs Maximum: [total_valid_antags] / [get_antag_cap()]"
	dat += "<HR>"
	dat += "<a href='?src=[REF(src)];panel=main;action=tab;tab=[GAMEMODE_PANEL_MAIN]' [panel_page == GAMEMODE_PANEL_MAIN ? "class='linkOn'" : ""]>Main</a>"
	dat += " <a href='?src=[REF(src)];panel=main;action=tab;tab=[GAMEMODE_PANEL_VARIABLES]' [panel_page == GAMEMODE_PANEL_VARIABLES ? "class='linkOn'" : ""]>Variables</a>"
	dat += "<HR>"
	switch(panel_page)
		if(GAMEMODE_PANEL_VARIABLES)
			dat += "<a href='?src=[REF(src)];panel=main;action=reload_config_vars'>Reload Config Vars</a> <font color='#888888'><i>Configs located in game_options.txt.</i></font>"
			dat += "<BR><b>Point Gains Multipliers (only over time):</b>"
			dat += "<BR><font color='#888888'><i>This affects points gained over time towards scheduling new events of the tracks.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='?src=[REF(src)];panel=main;action=vars;var=pts_multiplier;track=[track]'>[point_gain_multipliers[track]]</a>"
			dat += "<HR>"

			dat += "<b>Roundstart Points Multipliers:</b>"
			dat += "<BR><font color='#888888'><i>This affects points generated for roundstart events and antagonists.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='?src=[REF(src)];panel=main;action=vars;var=roundstart_pts;track=[track]'>[roundstart_point_multipliers[track]]</a>"
			dat += "<HR>"

			dat += "<b>Minimum Population for Tracks:</b>"
			dat += "<BR><font color='#888888'><i>This are the minimum population caps for events to be able to run.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='?src=[REF(src)];panel=main;action=vars;var=min_pop;track=[track]'>[min_pop_thresholds[track]]</a>"
			dat += "<HR>"

			dat += "<b>Point Thresholds:</b>"
			dat += "<BR><font color='#888888'><i>Those are thresholds the tracks require to reach with points to make an event.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='?src=[REF(src)];panel=main;action=vars;var=pts_threshold;track=[track]'>[point_thresholds[track]]</a>"

		if(GAMEMODE_PANEL_MAIN)
			var/even = TRUE
			dat += "<h2>Event Tracks:</h2>"
			dat += "<font color='#888888'><i>Every track represents progression towards scheduling an event of it's severity</i></font>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=25%><b>Track</b></td>"
			dat += "<td width=20%><b>Progress</b></td>"
			dat += "<td width=10%><b>Next</b></td>"
			dat += "<td width=10%><b>Forced</b></td>"
			dat += "<td width=35%><b>Actions</b></td>"
			dat += "</tr>"
			for(var/track in event_tracks)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				var/lower = event_track_points[track]
				var/upper = point_thresholds[track]
				var/percent = round((lower/upper)*100)
				var/next = 0
				var/last_points = last_point_gains[track]
				if(last_points)
					next = round(((upper - lower) / last_points / STORYTELLER_WAIT_TIME))
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[track] - [last_points] per process.</td>" //Track
				dat += "<td>[percent]% ([lower]/[upper])</td>" //Progress
				dat += "<td>~[next] seconds</td>" //Next
				var/datum/round_event_control/forced_event = forced_next_events[track]
				var/forced = forced_event ? "[forced_event.name] <a href='?src=[REF(src)];panel=main;action=track_action;track_action=remove_forced;track=[track]'>X</a>" : ""
				dat += "<td>[forced]</td>" //Forced
				dat += "<td><a href='?src=[REF(src)];panel=main;action=track_action;track_action=set_pts;track=[track]'>Set Pts.</a> <a href='?src=[REF(src)];panel=main;action=track_action;track_action=next_event;track=[track]'>Next Event</a></td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Scheduled Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "<td width=17%><b>Severity</b></td>"
			dat += "<td width=12%><b>Time</b></td>"
			dat += "<td width=41%><b>Actions</b></td>"
			dat += "</tr>"
			var/sorted_scheduled = list()
			for(var/datum/scheduled_event/scheduled as anything in scheduled_events)
				sorted_scheduled[scheduled] = scheduled.start_time
			sortTim(sorted_scheduled, cmp=/proc/cmp_numeric_asc, associative = TRUE)
			even = TRUE
			for(var/datum/scheduled_event/scheduled as anything in sorted_scheduled)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[scheduled.event.name]</td>" //Name
				dat += "<td>[scheduled.event.track]</td>" //Severity
				var/time = (scheduled.event.roundstart && !round_started) ? "ROUNDSTART" : "[(scheduled.start_time - world.time) / (1 SECONDS)] s."
				dat += "<td>[time]</td>" //Time
				dat += "<td>[scheduled.get_href_actions()]</td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Running Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "<td width=70%><b>Actions</b></td>"
			dat += "</tr>"
			even = TRUE
			for(var/datum/round_event/event as anything in running)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[event.control.name]</td>" //Name
				dat += "<td>-TBA-</td>" //Actions
				dat += "</tr>"
			dat += "</table>"

	var/datum/browser/popup = new(user, "gamemode_admin_panel", "Gamemode Panel", 670, 650)
	popup.set_content(dat.Join())
	popup.open()

 /// Panel containing information and actions regarding events
/datum/controller/subsystem/gamemode/proc/event_panel(mob/user)
	var/list/dat = list()
	if(storyteller)
		dat += "Storyteller: [storyteller.name]"
		dat += "<BR>Repetition penalty multiplier: [storyteller.event_repetition_multiplier]"
		dat += "<BR>Cost variance: [storyteller.cost_variance]"
		if(storyteller.tag_multipliers)
			dat += "<BR>Tag multipliers:"
			for(var/tag in storyteller.tag_multipliers)
				dat += "[tag]:[storyteller.tag_multipliers[tag]] | "
		storyteller.calculate_weights(statistics_track_page)
	else
		dat += "Storyteller: None<BR>Weight and chance statistics will be inaccurate due to the present lack of a storyteller."
	dat += "<BR><a href='?src=[REF(src)];panel=stats;action=set_roundstart'[roundstart_event_view ? "class='linkOn'" : ""]>Roundstart Events</a> Forced Roundstart events will use rolled points, and are guaranteed to trigger (even if the used points are not enough)"
	dat += "<BR>Avg. event intervals: "
	for(var/track in event_tracks)
		if(last_point_gains[track])
			var/est_time = round(point_thresholds[track] / last_point_gains[track] / STORYTELLER_WAIT_TIME * 40 / 6) / 10
			dat += "[track]: ~[est_time] m. | "
	dat += "<HR>"
	for(var/track in EVENT_PANEL_TRACKS)
		dat += "<a href='?src=[REF(src)];panel=stats;action=set_cat;cat=[track]'[(statistics_track_page == track) ? "class='linkOn'" : ""]>[track]</a>"
	dat += "<HR>"
	/// Create event info and stats table
	dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
	dat += "<tr style='vertical-align:top'>"
	dat += "<td width=17%><b>Name</b></td>"
	dat += "<td width=16%><b>Tags</b></td>"
	dat += "<td width=8%><b>Occurences</b></td>"
	dat += "<td width=8%><b>Max Occurences</b></td>"
	dat += "<td width=5%><b>M.Pop</b></td>"
	dat += "<td width=5%><b>M.Time</b></td>"
	dat += "<td width=7%><b>Can Occur</b></td>"
	dat += "<td width=7%><b>Failure Reason</b></td>"
	dat += "<td width=16%><b>Weight</b></td>"
	dat += "<td width=26%><b>Actions</b></td>"
	dat += "</tr>"
	var/even = TRUE
	var/total_weight = 0
	var/list/event_lookup
	switch(statistics_track_page)
		if(ALL_EVENTS)
			event_lookup = control
		if(UNCATEGORIZED_EVENTS)
			event_lookup = uncategorized
		else
			event_lookup = event_pools[statistics_track_page]
	var/list/assoc_spawn_weight = list()
	for(var/datum/round_event_control/event as anything in event_lookup)
		var/players_amt = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
		if(event.roundstart != roundstart_event_view)
			continue
		if(event.can_spawn_event(players_amt))
			total_weight += event.calculated_weight
			assoc_spawn_weight[event] = event.calculated_weight
		else
			assoc_spawn_weight[event] = 0
	sortTim(assoc_spawn_weight, cmp=/proc/cmp_numeric_dsc, associative = TRUE)
	for(var/datum/round_event_control/event as anything in assoc_spawn_weight)
		even = !even
		var/background_cl = even ? "#17191C" : "#23273C"
		dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
		dat += "<td>[event.name]</td>" //Name
		dat += "<td>" //Tags
		for(var/tag in event.tags)
			dat += "[tag] "
		dat += "</td>"
		var/occurence_string = "[event.occurrences]"
		if(event.shared_occurence_type)
			occurence_string += " (shared: [event.get_occurences()])"
		var/max_occurence_string = "[event.max_occurrences]"
		dat += "<td>[occurence_string]</td>" //Occurences
		dat += "<td>[max_occurence_string]</td>" //Max Occurences
		dat += "<td>[event.min_players]</td>" //Minimum pop
		dat += "<td>[event.earliest_start / (1 MINUTES)] m.</td>" //Minimum time
		dat += "<td>[assoc_spawn_weight[event] ? "Yes" : "No"]</td>" //Can happen?
		dat += "<td>[event.return_failure_string(active_players)]</td>" //Why can't happen?
		var/weight_string = "(new.[event.calculated_weight] /raw.[event.weight])"
		if(assoc_spawn_weight[event])
			var/percent = round((event.calculated_weight / total_weight) * 100)
			weight_string = "[percent]% - [weight_string]"
		dat += "<td>[weight_string]</td>" //Weight
		dat += "<td>[event.get_href_actions()]</td>" //Actions
		dat += "</tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "gamemode_event_panel", "Event Panel", 1100, 600)
	popup.set_content(dat.Join())
	popup.open()

/datum/controller/subsystem/gamemode/Topic(href, href_list)
	. = ..()
	var/mob/user = usr
	if(!check_rights(R_ADMIN))
		return
	switch(href_list["panel"])
		if("main")
			switch(href_list["action"])
				if("set_storyteller")
					message_admins("[key_name_admin(usr)] is picking a new Storyteller.")
					var/list/name_list = list()
					for(var/storyteller_type in storytellers)
						var/datum/storyteller/storyboy = storytellers[storyteller_type]
						name_list[storyboy.name] = storyboy.type
					var/new_storyteller_name = input(usr, "Choose new storyteller (circumvents voted one):", "Storyteller")  as null|anything in name_list
					if(!new_storyteller_name)
						message_admins("[key_name_admin(usr)] has cancelled picking a Storyteller.")
						return
					message_admins("[key_name_admin(usr)] has chosen [new_storyteller_name] as the new Storyteller.")
					var/new_storyteller_type = name_list[new_storyteller_name]
					set_storyteller(new_storyteller_type)
				if("halt_storyteller")
					halted_storyteller = !halted_storyteller
					message_admins("[key_name_admin(usr)] has [halted_storyteller ? "HALTED" : "un-halted"] the Storyteller.")
				if("vars")
					var/track = href_list["track"]
					switch(href_list["var"])
						if("pts_multiplier")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set point gain multiplier for [track] track to [new_value].")
							point_gain_multipliers[track] = new_value
						if("roundstart_pts")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set roundstart pts multiplier for [track] track to [new_value].")
							roundstart_point_multipliers[track] = new_value
						if("min_pop")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set minimum population for [track] track to [new_value].")
							min_pop_thresholds[track] = new_value
						if("pts_threshold")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set point threshold of [track] track to [new_value].")
							point_thresholds[track] = new_value
				if("reload_config_vars")
					message_admins("[key_name_admin(usr)] reloaded gamemode config vars.")
					load_config_vars()
				if("tab")
					var/tab = href_list["tab"]
					panel_page = tab
				if("open_stats")
					event_panel(user)
					return
				if("track_action")
					var/track = href_list["track"]
					if(!(track in event_tracks))
						return
					switch(href_list["track_action"])
						if("remove_forced")
							if(forced_next_events[track])
								var/datum/round_event_control/event = forced_next_events[track]
								message_admins("[key_name_admin(usr)] removed forced event [event.name] from track [track].")
								forced_next_events -= track
						if("set_pts")
							var/set_pts = input(usr, "New point amount ([point_thresholds[track]]+ invokes event):", "Set points for [track]") as num|null
							if(isnull(set_pts))
								return
							event_track_points[track] = set_pts
							message_admins("[key_name_admin(usr)] set points of [track] track to [set_pts].")
							log_admin_private("[key_name(usr)] set points of [track] track to [set_pts].")
						if("next_event")
							message_admins("[key_name_admin(usr)] invoked next event for [track] track.")
							log_admin_private("[key_name(usr)] invoked next event for [track] track.")
							event_track_points[track] = point_thresholds[track]
							if(storyteller)
								storyteller.handle_tracks()
			admin_panel(user)
		if("stats")
			switch(href_list["action"])
				if("set_roundstart")
					roundstart_event_view = !roundstart_event_view
				if("set_cat")
					var/new_category = href_list["cat"]
					if(new_category in EVENT_PANEL_TRACKS)
						statistics_track_page = new_category
			event_panel(user)

/datum/controller/subsystem/gamemode/proc/round_end_report()
	if(!length(round_end_data))
		return
	for(var/datum/round_event/event as anything in round_end_data)
		if(!istype(event))
			continue
		event.round_end_report()


/datum/controller/subsystem/gamemode/proc/store_roundend_data()
	var/congealed_string = ""
	for(var/event_name as anything in triggered_round_events)
		congealed_string += event_name
		congealed_string += ","
	text2file(congealed_string, "data/last_round_events.txt")

/datum/controller/subsystem/gamemode/proc/load_roundstart_data()
	var/massive_string = trim(file2text("data/last_round_events.txt"))
	if(fexists("data/last_round_events.txt"))
		fdel("data/last_round_events.txt")
	if(!massive_string)
		return
	last_round_events = splittext(massive_string, ",")

	if(!length(last_round_events))
		return
	for(var/event_name as anything in last_round_events)
		for(var/datum/round_event_control/listed as anything in control)
			if(listed.name != event_name)
				continue
			listed.occurrences++
			listed.occurrences++

#undef DEFAULT_STORYTELLER_VOTE_OPTIONS
#undef MAX_POP_FOR_STORYTELLER_VOTE

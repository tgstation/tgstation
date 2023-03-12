/datum/story_type
	/// Name of the story
	var/name = "Parent Story"
	/// A rough description of the story and what it does
	var/desc = "Parent story description"
	/// How impactful the story is (and how much budget it costs)
	var/impact = STORY_UNIMPACTFUL
	/// If this can be a round-start story
	var/roundstart_eligible = TRUE
	/// How many times this story can execute at most
	var/maximum_execute_times = 1
	/// Assoc list of actor datums to create in the form of 'actor typepath:amount'
	var/list/actor_datums_to_make = list()
	/// Assoc list of mind ref:actor ref involved in the story
	var/list/mind_actor_list = list()
	/// How many acts does this story have? If more than 1, make sure code for the act execution is written.
	var/num_of_acts = 1
	/// What's our current act?
	var/current_act = 1
	/// If we have acts, then what's the time between acts? Defaults to 15 minutes.
	var/time_between_acts = 15 MINUTES
	/// Should we cancel if we can't fill the roster during startup?
	var/allow_starting_with_minimum = TRUE

/datum/story_type/Destroy(force, ...)
	return ..()

/// General checks to see if we can actually run
/datum/story_type/proc/can_execute()
	SHOULD_CALL_PARENT(TRUE)
	if(impact > SSstories.budget)
		return FALSE
	return TRUE

/// If a story need to do pre-execution stuff before picking actors, do it here.
/datum/story_type/proc/pre_execute()
	return TRUE

/// Add new actors to an existing story with this proc. Returns FALSE if it failed to get candidates.
/datum/story_type/proc/add_actors(list/actors_to_add)
	var/involves_ghosts = 0
	var/involves_crew = 0
	for(var/datum/story_actor/actor_path as anything in actors_to_add)
		if(initial(actor_path.ghost_actor))
			involves_ghosts += actors_to_add[actor_path]
		else
			involves_crew += actors_to_add[actor_path]

	var/list/ghost_list
	var/list/player_list
	if(involves_ghosts)
		ghost_list = get_ghosts(involves_ghosts)
	if(involves_crew)
		player_list = get_players(involves_crew)
	if((involves_ghosts && !length(ghost_list)) || (involves_crew && !length(player_list)))
		return FALSE

	for(var/actor_path in actors_to_add)
		var/datum/story_actor/actor_datum = new actor_path(src)
		if(actor_datum.ghost_actor)
			actor_datum.handle_spawning(pick_n_take(ghost_list), src)
		else
			actor_datum.handle_spawning(pick_n_take(player_list), src)
	return TRUE

/// The general proc That Does Things, may get split later
/datum/story_type/proc/execute_story()
	pre_execute()
	var/involves_ghosts = 0
	var/involves_crew = 0
	for(var/datum/story_actor/actor_path as anything in actor_datums_to_make)
		if(initial(actor_path.ghost_actor))
			involves_ghosts += actor_datums_to_make[actor_path]
		else
			involves_crew += actor_datums_to_make[actor_path]

	var/list/ghost_list
	var/list/player_list
	if(involves_ghosts)
		ghost_list = get_ghosts(involves_ghosts)
	if(involves_crew)
		player_list = get_players(involves_crew)
	if((involves_ghosts && !length(ghost_list)) || (involves_crew && !length(player_list)))
		return FALSE

	for(var/actor_path in actor_datums_to_make)
		var/datum/story_actor/actor_datum = new actor_path(src)
		if(actor_datum.ghost_actor)
			actor_datum.handle_spawning(pick_n_take(ghost_list), src)
		else
			actor_datum.handle_spawning(pick_n_take(player_list), src)
	if(num_of_acts > 1)
		addtimer(CALLBACK(src, .proc/update_act), time_between_acts)
	return TRUE

/// Proc for attempting to execute a story at roundstart, DOES NOT WORK ELSEWHERE
/datum/story_type/proc/execute_roundstart_story()
	pre_execute()
	var/involved_amount = 0
	for(var/datum/story_actor/actor_path as anything in actor_datums_to_make)
		involved_amount += actor_datums_to_make[actor_path]

	var/list/involved_people = get_preround_actors(involved_amount)
	if(!length(involved_people))
		return FALSE

	for(var/actor_path in actor_datums_to_make)
		var/mob/dead/new_player/chosen_player = pick_n_take(involved_people)
		var/datum/story_actor/actor_datum = new actor_path(src)
		if(actor_datum.ghost_actor)
			chosen_player.ready = FALSE

		var/mob/dead/observer/observer = new()
		chosen_player.spawning = TRUE
		observer.started_as_observer = TRUE
		var/obj/effect/landmark/observer_start/start_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
		if(start_point)
			observer.forceMove(get_turf(start_point))
		observer.key = chosen_player.key
		observer.client = chosen_player.client
		observer.set_ghost_appearance()
		if(observer.client && observer.client.prefs)
			observer.real_name = observer.client.prefs.read_preference(/datum/preference/name/real_name)
			observer.name = observer.real_name
			observer.client.init_verbs()
		observer.update_appearance()
		observer.stop_sound_channel(CHANNEL_LOBBYMUSIC)
		QDEL_NULL(chosen_player.mind)
		qdel(chosen_player)

		actor_datum.handle_spawning(observer, src)
	if(num_of_acts > 1)
		addtimer(CALLBACK(src, .proc/update_act), time_between_acts)
	return TRUE

/// Runs based on the time_between_acts after executing the story for the first time, will re-queue if there's any remaining acts when it finishes running.
/datum/story_type/proc/update_act()
	SHOULD_CALL_PARENT(TRUE)
	current_act++
	message_admins("STORY: [src] is progressing to Act [current_act]; Actor information has been updated.")
	if(current_act < num_of_acts)
		addtimer(CALLBACK(src, .proc/update_act), time_between_acts) // Begin the timer to progress to the next act, if there's acts left.

/// A proc for getting a list of ghosts and returning an equal amount to `ghosts_involved`
/datum/story_type/proc/get_ghosts(ghosts_to_get)
	. = list()
	var/list/candidates = poll_ghost_candidates("Do you want to participate in a story?", ROLE_STORY_PARTICIPANT, ROLE_STORY_PARTICIPANT, 15 SECONDS, POLL_IGNORE_STORY_ROLE)

	if(!length(candidates))
		message_admins("Story type [src] didn't have any ghost candidates, cancelling.")
		return FALSE

	for(var/i in 1 to ghosts_to_get)
		if(!length(candidates))
			if(allow_starting_with_minimum)
				message_admins("Story type [src] didn't have maximum ghost candidates, executing anyway (Wanted [ghosts_to_get], got [i])")
				break
			else
				message_admins("Story type [src] didn't have the required amount of ghost candidates, cancelling")
				return FALSE
		. += pick_n_take(candidates)

	return .

/// A proc for getting a list of players and returning an equal amount to `players_involved`
/datum/story_type/proc/get_players(players_to_get)
	. = list()
	var/list/to_ask_players = list()

	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		var/mob/living/carbon/human/current_crew = crew_mind.current

		if(!ishuman(current_crew))
			continue
		if(current_crew.stat == DEAD)
			continue
		// Add smth to check if they're in a story already leter

		to_ask_players += current_crew

	var/list/candidates = poll_candidates("Do you want to participate in a story?", ROLE_STORY_PARTICIPANT, ROLE_STORY_PARTICIPANT, 15 SECONDS, POLL_IGNORE_STORY_ROLE, FALSE, to_ask_players)
	if(!length(candidates))
		message_admins("Story type [src] didn't have any crew candidates, cancelling.")
		return FALSE

	for(var/i in 1 to players_to_get)
		if(!length(candidates))
			if(allow_starting_with_minimum)
				message_admins("Story type [src] didn't have maximum candidates, executing anyway (Wanted [players_to_get], got [i])")
				break
			else
				message_admins("Story type [src] didn't have the required amount of candidates, cancelling")
				return FALSE
		. += pick_n_take(candidates)

	return .

/datum/story_type/proc/get_preround_actors(players_to_get)
	. = list()
	var/list/possible_players = list()

	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready != PLAYER_READY_TO_PLAY)
			continue
		if(!(player.client.prefs) || !(ROLE_STORY_PARTICIPANT in player.client.prefs.be_special))
			continue
		// Add smth to check if they're in a story already leter

		possible_players += player

	if(!length(possible_players))
		message_admins("Roundstart story type [src] didn't have any candidates, cancelling.")
		return FALSE

	for(var/i in 1 to players_to_get)
		if(!length(possible_players))
			if(allow_starting_with_minimum)
				message_admins("Roundstart story type [src] didn't have maximum candidates, executing anyway (Wanted [players_to_get], got [i])")
				break
			else
				message_admins("Roundstart story type [src] didn't have the required amount of candidates, cancelling")
				return FALSE
		. += pick_n_take(possible_players)

	return .

/// Builds the HTML panel entry for the admin verb and round end
/datum/story_type/proc/build_html_panel_entry()
	var/list/story_info = list()
	story_info += "<b>[name]</b>"
	story_info += "<br>[desc]<br>"
	for(var/datum/mind/mind_reference as anything in mind_actor_list)
		var/datum/story_actor/actor_role = mind_actor_list[mind_reference]
		story_info += " - <b>[mind_reference.key]</b> - ([actor_role.name]) "
		story_info += "<a href='?priv_msg=[ckey(mind_reference.key)]'>PM</a> "
		if(mind_reference.current)
			story_info += "<a href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(mind_reference.current)]'>FLW</a> "
			story_info += "<A href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(mind_reference.current)]'>Player Panel</A>"
		if(actor_role.actor_info)
			story_info += "<br> <b>Backstory:</b>"
			story_info += "<br> <i>[actor_role.actor_info]</i>"
		if(actor_role.actor_goal)
			story_info += "<br> <b>Goal:</b>"
			story_info += "<br> <i>[actor_role.actor_goal]</i>"
	return story_info.Join()

/datum/story_type/proc/roundend_report()
	var/list/report = list("<br>")
	report += span_big(span_greentext(name))

	report += "<br><br><b>Starring:</b><br>"
	if(!length(mind_actor_list))
		report += "Nobody!"
	else
		for(var/datum/mind/actor_mind as anything in mind_actor_list)
			var/datum/story_actor/actor_datum = mind_actor_list[actor_mind]
			report += " - [actor_mind.name], the [actor_datum.name]!"

	return report.Join("\n")

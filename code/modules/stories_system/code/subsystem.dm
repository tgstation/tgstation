SUBSYSTEM_DEF(stories)
	name = "Stories"
	wait = 5 MINUTES
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	/// List of initialized story types to pick from, these are the ones that haven't been used yet
	var/list/to_use_stories = list()

	/// Assoc list of stories and how much they've been used in format of instance:amount used
	var/list/used_stories = list()

	/// How much budget the story system has to work with
	var/budget = 0

	/// For logging purposes, the roundstart budget
	var/initial_budget = 0

	/// The last probability without the divisor
	var/last_prob = 1

	/// Stories to exclude becuase they're parent types
	var/list/exclude_stories = list(
		/datum/story_type/unimpactful,
		/datum/story_type/somewhat_impactful,
		/datum/story_type/very_impactful,
		/datum/story_type/incredibly_impactful,
	)

/datum/controller/subsystem/stories/Initialize()
	for(var/type in subtypesof(/datum/story_type) - exclude_stories)
		to_use_stories += new type
	budget = rand(0, 10)//rand(CONFIG_GET(number/minimum_story_budget), CONFIG_GET(number/maximum_story_budget))
	initial_budget = budget
	return SS_INIT_SUCCESS

/datum/controller/subsystem/stories/fire(resumed)
	if(!length(to_use_stories) || !budget)// || (length(used_stories) >= CONFIG_GET(number/maximum_story_amount)))
		return

	var/exponent_divisor = 1
	if(length(used_stories))
		var/datum/story_type/last_used_story = used_stories[length(used_stories)]
		exponent_divisor = last_used_story.impact
	else
		exponent_divisor = STORY_SOMEWHAT_IMPACTFUL

	last_prob *= 2
	if(!prob(last_prob / exponent_divisor))
		return //Add log or smth later
	last_prob = initial(last_prob) // Reset if we make a story

	var/list/copied_to_use_stories = to_use_stories.Copy()

	while(length(copied_to_use_stories))
		var/datum/story_type/picked_story = pick_n_take(copied_to_use_stories)
		if(!picked_story.can_execute())
			continue
		if(!picked_story.execute_story())
			message_admins("Story [picked_story] failed to run; budget staying at [budget].")
			return
		else
			budget -= picked_story.impact
			used_stories += picked_story
			var/amount_of_times_executed = 0
			for(var/datum/story_type/past_story as anything in used_stories)
				if(!istype(past_story, picked_story.type))
					continue
				amount_of_times_executed += 1

			if(picked_story.maximum_execute_times <= amount_of_times_executed)
				to_use_stories -= picked_story
			message_admins("Story [picked_story] executed; budget is now at [budget].")
			return

/datum/controller/subsystem/stories/Topic(href, list/href_list)
	if(href_list["force_story"])
		if(!check_rights(R_ADMIN))
			CRASH("SSstories TOPIC: Detected possible HREF exploit! ([usr])")
		if(SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(usr, span_admin("You cannot do this unless the round has started, but not finished."))
			return TRUE
		var/list/built_list = list()
		for(var/datum/story_type/story_path as anything in subtypesof(/datum/story_type) - exclude_stories)
			built_list[initial(story_path.name)] = story_path
		var/chosen_one = tgui_input_list(usr, "Choose story to execute", "Story Selection", built_list)
		var/datum/story_type/chosen_story = built_list[chosen_one]
		chosen_story = new chosen_story
		to_chat(usr, span_admin("Executing story [chosen_story]..."))
		if(!chosen_story.execute_story())
			to_chat(usr, span_admin("Unable to execute story [chosen_story]!"))
			qdel(chosen_story)
		else
			used_stories += chosen_story
			to_chat(usr, span_admin("Successfully executed story [chosen_story]!"))
		return TRUE

/// Gets info of all currently running stories and who is involved
/datum/controller/subsystem/stories/proc/get_stories_info()
	var/list/returned_html = list("<br>")

	returned_html += "<b><a href='?src=[REF(src)];force_story=1'>Force Story</a></b><br><br>"

	returned_html += "<b>Active Stories</b>"

	for(var/datum/story_type/used_story as anything in used_stories)
		returned_html += " - [used_story.build_html_panel_entry()]"

	return returned_html.Join("<br>")

/// Attempts to potentially execute a story roundstart
/datum/controller/subsystem/stories/proc/execute_roundstart_story()
	if(!budget || !length(to_use_stories) || !prob(CONFIG_GET(number/roundstart_story_chance)))
		return FALSE

	var/list/copied_to_use_stories = to_use_stories.Copy()

	while(length(copied_to_use_stories))
		var/datum/story_type/picked_story = pick_n_take(copied_to_use_stories)
		if(!picked_story.roundstart_eligible || !picked_story.can_execute())
			continue
		if(!picked_story.execute_roundstart_story())
			message_admins("Roundstart story [picked_story] failed to run; budget staying at [budget].")
			return
		else
			budget -= picked_story.impact
			used_stories += picked_story
			var/amount_of_times_executed = 0
			for(var/datum/story_type/past_story as anything in used_stories)
				if(!istype(past_story, picked_story.type))
					continue
				amount_of_times_executed += 1

			if(picked_story.maximum_execute_times <= amount_of_times_executed)
				to_use_stories -= picked_story
			message_admins("Roundstart story [picked_story] executed; budget is now at [budget].")
			return

#define PUZZGRID_CONFIG "[global.config.directory]/puzzgrids.txt"
#define PUZZGRID_GROUP_COUNT 4
#define PUZZGRID_MAX_ATTEMPTS 10

/// Attaches a puzzgrid to the atom.
/// You are expected to pass in the puzzgrid, likely from create_random_puzzgrid().
/// This is so you can handle when a puzzgrid can't be generated, either because the
/// config does not exist, or because the config is not set up properly.
/datum/component/puzzgrid
	var/datum/puzzgrid/puzzgrid

	/// Callback that will be called when you win
	var/datum/callback/on_victory_callback

	/// Callback that will be called when you lose, either through running out of time or running out of lives
	var/datum/callback/on_fail_callback

	/// The world timestamp for when the puzzgrid will fail, if timer was set in Initialize
	var/time_to_finish

	/// Every answer, in text, including already solved ones
	var/list/all_answers

	/// The answers, in text, that are currently selected
	var/list/selected_answers = list()

	/// The puzzgrid groups that have already been solved
	var/list/datum/puzzgrid_group/solved_groups = list()

	/// The number of lives left
	var/lives = 3

	COOLDOWN_DECLARE(wrong_group_select_cooldown)

/datum/component/puzzgrid/Initialize(
	datum/puzzgrid/puzzgrid,
	timer,
	datum/callback/on_victory_callback,
	datum/callback/on_fail_callback,
)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	if (!istype(puzzgrid))
		stack_trace("Invalid puzzgrid passed: [puzzgrid]")
		return COMPONENT_INCOMPATIBLE

	src.puzzgrid = puzzgrid
	src.on_victory_callback = on_victory_callback
	src.on_fail_callback = on_fail_callback

	all_answers = puzzgrid.answers.Copy()

	if (!isnull(timer))
		addtimer(CALLBACK(src, PROC_REF(out_of_time)), timer)
		time_to_finish = world.time + timer

/datum/component/puzzgrid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/component/puzzgrid/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/puzzgrid/proc/on_attack_hand(atom/source, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/puzzgrid/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Puzzgrid")
		ui.open()

/datum/component/puzzgrid/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .

	switch (action)
		if ("select")
			return try_select(params["answer"])
		if ("unselect")
			return try_unselect(params["answer"])

	return TRUE

/datum/component/puzzgrid/proc/try_select(answer)
	if (!(answer in all_answers))
		return FALSE

	if (!COOLDOWN_FINISHED(src, wrong_group_select_cooldown))
		return TRUE

	selected_answers |= answer

	if (selected_answers.len < PUZZGRID_GROUP_COUNT)
		return TRUE

	var/list/current_selected_answers = selected_answers
	selected_answers = list()

	search_group:
		for (var/datum/puzzgrid_group/puzzgrid_group in (puzzgrid.groups - solved_groups))
			for (var/selected_answer in current_selected_answers)
				if (!(selected_answer in puzzgrid_group.answers))
					continue search_group

			// This group has the right answers
			solved_groups += puzzgrid_group

			if (solved_groups.len == puzzgrid.groups.len - 1)
				on_victory()
			else
				update_static_data_for_all_viewers()

			return TRUE

	COOLDOWN_START(src, wrong_group_select_cooldown, 0.2 SECONDS)

	if (solved_groups.len == puzzgrid.groups.len - 2)
		lives -= 1

		if (lives == 0)
			out_of_lives()

	return TRUE

/datum/component/puzzgrid/proc/try_unselect(answer)
	selected_answers -= answer
	return TRUE

/datum/component/puzzgrid/proc/on_victory()
	report_answers()
	on_victory_callback?.InvokeAsync()
	qdel(src)

/datum/component/puzzgrid/proc/out_of_lives()
	var/atom/movable/movable_parent = parent
	if (istype(movable_parent))
		movable_parent.say("Ran out of lives!", forced = "puzzgrid component")

	fail()

/datum/component/puzzgrid/proc/out_of_time()
	var/atom/movable/movable_parent = parent
	if (istype(movable_parent))
		movable_parent.say("Ran out of time!", forced = "puzzgrid component")

	fail()

/datum/component/puzzgrid/proc/fail()
	report_answers()
	on_fail_callback?.InvokeAsync()
	qdel(src)

/datum/component/puzzgrid/proc/report_answers()
	var/list/answers = list()
	for (var/datum/puzzgrid_group/puzzgrid_group as anything in puzzgrid.groups)
		var/list/answers_encoded = list()
		for (var/answer in puzzgrid_group.answers)
			answers_encoded += html_encode(answer)

		answers += span_boldnotice("<p>[answers_encoded.Join(", ")]</p>") + span_notice("<p>[html_encode(puzzgrid_group.description)]</p>")

	var/message = answers.Join("<p>-----</p>")

	for (var/mob/mob as anything in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, src))
		to_chat(mob, message)

/datum/component/puzzgrid/ui_data(mob/user)
	return list(
		"selected_answers" = selected_answers,
		"time_left" = time_to_finish && (max(0, (time_to_finish - world.time) / (1 SECONDS))),
		"wrong_group_select_cooldown" = !COOLDOWN_FINISHED(src, wrong_group_select_cooldown),
		"lives" = lives,
	)

/datum/component/puzzgrid/ui_static_data(mob/user)
	var/list/data = list()

	data["answers"] = puzzgrid.answers

	var/list/serialized_solved_groups = list()
	for (var/datum/puzzgrid_group/solved_group as anything in solved_groups)
		serialized_solved_groups += list(list(
			"answers" = solved_group.answers,
		))

	var/atom/atom_parent = parent

	data["host"] = atom_parent.name
	data["solved_groups"] = serialized_solved_groups

	return data

/// Returns a random puzzgrid from config.
/// If config is empty, or no valid puzzgrids can be found in time, will return null.
/proc/create_random_puzzgrid()
	var/static/total_lines

	if (isnull(total_lines))
		total_lines = rustg_file_get_line_count(PUZZGRID_CONFIG)

		if (isnull(total_lines))
			// There was an error reading the file
			total_lines = 0

	if (total_lines == 0)
		return null

	for (var/_ in 1 to PUZZGRID_MAX_ATTEMPTS)
		var/line_number = rand(0, total_lines - 1)
		var/line = rustg_file_seek_line(PUZZGRID_CONFIG, line_number)
		if (!line)
			continue

		var/line_json_decoded = safe_json_decode(line)
		if (isnull(line_json_decoded))
			log_config("Line [line_number + 1] in puzzgrids.txt is not a JSON: [line]")
			continue

		var/datum/puzzgrid/puzzgrid = new
		var/populate_result = puzzgrid.populate(line_json_decoded)

		if (populate_result == TRUE)
			return puzzgrid
		else
			log_config("Line [line_number + 1] in puzzgrids.txt is not formatted correctly: [populate_result]")

	stack_trace("No valid puzzgrid config could be found in [PUZZGRID_MAX_ATTEMPTS] attempts, please check config_error. If it is empty, then seek line is failing.")
	return null

/// Represents an individual puzzgrid
/datum/puzzgrid
	var/list/answers = list()
	var/list/datum/puzzgrid_group/groups = list()

/// Will populate a puzzgrid with the information from the JSON.
/// Will return TRUE if the populate succeeded, or a string denoting the error otherwise.
/datum/puzzgrid/proc/populate(list/from_json)
	if (!islist(from_json))
		return "Puzzgrid was not a list"

	var/list/answers = list()
	var/list/groups = list()

	for (var/group_json in from_json)
		if (!islist(group_json))
			return "Group was not a list (received [json_encode(group_json)])"

		if (!("cells" in group_json))
			return "Group did not have a 'cells' field (received [json_encode(group_json)])"

		if (!("description" in group_json))
			return "Group did not have a 'description' field (received [json_encode(group_json)])"

		var/datum/puzzgrid_group/group = new
		group.answers = group_json["cells"]
		group.description = group_json["description"]

		answers += group.answers

		groups += group

	src.answers = shuffle(answers)
	src.groups = groups

	return TRUE

/// Represents an individual group in a puzzgrid
/datum/puzzgrid_group
	var/list/answers = list()
	var/description

/// Debug verb for validating that all puzzgrids can be created successfully.
/// Locked behind a verb because it's fairly slow and memory intensive.
/client/proc/validate_puzzgrids()
	set name = "Validate Puzzgrid Config"
	set category = "Debug"

	var/line_number = 0

	for (var/line in world.file2list(PUZZGRID_CONFIG))
		line_number += 1

		if (length(line) == 0)
			continue

		var/line_json_decoded = safe_json_decode(line)
		if (isnull(line_json_decoded))
			to_chat(src, span_warning("Line [line_number] in puzzgrids.txt is not a JSON: [line]"))
			continue

		var/datum/puzzgrid/puzzgrid = new
		var/populate_result = puzzgrid.populate(line_json_decoded)

		if (populate_result != TRUE)
			to_chat(src, span_warning("Line [line_number] in puzzgrids.txt is not formatted correctly: [populate_result]"))

	to_chat(src, span_notice("Validated. If you did not see any errors, you're in the clear."))

#undef PUZZGRID_CONFIG
#undef PUZZGRID_GROUP_COUNT
#undef PUZZGRID_MAX_ATTEMPTS

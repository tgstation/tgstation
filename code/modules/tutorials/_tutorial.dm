// MBTODO: Document everything
/datum/tutorial
	// MBTODO: Unit test that this is null, or a date
	var/grandfather_date

	var/mob/user

	var/atom/movable/screen/tutorial_instruction/instruction_screen

/datum/tutorial/New(mob/user)
	src.user = user

	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(destroy_self))
	RegisterSignal(user.client, COMSIG_PARENT_QDELETING, PROC_REF(destroy_self))

/datum/tutorial/Destroy(force, ...)
	user.client?.screen -= instruction_screen
	QDEL_NULL(instruction_screen)

	user = null

	return ..()

/datum/tutorial/proc/manager()
	RETURN_TYPE(/datum/tutorial_manager)
	return SStutorials.tutorial_managers[type]

/datum/tutorial/proc/perform()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] does not override perform()")

/datum/tutorial/proc/should_perform()
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

/datum/tutorial/proc/complete()
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)

	manager().complete(user)
	perform_base_completion_effects()

/datum/tutorial/proc/dismiss()
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)

	manager().dismiss(user)
	perform_base_completion_effects()

#define INSTRUCTION_SCREEN_DELAY (1 SECONDS)

/datum/tutorial/proc/perform_base_completion_effects()
	SHOULD_NOT_OVERRIDE(TRUE)

	var/delay = perform_completion_effects()

	if (!isnull(instruction_screen))
		animate(instruction_screen, time = INSTRUCTION_SCREEN_DELAY, alpha = 0, easing = SINE_EASING)
		delay += INSTRUCTION_SCREEN_DELAY

	QDEL_IN(src, delay)

/datum/tutorial/proc/perform_completion_effects()
	SHOULD_CALL_PARENT(FALSE)
	return 0

#undef INSTRUCTION_SCREEN_DELAY

/datum/tutorial/proc/destroy_self()
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)
	manager().dismiss(user)
	qdel(src)

/datum/tutorial/proc/show_instruction(message)
	if (isnull(instruction_screen))
		instruction_screen = new(null, message, user.client)
		user.client?.screen += instruction_screen
	else
		instruction_screen.change_message(message)

/datum/tutorial/proc/keybinding_message(datum/keybinding/keybinding_type, message, message_without_keybinds)
	var/list/keybinds = user.client?.prefs.key_bindings[initial(keybinding_type.name)]
	return keybinds?.len > 0 ? replacetext(message, "%KEY%", "<b>[keybinds[1]]</b>") : message_without_keybinds

/datum/tutorial/proc/animate_ui_element(icon_state, initial_screen_loc, target_screen_loc, animate_start_time)
	var/atom/movable/screen/preview = new
	preview.icon = ui_style2icon(user.client?.prefs.read_preference(/datum/preference/choiced/ui_style) || GLOB.available_ui_styles[1])
	preview.icon_state = icon_state
	preview.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	preview.screen_loc = "1,1"

	var/view = user.client?.view

	var/list/origin_offsets = screen_loc_to_offset(initial_screen_loc, view)

	// A little offset to the right (origin offsets on its own already starts pretty far)
	var/matrix/origin_transform = TRANSLATE_MATRIX(origin_offsets[1] - world.icon_size * 0.5, origin_offsets[2] - world.icon_size * 1.5)

	var/list/target_offsets = screen_loc_to_offset(target_screen_loc, view)
	// `- world.icon_Size * 0.5` to patch over a likely bug in screen_loc_to_offset with CENTER, needs more looking at
	var/matrix/animate_to_transform = TRANSLATE_MATRIX(target_offsets[1] - world.icon_size * 1.5, target_offsets[2] - world.icon_size)

	preview.transform = origin_transform

	preview.alpha = 0
	animate(preview, time = animate_start_time, alpha = 255, easing = CUBIC_EASING)
	animate(1.4 SECONDS)
	animate(transform = animate_to_transform, time = 2 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(alpha = 0, time = 2.4 SECONDS, easing = CUBIC_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

	user.client?.screen += preview

	return preview
/datum/tutorial_manager
	var/datum/tutorial/tutorial_type

	/// ckeys that we know have finished the tutorial
	VAR_PRIVATE/list/finished_ckeys = list()

	/// ckeys that have performed the tutorial, but have not completed it.
	/// Doesn't mean that they can still see the tutorial, might have meant the tutorial was dismissed
	/// without being completed, such as during a log out.
	VAR_PRIVATE/list/performing_ckeys = list()

/datum/tutorial_manager/New(tutorial_type)
	ASSERT(ispath(tutorial_type, /datum/tutorial))
	src.tutorial_type = tutorial_type

/datum/tutorial_manager/Destroy(force, ...)
	if (!force)
		stack_trace("Something is trying to destroy [type], which is a singleton")
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/tutorial_manager/proc/try_perform(mob/user, list/arguments)
	var/datum/tutorial/tutorial = new tutorial_type(user)
	if (!tutorial.should_perform(user))
		qdel(tutorial)
		return

	performing_ckeys[user.ckey] = TRUE

	tutorial.perform(arglist(arguments))

/datum/tutorial_manager/proc/should_run(mob/user)
	var/ckey = user.ckey

	if (isnull(ckey))
		return FALSE

	if (ckey in finished_ckeys)
		return FALSE

	if (ckey in performing_ckeys)
		return FALSE

	if (!SSdbcore.IsConnected())
		return CONFIG_GET(flag/give_tutorials_without_db)

	var/player_join_date = user.client?.player_join_date
	if (isnull(player_join_date))
		return FALSE

	// This works because ISO-8601 is cool
	var/grandfather_date = initial(tutorial_type.grandfather_date)
	if (!isnull(grandfather_date) && player_join_date < grandfather_date)
		return FALSE

	return TRUE

/datum/tutorial_manager/proc/complete(mob/user)
	set waitfor = FALSE

	ASSERT(!isnull(user.ckey))

	finished_ckeys[user.ckey] = TRUE
	performing_ckeys -= user.ckey

	SSblackbox.record_feedback("tally", "tutorial_completed", 1, "[tutorial_type]")
	log_game("[key_name(user)] completed the [tutorial_type] tutorial.")

	if (SSdbcore.IsConnected())
		INVOKE_ASYNC(src, PROC_REF(log_completion_to_database), user.ckey)

/datum/tutorial_manager/proc/log_completion_to_database(ckey)
	PRIVATE_PROC(TRUE)

	var/datum/db_query/insert_tutorial_query = SSdbcore.NewQuery(
		"INSERT IGNORE INTO [format_table_name("tutorial_completions")] (ckey, tutorial_key) VALUES (:ckey, :tutorial_key)",
		list(
			"ckey" = ckey,
			"tutorial_key" = get_key(),
		)
	)

	insert_tutorial_query.warn_execute()

	qdel(insert_tutorial_query)

/datum/tutorial_manager/proc/dismiss(mob/user)
	performing_ckeys -= user.ckey

/datum/tutorial_manager/proc/mark_as_completed(ckey)
	finished_ckeys[ckey] = TRUE
	performing_ckeys -= ckey

// MBTODO: Unit test that all of these are <= 64
/datum/tutorial_manager/proc/get_key()
	return copytext("[tutorial_type]", length("[/datum/tutorial]") + 2)

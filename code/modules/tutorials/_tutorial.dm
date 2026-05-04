/// The base for a contextual tutorial.
/// In order to give a tutorial to someone, use `SStutorials.suggest_tutorial(user, /datum/tutorial/subtype)`
/datum/tutorial
	/// If set, any account who started playing before this date will not be given this tutorial.
	/// Date is in YYYY-MM-DD format.
	var/grandfather_date

	/// The mob we are giving the tutorial to
	VAR_PROTECTED/mob/user

	VAR_PRIVATE/atom/movable/screen/tutorial_instruction/instruction_screen
	VAR_PRIVATE/atom/movable/screen/tutorial_skip/skip_button

/datum/tutorial/New(mob/user)
	src.user = user

	RegisterSignals(user, list(COMSIG_QDELETING, COMSIG_MOB_LOGOUT), PROC_REF(destroy_self))

/datum/tutorial/Destroy(force)
	user.client?.screen -= instruction_screen
	user.client?.screen -= skip_button
	QDEL_NULL(instruction_screen)
	QDEL_NULL(skip_button)

	user = null
	return ..()

/// Gets the [`/datum/tutorial_manager`] that owns this tutorial.
/datum/tutorial/proc/manager()
	RETURN_TYPE(/datum/tutorial_manager)
	return SStutorials.tutorial_managers[type]

/// The actual steps of the tutorial. Is given any excess arguments of suggest_tutorial.
/// Must be overridden.
/datum/tutorial/proc/perform()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] does not override perform()")

/// Returns TRUE/FALSE if this tutorial should be given.
/// If FALSE, does not mean it won't come back later.
/datum/tutorial/proc/should_perform()
	SHOULD_CALL_PARENT(FALSE)
	return TRUE

/// Called by the tutorial when the user has successfully completed it.
/// Will mark it as completed in the datbaase and kick off destruction of the tutorial.
/datum/tutorial/proc/complete()
	SIGNAL_HANDLER
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	manager().complete(user)
	perform_base_completion_effects()

/// As opposed to `complete()`, this merely hides the tutorial.
/// This should be used when the user doesn't need the tutorial anymore, but didn't
/// actually properly finish it.
/datum/tutorial/proc/dismiss()
	SIGNAL_HANDLER
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	manager().dismiss(user)
	perform_base_completion_effects()

#define INSTRUCTION_SCREEN_DELAY (1 SECONDS)

/datum/tutorial/proc/perform_base_completion_effects()
	SHOULD_NOT_OVERRIDE(TRUE)

	var/delay = perform_completion_effects_with_delay()

	if (!isnull(instruction_screen))
		animate(instruction_screen, time = INSTRUCTION_SCREEN_DELAY, alpha = 0, easing = SINE_EASING)
		animate(skip_button, time = INSTRUCTION_SCREEN_DELAY, alpha = 0, easing = SINE_EASING)
		delay += INSTRUCTION_SCREEN_DELAY

	QDEL_IN(src, delay)

/// Called when the tutorial is being hidden, but before it is deleted.
/// You should unregister signals and fade out any of your creations in here.
/// Returns how long extra to delay the deletion.
/datum/tutorial/proc/perform_completion_effects_with_delay()
	SHOULD_CALL_PARENT(FALSE)
	PROTECTED_PROC(TRUE)

	return 0

#undef INSTRUCTION_SCREEN_DELAY

/datum/tutorial/proc/destroy_self()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	manager().dismiss(user)
	qdel(src)

/// Shows a large piece of text on the user's screen with the given message.
/// If a message already exists, will fade it out and replace it.
/datum/tutorial/proc/show_instruction(message)
	PROTECTED_PROC(TRUE)
	if(isnull(skip_button))
		skip_button = new
		user.client?.screen += skip_button
		RegisterSignal(skip_button, COMSIG_SCREEN_ELEMENT_CLICK, PROC_REF(dismiss))

	if (isnull(instruction_screen))
		instruction_screen = new(null, null, message, user.client)
		user.client?.screen += instruction_screen
	else
		instruction_screen.change_message(message)

/// Given a keybind and a message, will replace %KEY% in `message` with the first keybind they have.
/// As a fallback, will return the third parameter, `message_without_keybinds`, if none are set.
/datum/tutorial/proc/keybinding_message(datum/keybinding/keybinding_type, message, message_without_keybinds)
	PROTECTED_PROC(TRUE)

	var/list/keybinds = user.client?.prefs.key_bindings[initial(keybinding_type.name)]
	return keybinds?.len > 0 ? replacetext(message, "%KEY%", "<b>[keybinds[1]]</b>") : message_without_keybinds

/// Creates a UI element with the given `icon_state`, starts it at `initial_screen_loc`, and animates it to `target_screen_loc`.
/// Waits `animate_start_time` before moving.
/datum/tutorial/proc/animate_ui_element(icon_state, initial_screen_loc, target_screen_loc, animate_start_time)
	PROTECTED_PROC(TRUE)

	var/atom/movable/screen/preview = new
	preview.icon = ui_style2icon(user.client?.prefs.read_preference(/datum/preference/choiced/ui_style) || GLOB.available_ui_styles[1])
	preview.icon_state = icon_state
	preview.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	preview.screen_loc = "1,1"

	var/view = user.client?.view

	var/list/origin_offsets = screen_loc_to_offset(initial_screen_loc, view)

	// A little offset to the right
	var/matrix/origin_transform = TRANSLATE_MATRIX(origin_offsets[1] - ICON_SIZE_X * 0.5, origin_offsets[2] - ICON_SIZE_Y * 1.5)

	var/list/target_offsets = screen_loc_to_offset(target_screen_loc, view)
	// `- world.icon_Size * 0.5` to patch over a likely bug in screen_loc_to_offset with CENTER, needs more looking at
	var/matrix/animate_to_transform = TRANSLATE_MATRIX(target_offsets[1] - ICON_SIZE_X * 1.5, target_offsets[2] - ICON_SIZE_Y)

	preview.transform = origin_transform

	preview.alpha = 0
	animate(preview, time = animate_start_time, alpha = 255, easing = CUBIC_EASING)
	animate(1.4 SECONDS)
	animate(transform = animate_to_transform, time = 2 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(alpha = 0, time = 2.4 SECONDS, easing = CUBIC_EASING | EASE_IN, flags = ANIMATION_PARALLEL)

	user.client?.screen += preview

	return preview

/// A singleton that manages when to create tutorials of a specific tutorial type.
/datum/tutorial_manager
	VAR_PRIVATE/datum/tutorial/tutorial_type

	/// ckeys that we know have finished the tutorial
	VAR_PRIVATE/list/finished_ckeys = list()

	/// ckeys that have performed the tutorial, but have not completed it.
	/// Doesn't mean that they can still see the tutorial, might have meant the tutorial was dismissed
	/// without being completed, such as during a log out.
	VAR_PRIVATE/list/performing_ckeys = list()

/datum/tutorial_manager/New(tutorial_type)
	ASSERT(ispath(tutorial_type, /datum/tutorial))
	src.tutorial_type = tutorial_type

/datum/tutorial_manager/Destroy(force)
	if (!force)
		stack_trace("Something is trying to destroy [type], which is a singleton")
		return QDEL_HINT_LETMELIVE
	return ..()

/// Checks if we should perform the tutorial for the given user, and performs if so.
/// Use `SStutorials.suggest_tutorial` instead of calling this directly.
/datum/tutorial_manager/proc/try_perform(mob/user, list/arguments)
	var/datum/tutorial/tutorial = new tutorial_type(user)
	if (!tutorial.should_perform(user))
		qdel(tutorial)
		return

	performing_ckeys[user.ckey] = TRUE

	tutorial.perform(arglist(arguments))

/// Checks if the user should be given this tutorial
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

/// Marks the tutorial as completed.
/// Call `/datum/tutorial/proc/complete()` instead.
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
		"INSERT INTO [format_table_name("tutorial_completions")] (ckey, tutorial_key) VALUES (:ckey, :tutorial_key) ON DUPLICATE KEY UPDATE tutorial_key = tutorial_key",
		list(
			"ckey" = ckey,
			"tutorial_key" = get_key(),
		)
	)

	insert_tutorial_query.warn_execute()
	QDEL_NULL(insert_tutorial_query)

/// Dismisses the tutorial, not marking it as completed in the database.
/// Call `/datum/tutorial/proc/dismiss()` instead.
/datum/tutorial_manager/proc/dismiss(mob/user)
	// this can be null in some disconnect/mob logout cases so we use some fallbacks
	var/user_ckey = user.ckey
	if(!user_ckey && user.canon_client)
		user_ckey = user.canon_client.ckey
	if(!user_ckey && user.mind?.key)
		user_ckey = ckey(user.mind.key)
	performing_ckeys -= user_ckey

/// Given a ckey, will mark them as being completed without affecting the database.
/// Call `/datum/tutorial/proc/complete()` instead.
/datum/tutorial_manager/proc/mark_as_completed(ckey)
	finished_ckeys[ckey] = TRUE
	performing_ckeys -= ckey

/// Gives the key that will be saved in the database.
/// Must be 64 characters or less.
/datum/tutorial_manager/proc/get_key()
	SHOULD_BE_PURE(TRUE)
	return copytext("[tutorial_type]", length("[/datum/tutorial]") + 2)

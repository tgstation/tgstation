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
	return GLOB.tutorial_managers[type]

/datum/tutorial/proc/perform()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] does not override perform()")

/datum/tutorial/proc/complete()
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	manager().complete(user)
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

/datum/tutorial_manager/proc/perform(mob/user, list/arguments)
	performing_ckeys[user.ckey] = TRUE

	var/datum/tutorial/tutorial = new tutorial_type(user)
	tutorial.perform(arglist(arguments))

/datum/tutorial_manager/proc/should_run(mob/user)
	var/ckey = user.ckey

	if (isnull(ckey))
		return FALSE

	if (ckey in finished_ckeys)
		return FALSE

	if (ckey in performing_ckeys)
		return FALSE

	// MBTODO: Check grandfather date
	// MBTODO: If no database, then use config which will forces this value

	return TRUE

// MBTODO: Log to database
/datum/tutorial_manager/proc/complete(mob/user)
	set waitfor = FALSE

	ASSERT(!isnull(user.ckey))

	finished_ckeys[user.ckey] = TRUE
	performing_ckeys -= user.ckey

	SSblackbox.record_feedback("tally", "tutorial_completed", 1, "[tutorial_type]")
	log_game("[key_name(user)] completed the [tutorial_type] tutorial.")

/datum/tutorial_manager/proc/dismiss(mob/user)
	performing_ckeys -= user.ckey

GLOBAL_LIST_INIT_TYPED(tutorial_managers, /datum/tutorial, init_tutorial_managers())
/proc/init_tutorial_managers()
	var/list/tutorial_managers = list()
	for (var/datum/tutorial/tutorial_type as anything in subtypesof(/datum/tutorial))
		tutorial_managers[tutorial_type] = new /datum/tutorial_manager(tutorial_type)
	return tutorial_managers

/proc/suggest_tutorial(mob/user, datum/tutorial/tutorial_type, ...)
	var/datum/tutorial_manager/tutorial_manager = GLOB.tutorial_managers[tutorial_type]
	if (isnull(tutorial_manager))
		CRASH("[tutorial_type] is not a valid tutorial type")

	if (!tutorial_manager.should_run(user))
		return

	INVOKE_ASYNC(tutorial_manager, TYPE_PROC_REF(/datum/tutorial_manager, perform), user, args.Copy(3))

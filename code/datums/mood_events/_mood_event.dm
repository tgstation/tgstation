/datum/mood_event
	/// Description of the mood event
	var/description
	/// The amount the mood will change
	var/mood_change = 0
	/// How long this mood event should last
	var/timeout = 0
	/// Is this mood event hidden on examine
	var/hidden = FALSE
	/// string of what category this mood was added in as
	var/category
	/// if it isn't null, it will replace or add onto the mood icon with this (same file).
	/// see happiness drug for example
	var/special_screen_obj
	/// if false, it will be an overlay instead
	var/special_screen_replace = TRUE
	/// Owner of this mood event
	var/mob/owner
	/// List of required jobs for this mood event
	var/list/required_job = list()

/datum/mood_event/New(mob/M, ...)
	owner = M
	var/list/params = args.Copy(2)
	if (!(M.mind?.assigned_role in required_job))
		qdel(src)
	add_effects(arglist(params))

/datum/mood_event/Destroy()
	remove_effects()
	owner = null
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/remove_effects()
	return

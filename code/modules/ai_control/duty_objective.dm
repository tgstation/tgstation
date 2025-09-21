/// Represents an individual duty the AI-controlled crew member should pursue.

/datum/ai_duty_objective
	var/id
	var/description
	var/priority = 3
	var/procpath/validation_proc
	var/cooldown = 0
	var/last_completed = 0

/datum/ai_duty_objective/New(id, description, priority = 3, validation_proc_path, cooldown = 0)
	..()
	src.id = id
	src.description = description
	set_priority(priority)
	set_validation_proc(validation_proc_path)
	set_cooldown(cooldown)

/datum/ai_duty_objective/proc/set_priority(value)
	if(!isnum(value))
		return priority
	priority = clamp(round(value), 1, 5)
	return priority

/datum/ai_duty_objective/proc/set_validation_proc(validation_proc_path)
	if(ispath(validation_proc_path))
		validation_proc = validation_proc_path
	return validation_proc

/datum/ai_duty_objective/proc/set_cooldown(value)
	if(!isnum(value) || value <= 0)
		cooldown = 0
	else
		cooldown = value
	return cooldown

/// Whether the objective can attempt execution at the current world time.
/datum/ai_duty_objective/proc/can_attempt(current_time = world.time)
	if(!cooldown)
		return TRUE
	return (current_time - last_completed) >= cooldown

/// Mark the objective as completed and start cooldown tracking.
/datum/ai_duty_objective/proc/mark_completed(current_time = world.time)
	last_completed = current_time

/// Invoke the validation proc (if defined) to confirm successful completion.
/datum/ai_duty_objective/proc/is_complete(args...)
	if(!validation_proc)
		return TRUE
	return call(validation_proc)(arglist(args))

/datum/ai_duty_objective/proc/to_list()
	return list(
		"id" = id,
		"description" = description,
		"priority" = priority,
		"cooldown" = cooldown,
		"last_completed" = last_completed,
	)

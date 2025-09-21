/// Temporary reservation for shared equipment so AI agents resolve contention safely.

/datum/ai_equipment_reservation
	var/datum/weakref/equipment_ref
	var/profile_id
	var/priority_score = 0
	var/expires_at = 0

/datum/ai_equipment_reservation/New(atom/movable/equipment, profile_id, priority_score = 0, duration_seconds = AI_CONTROL_DEFAULT_RESERVATION_SECONDS)
	..()
	set_equipment(equipment)
	src.profile_id = profile_id
	set_priority(priority_score)
	renew(duration_seconds)

/datum/ai_equipment_reservation/proc/set_equipment(atom/movable/equipment)
	if(equipment)
		equipment_ref = WEAKREF(equipment)
	else
		equipment_ref = null

/datum/ai_equipment_reservation/proc/get_equipment()
	return equipment_ref?.resolve()

/datum/ai_equipment_reservation/proc/set_priority(value)
	if(!isnum(value))
		priority_score = 0
	else
		priority_score = value

/datum/ai_equipment_reservation/proc/renew(duration_seconds = AI_CONTROL_DEFAULT_RESERVATION_SECONDS)
	if(!isnum(duration_seconds) || duration_seconds <= 0)
		duration_seconds = AI_CONTROL_DEFAULT_RESERVATION_SECONDS
	expires_at = world.time + round(duration_seconds * 10)

/datum/ai_equipment_reservation/proc/is_expired(current_time = world.time)
	return current_time >= expires_at

/datum/ai_equipment_reservation/proc/time_remaining(current_time = world.time)
	return max(expires_at - current_time, 0)

/datum/ai_equipment_reservation/proc/to_list()
	return list(
		"equipment" = get_equipment(),
		"profile_id" = profile_id,
		"priority_score" = priority_score,
		"expires_at" = expires_at,
	)

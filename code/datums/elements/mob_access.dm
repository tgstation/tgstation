///element given to mobs that have levels of access
/datum/element/mob_access
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// What can this mob access?
	var/list/my_access

/datum/element/mob_access/Attach(datum/target, list/accesses)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	for(var/access_path in accesses)
		if(!ispath(access_path))
			continue
		var/datum/id_trim/job/trim = SSid_access.trim_singletons_by_path[access_path]
		if(isnull(trim))
			continue
		my_access += trim.access

	RegisterSignal(target, COMSIG_MOB_TRIED_ACCESS, PROC_REF(attempt_access))

/datum/element/mob_access/proc/attempt_access(datum/source, obj/door_attempt)
	SIGNAL_HANDLER

	return (door_attempt.check_access_list(my_access)) ? ACCESS_ALLOWED : ACCESS_DISALLOWED

/datum/element/mob_access/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOB_TRIED_ACCESS)
	return ..()

/**
 * Request Emergency Temporary Access - ID Card Extensions
 * code\modules\reta\reta_system.dm
 */

/obj/item/card/id
	/// Dictionary of temporary department access: dept_name -> list(access_flags)
	var/list/reta_temp_access = list()
	/// Dictionary of timer IDs for clearing temporary access: dept_name -> timer_id
	var/list/reta_timers = list()

/// Grants temporary department access to this ID card
/obj/item/card/id/proc/grant_reta_access(dept, duration_ds)
	if(!GLOB.reta_dept_grants[dept])
		return FALSE

	// Clear existing timer for this department if any (allows extending/refreshing access)
	if(reta_timers[dept] && reta_timers[dept] != -1)
		deltimer(reta_timers[dept])
		reta_timers[dept] = null

	// Grant access flags for this department
	var/list/access_flags = GLOB.reta_dept_grants[dept]
	var/list/new_access = list()

	// Initialize department access list if needed
	if(!reta_temp_access[dept])
		reta_temp_access[dept] = list()

	for(var/flag in access_flags)
		if(!(flag in access)) // Only add if not permanently granted
			// Add to department-specific temporary access
			reta_temp_access[dept] |= flag
			// Add to main access list
			access += flag
			new_access += flag

	if(!LAZYLEN(new_access))
		return FALSE // No new access granted

	// Set timer for this specific department
	reta_timers[dept] = addtimer(CALLBACK(src, PROC_REF(clear_reta_access_for_dept), dept), duration_ds, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

	// Add to global registry for mass operations
	GLOB.reta_active_cards |= src

	// User feedback
	var/mob/living/carbon/human/holder = get_id_holder()
	if(holder)
		playsound(holder, 'sound/machines/cryo_warning.ogg', 25, TRUE)
		holder.balloon_alert(holder, "emergency access: [dept]")

	// Enhanced logging
	var/access_names = list()
	for(var/flag in new_access)
		access_names += SSid_access.get_access_desc(flag)

	var/holder_info = holder ? "held by [holder]" : "not being held"
	log_reta("Granted [dept] temporary access ([english_list(access_names)]) to ID '[registered_name || "Unknown"]' ([holder_info]) for [duration_ds/10] seconds")
	investigate_log("RETA: Granted [dept] temporary access ([english_list(access_names)]) to ID '[registered_name || "Unknown"]' ([holder_info])", INVESTIGATE_ACCESSCHANGES)

	return TRUE

/// Clears temporary access for a specific department
/obj/item/card/id/proc/clear_reta_access_for_dept(dept)
	if(!reta_temp_access[dept] || !LAZYLEN(reta_temp_access[dept]))
		return

	// User feedback before clearing
	var/mob/living/carbon/human/holder = get_id_holder()
	if(holder)
		holder.balloon_alert(holder, "[dept] access expired")
		to_chat(holder, span_warning("Emergency access to [dept] has expired."))

	// Remove department's temporary access from the main access list
	var/list/dept_access = reta_temp_access[dept]
	for(var/flag in dept_access)
		// Only remove if no other department also grants this access
		var/still_needed = FALSE
		for(var/other_dept in reta_temp_access)
			if(other_dept != dept && reta_temp_access[other_dept] && (flag in reta_temp_access[other_dept]))
				still_needed = TRUE
				break

		if(!still_needed)
			access -= flag

	// Enhanced logging
	var/access_names = list()
	for(var/flag in dept_access)
		access_names += SSid_access.get_access_desc(flag)

	var/holder_info = holder ? "held by [holder]" : "not being held"
	log_reta("Cleared [dept] temporary access ([english_list(access_names)]) from ID '[registered_name || "Unknown"]' ([holder_info])")
	investigate_log("RETA: Cleared [dept] temporary access ([english_list(access_names)]) from ID '[registered_name || "Unknown"]' ([holder_info])", INVESTIGATE_ACCESSCHANGES)

	// Clean up department data
	reta_temp_access[dept] = null
	reta_timers[dept] = null

	// Remove from global registry if no more temporary access
	if(!has_any_reta_access())
		GLOB.reta_active_cards -= src

/// Clears all temporary department access from this ID card
/obj/item/card/id/proc/clear_reta_access()
	if(!LAZYLEN(reta_temp_access))
		return

	// User feedback before clearing
	var/mob/living/carbon/human/holder = get_id_holder()
	if(holder)
		holder.balloon_alert(holder, "emergency access expired")
		to_chat(holder, span_warning("Emergency access has expired."))

	// Collect all temporary access flags for logging
	var/list/all_temp_access = list()
	for(var/dept in reta_temp_access)
		if(reta_temp_access[dept])
			all_temp_access |= reta_temp_access[dept]

	// Remove all temporary access from the main access list
	for(var/flag in all_temp_access)
		access -= flag

	// Enhanced logging
	var/access_names = list()
	for(var/flag in all_temp_access)
		access_names += SSid_access.get_access_desc(flag)

	var/holder_info = holder ? "held by [holder]" : "not being held"
	log_reta("Cleared all temporary access ([english_list(access_names)]) from ID '[registered_name || "Unknown"]' ([holder_info])")
	investigate_log("RETA: Cleared all temporary access ([english_list(access_names)]) from ID '[registered_name || "Unknown"]' ([holder_info])", INVESTIGATE_ACCESSCHANGES)

	// Clear all timers
	for(var/dept in reta_timers)
		if(reta_timers[dept] && reta_timers[dept] != -1)
			deltimer(reta_timers[dept])

	LAZYCLEARLIST(reta_temp_access)
	LAZYCLEARLIST(reta_timers)

	// Remove from global registry
	GLOB.reta_active_cards -= src

/// Checks if this ID card has any temporary access
/obj/item/card/id/proc/has_any_reta_access()
	for(var/dept in reta_temp_access)
		if(reta_temp_access[dept] && LAZYLEN(reta_temp_access[dept]))
			return TRUE
	return FALSE

/// Checks if this ID card has temporary access to a specific flag
/obj/item/card/id/proc/has_reta_access(access_flag)
	for(var/dept in reta_temp_access)
		if(reta_temp_access[dept] && (access_flag in reta_temp_access[dept]))
			return TRUE
	return FALSE

/// Checks if this ID card has temporary access for a specific department
/obj/item/card/id/proc/has_reta_access_for_dept(dept)
	return reta_temp_access[dept] && LAZYLEN(reta_temp_access[dept])

/// Gets all current temporary access flags for this ID card
/obj/item/card/id/proc/get_reta_access()
	var/list/all_access = list()
	for(var/dept in reta_temp_access)
		if(reta_temp_access[dept])
			all_access |= reta_temp_access[dept]
	return all_access

/// Gets temporary access flags for a specific department
/obj/item/card/id/proc/get_reta_access_for_dept(dept)
	var/list/dept_access = reta_temp_access[dept]
	return dept_access?.Copy() || list()

/// Gets a summary of all active RETA accesses (for debugging/display)
/obj/item/card/id/proc/get_reta_summary()
	var/list/summary = list()
	for(var/dept in reta_temp_access)
		if(reta_temp_access[dept] && LAZYLEN(reta_temp_access[dept]))
			var/time_left = "unknown"
			if(reta_timers[dept])
				var/remaining = timeleft(reta_timers[dept])
				if(remaining > 0)
					time_left = "[remaining/10]s"
			summary += "[dept] ([LAZYLEN(reta_temp_access[dept])] access, [time_left] left)"
	return summary

/// Helper to get the human holding this ID card
/obj/item/card/id/proc/get_id_holder()
	var/mob/living/carbon/human/holder
	if(istype(loc, /mob/living/carbon/human))
		holder = loc
	else if(istype(loc, /obj/item/card/id) && istype(loc.loc, /mob/living/carbon/human))
		holder = loc.loc
	else
		// Check if worn in ID slot
		for(var/mob/living/carbon/human/human in range(0, src))
			if(human.get_idcard() == src)
				holder = human
				break
	return holder

/// Cleanup temporary access when ID card is deleted
/obj/item/card/id/Destroy()
	// Clear all department timers
	for(var/dept in reta_timers)
		if(reta_timers[dept] && reta_timers[dept] != -1)
			deltimer(reta_timers[dept])
	GLOB.reta_active_cards -= src
	return ..()
/*
/mob/living/death(gibbed)
	. = ..()
	clear_temp_dept_access()
*/

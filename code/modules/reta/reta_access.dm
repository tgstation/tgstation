/**
 * Request Emergency Temporary Access - Access System
 * code/modules/reta/reta_system.dm
 * Extends the access checking system to include temporary department access
 */

/**
 * Extended access list retrieval that includes temporary access
 */
/mob/living/get_access()
	var/list/access_list = ..()

	// Add temporary department access if any
	if(LAZYLEN(temp_dept_access))
		access_list += temp_dept_access

	return access_list

/**
 * Override allowed() for mobs to check temporary access first
 * This ensures temporary access is checked before regular ID card access
 */
/atom/movable/allowed(mob/accessor)
	// Check for temporary access first if accessor is a mob with temp access
	if(ismob(accessor) && LAZYLEN(accessor:temp_dept_access))
		var/mob/temp_accessor = accessor
		var/list/temp_access = temp_accessor.get_temp_dept_access()
		if(check_access_list(temp_access))
			return TRUE

	// Fall back to normal access checking
	return ..()

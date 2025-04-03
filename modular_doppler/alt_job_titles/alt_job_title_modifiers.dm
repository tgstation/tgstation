/**
 * Some specific jobs may require a modifier to be applied to their alt title.
 * Here is where we handle doing such.
 */

// Applies any potential modifiers to our alt title
/datum/id_trim/proc/get_modified_title(base_title)
	return base_title

// Applies any potential modifiers to our alt title
/obj/item/card/id/proc/get_modified_title(base_title)
	if(trim)
		return trim.get_modified_title(base_title)
	return base_title

/**
 * Departmental security requires appending the subdepartment after its alt job title.
 */

/datum/id_trim/job/security_officer
	// Which string to append to our title based on our subdepartment, if any
	var/subdepartment_title_modifier

/datum/id_trim/job/security_officer/get_modified_title(base_title)
	if(subdepartment_title_modifier)
		return "[base_title] ([subdepartment_title_modifier])"
	return ..()

/datum/id_trim/job/security_officer/supply
	subdepartment_title_modifier = SEC_DEPT_SUPPLY

/datum/id_trim/job/security_officer/engineering
	subdepartment_title_modifier = SEC_DEPT_ENGINEERING

/datum/id_trim/job/security_officer/medical
	subdepartment_title_modifier = SEC_DEPT_MEDICAL

/datum/id_trim/job/security_officer/science
	subdepartment_title_modifier = SEC_DEPT_SCIENCE

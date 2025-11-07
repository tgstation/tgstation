/datum/objective/blood_worm/proc/get_worm()
	if (istype(owner.current, /mob/living/basic/blood_worm))
		return owner.current
	if (!ishuman(owner.current))
		return null
	if (!HAS_TRAIT(owner.current, TRAIT_BLOOD_WORM_HOST))
		return null
	return locate(/mob/living/basic/blood_worm) in owner.current

/datum/objective/blood_worm/proc/get_host()
	if (ishuman(owner.current) && HAS_TRAIT(owner.current, TRAIT_BLOOD_WORM_HOST))
		return owner.current

	var/mob/living/basic/blood_worm/worm = get_worm()

	return worm?.host

/datum/objective/blood_worm/reach_adulthood
	name = "growth milestone"
	explanation_text = "Reach adulthood at least once."

/datum/objective/blood_worm/reach_adulthood/check_completion()
	if (completed)
		return TRUE

	var/datum/antagonist/blood_worm/antag_datum = owner.has_antag_datum(/datum/antagonist/blood_worm)

	return antag_datum?.has_reached_adulthood

/datum/objective/blood_worm/specific_host
	name = "target infiltration"
	explanation_text = "Survive until the end with the body of your target as your host."
	target_amount = 1

	var/datum/weakref/target_ref

/datum/objective/blood_worm/specific_host/check_completion()
	if (completed)
		return TRUE
	if (!target_ref)
		return TRUE

	var/target = target_ref.resolve()

	return target && target == get_host()

/datum/objective/blood_worm/specific_host/find_target(dupe_search_range, list/blacklist)
	. = ..()
	if (!.)
		return

	target_ref = WEAKREF(target.current)
	update_explanation_text()

/datum/objective/blood_worm/specific_host/is_valid_target(datum/mind/possible_target)
	return ..()

/datum/objective/blood_worm/specific_host/update_explanation_text()
	if (!target_ref)
		explanation_text = "Free objective."
	else
		var/mob/living/target_body = target_ref.resolve()
		explanation_text = "Survive until the end in the body of [target_body.real_name]."

/datum/objective/blood_worm/department_host
	name = "department infiltration"
	explanation_text = "Survive until the end with a member of the ERROR: CONTACT ADMINS department as your host."

	var/department_bitflag = NONE

/datum/objective/blood_worm/department_host/check_completion()
	if (completed)
		return TRUE

	var/mob/living/carbon/human/host = get_host()
	var/mob/living/basic/blood_worm/worm = get_worm()

	return host && (worm.backseat?.mind?.assigned_role?.departments_bitflags & department_bitflag)

/datum/objective/blood_worm/department_host/security
	name = "security infiltration"
	explanation_text = "Survive until the end with a member of the security department as your host."
	department_bitflag = DEPARTMENT_BITFLAG_SECURITY

/datum/objective/blood_worm/department_host/command
	name = "command infiltration"
	explanation_text = "Survive until the end with a member of station command as your host."
	department_bitflag = DEPARTMENT_BITFLAG_COMMAND

/datum/objective/blood_worm/infiltrate_centcom
	name = "freeform infiltration"
	explanation_text = "Infiltrate central command to further the reach of the blood worms."

/datum/objective/blood_worm/infiltrate_centcom/check_completion()
	if (completed)
		return TRUE

	var/mob/living/basic/blood_worm/worm = get_worm()

	return worm && worm.stat != DEAD && worm.onCentCom()

/datum/objective/blood_worm/infiltrate_centcom/host
	name = "stealthy infiltration"
	explanation_text = "Infiltrate central command while hidden within a host."

/datum/objective/blood_worm/infiltrate_centcom/check_completion()
	if (completed)
		return TRUE

	var/mob/living/carbon/human/host = get_host()

	return host && host.onCentCom()


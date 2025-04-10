/**
 * Checks if the target has antag datums and, if so,
 * are they allowed to be Vassalized, or not, or banned.
 * Args:
 * target - The person we check for antag datums.
 */
/datum/antagonist/bloodsucker/proc/AmValidAntag(mob/target)
	if(HAS_MIND_TRAIT(target, TRAIT_UNCONVERTABLE))
		return VASSALIZATION_BANNED

	var/vassalization_status = VASSALIZATION_ALLOWED
	for(var/datum/antagonist/antag_datum as anything in target.mind.antag_datums)
		if(antag_datum.type in vassal_banned_antags)
			return VASSALIZATION_BANNED
		vassalization_status = VASSALIZATION_DISLOYAL
	return vassalization_status

/**
 * # can_make_vassal
 * Checks if the person is allowed to turn into the Bloodsucker's
 * Vassal, ensuring they are a player and valid.
 * If they are a Vassal themselves, will check if their master
 * has broken the Masquerade, to steal them.
 * Args:
 * conversion_target - Person being vassalized
 */
/datum/antagonist/bloodsucker/proc/can_make_vassal(mob/living/conversion_target)
	if(!iscarbon(conversion_target))
		return FALSE
	// No Mind!
	if(!conversion_target.mind)
		to_chat(owner.current, span_danger("[conversion_target] isn't self-aware enough to be made into a vassal."))
		return FALSE
	if(AmValidAntag(conversion_target) == VASSALIZATION_BANNED)
		to_chat(owner.current, span_danger("[conversion_target] resists the power of your blood to dominate their mind!"))
		return FALSE
	var/mob/living/master = conversion_target.mind.enslaved_to?.resolve()
	if(!master || (master == owner.current))
		return TRUE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = master.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.broke_masquerade)
		//vassal stealing
		return TRUE
	to_chat(owner.current, span_danger("[conversion_target]'s mind is overwhelmed with too much external force to put your own!"))
	return FALSE

/**
 * First will check if the target can be turned into a Vassal, if so then it will
 * turn them into one, log it, sync their minds, then updates the Rank
 * Args:
 * conversion_target - The person converted.
 */
/datum/antagonist/bloodsucker/proc/make_vassal(mob/living/conversion_target)
	if(!can_make_vassal(conversion_target))
		return FALSE

	//Check if they used to be a Vassal and was stolen.
	var/datum/antagonist/vassal/old_vassal = conversion_target.mind.has_antag_datum(/datum/antagonist/vassal)
	if(old_vassal)
		conversion_target.mind.remove_antag_datum(/datum/antagonist/vassal)

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum.SelectTitle(am_fledgling = FALSE)

	//set the master, then give the datum.
	var/datum/antagonist/vassal/vassaldatum = new(conversion_target.mind)
	vassaldatum.master = bloodsuckerdatum
	conversion_target.mind.add_antag_datum(vassaldatum)

	message_admins("[conversion_target] has become a vassal, and is enslaved to [owner.current].")
	log_admin("[conversion_target] has become a vassal, and is enslaved to [owner.current].")
	return TRUE

/*
 *	# can_make_special
 *
 * MIND Helper proc that ensures the person can be a Special Vassal,
 * without actually giving the antag datum to them.
 * This is because Special Vassals get special abilities, without the unique Bloodsucker blood tracking,
 * and we don't want this to be infinite.
 * Args:
 * creator - Person attempting to convert them.
 */
/datum/mind/proc/can_make_special(datum/mind/creator)
	var/mob/living/user = current
	if(!(user.mob_biotypes & MOB_ORGANIC))
		if(creator)
			to_chat(creator, span_danger("[user]'s DNA isn't compatible!"))
		return FALSE
	return TRUE

/*
 *	# make_bloodsucker
 *
 * MIND Helper proc that turns the person into a Bloodsucker
 * Args:
 * creator - Person attempting to convert them.
 */
/datum/mind/proc/make_bloodsucker(datum/mind/creator)
	var/datum/antagonist/bloodsuckerdatum = add_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && creator)
		message_admins("[src] has become a Bloodsucker, and was created by [creator].")
		log_admin("[src] has become a Bloodsucker, and was created by [creator].")
	return bloodsuckerdatum

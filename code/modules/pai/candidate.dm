/**
 * #pAI Candidate
 *
 * Created when a user opens the pAI submit interface.
 * Stores the candidate in an associative list of ckey: candidate objects.
 */
/datum/pai_candidate
	/// User inputted OOC comments
	var/comments
	/// User inputted behavior description
	var/description
	/// User's ckey
	var/ckey
	/// User's pAI name. If blank, ninja name.
	var/name
	/// If the user has hit "submit"
	var/ready = FALSE

/datum/pai_candidate/New(ckey)
	src.ckey = ckey

/**
 * Checks if a candidate is ready so that they may be displayed or
 * downloaded. Removes any invalid entries.
 *
 * @returns {boolean} - TRUE if the candidate is ready, FALSE if not
 */
/datum/pai_candidate/proc/check_ready()
	var/mob/candidate_mob = get_mob_by_key(ckey)
	if(!candidate_mob?.client || !isobserver(candidate_mob) || is_banned_from(ckey, ROLE_PAI))
		SSpai.candidates -= ckey
		return FALSE
	if(!ready)
		return FALSE
	return TRUE

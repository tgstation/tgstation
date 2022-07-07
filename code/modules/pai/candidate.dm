/// Created when a user clicks the "pAI candidate" window
/datum/pai_candidate
	/// User inputted OOC comments
	var/comments
	/// User inputted behavior description
	var/description
	/// The candidate's mob
	var/mob/user
	/// User's ckey
	var/ckey
	/// User's pAI name. If blank, ninja name.
	var/name
	/// If the user has hit "submit"
	var/ready = FALSE

/datum/pai_candidate/New(mob/user)
	ckey = user.ckey
	user = user

/**
 * Checks if a candidate is ready so that they may be displayed in the pAI
 * card's candidate window
 */
/datum/pai_candidate/proc/check_ready()
	if(!ready)
		return FALSE
	if(!user || !GLOB.player_list[ckey] || !isobserver(user))
		if(SSpai.candidates[ckey])
			SSpai.candidates.Remove(ckey)
		return FALSE
	return TRUE


/**
 * # Vote Singleton
 *
 * A singleton datum that represents a type of vote for the voting subsystem.
 */
/datum/vote
	/// A list of default choices we have for this vote.
	var/list/default_choices

	/// An assoc list of [all choices] to [number of votes in the current running].
	/// Don't put the choices of your vote in this, put them in [default_choices]!
	var/list/choices

/datum/vote/proc/reset()
	choices = null

/datum/vote/proc/setup_choices()
	choices = list()
	for(var/key in default_choices)
		choices[key] = 0

/**
 * Used to determine if this vote is a possible
 * vote type for the vote subsystem.
 *
 * If FALSE is returned, this vote singleton
 * will not be created when the vote subsystem initializes,
 * meaning no one will be able to hold this vote.
 */
/datum/vote/proc/is_accessible_vote()
	return TRUE

/**
 * Checks if the passed client can initiate this vote.
 *
 * Return TRUE if the client can begin the vote,
 * allowing anyone to actually vote on it.
 * Return FALSE if the client cannot initiate the vote,
 * such as if the vote is admin only.
 */
/datum/vote/proc/can_be_initiated(client/by_who)
	return TRUE

/**
 * Gets any UI data related to this vote,
 * for the voting subsystem's vote UI.
 */
/datum/vote/proc/get_vote_ui_data()
	var/list/data = list()


	return data

/datum/vote/proc/initiate_vote()

/datum/vote/proc/get_result()

/datum/vote/proc/announce_result()

/datum/vote/proc/on_success()

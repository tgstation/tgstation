GLOBAL_LIST_EMPTY(ctf_voting_controllers)

/datum/ctf_voting_controller
	/// The list of ckeys that want to play CTF
	var/list/volunteers = list()

	var/game_id

/datum/ctf_voting_controller/New(game_id)
	src.game_id = game_id

/// Casts a vote in favor of CTF for user.
/datum/ctf_voting_controller/proc/vote(mob/user)
	if (user.ckey in volunteers)
		return

	volunteers += user.ckey

	var/volunteer_count = volunteers.len
	var/remaining = CTF_REQUIRED_PLAYERS - volunteer_count

	if (remaining <= 0)
		volunteers.Cut()
		toggle_id_ctf(activated_id = game_id)
	else
		to_chat(user, span_notice("CTF has been requested. [volunteer_count]/[CTF_REQUIRED_PLAYERS] have readied up."))

/// Removes an existing vote for user.
/datum/ctf_voting_controller/proc/unvote(mob/user)
	if (!(user.ckey in volunteers))
		return

	volunteers -= user.ckey
	to_chat(user, span_notice("Removed vote for CTF."))

/// Returns the existing [/datum/ctf_voting_controller] for the given ID, or makes one
/proc/get_ctf_voting_controller(game_id)
	RETURN_TYPE(/datum/ctf_voting_controller)

	var/datum/ctf_voting_controller/controller = GLOB.ctf_voting_controllers[game_id]
	if (isnull(controller))
		controller = new(game_id)
		GLOB.ctf_voting_controllers[game_id] = controller

	return controller

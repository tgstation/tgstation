/**
 * The contestant represents one player.
 */
/datum/contestant
	var/name
	/// The ckey we try to match with
	var/ckey
	/// How many rounds this contestant has participated in? Incremented when their team has [/datum/event_team/proc/match_result] called on it
	var/rounds_participated
	/// What team datum we're on right now
	var/datum/event_team/current_team
	/// If we've been marked for elimination
	var/flagged_for_elimination = FALSE
	/// If we've actually been eliminated
	var/eliminated = FALSE
	/// Set to TRUE with [/datum/contestant/proc/set_flag_on_death] if you want the contestant to be marked for elimination when their current living body dies (must be in body already)
	var/flagged_on_death = FALSE
	/// If TRUE, this contestant is supposed to be frozen (immobilized), and will be frozen if spawned in
	var/frozen = FALSE
	/// If TRUE, this contestant is supposed to be godmoded, and will be godmoded if spawned in
	var/godmode = FALSE

/datum/contestant/New(new_ckey)
	ckey = new_ckey
	name = ckey

	if(!get_mob_by_ckey(ckey))
		return

/datum/contestant/Destroy(force, ...)
	if(current_team)
		current_team.remove_member(src)
	. = ..()

/// Helper to return the current mob quickly
/datum/contestant/proc/get_mob()
	if(!ckey)
		return

	return get_mob_by_ckey(ckey)

/// If arg is TRUE, this contestant will be marked for elimination when their current body dies. If arg is FALSE, disables that
/datum/contestant/proc/set_flag_on_death(new_mode)
	if(flagged_on_death == new_mode)
		return

	flagged_on_death = new_mode
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(flagged_on_death)
		RegisterSignal(our_boy, COMSIG_LIVING_DEATH, .proc/on_flagged_death)
	else
		UnregisterSignal(our_boy, COMSIG_LIVING_DEATH)

/// If arg is TRUE, this contestant will be immobilized if they're currently alive, and set to immobilized when they spawn, set to FALSE to disable that
/datum/contestant/proc/set_frozen(new_mode)
	if(frozen == new_mode)
		return

	frozen = new_mode
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(frozen)
		ADD_TRAIT(our_boy, TRAIT_IMMOBILIZED, TRAIT_EVENT)
	else
		REMOVE_TRAIT(our_boy, TRAIT_IMMOBILIZED, TRAIT_EVENT)

/// If arg is TRUE, this contestant will be set for godmode if they're currently alive, and set to godmode when they spawn, set to FALSE to disable that
/datum/contestant/proc/set_godmode(new_mode)
	if(godmode == new_mode)
		return

	godmode = new_mode
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(godmode)
		our_boy.status_traits |= GODMODE
	else
		our_boy &= GODMODE

/// Set any effects that we need on the person, this is to be called after they've been put in their body
/datum/contestant/proc/on_spawn()
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(frozen)
		ADD_TRAIT(our_boy, TRAIT_IMMOBILIZED, TRAIT_EVENT)
	if(godmode)
		our_boy.status_flags |= GODMODE

/// If we die while we were listening for our death, mark us for elimination then stop listening
/datum/contestant/proc/on_flagged_death(datum/source)
	SIGNAL_HANDLER

	flagged_for_elimination = TRUE
	set_flag_on_death(FALSE)

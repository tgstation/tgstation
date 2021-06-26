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
	/// The antag hud we're currently joined on, so we can remember to unjoin it when we leave
	var/datum/atom_hud/antag/our_team_hud

/datum/contestant/New(new_ckey)
	ckey = new_ckey
	name = ckey

	if(!get_mob_by_ckey(ckey))
		return

/datum/contestant/Destroy(force, ...)
	if(current_team)
		current_team.remove_member(src)
	. = ..()

/// For helping things get back on track after some idiot deletes all the contestants mid-tournament
/datum/contestant/proc/dump_info()
	if(!ckey)
		return

	var/return_line = "CONTESTANT LINE| Ckey: [ckey] | Eliminated: [eliminated] | Flagged for Elimination: [flagged_for_elimination] | Rounds Participated: [rounds_participated] | Team: [current_team]"
	return return_line

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
/datum/contestant/proc/set_frozen(mob/user, new_mode)
	if(frozen == new_mode)
		return

	if(user)
		message_admins("[key_name_admin(user)] has [new_mode ? "FROZEN" : "UNFROZEN"] [src]!")
		log_game("[key_name_admin(user)] has [new_mode ? "FROZEN" : "UNFROZEN"] [src]!")

	frozen = new_mode
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(frozen)
		ADD_TRAIT(our_boy, TRAIT_IMMOBILIZED, TRAIT_EVENT)
	else
		REMOVE_TRAIT(our_boy, TRAIT_IMMOBILIZED, TRAIT_EVENT)

/// If arg is TRUE, this contestant will be set for godmode if they're currently alive, and set to godmode when they spawn, set to FALSE to disable that
/datum/contestant/proc/set_godmode(mob/user, new_mode)
	if(godmode == new_mode)
		return

	if(user)
		message_admins("[key_name_admin(user)] has [new_mode ? "GODMODED" : "UNGODMODED"] [src]!")
		log_game("[key_name_admin(user)] has [new_mode ? "GODMODED" : "UNGODMODED"] [src]!")

	godmode = new_mode
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(godmode)
		our_boy.status_flags |= GODMODE
	else
		our_boy.status_flags &= ~GODMODE

/// Spawn this guy in as a human at the appropriate spawnpoint. Returns TRUE if successful, so we can count off how many successfully spawn when needed
/datum/contestant/proc/spawn_this_contestant(obj/machinery/arena_spawn/spawnpoint)
	if(!istype(spawnpoint))
		CRASH("[src] cannot be spawned, no spawnpoint was provided")

	if(LAZYFIND(GLOB.global_roster.live_contestants, src))
		message_admins("[src] is already spawned??")
		//return

	var/mob/oldbody = get_mob()
	if(oldbody && !isobserver(oldbody))
		testing("Spawning in [ckey] even though already in body [oldbody]")
		//return

	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(spawnpoint))
	if(oldbody?.client) // debug testing with empty contestant datums
		oldbody.client.prefs.copy_to(M)
	if(!(M.dna?.species in list(/datum/species/human, /datum/species/moth, /datum/species/lizard, /datum/species/human/felinid)))
		M.set_species(/datum/species/human) // Could use setting per team
	M.equipOutfit(/datum/outfit/job/assistant) // TODO: ADD CONTROLS FOR THIS
	//M.equipOutfit(outfits[team] ? outfits[team] : default_outfit)
	//M.faction += team //In case anyone wants to add team based stuff to arena special effects
	M.key = ckey
	M.forceMove(get_turf(spawnpoint))
	LAZYADD(GLOB.global_roster.live_contestants, src)
	on_spawn()
	return TRUE

/// Set any extra effects that we need on the person, this is to be called after they've been put in their body
/datum/contestant/proc/on_spawn()
	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(frozen)
		ADD_TRAIT(our_boy, TRAIT_IMMOBILIZED, TRAIT_EVENT)
	if(godmode)
		our_boy.status_flags |= GODMODE

	if(!current_team || current_team.battle_royale)
		return

	if(!our_boy.mind) // only needed for empty contestant testing
		our_boy.mind_initialize()
	update_antag_hud()


/// This'll need to be hooked up to more things, this is the anti spawn_this_contestant proc to undo them being in the live contestants
/datum/contestant/proc/update_antag_hud()
	var/datum/roster/the_roster = GLOB.global_roster
	var/team_slot = the_roster.get_team_slot(current_team)

	var/mob/living/our_boy = get_mob()
	if(!istype(our_boy))
		return
	if(!team_slot)
		our_team_hud?.remove_from_hud(our_boy)
		return

	var/datum/atom_hud/antag/new_team_hud = the_roster.get_team_antag_hud(current_team)
	if(our_team_hud && our_team_hud != new_team_hud) // no need to update if they match, we're already good
		our_team_hud.leave_hud(our_boy)
	our_team_hud = new_team_hud
	if(!our_team_hud)
		return
	our_team_hud.join_hud(our_boy)
	set_antag_hud(our_boy,"arena",the_roster.team_hud_index[team_slot])

/// This'll need to be hooked up to more things, this is the anti spawn_this_contestant proc to undo them being in the live contestants
/datum/contestant/proc/despawn()
	LAZYREMOVE(GLOB.global_roster.live_contestants, src)

/// If we die while we were listening for our death, mark us for elimination then stop listening
/datum/contestant/proc/on_flagged_death(datum/source)
	SIGNAL_HANDLER

	flagged_for_elimination = TRUE
	set_flag_on_death(FALSE)

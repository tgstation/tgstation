// Allows for linking one mob's view to another
// Exists to make debugging stuff on live easier, please do not build gameplay around this it's not stable
// Mostly because we don't have setters for everything (like ui elements IE: client.screen)

// DEBUG ONLY, THIS IS  N O T  STABLE ENOUGH FOR PLAYERS
// Should potentially support images, might be too hard tho since there's no default "refresh" tool

// Convenience datum, not for use outside of this ui
/datum/visual_data
	/// Sight flags
	var/sight = NONE
	/// see_invisible values
	var/see_invis
	/// see_in_dark values
	var/see_dark
	/// What the client is seeing "out of", client.eye
	var/datum/weakref/client_eye
	/// Weakref to the mob we're mirroring off
	var/datum/weakref/mirroring_off_ref

	var/do_updates = FALSE

	// Note: we do not attempt to mirror all of screen, instead confining ourselves to mirroring
	// Plane master and parralax stuff and such
	// Again, this isn't stable

/datum/visual_data/proc/shadow(mob/mirror_off)
	do_updates = FALSE
	mirroring_off_ref = WEAKREF(mirror_off)
	RegisterSignal(mirror_off, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(sight_changed))
	sight_changed(mirror_off)
	RegisterSignal(mirror_off, COMSIG_MOB_SEE_INVIS_CHANGE, PROC_REF(invis_changed))
	invis_changed(mirror_off)
	RegisterSignal(mirror_off, COMSIG_MOB_SEE_IN_DARK_CHANGE, PROC_REF(in_dark_changed))
	in_dark_changed(mirror_off)
	RegisterSignal(mirror_off, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(mirror_off, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	if(mirror_off.client)
		on_login(mirror_off)
	do_updates = TRUE

/datum/visual_data/proc/paint_onto(mob/paint_to)
	// Note: we explicitly do NOT use setters here, since it would break the behavior
	paint_to.sight = sight
	paint_to.see_invisible = see_invis
	paint_to.see_in_dark = see_dark
	if(paint_to.client)
		var/atom/eye = client_eye?.resolve()
		if(eye)
			paint_to.client.eye = eye
		// This is hacky I know, I don't have a way to update just
		/// Plane masters. I'm sorry
		var/mob/mirroring_off = mirroring_off_ref?.resolve()
		if(mirroring_off?.client && paint_to != mirroring_off)
			paint_to.client.screen = mirroring_off.client.screen

/datum/visual_data/proc/on_update()
	return

/datum/visual_data/proc/sight_changed(mob/source)
	SIGNAL_HANDLER
	sight = source.sight
	on_update()

/datum/visual_data/proc/invis_changed(mob/source)
	SIGNAL_HANDLER
	see_invis = source.see_invisible
	on_update()

/datum/visual_data/proc/in_dark_changed(mob/source)
	SIGNAL_HANDLER
	see_dark = source.see_in_dark
	on_update()

/datum/visual_data/proc/on_login(mob/source)
	SIGNAL_HANDLER
	// visual data can be created off login, so conflicts here are inevitable
	// Best to just override
	RegisterSignal(source.client, COMSIG_CLIENT_SET_EYE, PROC_REF(eye_change), override = TRUE)
	set_eye(source.client.eye)

/datum/visual_data/proc/on_logout(mob/source)
	SIGNAL_HANDLER
	// Canon here because it'll be gone come the logout signal
	UnregisterSignal(source.canon_client, COMSIG_CLIENT_SET_EYE)
	// We do NOT unset the eye, because it's still valid even if the mob ain't logged in

/datum/visual_data/proc/eye_change(client/source)
	SIGNAL_HANDLER
	set_eye(source.eye)

/datum/visual_data/proc/set_eye(atom/new_eye)
	var/atom/old_eye = client_eye?.resolve()
	if(old_eye)
		UnregisterSignal(old_eye, COMSIG_PARENT_QDELETING)
	if(new_eye)
		// Need to update any party's client.eyes
		RegisterSignal(new_eye, COMSIG_PARENT_QDELETING, PROC_REF(eye_deleted))
	client_eye = WEAKREF(new_eye)
	on_update()

/datum/visual_data/proc/eye_deleted(datum/source)
	SIGNAL_HANDLER
	set_eye(null)

/// Tracks but does not relay updates to someone's visual data
/// Accepts a second visual data datum to use as a source of truth for the mob's values
/datum/visual_data/tracking
	/// Weakref to the visual data datum to reset our mob to
	var/datum/weakref/default_to_ref

/datum/visual_data/tracking/Destroy()
	var/mob/our_lad = mirroring_off_ref?.resolve()
	if(our_lad)
		// Reset our mob to his proper visuals
		paint_onto(our_lad)
	return ..()

/datum/visual_data/tracking/proc/set_truth(datum/visual_data/truth)
	default_to_ref = WEAKREF(truth)
	on_update()

/datum/visual_data/tracking/paint_onto(mob/paint_onto)
	. = ..()
	// Rebuild the passed in mob's screen, since we can't track it currently
	paint_onto.hud_used?.show_hud(paint_onto.hud_used.hud_version)

/datum/visual_data/tracking/on_update()
	var/mob/updated = mirroring_off_ref?.resolve()
	var/datum/visual_data/mirror = default_to_ref?.resolve()
	if(!updated || !mirror)
		return
	mirror.paint_onto(updated)

/// Tracks and updates another mob with our mob's visual data
/datum/visual_data/mirroring
	/// Weakref to what mob, if any, we should mirror our changes onto
	var/datum/weakref/mirror_onto_ref

/datum/visual_data/mirroring/proc/set_mirror_target(mob/target)
	var/mob/old_target = mirror_onto_ref?.resolve()
	if(old_target)
		UnregisterSignal(old_target, COMSIG_MOB_HUD_REFRESHED)
	mirror_onto_ref = WEAKREF(target)
	if(target)
		RegisterSignal(target, COMSIG_MOB_HUD_REFRESHED, PROC_REF(push_ontod_hud_refreshed))

/datum/visual_data/mirroring/proc/push_ontod_hud_refreshed(mob/source)
	SIGNAL_HANDLER
	// Our mob refreshed its hud, so we're gonna reset it to our screen
	// I hate that I don't have a signal for this, hhhh
	paint_onto(source)

/datum/visual_data/mirroring/on_update()
	var/mob/draw_onto = mirror_onto_ref?.resolve()
	if(!draw_onto)
		return
	paint_onto(draw_onto)

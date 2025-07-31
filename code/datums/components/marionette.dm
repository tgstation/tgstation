/**
 * Marionette component
 *
 * Upon being grabbed, we will align the direction of the parent with the direction of the grabber when they rotate.
 * While grabbed, will also speak out whatever the original person says
 */
/datum/component/marionette
	///Reference to the mob that is grabbing us, which we hook signals to for marionette stuff.
	var/mob/grabber

/datum/component/marionette/Destroy()
	if(grabber)
		UnregisterSignal(grabber, list(COMSIG_MOVABLE_KEYBIND_FACE_DIR, COMSIG_MOB_SAY, COMSIG_QDELETING))
	grabber = null
	return ..()

/datum/component/marionette/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_TRYING_TO_PULL, PROC_REF(on_pull))
	RegisterSignal(parent, COMSIG_ATOM_NO_LONGER_PULLED, PROC_REF(on_stop_pull))

/datum/component/marionette/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_LIVING_TRYING_TO_PULL,
		COMSIG_ATOM_NO_LONGER_PULLED,
	))
	return ..()

///Called when something starts pulling us, we now listen in to that thing for rotation.
/datum/component/marionette/proc/on_pull(atom/movable/source, atom/movable/puller, force)
	SIGNAL_HANDLER

	if(!puller || grabber == puller)
		return
	if(grabber)
		UnregisterSignal(grabber, list(COMSIG_MOVABLE_KEYBIND_FACE_DIR, COMSIG_MOB_SAY, COMSIG_QDELETING))
	grabber = puller
	RegisterSignal(grabber, COMSIG_MOVABLE_KEYBIND_FACE_DIR, PROC_REF(on_puller_turn))
	RegisterSignal(grabber, COMSIG_MOB_SAY, PROC_REF(on_puller_speech))
	RegisterSignal(grabber, COMSIG_QDELETING, PROC_REF(on_puller_qdel))

///Stopped pulling, we clear out signals and references.
/datum/component/marionette/proc/on_stop_pull(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER
	if(grabber)
		UnregisterSignal(grabber, list(COMSIG_MOVABLE_KEYBIND_FACE_DIR, COMSIG_MOB_SAY, COMSIG_QDELETING))
	grabber = null

///Callled when the person grabbin us turns, we rotate to match their direction.
/datum/component/marionette/proc/on_puller_turn(mob/living/source, direction)
	SIGNAL_HANDLER
	var/atom/movable/parent_movable = parent
	parent_movable.setDir(direction)

///Called when the person grabbing us speaks, we lower their volume to 1 tile and speak what they said through us.
/datum/component/marionette/proc/on_puller_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT(grabber, TRAIT_SIGN_LANG))
		return

	var/message = speech_args[SPEECH_MESSAGE]
	var/list/spans = speech_args[SPEECH_SPANS]
	var/language = speech_args[SPEECH_LANGUAGE]
	var/saymode = speech_args[SPEECH_SAYMODE]
	var/atom/movable/movable_parent = parent
	movable_parent.say(
		message = message,
		spans = spans.Copy(),
		language = language,
		forced = "[source]'s marionette",
		saymode = saymode,
		message_mods = list(MODE_RELAY = TRUE),
	)
	speech_args[SPEECH_RANGE] = WHISPER_RANGE

///Called when our puller is somehow deleted, we simply clear the reference to them.
/datum/component/marionette/proc/on_puller_qdel()
	SIGNAL_HANDLER

	grabber = null

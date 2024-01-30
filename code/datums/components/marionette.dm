/**
 * Marionette component
 *
 * Upon being grabbed, we will align the direction of the parent with the direction of the grabber when they rotate.
 */
/datum/component/marionette
	/// Weakref to a person grabbing the owner of the component, which we align our direction to.
	var/datum/weakref/grabbing_ref

/datum/component/marionette/Destroy()
	var/mob/living/grabber = grabbing_ref?.resolve()
	if(grabbing_ref)
		UnregisterSignal(grabber, list(COMSIG_MOVABLE_KEYBIND_FACE_DIR, COMSIG_LIVING_TRY_SPEECH))
	grabbing_ref = null
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

	if(!puller)
		return
	grabbing_ref = WEAKREF(puller)
	RegisterSignal(puller, COMSIG_MOVABLE_KEYBIND_FACE_DIR, PROC_REF(on_puller_turn))
	RegisterSignal(puller, COMSIG_LIVING_TRY_SPEECH, PROC_REF(on_puller_speech))

///Stopped pulling, we clear out signals and references.
/datum/component/marionette/proc/on_stop_pull(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER
	var/mob/living/grabber = grabbing_ref?.resolve()
	if(grabber)
		UnregisterSignal(grabber, list(COMSIG_MOVABLE_KEYBIND_FACE_DIR, COMSIG_LIVING_TRY_SPEECH))
	grabbing_ref = null

///Called when the driver turns with the movement lock key, we rotate as well.
/datum/component/marionette/proc/on_puller_turn(mob/living/source, direction)
	SIGNAL_HANDLER
	var/atom/movable/parent_movable = parent
	parent_movable.dir = direction

///Called when the driver turns with the movement lock key, we rotate as well.
/datum/component/marionette/proc/on_puller_speech(mob/living/source, message, ignore_spam, forced)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	movable_parent.say(message)
	return COMPONENT_CANNOT_SPEAK

/**
 * ### Sticker component
 *
 * Component that draws supplied atom's icon over parent object with specified offset,
 * icon centering is handled inside.
 */
/datum/component/sticker
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// Either `turf` or `null`, used to connect to `COMSIG_TURF_EXPOSE` signal when parent is a turf.
	var/turf/listening_turf
	/// Refernce to a "stickered" atom.
	var/atom/movable/our_sticker
	/// Reference to the created overlay, used during component deletion.
	var/mutable_appearance/sticker_overlay
	/// Callback invoked when sticker is applied to the parent.
	var/datum/callback/stick_callback
	/// Callback invoked when sticker is peeled (not removed) from the parent.
	var/datum/callback/peel_callback
	/// Text added to the atom's examine when stickered.
	var/examine_text

/datum/component/sticker/Initialize(atom/stickering_atom, dir = NORTH, px = 0, py = 0, datum/callback/stick_callback, datum/callback/peel_callback, examine_text)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.our_sticker = our_sticker
	src.stick_callback = stick_callback
	src.peel_callback = peel_callback
	src.examine_text = examine_text
	stick(stickering_atom, px, py)
	register_turf_signals(dir)

/datum/component/sticker/Destroy(force)
	var/atom/parent_atom = parent
	parent_atom.cut_overlay(sticker_overlay)

	unregister_turf_signals()

	REMOVE_TRAIT(parent, TRAIT_STICKERED, REF(src))

	our_sticker = null
	sticker_overlay = null
	stick_callback = null
	peel_callback = null
	return ..()

/datum/component/sticker/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/sticker/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_IGNITED, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_ATOM_EXAMINE))

/// Subscribes to `COMSIG_TURF_EXPOSE` if parent atom is a turf. If turf is closed - subscribes to signal
/datum/component/sticker/proc/register_turf_signals(dir)
	if(!isturf(parent))
		return

	listening_turf = isclosedturf(parent) ? get_step(parent, dir) : parent
	RegisterSignal(listening_turf, COMSIG_TURF_EXPOSE, PROC_REF(on_turf_expose))

/// Unsubscribes from `COMSIG_TURF_EXPOSE` if `listening_turf` is not `null`.
/datum/component/sticker/proc/unregister_turf_signals()
	if(isnull(listening_turf))
		return

	UnregisterSignal(listening_turf, COMSIG_TURF_EXPOSE)

/datum/component/sticker/proc/sticker_gone(...)
	SIGNAL_HANDLER

	UnregisterSignal(our_sticker, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	our_sticker = null
	qdel(src)

/// Handles overlay creation from supplied atom, adds created icon to the parent object, moves source atom to the nullspace.
/datum/component/sticker/proc/stick(atom/movable/stickering_atom, px, py)
	our_sticker = stickering_atom
	our_sticker.moveToNullspace()
	RegisterSignals(our_sticker, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(sticker_gone))

	var/atom/parent_atom = parent

	sticker_overlay = mutable_appearance(icon = our_sticker.icon, icon_state = our_sticker.icon_state, layer = parent_atom.layer + 0.01, appearance_flags = RESET_COLOR)
	sticker_overlay.pixel_w = px - ICON_SIZE_X / 2
	sticker_overlay.pixel_z = py - ICON_SIZE_Y / 2

	parent_atom.add_overlay(sticker_overlay)
	stick_callback?.Invoke(parent)
	ADD_TRAIT(parent, TRAIT_STICKERED, REF(src))

/// Moves stickered atom from the nullspace, deletes component.
/datum/component/sticker/proc/peel()
	var/atom/parent_atom = parent
	var/turf/drop_location = listening_turf || parent_atom.drop_location()

	UnregisterSignal(our_sticker, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	our_sticker.forceMove(drop_location)
	our_sticker = null
	peel_callback?.Invoke(parent)

	qdel(src)

/datum/component/sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER

	qdel(our_sticker) // which qdels us

/datum/component/sticker/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	peel()

	return COMPONENT_CLEANED

/datum/component/sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER

	if(exposed_temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		qdel(our_sticker) // which qdels us

/datum/component/sticker/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!isnull(examine_text))
		examine_list += span_warning(examine_text)

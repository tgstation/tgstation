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

/datum/component/sticker/Initialize(atom/stickering_atom, mob/user, dir = NORTH, px = 0, py = 0)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.our_sticker = our_sticker

	if(isliving(parent) && !isnull(user))
		var/mob/living/victim = parent

		if(!isnull(victim.client))
			user.log_message("stuck [stickering_atom] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [stickering_atom] stuck to them by [key_name(user)]", LOG_ATTACK)

	stick(stickering_atom, px, py)
	register_turf_signals(dir)

/datum/component/sticker/Destroy(force)
	var/atom/parent_atom = parent
	parent_atom.cut_overlay(sticker_overlay)

	unregister_turf_signals()

	REMOVE_TRAIT(parent, TRAIT_STICKERED, REF(src))

	QDEL_NULL(our_sticker)
	QDEL_NULL(sticker_overlay)
	return ..()

/datum/component/sticker/RegisterWithParent()
	if(isliving(parent))
		RegisterSignal(parent, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/sticker/UnregisterFromParent()
	if(isliving(parent))
		UnregisterSignal(parent, COMSIG_LIVING_IGNITED)
	UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)

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

/// Handles overlay creation from supplied atom, adds created icon to the parent object, moves source atom to the nullspace.
/datum/component/sticker/proc/stick(atom/movable/stickering_atom, px, py)
	our_sticker = stickering_atom
	our_sticker.moveToNullspace()

	var/atom/parent_atom = parent

	sticker_overlay = mutable_appearance(icon = our_sticker.icon, icon_state = our_sticker.icon_state, layer = parent_atom.layer + 0.01, appearance_flags = RESET_COLOR)
	sticker_overlay.pixel_w = px - world.icon_size / 2
	sticker_overlay.pixel_z = py - world.icon_size / 2

	parent_atom.add_overlay(sticker_overlay)

	ADD_TRAIT(parent, TRAIT_STICKERED, REF(src))

/// Moves stickered atom from the nullspace, deletes component.
/datum/component/sticker/proc/peel()
	var/atom/parent_atom = parent
	var/turf/drop_location = isnull(listening_turf) ? parent_atom.drop_location() : listening_turf

	our_sticker.forceMove(drop_location)
	our_sticker = null

	qdel(src)

/datum/component/sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/component/sticker/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	peel()

	return COMPONENT_CLEANED

/datum/component/sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER

	if(exposed_temperature >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		qdel(src)

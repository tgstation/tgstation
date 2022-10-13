/**
 * # Secluded Atom Element
 *
 * This atom is secluded. When other atoms enter us they should react accordingly,
 * as they are now unreachable as far as the game world is concerned
 */
/datum/element/secluded_atom

/datum/element/secluded_atom/Attach(datum/target)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/atom_target = target

	RegisterSignal(target, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), .proc/on_atom_entered_seclusion)
	for(var/existing_atom in atom_target)
		on_atom_entered_seclusion(target, existing_atom)

/datum/element/secluded_atom/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON))

/datum/element/secluded_atom/proc/on_atom_entered_seclusion(atom/source, atom/entering_seclusion)
	SIGNAL_HANDLER

	// When an atom enters our atom, they have officially become secluded.
	// Send a signal to the mob that this has occured.
	SEND_SIGNAL(entering_seclusion, COMSIG_MOVABLE_SECLUDED_LOCATION)

/**
 * # Secluded Atom Loc Element
 *
 * This element handles making their loc (usually, a turf) secluded.
 * Useful for big atoms which make their turf uncreachable, such as multitile structures.
 */
/datum/element/secluded_atom_loc
	element_flags = ELEMENT_DETACH // handles if our movable is deleted

/datum/element/secluded_atom_loc/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/movable/movable_target = target

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_movable_relocated)
	movable_target.loc?.AddElement(/datum/element/secluded_atom)

/datum/element/secluded_atom_loc/Detach(atom/movable/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	source.loc?.RemoveElement(/datum/element/secluded_atom)

/datum/element/secluded_atom_loc/proc/on_movable_relocated(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER

	old_loc.RemoveElement(/datum/element/secluded_atom)
	source.loc?.AddElement(/datum/element/secluded_atom)

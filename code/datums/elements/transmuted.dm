/**
 * Marks an atom as having been transmuted and block attempts to retrieve the materials from the atom.
 */
/datum/element/transmuted
	element_flags = ELEMENT_DETACH

/datum/element/transmuted/Attach(datum/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	if(. & ELEMENT_INCOMPATIBLE)
		return

	RegisterSignal(target, COMSIG_ATOM_GET_MAT_COMP, .proc/block_recycling, TRUE)

/datum/element/transmuted/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_ATOM_GET_MAT_COMP)
	return ..()

/datum/element/transmuted/proc/block_recycling(atom/source, breakdown_flags, list/mat_comp)
	SIGNAL_HANDLER
	return (breakdown_flags & BREAKDOWN_INCLUDE_ALCHEMY) ? NONE : COMPONENT_OVERRIDE_MAT_COMP

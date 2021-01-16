/**
 * Applies an emissive blocker vis overlay to the target atom and re-applies it whenever the atom updates its vis overlays
 *
 * Used to make emissive blockers compatible with structures that mess with their vis overlays
 * If this isn't handled neon carpets start glowing through vending machines and computer consoles
 */
/datum/element/emissive_blocker
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// The plane used
	var/blocker_plane

/datum/element/emissive_blocker/Attach(atom/target, plane)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!isnum(plane))
		stack_trace("Invalid plane value passed to emissive blocker element")
		return ELEMENT_INCOMPATIBLE

	blocker_plane = plane
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/update_blocker)
	update_blocker(target, null)
	return ..()

/datum/element/emissive_blocker/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	return ..()

/// Re-applies the emissive blocker vis overlay
/datum/element/emissive_blocker/proc/update_blocker(atom/source, list/overlays)
	SIGNAL_HANDLER
	SSvis_overlays.add_vis_overlay(source, source.icon, source.icon_state, EMISSIVE_LAYER, blocker_plane, source.dir)
	return NONE

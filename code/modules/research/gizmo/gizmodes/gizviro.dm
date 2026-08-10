// Releasing the cloud of smoke.. with Gizmo virus
// Unique Gizmo Virus - with variations.
// Currently its limited with Delta and Alpha names, but also names can be randomly generated from the words of the.. gizmo machine naming? Insane
/datum/gizmodes/gizmo_virus
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/gizmo_virus/unique_gizmo_virus,
	)

/datum/gizpulse/gizmo_virus/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	release_gizmo_virus()

/datum/gizpulse/gizmo_virus/proc/release_gizmo_virus(atom/movable/holder)

/datum/gizpulse/gizmo_virus/unique_gizmo_virus
	// here the holder for unique gizmo virus, gizmo virus itself needs to be done
	// virus = ...

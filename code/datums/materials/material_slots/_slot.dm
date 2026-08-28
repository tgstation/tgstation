/// Singleton datum which controls how materials affect atoms they're applied to
/datum/material_slot
	abstract_type = /datum/material_slot
	/// Name of the slot for autolathe UI
	var/name = "error"
	/// Material requirement type which controls what materials can be used to fill this slot when printing an item
	var/datum/material_requirement/requirement_type = null
	/// Relative amount of material in this slot for when multiple slots are filled with a single material
	var/material_amount = 1

/// Called when the material in this slot is applied to the atom. Return FALSE to prevent base apply_single_mat_effect from running.
/// If the material is main, main material application will also be cancelled. Should be consistent with on_removed.
/datum/material_slot/proc/on_applied(atom/target, datum/material/material, amount, multiplier)
	return TRUE

/// Called when the material in this slot is removed from the atom. Return FALSE to prevent base remove_single_mat_effect from running.
/// If the material is main, main material removal will also be cancelled. Should be consistent with on_applied.
/datum/material_slot/proc/on_removed(atom/target, datum/material/material, amount, multiplier)
	return TRUE

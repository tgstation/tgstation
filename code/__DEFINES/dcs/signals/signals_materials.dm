/// from base of [/datum/materials_controller/proc/initialize_material]: (/datum/material)
#define COMSIG_MATERIALS_INIT_MAT "SSmaterials_init_mat"
/// from /datum/material/proc/on_applied(source, mat_amount, multiplier): (atom/new_atom, mat_amount, multiplier)
#define COMSIG_MATERIAL_APPLIED "material_applied"
/// from /datum/material/proc/on_main_applied(source, mat_amount, multiplier): (atom/new_atom, mat_amount, multiplier)
#define COMSIG_MATERIAL_MAIN_APPLIED "material_main_applied"
/// from /datum/material/proc/on_removed(source, mat_amount, multiplier): (atom/old_atom, amount, material_flags)
#define COMSIG_MATERIAL_REMOVED "material_removed"
/// from /datum/material/proc/on_main_removed(source, mat_amount, multiplier): (atom/old_atom, mat_amount, multiplier)
#define COMSIG_MATERIAL_MAIN_REMOVED "material_main_removed"

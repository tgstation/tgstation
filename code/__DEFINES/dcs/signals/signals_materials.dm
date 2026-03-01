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

// Material property effect triggers
/// When a material comes into active contact with an atom (such as hitting it): (datum/material/source, atom/object, atom/target, mob/living/user, def_zone, skin_contact)
/// skin_contact determines if there was direct contact if it was a mob who was affected
#define COMSIG_MATERIAL_EFFECT_CONTACT "material_effect_contact"

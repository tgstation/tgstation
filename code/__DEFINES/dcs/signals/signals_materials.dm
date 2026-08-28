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
/// When a material is touched by an atom: (datum/material/source, atom/object, atom/target, mob/living/initiator, def_zone, skin_contact)
#define COMSIG_MATERIAL_EFFECT_TOUCH "material_effect_touch"
/// When a material is stepped onto: (datum/material/source, atom/object, atom/target, mob/living/initiator, def_zone, skin_contact)
#define COMSIG_MATERIAL_EFFECT_STEP "material_effect_step"
/// When a material hits something: (datum/material/source, atom/object, atom/target, mob/living/user, def_zone, skin_contact)
#define COMSIG_MATERIAL_EFFECT_HIT "material_effect_hit"
/// When a material hits something when thrown: (datum/material/source, atom/object, atom/target, mob/living/thrower, def_zone, skin_contact)
#define COMSIG_MATERIAL_EFFECT_THROW_IMPACT "material_effect_throw_impact"

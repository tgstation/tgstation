// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/expose_reagents(): (/list, /datum/reagents, methods, volume_modifier, show_message)
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
	/// Prevents the atom from being exposed to reagents if returned on [COMSIG_ATOM_EXPOSE_REAGENTS]
	#define COMPONENT_NO_EXPOSE_REAGENTS (1<<0)
///from base of [/datum/reagent/proc/expose_atom]: (/datum/reagent, reac_volume)
#define COMSIG_ATOM_EXPOSE_REAGENT "atom_expose_reagent"
///from base of [/datum/reagent/proc/expose_atom]: (/atom, reac_volume)
#define COMSIG_REAGENT_EXPOSE_ATOM "reagent_expose_atom"
///from base of [/datum/reagent/proc/expose_atom]: (/obj, reac_volume, methods, show_message)
#define COMSIG_REAGENT_EXPOSE_OBJ "reagent_expose_obj"
///from base of [/datum/reagent/proc/expose_atom]: (/mob/living, reac_volume, methods, show_message, touch_protection, /mob/eye/blob) // ovemind arg is only used by blob reagents.
#define COMSIG_REAGENT_EXPOSE_MOB "reagent_expose_mob"
///from base of [/datum/reagent/proc/expose_atom]: (/turf, reac_volume)
#define COMSIG_REAGENT_EXPOSE_TURF "reagent_expose_turf"
///from base of [/datum/reagent/proc/on_merge(data, amount)]: (list/data, amount)
#define COMSIG_REAGENT_ON_MERGE "reagent_on_merge"
///from base of [/datum/reagent/proc/on_transfer_creation(reagent, target_holder, new_reagent)]: (datum/reagents/target_holder, datum/reagent/new_reagent)
#define COMSIG_REAGENT_ON_TRANSFER "reagent_on_transfer"

///from base of [/datum/materials_controller/proc/InitializeMaterial]: (/datum/material)
#define COMSIG_MATERIALS_INIT_MAT "SSmaterials_init_mat"

///from base of [/datum/component/multiple_lives/proc/respawn]: (mob/respawned_mob, gibbed, lives_left)
#define COMSIG_ON_MULTIPLE_LIVES_RESPAWN "on_multiple_lives_respawn"

///from base of [/datum/reagents/proc/update_total()]
#define COMSIG_REAGENTS_HOLDER_UPDATED "reagents_update_total"
///from base of [/datum/reagents/proc/set_temperature]: (new_temp, old_temp)
#define COMSIG_REAGENTS_TEMP_CHANGE "reagents_temp_change"
///from base of [/datum/reagents/proc/process]: (num_reactions)
#define COMSIG_REAGENTS_REACTION_STEP "reagents_time_step"

///from base of [/obj/proc/expose_reagents]: (/obj, /list, methods, volume_modifier, show_message)
#define COMSIG_REAGENTS_EXPOSE_OBJ "reagents_expose_obj"
///from base of [/mob/living/proc/expose_reagents]: (/mob/living, /list, methods, volume_modifier, show_message, touch_protection)
#define COMSIG_REAGENTS_EXPOSE_MOB "reagents_expose_mob"
///from base of [/turf/proc/expose_reagents]: (/turf, /list, methods, volume_modifier, show_message)
#define COMSIG_REAGENTS_EXPOSE_TURF "reagents_expose_turf"
/// sent when reagents are transfered from a cup, to something refillable (atom/transfer_to)
#define COMSIG_REAGENTS_CUP_TRANSFER_TO "reagents_cup_transfer_to"
/// sent when reagents are transfered from some reagent container, to a cup (atom/transfer_from)
#define COMSIG_REAGENTS_CUP_TRANSFER_FROM "reagents_cup_transfer_from"

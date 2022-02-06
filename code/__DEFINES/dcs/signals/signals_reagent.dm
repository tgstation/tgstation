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
///from base of [/datum/reagent/proc/expose_atom]: (/obj, reac_volume)
#define COMSIG_REAGENT_EXPOSE_OBJ "reagent_expose_obj"
///from base of [/datum/reagent/proc/expose_atom]: (/mob/living, reac_volume, methods, show_message, touch_protection, /mob/camera/blob) // ovemind arg is only used by blob reagents.
#define COMSIG_REAGENT_EXPOSE_MOB "reagent_expose_mob"
///from base of [/datum/reagent/proc/expose_atom]: (/turf, reac_volume)
#define COMSIG_REAGENT_EXPOSE_TURF "reagent_expose_turf"

///from base of [/datum/controller/subsystem/materials/proc/InitializeMaterial]: (/datum/material)
#define COMSIG_MATERIALS_INIT_MAT "SSmaterials_init_mat"

///from base of [/datum/component/multiple_lives/proc/respawn]: (mob/respawned_mob, gibbed, lives_left)
#define COMSIG_ON_MULTIPLE_LIVES_RESPAWN "on_multiple_lives_respawn"

///from base of [/datum/reagents/proc/add_reagent] - Sent before the reagent is added: (reagenttype, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_PRE_ADD_REAGENT "reagents_pre_add_reagent"
	/// Prevents the reagent from being added.
	#define COMPONENT_CANCEL_REAGENT_ADD (1<<0)
///from base of [/datum/reagents/proc/add_reagent]: (/datum/reagent, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_NEW_REAGENT "reagents_new_reagent"
///from base of [/datum/reagents/proc/add_reagent]: (/datum/reagent, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_ADD_REAGENT "reagents_add_reagent"
///from base of [/datum/reagents/proc/del_reagent]: (/datum/reagent)
#define COMSIG_REAGENTS_DEL_REAGENT "reagents_del_reagent"
///from base of [/datum/reagents/proc/remove_reagent]: (/datum/reagent, amount)
#define COMSIG_REAGENTS_REM_REAGENT "reagents_rem_reagent"
///from base of [/datum/reagents/proc/clear_reagents]: ()
#define COMSIG_REAGENTS_CLEAR_REAGENTS "reagents_clear_reagents"
///from base of [/datum/reagents/proc/set_temperature]: (new_temp, old_temp)
#define COMSIG_REAGENTS_TEMP_CHANGE "reagents_temp_change"
///from base of [/datum/reagents/proc/handle_reactions]: (num_reactions)
#define COMSIG_REAGENTS_REACTED "reagents_reacted"
///from base of [/datum/reagents/proc/process]: (num_reactions)
#define COMSIG_REAGENTS_REACTION_STEP "reagents_time_step"
///from base of [/atom/proc/expose_reagents]: (/atom, /list, methods, volume_modifier, show_message)
#define COMSIG_REAGENTS_EXPOSE_ATOM "reagents_expose_atom"
///from base of [/obj/proc/expose_reagents]: (/obj, /list, methods, volume_modifier, show_message)
#define COMSIG_REAGENTS_EXPOSE_OBJ "reagents_expose_obj"
///from base of [/mob/living/proc/expose_reagents]: (/mob/living, /list, methods, volume_modifier, show_message, touch_protection)
#define COMSIG_REAGENTS_EXPOSE_MOB "reagents_expose_mob"
///from base of [/turf/proc/expose_reagents]: (/turf, /list, methods, volume_modifier, show_message)
#define COMSIG_REAGENTS_EXPOSE_TURF "reagents_expose_turf"
///from base of [/datum/component/personal_crafting/proc/del_reqs]: ()
#define COMSIG_REAGENTS_CRAFTING_PING "reagents_crafting_ping"

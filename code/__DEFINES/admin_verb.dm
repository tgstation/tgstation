/client/CanProcCall(procname)
	if(findtext(procname, "__avd_") == 1)
		message_admins("[key_name_admin(usr)] attempted to directly call admin verb '[procname]'.")
		log_admin("[key_name(usr)] attempted to directly call admin verb '[procname]'.")
		return FALSE
	return ..()

/**
 * This is the only macro you should use to define admin verbs.
 * It will define the verb and the verb holder for you.
 * Using it is very simple:
 *  ADMIN_VERB(verb_path, R_PERM, "Name", "Description", "Admin.Category")
 * This sets up all of the above and also acts as syntatic sugar as a verb delcaration for the verb itself.
 * Note that the verb args have an injected `client/user` argument that is the user that called the verb.
 * Do not use usr in your verb; technically you can but I'll kill you.
 *
 * Verb arguments are declared in the proc body via VERB_ARG macros which self-register metadata
 * at world init and extract values from the structured_args list at runtime.
 */
#define _ADMIN_VERB(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category, show_in_context_menu) \
/datum/admin_verb/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	permissions = ##verb_permissions; \
	verb_path = /client/proc/__avd_##verb_path_name; \
}; \
/client/proc/__avd_##verb_path_name() \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = FALSE; /* this is explicitly needed as the proc begins with an underscore */ \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/##verb_path_name); \
}; \
/datum/admin_verb/##verb_path_name/__avd_do_verb(client/user, list/structured_args)

#define _ADMIN_VERB_CONTEXT(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category, context_type) \
/datum/admin_verb/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	permissions = ##verb_permissions; \
	verb_path = /client/proc/__avd_##verb_path_name; \
}; \
/client/proc/__avd_##verb_path_name(UNLINT(var##context_type/__context_target in world)) /* UNLINT as SpacemanDMM (correctly) notes that var/ is redundant, however, we use it to make the verb parameter look like a typepath for user clarity */ \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = FALSE; \
	set popup_menu = TRUE; \
	set category = ##verb_category; \
	SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/##verb_path_name, list("__context_target__" = __context_target)); \
}; \
/datum/admin_verb/##verb_path_name/__avd_do_verb(client/user, list/structured_args)

#define ADMIN_VERB(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category) \
_ADMIN_VERB(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category, FALSE)

#define ADMIN_VERB_ONLY_CONTEXT_MENU(verb_path_name, verb_permissions, verb_name, context_type) \
_ADMIN_VERB_CONTEXT(verb_path_name, verb_permissions, verb_name, ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, context_type)

#define ADMIN_VERB_AND_CONTEXT_MENU(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category, context_type) \
_ADMIN_VERB_CONTEXT(verb_path_name, verb_permissions, verb_name, verb_desc, verb_category, context_type)

/// Used to define a special check to determine if the admin verb should exist at all. Useful for verbs such as play sound which require configuration.
#define ADMIN_VERB_CUSTOM_EXIST_CHECK(verb_path_name) \
/datum/admin_verb/##verb_path_name/__avd_check_should_exist()

/// Used to define the visibility flag of the verb. If the admin does not have this flag enabled they will not see the verb.
#define ADMIN_VERB_VISIBILITY(verb_path_name, verb_visibility) /datum/admin_verb/##verb_path_name/visibility_flag = ##verb_visibility

// These are put here to prevent the "procedure override precedes definition" error.
/datum/admin_verb/proc/__avd_get_verb_path()
	CRASH("__avd_get_verb_path not defined. use the macro")
/datum/admin_verb/proc/__avd_do_verb(...)
	CRASH("__avd_do_verb not defined. use the macro")
/datum/admin_verb/proc/__avd_check_should_exist()
	return TRUE

/*
 * This is an example of how to use the above macro:
 * ```
 * ADMIN_VERB(name_of_verb, R_ADMIN, "Verb Name", "Verb Desc", "Verb Category")
 *     VERB_ARG(target, VERB_ARG_TYPE_MOB, VERB_ARG_SOURCE_WORLD, /mob)
 *     to_chat(user, "Hello [target]!")
 * ```
 * Note the implied `client/user` argument that is injected into the verb.
 * Also note that byond is shit and you cannot multi-line the macro call.
 */

/// Use this to mark your verb as not having a description. Should ONLY be used if you are also hiding the verb!
#define ADMIN_VERB_NO_DESCRIPTION ""
/// Used to verbs you do not want to show up in the master verb panel.
#define ADMIN_CATEGORY_HIDDEN null

// Admin verb categories
#define ADMIN_CATEGORY_PLAYERS "Players"
#define ADMIN_CATEGORY_COMMUNICATION "Communication"
#define ADMIN_CATEGORY_FUN "Fun"
#define ADMIN_CATEGORY_EVENTS "Events"
#define ADMIN_CATEGORY_SPAWNING "Spawning"
#define ADMIN_CATEGORY_SHUTTLE "Shuttle"
#define ADMIN_CATEGORY_SERVER "Server"
#define ADMIN_CATEGORY_MAPPING "Mapping"
#define ADMIN_CATEGORY_DEBUG "Debug"
#define ADMIN_CATEGORY_PROFILE "Profile"
#define ADMIN_CATEGORY_IPINTEL "IPIntel"

// Legacy aliases — use the new names above for new verbs
#define ADMIN_CATEGORY_MAIN ADMIN_CATEGORY_PLAYERS
#define ADMIN_CATEGORY_GAME ADMIN_CATEGORY_PLAYERS

// Visibility flags
#define ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG "Map-Debug"
#define ADMIN_VERB_VISIBLITY_FLAG_LOCALHOST "Localhost"

// Legacy aliases for admin verb arg types — use VERB_ARG_TYPE_* and VERB_ARG_SOURCE_* for new code
#define ADMIN_VERB_ARG_TYPE_TEXT VERB_ARG_TYPE_TEXT
#define ADMIN_VERB_ARG_TYPE_NUM VERB_ARG_TYPE_NUM
#define ADMIN_VERB_ARG_TYPE_MESSAGE VERB_ARG_TYPE_MESSAGE
#define ADMIN_VERB_ARG_TYPE_SOUND VERB_ARG_TYPE_SOUND
#define ADMIN_VERB_ARG_TYPE_ICON VERB_ARG_TYPE_ICON
#define ADMIN_VERB_ARG_TYPE_MOB VERB_ARG_TYPE_MOB
#define ADMIN_VERB_ARG_TYPE_OBJ VERB_ARG_TYPE_OBJ
#define ADMIN_VERB_ARG_TYPE_TURF VERB_ARG_TYPE_TURF
#define ADMIN_VERB_ARG_TYPE_AREA VERB_ARG_TYPE_AREA
#define ADMIN_VERB_ARG_TYPE_DATUM VERB_ARG_TYPE_DATUM
#define ADMIN_VERB_ARG_TYPE_ATOM VERB_ARG_TYPE_ATOM
#define ADMIN_VERB_ARG_SOURCE_INPUT VERB_ARG_SOURCE_INPUT
#define ADMIN_VERB_ARG_SOURCE_WORLD VERB_ARG_SOURCE_WORLD
#define ADMIN_VERB_ARG_SOURCE_VIEW VERB_ARG_SOURCE_VIEW

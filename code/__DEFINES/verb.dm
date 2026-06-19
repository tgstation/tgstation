/**
 * Defines a game verb with an associated /datum/verb_metadata.
 *
 * Usage:
 *   GAME_VERB(/client, ooc, "OOC", "Send a message in OOC.", "OOC", msg as text)
 *       // verb body
 */

#define _GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, is_instant, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(##verb_args) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##is_hidden; \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	set instant = ##is_instant; \
	__gvb_##verb_path_name(arglist(args)); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, FALSE, ##verb_args)

#define GAME_VERB_DESC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, FALSE, ##verb_args)

#define GAME_VERB_HIDDEN(owner_type, verb_path_name, verb_name, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", null, FALSE, TRUE, FALSE, ##verb_args)

#define GAME_VERB_HIDDEN_INSTANT(owner_type, verb_path_name, verb_name, verb_args...) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", null, FALSE, TRUE, TRUE, ##verb_args)

#define _GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/proc/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/proc/##verb_path_name(##verb_args) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##is_hidden; \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	__gvb_##verb_path_name(arglist(args)); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB_PROC(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, ##verb_args)

#define GAME_VERB_PROC_DESC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, ##verb_args)

#define _GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(##verb_args) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##is_hidden; \
	set popup_menu = ##show_in_context_menu; \
	set category = ##verb_category; \
	set src in src_value; \
	__gvb_##verb_path_name(arglist(args)); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_category, verb_args...) \
_GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, "", verb_category, TRUE, FALSE, ##verb_args)

#define GAME_VERB_SRC_DESC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, TRUE, FALSE, ##verb_args)

#define _GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, is_hidden, verb_args...) \
/datum/verb_metadata/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = /proc/##verb_path_name; \
	body_path = /proc/__gvb_##verb_path_name; \
}; \
/proc/##verb_path_name(##verb_args) \
{ \
	set name = ##verb_name; \
	set desc = ##verb_desc; \
	set hidden = ##is_hidden; \
	set category = ##verb_category; \
	__gvb_##verb_path_name(arglist(args)); \
}; \
/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, verb_args...) \
_GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, FALSE, ##verb_args)

#define INVOKE_GAME_VERB(target, owner_type, verb_path_name, args...) SSverbs.invoke(target, /datum/verb_metadata##owner_type/##verb_path_name, ##args)
#define ASSIGN_GAME_VERB(target, owner_type, verb_path_name) SSverbs.assign_verb(target, /datum/verb_metadata##owner_type/##verb_path_name)
#define UNASSIGN_GAME_VERB(target, owner_type, verb_path_name) SSverbs.unassign_verb(target, /datum/verb_metadata##owner_type/##verb_path_name)

/// Self-registers argument metadata at world init and extracts value from structured_args at runtime.
/// For typed args, pass the type path as the last argument: VERB_ARG(target, VERB_ARG_TYPE_MOB, VERB_ARG_SOURCE_WORLD, /mob/living)
/// For untyped args (primitives), omit it: VERB_ARG(count, VERB_ARG_TYPE_NUM, VERB_ARG_SOURCE_INPUT)
#define VERB_ARG(name, arg_type, source, type_path...) \
	var/static/____reg_##name = ____register_verb_arg(__TYPE__, #name, arg_type, ##type_path, source); \
	var##type_path/##name = structured_args[#name]

// Argument type bitflags. Combine with | for multi-type args.
#define VERB_ARG_TYPE_TEXT (1<<0)
#define VERB_ARG_TYPE_NUM (1<<1)
#define VERB_ARG_TYPE_MESSAGE (1<<2)
#define VERB_ARG_TYPE_SOUND (1<<3)
#define VERB_ARG_TYPE_ICON (1<<4)
#define VERB_ARG_TYPE_MOB (1<<5)
#define VERB_ARG_TYPE_OBJ (1<<6)
#define VERB_ARG_TYPE_TURF (1<<7)
#define VERB_ARG_TYPE_AREA (1<<8)
#define VERB_ARG_TYPE_DATUM (1<<9)
#define VERB_ARG_TYPE_ATOM (1<<10)

// Argument source constants
#define VERB_ARG_SOURCE_INPUT "input"
#define VERB_ARG_SOURCE_WORLD "world"
#define VERB_ARG_SOURCE_VIEW "view"
>>>>>>> 3b9f03367c3 (rebase changes)

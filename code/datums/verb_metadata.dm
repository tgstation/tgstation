/datum/verb_metadata
	var/name
	var/description
	var/category
	var/verb_path
	var/body_path
	var/list/arguments = list()

/datum/verb_metadata/proc/assign_to(target)
	add_verb(target, verb_path)

/datum/verb_metadata/proc/unassign_from(target)
	remove_verb(target, verb_path)

/datum/verb_arg_metadata
	var/name
	var/arg_type
	var/type_path
	var/source

/datum/verb_arg_metadata/New(arg_name, arg_arg_type, arg_type_path, arg_source)
	. = ..()
	name = arg_name
	arg_type = arg_arg_type
	type_path = arg_type_path
	source = arg_source

GLOBAL_LIST_INIT(____pending_verb_args, list())

/proc/____register_verb_arg(verb_type, arg_name, arg_type, arg_type_path, arg_source)
	if(!GLOB.____pending_verb_args[verb_type])
		GLOB.____pending_verb_args[verb_type] = list()
	GLOB.____pending_verb_args[verb_type] += list(new /datum/verb_arg_metadata(arg_name, arg_type, arg_type_path, arg_source))
	return TRUE

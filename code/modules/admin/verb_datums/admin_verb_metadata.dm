GLOBAL_LIST_INIT(____avd_pending_verb_args, list())

/proc/____avd_register_arg(verb_type, arg_name, arg_type, arg_type_path, arg_source)
	if(!GLOB.____avd_pending_verb_args[verb_type])
		GLOB.____avd_pending_verb_args[verb_type] = list()
	GLOB.____avd_pending_verb_args[verb_type] += list(new /datum/admin_verb_metadata/argument(arg_name, arg_type, arg_type_path, arg_source))
	return TRUE

/datum/admin_verb_metadata
	var/list/arguments = list()

/datum/admin_verb_metadata/argument
	var/name
	var/arg_type
	var/type_path
	var/source

/datum/admin_verb_metadata/argument/New(arg_name, arg_arg_type, arg_type_path, arg_source)
	. = ..()
	name = arg_name
	arg_type = arg_arg_type
	type_path = arg_type_path
	source = arg_source

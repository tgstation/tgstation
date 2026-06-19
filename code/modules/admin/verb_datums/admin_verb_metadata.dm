// Admin verb metadata is now shared via /datum/verb_metadata in code/datums/verb_metadata.dm
// This file remains for the admin_verb_metadata type alias used by existing admin verb code.

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

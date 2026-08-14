SUBSYSTEM_DEF(verbs)
	name = "Verbs"
	ss_flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	var/list/datum/verb_metadata/verbs_by_type = list()
	var/list/datum/verb_metadata/verbs_by_verb_path = list()

/datum/controller/subsystem/verbs/Initialize()
	if (!length(verbs_by_type))
		initialize_verb_types()
	initialized = TRUE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/verbs/proc/initialize_verb_types()
	for(var/datum/verb_metadata/verb_type as anything in subtypesof(/datum/verb_metadata))
		var/datum/verb_metadata/meta = new verb_type
		var/list/pending = GLOB.____pending_verb_args[meta.body_path]
		if(pending)
			meta.arguments = pending
		verbs_by_type[verb_type] = meta
		if(meta.verb_path)
			verbs_by_verb_path[meta.verb_path] = meta

/datum/controller/subsystem/verbs/proc/invoke(target, datum/verb_metadata/verb_type, invoker, ...)
	if(!initialized)
		initialize_verb_types()

	var/datum/verb_metadata/meta = verbs_by_type[verb_type]
	if(isnull(meta))
		CRASH("Attempted to invoke unknown verb '[verb_type]'.")
	var/list/invoke_args = args.Copy(4)
	if(invoker)
		usr = invoker
	call(target, meta.body_path)(arglist(invoke_args))

/datum/controller/subsystem/verbs/proc/invoke_verb(target, verb_path, list/positional_args, invoker)
	if(!initialized)
		initialize_verb_types()

	var/datum/verb_metadata/meta = verbs_by_verb_path[verb_path]
	if(isnull(meta))
		CRASH("invoke_verb called for '[verb_path]' with no metadata registered")
	var/resolved_caller = invoker || target
	var/client/user_client
	if(istype(resolved_caller, /client))
		user_client = resolved_caller
	else if(ismob(resolved_caller))
		var/mob/mob_target = resolved_caller
		user_client = mob_target.client
	if(!user_client)
		return

	var/list/structured_args = ____collect_verb_args(user_client, meta.name, meta.arguments, positional_args)
	if(isnull(structured_args))
		return

	if(invoker)
		usr = invoker
	call(target, meta.body_path)(structured_args)

/datum/controller/subsystem/verbs/proc/assign_verb(target, datum/verb_metadata/verb_type)
	// When launching via dreamseeker and not dreamdaemon, client is created first before any of the subsystems init
	// This can only happen in dev environments so its not a big deal
	if (!initialized)
		initialize_verb_types()
	var/datum/verb_metadata/meta = verbs_by_type[verb_type]
	if(isnull(meta))
		CRASH("Attempted to assign unknown verb '[verb_type]'.")
	meta.assign_to(target)

/datum/controller/subsystem/verbs/proc/unassign_verb(target, datum/verb_metadata/verb_type)
	var/datum/verb_metadata/meta = verbs_by_type[verb_type]
	if(isnull(meta))
		CRASH("Attempted to unassign unknown verb '[verb_type]'.")
	meta.unassign_from(target)

/datum/controller/subsystem/verbs/proc/serialize_verb(procpath/verb_path)
	var/list/arg_data = list()
	var/list/entry = list(
		"name" = verb_path.name,
		"category" = verb_path.category,
		"type" = "[verb_path]",
		"args" = arg_data,
	)

	var/datum/verb_metadata/meta = verbs_by_verb_path[verb_path]
	if(meta)
		entry["type"] = "[meta.verb_path]"
		for(var/datum/verb_arg_metadata/arg in meta.arguments)
			var/list/arg_entry = list("name" = arg.name, "arg_type" = arg.arg_type, "source" = arg.source)
			if(length(arg.options))
				arg_entry["options"] = arg.options
			arg_data += list(arg_entry)
	else
		var/datum/admin_verb/av = SSadmin_verbs.admin_verbs_by_verb_path[verb_path]
		if(av)
			entry["type"] = "[av.get_verb_path()]"
			for(var/datum/verb_arg_metadata/arg in av.arguments)
				var/list/arg_entry = list("name" = arg.name, "arg_type" = arg.arg_type, "source" = arg.source)
				if(length(arg.options))
					arg_entry["options"] = arg.options
				arg_data += list(arg_entry)

	return entry

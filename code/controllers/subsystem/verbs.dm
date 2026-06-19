SUBSYSTEM_DEF(verbs)
	name = "Verbs"
	ss_flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	var/list/datum/verb_metadata/verbs_by_type = list()
	var/list/datum/verb_metadata/verbs_by_verb_path = list()

/datum/controller/subsystem/verbs/Initialize()
	for(var/datum/verb_metadata/verb_type as anything in subtypesof(/datum/verb_metadata))
		var/datum/verb_metadata/meta = new verb_type
		var/list/pending = GLOB.____pending_verb_args[verb_type]
		if(pending)
			meta.arguments = pending
		verbs_by_type[verb_type] = meta
		if(meta.verb_path)
			verbs_by_verb_path[meta.verb_path] = meta
	return SS_INIT_SUCCESS

/datum/controller/subsystem/verbs/proc/invoke(target, datum/verb_metadata/verb_type, ...)
	var/datum/verb_metadata/meta = verbs_by_type[verb_type]
	if(isnull(meta))
		CRASH("Attempted to invoke unknown verb '[verb_type]'.")
	var/list/invoke_args = args.Copy(3)
	call(target, meta.body_path)(arglist(invoke_args))

/datum/controller/subsystem/verbs/proc/invoke_verb(target, verb_path, list/positional_args)
	var/datum/verb_metadata/meta = verbs_by_verb_path[verb_path]
	if(isnull(meta))
		// Raw verb without metadata — call it directly
		call(target, verb_path)(arglist(positional_args))
		return
	var/list/structured_args = list()
	// Check for context menu target
	var/context_target = positional_args?["__context_target__"]
	if(context_target)
		positional_args -= "__context_target__"
	// Map positional args to metadata arg names
	if(length(positional_args) && length(meta.arguments))
		for(var/i in 1 to min(length(positional_args), length(meta.arguments)))
			var/datum/verb_arg_metadata/arg = meta.arguments[i]
			structured_args[arg.name] = positional_args[i]
	// Auto-fill context target into first entity arg
	if(context_target && length(meta.arguments))
		for(var/datum/verb_arg_metadata/arg in meta.arguments)
			if(isnull(structured_args[arg.name]) && (arg.source == VERB_ARG_SOURCE_WORLD || arg.source == VERB_ARG_SOURCE_VIEW))
				structured_args[arg.name] = context_target
				break
	if(length(meta.arguments))
		structured_args = collect_args(target, meta, structured_args)
		if(isnull(structured_args))
			return
	call(target, meta.body_path)(structured_args)

/datum/controller/subsystem/verbs/proc/collect_args(target, datum/verb_metadata/meta, list/collected)
	if(!collected)
		collected = list()
	var/client/user_client
	if(istype(target, /client))
		user_client = target
	else if(ismob(target))
		var/mob/mob_target = target
		user_client = mob_target.client
	if(!user_client)
		return null
	for(var/datum/verb_arg_metadata/arg in meta.arguments)
		if(!isnull(collected[arg.name]))
			continue
		var/value = prompt_for_arg(user_client, meta.name, arg)
		if(isnull(value))
			return null
		collected[arg.name] = value
	return collected

/datum/controller/subsystem/verbs/proc/prompt_for_arg(client/user, verb_name, datum/verb_arg_metadata/arg)
	if(arg.arg_type & VERB_ARG_TYPE_NUM)
		return tgui_input_number(user, arg.name, verb_name)
	if(arg.arg_type & VERB_ARG_TYPE_TEXT)
		return tgui_input_text(user, arg.name, verb_name)
	if(arg.arg_type & VERB_ARG_TYPE_MESSAGE)
		return tgui_input_text(user, arg.name, verb_name, multiline = TRUE)
	if(arg.arg_type & VERB_ARG_TYPE_SOUND)
		return input(user, arg.name, verb_name) as null|sound
	if(arg.arg_type & VERB_ARG_TYPE_MOB)
		return tgui_input_list(user, arg.name, verb_name, sort_names(GLOB.mob_list))
	if(arg.arg_type & VERB_ARG_TYPE_AREA)
		return tgui_input_list(user, arg.name, verb_name, get_sorted_areas())
	if(arg.arg_type & (VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_ATOM | VERB_ARG_TYPE_TURF))
		if(user.mob)
			return tgui_input_list(user, arg.name, verb_name, view(user.view, user.mob))
	return null

/datum/controller/subsystem/verbs/proc/assign_verb(target, datum/verb_metadata/verb_type)
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
	var/list/entry = list(
		"name" = verb_path.name,
		"category" = verb_path.category,
		"type" = "[verb_path]",
	)

	// Check game verbs first, then admin verbs
	var/datum/verb_metadata/meta = verbs_by_verb_path[verb_path]
	if(meta)
		entry["type"] = "[meta.verb_path]"
		var/list/arg_data = list()
		for(var/datum/verb_arg_metadata/arg in meta.arguments)
			arg_data += list(list("name" = arg.name, "arg_type" = arg.arg_type, "source" = arg.source))
		if(length(arg_data))
			entry["args"] = arg_data
	else
		var/datum/admin_verb/av = SSadmin_verbs.admin_verbs_by_verb_path[verb_path]
		if(av)
			entry["type"] = "[av.verb_path]"
			var/list/arg_data = list()
			for(var/datum/admin_verb_metadata/argument/arg in av.metadata?.arguments)
				arg_data += list(list("name" = arg.name, "arg_type" = arg.arg_type, "source" = arg.source))
			if(length(arg_data))
				entry["args"] = arg_data
			log_world("DEBUG serialize_verb: admin verb [verb_path] found, metadata args=[length(av.metadata?.arguments)], serialized args=[length(arg_data)]")
		else
			log_world("DEBUG serialize_verb: [verb_path] NOT found in game verbs ([length(verbs_by_verb_path)] entries) or admin verbs ([length(SSadmin_verbs.admin_verbs_by_verb_path)] entries)")

	return entry

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
	var/datum/verb_metadata/meta = verbs_by_verb_path[verb_path]
	var/list/entry = list(
		"name" = verb_path.name,
		"category" = verb_path.category,
		"type" = "[meta.verb_path]",
	)

	var/list/arg_names = list()
	for(var/datum/verb_arg_metadata/arg in meta.arguments)
		arg_names += arg.name
	entry["args"] = arg_names

	return entry

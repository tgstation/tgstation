SUBSYSTEM_DEF(verbs)
	name = "Verbs"
	ss_flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	var/list/datum/verb_metadata/verbs_by_type = list()

/datum/controller/subsystem/verbs/Initialize()
	if (!length(verbs_by_type))
		initialize_verb_types()
	initialized = TRUE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/verbs/proc/initialize_verb_types()
	for(var/datum/verb_metadata/verb_type as anything in subtypesof(/datum/verb_metadata))
		verbs_by_type[verb_type] = new verb_type

/datum/controller/subsystem/verbs/proc/invoke(target, datum/verb_metadata/verb_type, ...)
	var/datum/verb_metadata/meta = verbs_by_type[verb_type]
	if(isnull(meta))
		CRASH("Attempted to invoke unknown verb '[verb_type]'.")
	var/list/invoke_args = args.Copy(3)
	call(target, meta.body_path)(arglist(invoke_args))

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

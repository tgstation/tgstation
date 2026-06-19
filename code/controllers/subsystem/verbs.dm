SUBSYSTEM_DEF(verbs)
	name = "Verbs"
	ss_flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	var/list/datum/verb_metadata/verbs_by_type = list()

/datum/controller/subsystem/verbs/Initialize()
	for(var/datum/verb_metadata/verb_type as anything in subtypesof(/datum/verb_metadata))
		verbs_by_type[verb_type] = new verb_type
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

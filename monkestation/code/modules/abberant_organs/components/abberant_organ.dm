/datum/component/abberant_organ
	///our trigger
	var/datum/organ_trigger/trigger
	///our processors
	var/list/processors = list()
	///our outcome
	var/datum/organ_outcome/outcome
	///list of added traits
	var/list/organ_traits = list()
	///our stability
	var/stability = 100
	///our complexity
	var/complexity = 0
	///our max complexity before genetic failure
	var/max_complexity = 100
	///weakref to our human
	var/datum/weakref/host
	///our restriction flags
	var/restriction_flags = NONE

/datum/component/abberant_organ/Initialize(max_complexity = 100, restriction_flags = NONE, list/new_processors = list(), datum/organ_trigger/new_trigger, datum/organ_outcome/outcome)
	. = ..()
	src.max_complexity = max_complexity
	src.restriction_flags = restriction_flags

	if(new_trigger)
		trigger = new new_trigger(parent)
		complexity += trigger.complexity_cost

	if(length(new_processors))
		for(var/datum/organ_process/process as anything in new_processors)
			add_process(process)

/datum/component/abberant_organ/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ABBERANT_TRIGGER, PROC_REF(trigger))
	RegisterSignal(parent, COMSIG_ABBERANT_OUTCOME, PROC_REF(process_outcome))
	RegisterSignal(parent, COMSIG_ABBERANT_ADD_TRAIT, PROC_REF(add_trait))
	RegisterSignal(parent, COMSIG_ABBERANT_TRY_ADD_PROCESS, PROC_REF(try_add_process))

	RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(add_host))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(remove_host))

/datum/component/abberant_organ/proc/add_host(obj/item/organ/source, mob/living/new_host)
	host = WEAKREF(new_host)
	SEND_SIGNAL(parent, COMSIG_ABBERANT_HOST_SET, new_host)

/datum/component/abberant_organ/proc/remove_host()
	host = null
	SEND_SIGNAL(parent, COMSIG_ABBERANT_HOST_CLEARED)

/datum/component/abberant_organ/proc/trigger()
	SIGNAL_HANDLER
	for(var/datum/organ_process/process as anything in processors)
		process.trigger(host, stability)
	SEND_SIGNAL(parent, COMSIG_ABBERANT_OUTCOME)

/datum/component/abberant_organ/proc/add_trait(datum/source, /datum/organ_trait)
	//TODO

/datum/component/abberant_organ/proc/try_add_process(datum/source, datum/organ_process/process)
	if(!(restriction_flags & process.process_flags))
		return FALSE

/datum/component/abberant_organ/proc/process_outcome(datum/source)
	if(outcome)
		outcome.trigger(host, stability)

/datum/component/abberant_organ/proc/add_process(datum/organ_process/new_process)
	var/datum/organ_process/created_process = new new_process(parent)
	if(complexity + created_process.complexity_cost > max_complexity)
		qdel(created_process)
		return
	processors |= created_process

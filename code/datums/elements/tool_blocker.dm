/// Blocks using the passed tool type on this atom
/datum/element/tool_blocker
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// e.g. TOOL_SCREWDRIVER, TOOL_CROWBAR
	var/tool_type
	/// Bitflag representing which tool_acts to block
	var/action_type

/datum/element/tool_blocker/Attach(datum/target, tool_type, action_type = TOOL_ACT_ALL)
	. = ..()
	if(isnull(tool_type) || !(action_type & TOOL_ACT_ALL))
		return ELEMENT_INCOMPATIBLE

	src.tool_type = tool_type
	src.action_type = action_type

	var/list/signals_to_register = list()

	if(action_type & TOOL_ACT_PRIMARY)
		signals_to_register += COMSIG_ATOM_TOOL_ACT(tool_type)
	if(action_type & TOOL_ACT_SECONDARY)
		signals_to_register += COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type)
	if(isturf(target))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_turf_deleted), override = TRUE)

	RegisterSignals(target, signals_to_register, PROC_REF(block_tool))

/datum/element/tool_blocker/Detach(datum/source, ...)
	var/list/signals_to_unregister = list()

	if(action_type & TOOL_ACT_PRIMARY)
		signals_to_unregister += COMSIG_ATOM_TOOL_ACT(tool_type)
	if(action_type & TOOL_ACT_SECONDARY)
		signals_to_unregister += COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type)
	if(isturf(source))
		signals_to_unregister += COMSIG_QDELETING
	UnregisterSignal(source, signals_to_unregister)

	return ..()

/datum/element/tool_blocker/proc/block_tool(...)
	SIGNAL_HANDLER
	return ITEM_INTERACT_SKIP_TO_ATTACK

/datum/element/tool_blocker/proc/on_turf_deleted(datum/source)
	SIGNAL_HANDLER
	Detach(source)

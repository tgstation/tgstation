/// Blocks using the passed tool type on this atom
/datum/element/tool_blocker
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/tool_type

/datum/element/tool_blocker/Attach(datum/target, tool_type)
	. = ..()
	src.tool_type = tool_type
	RegisterSignals(target, list(
		COMSIG_ATOM_TOOL_ACT(tool_type),
		COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type),
	), PROC_REF(block_tool))

/datum/element/tool_blocker/Detach(datum/source, ...)
	UnregisterSignal(source, list(
		COMSIG_ATOM_TOOL_ACT(tool_type),
		COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type),
	))
	return ..()

/datum/element/tool_blocker/proc/block_tool(...)
	SIGNAL_HANDLER
	return ITEM_INTERACT_SKIP_TO_ATTACK

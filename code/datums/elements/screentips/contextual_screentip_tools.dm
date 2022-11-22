/// Apply basic contextual screentips when the user hovers over this item with an item of the given tool behavior.
/// A "Type B" interaction.
/// This stacks with other contextual screentip elements, though you may want to register the signal/flag manually at that point for performance.
/datum/element/contextual_screentip_tools
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2

	/// Map of tool behaviors to contexts to usages
	var/list/tool_behaviors

/datum/element/contextual_screentip_tools/Attach(datum/target, tool_behaviors)
	. = ..()
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.tool_behaviors = tool_behaviors

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/element/contextual_screentip_tools/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM)

	// We don't remove HAS_CONTEXTUAL_SCREENTIPS_1, since there could be other stuff still hooked to it,
	// and being set without signals is not dangerous, just less performant.
	// A lot of things don't do this, perhaps make a proc that checks if any signals are still set, and if not,
	// remove the flag.

	return ..()

/datum/element/contextual_screentip_tools/proc/on_requesting_context_from_item(
	datum/source,
	list/context,
	obj/item/held_item,
)
	SIGNAL_HANDLER

	if (isnull(held_item))
		return NONE

	var/tool_behavior = held_item.tool_behaviour
	if (!(tool_behavior in tool_behaviors))
		return NONE

	context += tool_behaviors[tool_behavior]

	return CONTEXTUAL_SCREENTIP_SET

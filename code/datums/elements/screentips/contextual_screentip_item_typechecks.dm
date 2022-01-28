/// Apply basic contextual screentips when the user hovers over this item with a provided item.
/// A "Type B" interaction.
/// This stacks with other contextual screentip elements, though you may want to register the signal/flag manually at that point for performance.
/datum/element/contextual_screentip_item_typechecks
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	/// Map of item paths to contexts to usages
	var/list/item_paths_to_contexts

/datum/element/contextual_screentip_item_typechecks/Attach(datum/target, item_paths_to_contexts)
	. = ..()
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.item_paths_to_contexts = item_paths_to_contexts

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, .proc/on_requesting_context_from_item)

/datum/element/contextual_screentip_item_typechecks/proc/on_requesting_context_from_item(
	datum/source,
	list/context,
	obj/item/held_item,
)
	SIGNAL_HANDLER

	if (isnull(held_item))
		return NONE

	for (var/item_path in item_paths_to_contexts)
		if (istype(held_item, item_path))
			context += item_paths_to_contexts[item_path]
			return CONTEXTUAL_SCREENTIP_SET

	return NONE

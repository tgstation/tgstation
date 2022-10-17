/// Apply basic contextual screentips when the user hovers over this item with an item of the given tool behavior.
/// A "Type B" interaction.
/// This stacks with other contextual screentip elements, though you may want to register the signal/flag manually at that point for performance.
/datum/element/contextual_screentip_sharpness
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	/// If set, the text to show for LMB
	var/lmb_text

	/// If set, the text to show for RMB
	var/rmb_text

/datum/element/contextual_screentip_sharpness/Attach(datum/target, lmb_text, rmb_text)
	. = ..()
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.lmb_text = lmb_text
	src.rmb_text = rmb_text

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, .proc/on_requesting_context_from_item)

/datum/element/contextual_screentip_sharpness/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM)

	// We don't remove HAS_CONTEXTUAL_SCREENTIPS_1, since there could be other stuff still hooked to it,
	// and being set without signals is not dangerous, just less performant.
	// A lot of things don't do this, perhaps make a proc that checks if any signals are still set, and if not,
	// remove the flag.

	return ..()

/datum/element/contextual_screentip_sharpness/proc/on_requesting_context_from_item(
	datum/source,
	list/context,
	obj/item/held_item,
)
	SIGNAL_HANDLER

	if (isnull(held_item))
		return NONE

	var/sharpness = held_item.get_sharpness()
	if (!sharpness)
		return NONE

	if (!isnull(lmb_text))
		context[SCREENTIP_CONTEXT_LMB] = lmb_text

	if (!isnull(rmb_text))
		context[SCREENTIP_CONTEXT_RMB] = rmb_text

	return CONTEXTUAL_SCREENTIP_SET


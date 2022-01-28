/// Create a "Type-B" contextual screentip interaction, registering to `add_context()`.
/// This will run `add_context()` when the atom is hovered over by an item for context.
/// `add_context()` will *not* be called unless this is run.
/// This is not necessary for Type-B interactions, as you can just apply the flag and register to the signal yourself.
/atom/proc/register_context()
	flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(src, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, .proc/add_context)

/// Creates a "Type-B" contextual screentip interaction.
/// When a user hovers over this, this proc will be called in order
/// to provide context for contextual screentips.
/// You must call `register_context()` in order for this to be registered.
/// A screentip context list is a list that has context keys (SCREENTIP_CONTEXT_*, from __DEFINES/screentips.dm)
/// that map to the action as text.
/// If you mutate the list in this signal, you must return CONTEXTUAL_SCREENTIP_SET.
/// `source` can, in all cases, be replaced with `src`, and only exists because this proc directly connects to a signal.
/atom/proc/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)
	SIGNAL_HANDLER

	return NONE

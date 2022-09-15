/// Create a "Type-A" contextual screentip interaction, registering to `add_item_context()`.
/// This will run `add_item_context()` when the item hovers over another object for context.
/// `add_item_context()` will *not* be called unless this is run.
/// This is not necessary for Type-A interactions, as you can just apply the flag and register to the signal yourself.
/obj/item/proc/register_item_context()
	item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS
	RegisterSignal(
		src,
		COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET,
		.proc/add_item_context,
	)

/// Creates a "Type-A" contextual screentip interaction.
/// When a user hovers over something with this item in hand, this proc will be called in order
/// to provide context for contextual screentips.
/// You must call `register_item_context()` in order for this to be registered.
/// A screentip context list is a list that has context keys (SCREENTIP_CONTEXT_*, from __DEFINES/screentips.dm)
/// that map to the action as text.
/// If you mutate the list in this signal, you must return CONTEXTUAL_SCREENTIP_SET.
/// `source` can, in all cases, be replaced with `src`, and only exists because this proc directly connects to a signal.
/obj/item/proc/add_item_context(
	obj/item/source,
	list/context,
	atom/target,
	mob/living/user,
)
	SIGNAL_HANDLER

	return NONE

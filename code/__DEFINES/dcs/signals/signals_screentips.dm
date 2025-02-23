/// A "Type-A" contextual screentip interaction.
/// These are used for items that are defined by their behavior. They define their contextual text within *themselves*,
/// not in their targets.
/// Examples include syringes (LMB to inject, RMB to draw) and health analyzers (LMB to scan health/wounds, RMB for chems)
/// Items can override `add_item_context()`, and call `register_item_context()` in order to easily connect to this.
/// Called on /obj/item with a mutable screentip context list, the hovered target, and the mob hovering.
/// A screentip context list is a list that has context keys (SCREENTIP_CONTEXT_*, from __DEFINES/screentips.dm)
/// that map to the action as text.
/// If you mutate the list in this signal, you must return CONTEXTUAL_SCREENTIP_SET.
#define COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET "item_requesting_context_for_target"

/// A "Type-B" contextual screentip interaction.
/// These are atoms that are defined by what happens *to* them. These should define contextual text within themselves, and
/// not in their operating tools.
/// Examples include construction objects (LMB with glass to put in screen for computers).
/// Called on /atom with a mutable screentip context list, the item being used, and the mob hovering.
/// A screentip context list is a list that has context keys (SCREENTIP_CONTEXT_*, from __DEFINES/screentips.dm)
/// that map to the action as text.
/// If you mutate the list in this signal, you must return CONTEXTUAL_SCREENTIP_SET.
#define COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM "atom_requesting_context_from_item"

/// Tells the contextual screentips system that the list context was mutated.
#define CONTEXTUAL_SCREENTIP_SET (1 << 0)


/// A user screentip name override.
/// These are used for mobs that may override the names of atoms they hover over.
/// Examples include prosopagnosia (sees human names as Unknown regardless of what they are).
/// Called on /mob with a mutable screentip name list, the item being used, and the atom hovered over.
/// A screentip name override list is a list used for returning a string value from the signal. Only the first value matters.
/// If you mutate the list in this signal, you must return SCREENTIP_NAME_SET.
#define COMSIG_MOB_REQUESTING_SCREENTIP_NAME_FROM_USER "mob_requesting_screentip_name_from_user"

/// Tells the screentips system that the list names was mutated.
#define SCREENTIP_NAME_SET (1 << 0)

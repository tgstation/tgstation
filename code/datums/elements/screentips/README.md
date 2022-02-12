# Contextual screentips (and when to not use this folder)

Contextual screentips provide information in the form of text at the top of your screen to inform you of the possibilities of an item. The "contextual" here refers to this being handled entirely through code, what it displays and when is completely up to you.

## The elements (and this folder)

This folder provides several useful shortcuts to be able to handle 95% of situations.

### `/datum/element/contextual_screentip_bare_hands`

This element is used to display screentips **when the user hovers over the object with nothing in their active hand.**

It takes parameters in the form of both non-combat mode and, optionally, combat mode.

Example:

```dm
/obj/machinery/firealarm/Initialize(mapload)
	. = ..()

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		lmb_text = "Turn on", \
		rmb_text = "Turn off", \
	)
```

This will display "LMB: Turn on | RMB: Turn off" when the user hovers over a fire alarm with an empty active hand.

### `/datum/element/contextual_screentip_tools`

This element takes a map of tool behaviors to [context lists](#context-lists). These will be displayed **when the user hovers over the object with an item that has the tool behavior.**

Example:

```dm
/obj/structure/table/Initialize(mapload)
	if (!(flags_1 & NODECONSTRUCT_1))
		var/static/list/tool_behaviors = list(
			TOOL_SCREWDRIVER = list(
				SCREENTIP_CONTEXT_RMB = "Disassemble",
			),

			TOOL_WRENCH = list(
				SCREENTIP_CONTEXT_RMB = "Deconstruct",
			),
		)

		AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
```

This will display "RMB: Deconstruct" when the user hovers over a table with a wrench.

### `/datum/element/contextual_screentip_item_typechecks`

This element takes a map of item typepaths to [context lists](#context-lists). These will be displayed **when the user hovers over the object with the selected item.**

Example:

```dm
/obj/item/restraints/handcuffs/cable/Initialize(mapload)
	. = ..()

	var/static/list/hovering_item_typechecks = list(
		/obj/item/stack/rods = list(
			SCREENTIP_CONTEXT_LMB = "Craft wired rod",
		),

		/obj/item/stack/sheet/iron = list(
			SCREENTIP_CONTEXT_LMB = "Craft bola",
		),
	)

	AddElement(/datum/element/contextual_screentip_item_typechecks, hovering_item_typechecks)
```

This will display "LMB: Craft bola" when the user hovers over cable restraints with metal in their hand.

## The basic system (and when to not use this folder)

The basic system acknowledges the following two interactions:

### Self-defining items (Type A)
These are items that are defined by their behavior. These should define their contextual text within themselves, and not in their targets.

- Stun batons (LMB to stun, RMB to harm)
- Syringes (LMB to inject, RMB to draw)
- Health analyzers (LMB to scan for health/wounds [another piece of context], RMB to scans for chemicals)

### Receiving action defining objects (Type B)
These are objects (not necessarily items) that are defined by what happens *to* them. These should define their contextual text within themselves, and not in their operating tools.

- Tables (RMB with wrench to deconstruct)
- Construction objects (LMB with glass to put in screen for computers)
- Carbon copies (RMB to take a copy)

---

Both of these are supported, and can be hooked to through several means.

Note that you **must return `CONTEXTUAL_SCREENTIP_SET` if you change the contextual screentip at all**, otherwise you may not see it.

### `COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET`

This signal is registered on **items**, and receives **the hovering object**, provided in the form of `obj/item/source, list/context, atom/target, mob/living/user`.

### `/atom/proc/register_item_context()`, and `/atom/proc/add_item_context()`
`/atom/proc/add_item_context()` is a proc intended to be overridden to easily create Type-B interactions (ones where atoms are hovered over by items). It receives the exact same arguments as `COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET`: `obj/item/source, list/context, atom/target, mob/living/user`.

In order for your `add_item_context()` method to be run, you **must** call `register_item_context()`.

### `COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM`

This signal is registered on **atoms**, and receives **what the user is hovering with**, provided in the form of `atom/source, list/context, obj/item/held_item, mob/living/user`.

### `/atom/proc/register_context()`, and `/atom/proc/add_context()`
`/atom/proc/add_context()` is a proc intended to be overridden to easily create Type-B interactions (ones where atoms are hovered over by items). It receives the exact same arguments as `COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM`: `atom/source, list/context, obj/item/held_item, mob/living/user`.

In order for your `add_context()` method to be run, you **must** call `register_context()`.

---

When using any of these methods, you will receive a mutable context list.

### Context lists

Context lists are lists with keys mapping from `SCREENTIP_CONTEXT_*` to a string. You can find these keys in `code/__DEFINES/screentips.dm`.

The signals and `add_context()` variants mutate the list directly, while shortcut elements will just have you pass them in directly.

For example:

```dm
context[SCREENTIP_CONTEXT_LMB] = "Open"
context[SCREENTIP_CONTEXT_RMB] = "Destroy"
```

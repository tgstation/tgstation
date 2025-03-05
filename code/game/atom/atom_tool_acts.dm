/**
 * ## Item interaction
 *
 * Handles non-combat interactions of a tool on this atom,
 * such as using a tool on a wall to deconstruct it,
 * or scanning someone with a health analyzer
 */
/atom/proc/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	if(!user.combat_mode)
		var/tool_return = tool_act(user, tool, modifiers)
		if(tool_return)
			return tool_return

	var/is_right_clicking = text2num(LAZYACCESS(modifiers, RIGHT_CLICK))
	var/is_left_clicking = !is_right_clicking
	var/early_sig_return = NONE
	if(is_left_clicking)
		/*
		 * This is intentionally using `||` instead of `|` to short-circuit the signal calls
		 * This is because we want to return early if ANY of these signals return a value
		 *
		 * This puts priority on the atom's signals, then the tool's signals, then the user's signals,
		 * so we can avoid doing two interactions at once
		 */
		early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_ITEM_INTERACTION, user, tool, modifiers) \
			|| SEND_SIGNAL(tool, COMSIG_ITEM_INTERACTING_WITH_ATOM, user, src, modifiers) \
			|| SEND_SIGNAL(user, COMSIG_USER_ITEM_INTERACTION, src, tool, modifiers)
	else
		// See above
		early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, user, tool, modifiers) \
			|| SEND_SIGNAL(tool, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, user, src, modifiers) \
			|| SEND_SIGNAL(user, COMSIG_USER_ITEM_INTERACTION_SECONDARY, src, tool, modifiers)
	if(early_sig_return)
		return early_sig_return

	var/self_interaction = is_left_clicking \
		? item_interaction(user, tool, modifiers) \
		: item_interaction_secondary(user, tool, modifiers)
	if(self_interaction)
		return self_interaction

	var/interact_return = is_left_clicking \
		? tool.interact_with_atom(src, user, modifiers) \
		: tool.interact_with_atom_secondary(src, user, modifiers)
	if(interact_return)
		return interact_return

	// We have to manually handle storage in item_interaction because storage is blocking in 99% of interactions, which stifles a lot
	// Yeah it sucks not being able to signalize this, but the other option is to have a second signal here just for storage which is also not great
	if(atom_storage)
		if(is_left_clicking)
			if(atom_storage.insert_on_attack)
				return atom_storage.item_interact_insert(user, tool)
		else
			if(atom_storage.open_storage(user) && atom_storage.display_contents)
				return ITEM_INTERACT_SUCCESS

	return NONE

/**
 *
 * ## Tool Act
 *
 * Handles using specific tools on this atom directly.
 * Only called when combat mode is off.
 *
 * Handles the tool_acts in particular, such as wrenches and screwdrivers.
 *
 * This can be overridden to handle unique "tool interactions"
 * IE using an item like a tool (when it's not actually one)
 * This is particularly useful for things that shouldn't be inserted into storage
 * (because tool acting runs before storage checks)
 * but otherwise does nothing that [item_interaction] doesn't already do.
 *
 * In other words, use sparingly. It's harder to use (correctly) than [item_interaction].
 */
/atom/proc/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	var/tool_type = tool.tool_behaviour
	if(!tool_type)
		return NONE

	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/is_left_clicking = !is_right_clicking

	var/list/processing_recipes = list()
	var/signal_result = is_left_clicking \
		? SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, tool, processing_recipes) \
		: SEND_SIGNAL(src, COMSIG_ATOM_SECONDARY_TOOL_ACT(tool_type), user, tool)
	if(signal_result)
		return signal_result
	if(length(processing_recipes))
		process_recipes(user, tool, processing_recipes)
		return ITEM_INTERACT_SUCCESS
	if(QDELETED(tool))
		return ITEM_INTERACT_SUCCESS // Safe-ish to assume that if we deleted our item something succeeded

	var/act_result = NONE // or FALSE, or null, as some things may return

	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = is_left_clicking ? crowbar_act(user, tool) : crowbar_act_secondary(user, tool)
		if(TOOL_MULTITOOL)
			act_result = is_left_clicking ? multitool_act(user, tool) : multitool_act_secondary(user, tool)
		if(TOOL_SCREWDRIVER)
			act_result = is_left_clicking ? screwdriver_act(user, tool) : screwdriver_act_secondary(user, tool)
		if(TOOL_WRENCH)
			act_result = is_left_clicking ? wrench_act(user, tool) : wrench_act_secondary(user, tool)
		if(TOOL_WIRECUTTER)
			act_result = is_left_clicking ? wirecutter_act(user, tool) : wirecutter_act_secondary(user, tool)
		if(TOOL_WELDER)
			act_result = is_left_clicking ? welder_act(user, tool) : welder_act_secondary(user, tool)
		if(TOOL_ANALYZER)
			act_result = is_left_clicking ? analyzer_act(user, tool) : analyzer_act_secondary(user, tool)

	if(!act_result)
		return NONE

	// A tooltype_act has completed successfully
	if(is_left_clicking)
		log_tool("[key_name(user)] used [tool] on [src] at [AREACOORD(src)]")
		SEND_SIGNAL(tool, COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_type), src)
	else
		log_tool("[key_name(user)] used [tool] on [src] (right click) at [AREACOORD(src)]")
		SEND_SIGNAL(tool, COMSIG_TOOL_ATOM_ACTED_SECONDARY(tool_type), src)
	SEND_SIGNAL(tool, COMSIG_ITEM_TOOL_ACTED, src, user, tool_type, act_result)
	return act_result

/**
 * Called when this atom has an item used on it.
 * IE, a mob is clicking on this atom with an item.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/atom/proc/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return NONE

/**
 * Called when this atom has an item used on it WITH RIGHT CLICK,
 * IE, a mob is right clicking on this atom with an item.
 * Default behavior has it run the same code as left click.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/atom/proc/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	return item_interaction(user, tool, modifiers)

/**
 * Called when this item is being used to interact with an atom,
 * IE, a mob is clicking on an atom with this item.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/obj/item/proc/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return NONE

/**
 * Called when this item is being used to interact with an atom WITH RIGHT CLICK,
 * IE, a mob is right clicking on an atom with this item.
 *
 * Default behavior has it run the same code as left click.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/obj/item/proc/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/**
 * ## Ranged item interaction
 *
 * Handles non-combat ranged interactions of a tool on this atom,
 * such as shooting a gun in the direction of someone*,
 * having a scanner you can point at someone to scan them at any distance,
 * or pointing a laser pointer at something.
 *
 * *While this intuitively sounds combat related, it is not,
 * because a "combat use" of a gun is gun-butting.
 */
/atom/proc/base_ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	var/is_right_clicking = LAZYACCESS(modifiers, RIGHT_CLICK)
	var/is_left_clicking = !is_right_clicking
	var/early_sig_return = NONE
	if(is_left_clicking)
		// See [base_item_interaction] for defails on why this is using `||` (TL;DR it's short circuiting)
		early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_RANGED_ITEM_INTERACTION, user, tool, modifiers) \
			|| SEND_SIGNAL(tool, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM, user, src, modifiers)
	else
		// See above
		early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_RANGED_ITEM_INTERACTION_SECONDARY, user, tool, modifiers) \
			|| SEND_SIGNAL(tool, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY, user, src, modifiers)
	if(early_sig_return)
		return early_sig_return

	var/self_interaction = is_left_clicking \
		? ranged_item_interaction(user, tool, modifiers) \
		: ranged_item_interaction_secondary(user, tool, modifiers)
	if(self_interaction)
		return self_interaction

	var/interact_return = is_left_clicking \
		? tool.ranged_interact_with_atom(src, user, modifiers) \
		: tool.ranged_interact_with_atom_secondary(src, user, modifiers)
	if(interact_return)
		return interact_return

	return NONE

/**
 * Called when this atom has an item used on it from a distance.
 * IE, a mob is clicking on this atom with an item and is not adjacent.
 *
 * Does NOT include Telekinesis users, they are considered adjacent generally.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/atom/proc/ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return NONE

/**
 * Called when this atom has an item used on it from a distance WITH RIGHT CLICK,
 * IE, a mob is right clicking on this atom with an item and is not adjacent.
 *
 * Default behavior has it run the same code as left click.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/atom/proc/ranged_item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	return ranged_item_interaction(user, tool, modifiers)

/**
 * Called when this item is being used to interact with an atom from a distance,
 * IE, a mob is clicking on an atom with this item and is not adjacent.
 *
 * Does NOT include Telekinesis users, they are considered adjacent generally
 * (so long as this item is adjacent to the atom).
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 */
/obj/item/proc/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return NONE

/**
 * Called when this item is being used to interact with an atom from a distance WITH RIGHT CLICK,
 * IE, a mob is right clicking on an atom with this item and is not adjacent.
 *
 * Default behavior has it run the same code as left click.
 */
/obj/item/proc/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/*
 * Tool-specific behavior procs.
 *
 * Return an ITEM_INTERACT_ flag to handle the event, or NONE to allow the mob to attack the atom.
 * Returning TRUE will also cancel attacks. It is equivalent to an ITEM_INTERACT_ flag. (This is legacy behavior, and is not to be relied on)
 * Returning FALSE or null will also allow the mob to attack the atom. (This is also legacy behavior)
 */

/// Called on an object when a tool with crowbar capabilities is used to left click an object
/atom/proc/crowbar_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with crowbar capabilities is used to right click an object
/atom/proc/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to left click an object
/atom/proc/multitool_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to right click an object
/atom/proc/multitool_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to left click an object
/atom/proc/screwdriver_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with screwdriver capabilities is used to right click an object
/atom/proc/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/wrench_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to right click an object
/atom/proc/wrench_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to left click an object
/atom/proc/wirecutter_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to right click an object
/atom/proc/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to left click an object
/atom/proc/welder_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to right click an object
/atom/proc/welder_act_secondary(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to left click an object
/atom/proc/analyzer_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to right click an object
/atom/proc/analyzer_act_secondary(mob/living/user, obj/item/tool)
	return

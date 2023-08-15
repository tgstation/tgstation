/// A component attached to any item (typically a weapon) that causes it to break after a certain number of uses.
///
/// Upon breaking, a number of effects can be applied to the item.
/datum/component/durability
	/// Whether the item has broken.
	var/broken

	/// The prefix applied to the item when it breaks.
	var/broken_prefix = "broken"

	/// An absolute name to apply to the item when it breaks.
	var/broken_name

	/// An absolute description to apply to the item when it breaks.
	var/broken_desc

	/// The maximum number of times the item can be used before breaking.
	var/max_durability

	/// The current durability of the item. Upon reaching zero, the item breaks.
	var/current_durability

	/// If present, the icon state to apply to the item after it breaks.
	var/broken_icon_state

	/// If present, a sound that plays when the item breaks.
	var/break_sound

	/// The force of the item after breaking.
	var/broken_force

	/// A flat penalty to apply to the force of the item after breaking.
	var/broken_force_decrease

	/// The throw force of the item after breaking.
	var/broken_throw_force = 0

	/// A flat penalty to apply to the throw force of the item after breaking.
	var/broken_throw_force_decrease = 0

	/// The throw range of the item after breaking.
	var/broken_throw_range

	/// The embedding attributes of the item after breaking.
	var/list/broken_embedding

	/// The block chance of the item after breaking.
	var/broken_block_chance

	/// The `w_class` of the item after breaking.
	var/broken_w_class

	/// If present, a message that plays when the item breaks.
	var/broken_message

/datum/component/durability/Initialize(
	broken = FALSE,
	broken_prefix,
	broken_name = "broken item",
	broken_desc = "broken item description",
	broken_embedding,
	max_durability = 0,
	current_durability = 0,
	broken_icon_state = "broken_item",
	break_sound = 'sound/effects/glassbr1.ogg',
	broken_force = 0,
	broken_force_decrease = 0,
	broken_throw_force = 0,
	broken_throw_force_decrease = 0,
	broken_throw_range = 0,
	broken_block_chance = 0,
	broken_message = "It broke",
	broken_w_class = WEIGHT_CLASS_TINY
)
	if (broken)
		src.broken = broken

	if (broken_prefix)
		src.broken_prefix = broken_prefix

	if (broken_name)
		src.broken_name = broken_name

	if (broken_desc)
		src.broken_desc = broken_desc

	if (max_durability)
		src.max_durability = max_durability
		src.current_durability = max_durability

	if (current_durability)
		src.current_durability = current_durability

	if (broken_icon_state)
		src.broken_icon_state = broken_icon_state

	if (break_sound)
		src.break_sound = break_sound

	if (broken_force)
		src.broken_force = broken_force

	if (broken_throw_force)
		src.broken_throw_force = broken_throw_force

	if (broken_throw_force_decrease)
		src.broken_throw_force_decrease = broken_throw_force_decrease

	if (broken_throw_range)
		src.broken_throw_range = broken_throw_range

	if (broken_embedding)
		src.broken_embedding = broken_embedding

	if (broken_block_chance)
		src.broken_block_chance = broken_block_chance

	if (broken_message)
		src.broken_message = broken_message

	if (broken_w_class)
		src.broken_w_class = broken_w_class


/datum/component/durability/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_after_attack))

/datum/component/durability/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK))

/datum/component/durability/proc/on_after_attack(obj/item/source, atom/target, mob/living/user, proximity)
	SIGNAL_HANDLER

	if(broken)
		return NONE

	current_durability -= 1

	if(!isnull(max_durability) && current_durability == 0)
		broken = TRUE

		if (!isnull(broken_prefix))
			source.name = "[broken_prefix] [source.name]"

		if (!isnull(broken_name))
			source.name = broken_name

		if (!isnull(broken_desc))
			source.desc = broken_desc

		if (!isnull(broken_icon_state))
			source.icon_state = broken_icon_state
			source.inhand_icon_state = broken_icon_state
			source.worn_icon_state = broken_icon_state

		if (!isnull(broken_force))
			source.force = broken_force

		if (!isnull(broken_throw_force))
			source.throwforce = broken_throw_force

		if (!isnull(broken_throw_range))
			source.throw_range = broken_throw_range

		if (!isnull(broken_embedding))
			source.embedding = broken_embedding

		if (!isnull(broken_block_chance))
			source.block_chance = broken_block_chance

		if (!isnull(broken_w_class))
			source.w_class = broken_w_class

		if (!isnull(broken_force_decrease))
			source.force -= broken_force_decrease

		if (!isnull(broken_throw_force_decrease))
			source.throwforce -= broken_throw_force_decrease

		if (!isnull(broken_message))
			source.visible_message(broken_message)

		if (!isnull(break_sound))
			playsound(source, break_sound, 100, TRUE)

	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

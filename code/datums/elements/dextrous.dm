/**
 * Sets up the attachee to have hands and manages things like dropping items on death and displaying them on examine
 * Actual hand performance is managed by code on /living/ and not encapsulated here, we just enable it
 */
/datum/element/dextrous

/datum/element/dextrous/Attach(datum/target, hands_count = 2, hud_type = /datum/hud/dextrous)
	. = ..()
	if (!isliving(target) || iscarbon(target))
		return ELEMENT_INCOMPATIBLE // Incompatible with the carbon typepath because that already has its own hand handling and doesn't need hand holding

	var/mob/living/mob_parent = target
	set_available_hands(mob_parent, hands_count)
	mob_parent.hud_type = hud_type
	if (mob_parent.hud_used)
		mob_parent.set_hud_used(new hud_type(target))
		mob_parent.hud_used.show_hud(mob_parent.hud_used.hud_version)
	ADD_TRAIT(target, TRAIT_CAN_HOLD_ITEMS, REF(src))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_hand_clicked))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

/datum/element/dextrous/Detach(datum/source)
	. = ..()
	var/mob/living/mob_parent = source
	set_available_hands(mob_parent, initial(mob_parent.default_num_hands))
	var/initial_hud = initial(mob_parent.hud_type)
	mob_parent.hud_type = initial_hud
	if (mob_parent.hud_used)
		mob_parent.set_hud_used(new initial_hud(source))
		mob_parent.hud_used.show_hud(mob_parent.hud_used.hud_version)
	REMOVE_TRAIT(source, TRAIT_CAN_HOLD_ITEMS, REF(src))
	UnregisterSignal(source, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_UNARMED_ATTACK,
	))

/// Set up how many hands we should have
/datum/element/dextrous/proc/set_available_hands(mob/living/hand_owner, hands_count)
	hand_owner.drop_all_held_items()
	var/held_items = list()
	for (var/i in 1 to hands_count)
		held_items += null
	hand_owner.held_items = held_items
	hand_owner.set_num_hands(hands_count)
	hand_owner.set_usable_hands(hands_count)

/// Drop our shit when we die
/datum/element/dextrous/proc/on_death(mob/living/died, gibbed)
	SIGNAL_HANDLER
	died.drop_all_held_items()

/// Try picking up items
/datum/element/dextrous/proc/on_hand_clicked(mob/living/hand_haver, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if (!proximity && target.loc != hand_haver)
		var/obj/item/obj_item = target
		if (istype(obj_item) && !obj_item.atom_storage && !(obj_item.item_flags & IN_STORAGE))
			return NONE
	if (!isitem(target) && hand_haver.combat_mode)
		return NONE
	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand_secondary), hand_haver, modifiers)
	else
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand), hand_haver, modifiers)
	INVOKE_ASYNC(hand_haver, TYPE_PROC_REF(/mob, update_held_items))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Tell people what we are holding
/datum/element/dextrous/proc/on_examined(mob/living/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	for(var/obj/item/held_item in examined.held_items)
		if((held_item.item_flags & (ABSTRACT|HAND_ITEM)) || HAS_TRAIT(held_item, TRAIT_EXAMINE_SKIP))
			continue
		examine_list += span_info("[examined.p_They()] [examined.p_have()] [held_item.examine_title(user)] in [examined.p_their()] \
			[examined.get_held_index_name(examined.get_held_index_of_item(held_item))].")

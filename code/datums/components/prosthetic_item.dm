/**
 * This makes an arbitrary item into a "prosthetic limb"
 */
/datum/component/item_as_prosthetic_limb
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The item that is the prosthetic limb
	VAR_PRIVATE/obj/item/item_limb
	/// Prob of losing the arm on attack
	var/drop_prob = 100

/datum/component/item_as_prosthetic_limb/Initialize(obj/item/prosthetic_item, drop_prob = 100)
	if(!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/bodypart/bodyparent = parent
	if(bodyparent.body_zone != BODY_ZONE_L_ARM && bodyparent.body_zone != BODY_ZONE_R_ARM)
		return COMPONENT_INCOMPATIBLE
	if(isnull(bodyparent.owner))
		return COMPONENT_INCOMPATIBLE

	bodyparent.bodypart_flags |= BODYPART_PSEUDOPART|BODYPART_IMPLANTED
	src.item_limb = prosthetic_item // calls register_item() in registerWithParent()
	src.drop_prob = drop_prob

/datum/component/item_as_prosthetic_limb/InheritComponent(datum/component/new_comp, i_am_original, obj/item/prosthetic_item, drop_prob = 100)
	if(prosthetic_item)
		unregister_item(item_limb)
		register_item(prosthetic_item)

	src.drop_prob = drop_prob

/datum/component/item_as_prosthetic_limb/proc/register_item(obj/item/prosthetic_item)
	SEND_SIGNAL(prosthetic_item, COMSIG_ITEM_PRE_USED_AS_PROSTHETIC, parent)
	item_limb = prosthetic_item
	RegisterSignal(prosthetic_item, COMSIG_QDELETING, PROC_REF(qdel_limb))
	RegisterSignal(prosthetic_item, COMSIG_MOVABLE_MOVED, PROC_REF(limb_moved))
	// adds a bunch of flags to the item to make it act like a limb
	prosthetic_item.item_flags |= (HAND_ITEM|ABSTRACT)
	prosthetic_item.interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	ADD_TRAIT(prosthetic_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	// update the name of the real limb to match the item, so you see "their chainsaw arm is wounded"
	var/obj/item/bodypart/bodyparent = parent
	// ensures the item is in the proper place
	switch(bodyparent.body_zone)
		if(BODY_ZONE_R_ARM)
			bodyparent.name = "right [prosthetic_item.name]"
			bodyparent.plaintext_zone = "right [prosthetic_item.name]"
			bodyparent.owner.put_in_r_hand(prosthetic_item)
		if(BODY_ZONE_L_ARM)
			bodyparent.name = "left [prosthetic_item.name]"
			bodyparent.plaintext_zone = "left [prosthetic_item.name]"
			bodyparent.owner.put_in_l_hand(prosthetic_item)
	SEND_SIGNAL(prosthetic_item, COMSIG_ITEM_POST_USED_AS_PROSTHETIC, parent)

/datum/component/item_as_prosthetic_limb/proc/unregister_item(obj/item/prosthetic_item)
	item_limb = null
	UnregisterSignal(prosthetic_item, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	// nothing to be done if it's being thrown away
	if(QDELING(prosthetic_item))
		return

	// reset all the flags
	prosthetic_item.item_flags &= ~(HAND_ITEM|ABSTRACT)
	prosthetic_item.interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
	REMOVE_TRAIT(prosthetic_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	// note: default behavior is to keep the item in the contents of the arm
	// so if the limb is deleted by some unknown means (supermatter?), the item will also be deleted
	SEND_SIGNAL(prosthetic_item, COMSIG_ITEM_DROPPED_FROM_PROSTHETIC, parent)

/datum/component/item_as_prosthetic_limb/proc/register_limb(obj/item/bodypart/bodyparent)
	RegisterSignal(bodyparent, COMSIG_BODYPART_REMOVED, PROC_REF(clear_comp))
	RegisterSignals(bodyparent.owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK), PROC_REF(pop_limb))

/datum/component/item_as_prosthetic_limb/proc/unregister_limb(obj/item/bodypart/bodyparent)
	UnregisterSignal(bodyparent, COMSIG_BODYPART_REMOVED)
	if(bodyparent.owner) // may be null frim removal
		UnregisterSignal(bodyparent.owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK))

/datum/component/item_as_prosthetic_limb/RegisterWithParent()
	register_limb(parent)
	register_item(item_limb)

/datum/component/item_as_prosthetic_limb/UnregisterFromParent()
	unregister_limb(parent)
	unregister_item(item_limb)

/// If the fake limb (the item) is deleted, the real limb goes with it.
/datum/component/item_as_prosthetic_limb/proc/qdel_limb(obj/item/source)
	SIGNAL_HANDLER

	if(QDELING(parent))
		return
	qdel(parent) // which nulls all the references and signals

/// If the item is removed from our hands somehow, the real limb has to go
/datum/component/item_as_prosthetic_limb/proc/limb_moved(obj/item/source)
	SIGNAL_HANDLER

	if(QDELING(parent))
		return
	var/obj/item/bodypart/bodyparent = parent
	if(source.loc == bodyparent.owner)
		return
	qdel(parent) // which nulls all the references and signals

/// When the bodypart is removed, we will drop the item on the ground, and then delete the the real limb.
/datum/component/item_as_prosthetic_limb/proc/clear_comp(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	UnregisterSignal(owner, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_LIVING_UNARMED_ATTACK))
	if(item_limb.loc == owner)
		item_limb.forceMove(owner.drop_location())
	if(QDELING(parent))
		return
	qdel(parent) // which nulls all the references and signals

/// Attacking with the fake limb (the item) can cause it to fall off, which in turn will result in the real limb being deleted.
/datum/component/item_as_prosthetic_limb/proc/pop_limb(mob/living/source, ...)
	SIGNAL_HANDLER

	if(source.get_active_hand() != parent)
		return NONE
	if(!prob(drop_prob))
		return NONE

	var/obj/item/bodypart/bodyparent = parent
	source.visible_message(
		span_warning("As [source] attempts to swing with [source.p_their()] [bodyparent.name], it falls right off!"),
		span_warning("As you attempt to swing with [source.p_their()] [bodyparent.name], it falls right off!"),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
	bodyparent.dismember(silent = TRUE) // which removes the limb, which qdels us (which nulls all the references and signals)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Makes the passed item into a "prosthetic limb" of this mod, replacing any existing arm
 *
 * Returns the created pseudopart
 */
/mob/living/carbon/proc/make_item_prosthetic(obj/item/some_thing, target_zone = BODY_ZONE_R_ARM, fall_prob = 0)
	var/obj/item/bodypart/existing = get_bodypart(target_zone)
	existing?.drop_limb(special = TRUE)

	var/obj/item/bodypart/bodypart_to_attach = newBodyPart(target_zone)
	bodypart_to_attach.change_appearance(icon = 'icons/mob/augmentation/surplus_augments.dmi', id = BODYPART_ID_ROBOTIC, greyscale = FALSE, dimorphic = FALSE)
	bodypart_to_attach.try_attach_limb(src)
	bodypart_to_attach.AddComponent(/datum/component/item_as_prosthetic_limb, some_thing, fall_prob)

	if(bodypart_to_attach.owner != src)
		stack_trace("make_item_prosthetic failed to attach to owner!")
		qdel(bodypart_to_attach)
		return null

	return bodypart_to_attach

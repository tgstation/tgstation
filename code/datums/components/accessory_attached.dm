/datum/element/accepts_accesories
	var/max_number_of_accessories = 1
	var/accessory_type = /obj/item/clothing/accessory


/datum/element/accepts_accesories/Attach(obj/item/target, max_number_of_accessories = 1, accessory_type = /obj/item/clothing/accessory)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.max_number_of_accessories = max_number_of_accessories
	src.accessory_type = accessory_type

	target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(add_context))
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attack))


/datum/element/accepts_accesories/proc/add_context(obj/item/source, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER

	if(istype(held_item, accessory_type))
		context[SCREENTIP_CONTEXT_LMB] = "Attach accessory"
		return CONTEXTUAL_SCREENTIP_SET

/datum/element/accepts_accesories/proc/on_attack(obj/item/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(istype(held_item, accessory_type))
		INVOKE_ASYNC(src, PROC_REF(try_attach_accessory), source, attacking_item, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/accepts_accesories/proc/try_attach_accessory(obj/item/source, obj/item/accessory, mob/user)


/datum/component/accessory_holder

	/// A list of all accessories attached to us.
	var/list/obj/item/clothing/accessory/attached_accessories
	/// The overlay of the accessory we're demonstrating. Only index 1 will show up.
	/// This is the overlay on the MOB, not the item itself.
	var/mutable_appearance/accessory_overlay

/// Attached to clothing items to have them apply a texture to bodyparts when worn."
/datum/element/equipment_bodypart_texture
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Bodypart we apply the texture to
	var/body_zone
	/// Texture we apply to the bodypart
	var/bodypart_overlay_type

/datum/element/equipment_bodypart_texture/Attach(datum/target, body_zone, bodypart_overlay_type)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.body_zone = body_zone
	src.bodypart_overlay_type = bodypart_overlay_type

	var/obj/item/target_item = target
	RegisterSignal(target_item, COMSIG_ITEM_EQUIPPED, PROC_REF(item_equipped))
	RegisterSignal(target_item, COMSIG_ITEM_DROPPED, PROC_REF(item_dropped))
	if(isliving(target_item.loc))
		var/mob/living/wearer = target_item.loc
		item_equipped(target_item, wearer, wearer.get_slot_by_item(target_item))

/datum/element/equipment_bodypart_texture/Detach(datum/source, ...)
	. = ..()
	var/obj/item/target_item = source
	UnregisterSignal(target_item, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(target_item, COMSIG_ITEM_DROPPED)
	if(isliving(target_item.loc))
		var/mob/living/wearer = target_item.loc
		item_dropped(target_item, wearer)

/datum/element/equipment_bodypart_texture/proc/item_equipped(obj/item/equipped_item, mob/living/carbon/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & equipped_item.slot_flags))
		return

	var/obj/item/bodypart/affected_bodypart = equipper.get_bodypart(body_zone)
	affected_bodypart?.add_bodypart_texture(bodypart_overlay_type)
	RegisterSignal(equipper, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(limb_removed))
	RegisterSignal(equipper, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(limb_added))

/datum/element/equipment_bodypart_texture/proc/item_dropped(obj/item/dropped_item, mob/living/carbon/dropper)
	SIGNAL_HANDLER

	if(dropper.get_item_by_slot(dropped_item.slot_flags) != dropped_item)
		return

	var/obj/item/bodypart/affected_bodypart = dropper.get_bodypart(body_zone)
	affected_bodypart?.remove_bodypart_texture(bodypart_overlay_type)
	UnregisterSignal(dropper, COMSIG_CARBON_POST_REMOVE_LIMB)
	UnregisterSignal(dropper, COMSIG_CARBON_POST_ATTACH_LIMB)

/datum/element/equipment_bodypart_texture/proc/limb_removed(mob/living/carbon/limb_owner, obj/item/bodypart/removed_limb)
	SIGNAL_HANDLER

	removed_limb.remove_bodypart_texture(bodypart_overlay_type)

/datum/element/equipment_bodypart_texture/proc/limb_added(mob/living/carbon/limb_owner, obj/item/bodypart/added_limb)
	SIGNAL_HANDLER

	added_limb.add_bodypart_texture(bodypart_overlay_type)

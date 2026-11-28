
/datum/inventory_slot/human
	abstract_type = /datum/inventory_slot/human
	has_equip_delay = TRUE

/datum/inventory_slot/human/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if (target.slot_flags & slot)
		return TRUE
	return FALSE

/datum/inventory_slot/human/uniform
	name = "uniform"
	slot_id = ITEM_SLOT_ICLOTHING
	icon_state = "uniform"
	icon_full = "template"
	screen_loc = ui_iclothing
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/suit
	name = "suit"
	slot_id = ITEM_SLOT_OCLOTHING
	icon_state = "suit"
	icon_full = "template"
	screen_loc = ui_oclothing
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/id
	name = "id"
	slot_id = ITEM_SLOT_ID
	icon_state = "id"
	icon_full = "template_small"
	screen_loc = ui_id

/datum/inventory_slot/human/id/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	var/obj/item/bodypart/chest/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if (!owner.get_item_by_slot(ITEM_SLOT_ICLOTHING) && !HAS_TRAIT(owner, TRAIT_NO_JUMPSUIT) && (!chest || IS_ORGANIC_LIMB(chest)))
		if (!disable_warning)
			to_chat(owner, span_warning("You need a jumpsuit before you can attach this [target.name]!"))
		return FALSE

/datum/inventory_slot/human/mask
	name = "mask"
	slot_id = ITEM_SLOT_MASK
	icon_state = "mask"
	icon_full = "template"
	screen_loc = ui_mask
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/mask/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	if (!owner.get_bodypart(BODY_ZONE_HEAD))
		return FALSE

/datum/inventory_slot/human/neck
	name = "neck"
	slot_id = ITEM_SLOT_NECK
	icon_state = "neck"
	icon_full = "template"
	screen_loc = ui_neck
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY
	has_equip_delay = FALSE

/datum/inventory_slot/human/back
	name = "back"
	slot_id = ITEM_SLOT_BACK
	icon_state = "back"
	icon_full = "template_small"
	screen_loc = ui_back

/datum/inventory_slot/human/pocket
	icon_state = "pocket"
	icon_full = "template_small"
	abstract_type = /datum/inventory_slot/human/pocket
	has_equip_delay = FALSE

/datum/inventory_slot/human/pocket/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	// Let small items go into pockets even if they don't have the slot flag
	if (!. && target.w_class > POCKET_WEIGHT_CLASS)
		return
	if (HAS_TRAIT(target, TRAIT_NODROP)) // Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
		return FALSE
	return TRUE

/datum/inventory_slot/human/pocket/left
	name = "left pocket"
	slot_id = ITEM_SLOT_LPOCKET
	screen_loc = ui_storage1

/datum/inventory_slot/human/pocket/left/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	var/obj/item/bodypart/leg = owner.get_bodypart(BODY_ZONE_L_LEG)
	if (!owner.get_item_by_slot(ITEM_SLOT_ICLOTHING) && !HAS_TRAIT(owner, TRAIT_NO_JUMPSUIT) && (!leg || IS_ORGANIC_LIMB(leg)))
		if (!disable_warning)
			to_chat(owner, span_warning("You need a jumpsuit before you can put [target] in your pocket!"))
		return FALSE

/datum/inventory_slot/human/pocket/right
	name = "right pocket"
	slot_id = ITEM_SLOT_RPOCKET
	screen_loc = ui_storage2

/datum/inventory_slot/human/pocket/right/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	var/obj/item/bodypart/leg = owner.get_bodypart(BODY_ZONE_R_LEG)
	if (!owner.get_item_by_slot(ITEM_SLOT_ICLOTHING) && !HAS_TRAIT(owner, TRAIT_NO_JUMPSUIT) && (!leg || IS_ORGANIC_LIMB(leg)))
		if (!disable_warning)
			to_chat(owner, span_warning("You don't have a pocket on that side!"))
		return FALSE

/datum/inventory_slot/human/suit_storage
	name = "suit storage"
	slot_id = ITEM_SLOT_SUITSTORE
	icon_state = "suit_storage"
	icon_full = "template"
	screen_loc = ui_sstore1
	has_equip_delay = FALSE

/datum/inventory_slot/human/suit_storage/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	if (HAS_TRAIT(target, TRAIT_NODROP))
		return FALSE
	var/obj/item/clothing/suit/suit = owner.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if (!istype(suit))
		if (!disable_warning)
			to_chat(owner, span_warning("You need a suit before you can attach this [target.name]!"))
		return FALSE
	if (is_type_in_typecache(target, GLOB.any_suit_storage) || target.w_class == WEIGHT_CLASS_TINY)
		return TRUE
	if (target.w_class > WEIGHT_CLASS_BULKY)
		if (!disable_warning)
			to_chat(owner, span_warning("\The [target] is too big to attach!"))
		return FALSE
	if(is_type_in_list(target, suit.allowed))
		return TRUE
	return FALSE

/datum/inventory_slot/human/gloves
	name = "gloves"
	slot_id = ITEM_SLOT_GLOVES
	icon_state = "gloves"
	icon_full = "template"
	screen_loc = ui_gloves
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/gloves/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	if (!owner.num_hands)
		return FALSE

/datum/inventory_slot/human/eyes
	name = "eyes"
	slot_id = ITEM_SLOT_EYES
	icon_state = "glasses"
	icon_full = "template"
	screen_loc = ui_glasses
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/eyes/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	if (!owner.get_bodypart(BODY_ZONE_HEAD))
		return FALSE
	var/obj/item/organ/eyes/eyes = owner.get_organ_slot(ORGAN_SLOT_EYES)
	if (eyes?.no_glasses)
		return FALSE

/datum/inventory_slot/human/ears
	name = "ears"
	slot_id = ITEM_SLOT_EARS
	icon_state = "ears"
	icon_full = "template"
	screen_loc = ui_ears
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/ears/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	if (!owner.get_bodypart(BODY_ZONE_HEAD))
		return FALSE

/datum/inventory_slot/human/head
	name = "head"
	slot_id = ITEM_SLOT_HEAD
	icon_state = "head"
	icon_full = "template"
	screen_loc = ui_head
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/head/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	if (!owner.get_bodypart(BODY_ZONE_HEAD))
		return FALSE

/datum/inventory_slot/human/shoes
	name = "shoes"
	slot_id = ITEM_SLOT_FEET
	icon_state = "shoes"
	icon_full = "template"
	screen_loc = ui_shoes
	screen_group = HUD_GROUP_TOGGLEABLE_INVENTORY

/datum/inventory_slot/human/shoes/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	if(owner.num_legs < 2)
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	if(!(human_owner.bodytype & BODYTYPE_DIGITIGRADE) || (target.item_flags & IGNORE_DIGITIGRADE) || (target.supports_variations_flags & DIGITIGRADE_VARIATIONS))
		return
	if(!disable_warning)
		to_chat(owner, span_warning("The footwear around here isn't compatible with your feet!"))
	return FALSE

/datum/inventory_slot/human/belt
	name = "belt"
	slot_id = ITEM_SLOT_BELT
	icon_state = "belt"
	icon_full = "template_small"
	screen_loc = ui_belt

/datum/inventory_slot/human/belt/can_equip(obj/item/target, slot, disable_warning, mob/living/owner, bypass_equip_delay_self, ignore_equipped, indirect_action)
	. = ..()
	if (!.)
		return
	var/obj/item/bodypart/chest/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if (!owner.get_item_by_slot(ITEM_SLOT_ICLOTHING) && !HAS_TRAIT(owner, TRAIT_NO_JUMPSUIT) && (!chest || IS_ORGANIC_LIMB(chest)))
		if (!disable_warning)
			to_chat(owner, span_warning("You need a jumpsuit before you can attach this [target.name]!"))
		return FALSE

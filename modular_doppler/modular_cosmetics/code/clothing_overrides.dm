/obj/item/clothing
	var/attachment_slot_override = NONE

/obj/item/clothing/accessory/can_attach_accessory(obj/item/clothing/clothing_item, mob/user)
	if(!attachment_slot || (clothing_item?.attachment_slot_override & attachment_slot))
		return TRUE
	return ..()

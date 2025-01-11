/obj/item/clothing
	var/attachment_slot_override = NONE

/obj/item/clothing/accessory/can_attach_accessory(obj/item/clothing/clothing_item, mob/user)
	if(!attachment_slot || (clothing_item?.attachment_slot_override & attachment_slot))
		return TRUE
	return ..()

//for making rollerskates work again

/obj/item/clothing/shoes/wheelys
	supported_bodyshapes = null
	bodyshape_icon_files = null

/datum/component/riding/vehicle/scooter/skateboard/wheelys
	vehicle_move_delay = 1.5

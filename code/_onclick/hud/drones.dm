/datum/hud/dextrous/drone
	inventory_slots = /datum/inventory_slot/drone

/datum/hud/dextrous/drone/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/basic/drone/drone = mymob

	if(hud_shown)
		if(!isnull(drone.internal_storage))
			drone.internal_storage.screen_loc = ui_drone_storage
			drone.client.screen += drone.internal_storage
		if(!isnull(drone.head))
			drone.head.screen_loc = ui_drone_head
			drone.client.screen += drone.head
	else
		drone.internal_storage?.screen_loc = null
		drone.head?.screen_loc = null
	..()

/datum/inventory_slot/drone
	abstract_type = /datum/inventory_slot/drone

/datum/inventory_slot/drone/storage
	name = "internal storage"
	icon_state = "suit_storage"
	slot_id = ITEM_SLOT_DEX_STORAGE
	screen_loc = ui_drone_storage

/datum/inventory_slot/drone/head
	name = "head/mask"
	icon_state = "mask"
	slot_id = ITEM_SLOT_HEAD
	screen_loc = ui_drone_head

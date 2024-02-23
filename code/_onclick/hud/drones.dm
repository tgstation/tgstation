/datum/hud/dextrous/drone/New(mob/owner)
	..()
	var/atom/movable/screen/inventory/inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
// inv_box.icon_full = "template"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = ITEM_SLOT_DEX_STORAGE
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "head/mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
// inv_box.icon_full = "template"
	inv_box.screen_loc = ui_drone_head
	inv_box.slot_id = ITEM_SLOT_HEAD
	static_inventory += inv_box

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()


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

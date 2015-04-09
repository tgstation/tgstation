/datum/hud/proc/drone_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	adding = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	adding += using

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_drone_pull
	adding += mymob.pullin

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r_inactive"
	if(mymob && !mymob.hand) //Hand being true means the LEFT hand is active
		inv_box.icon_state = "hand_r_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = 19
	r_hand_hud_object = inv_box
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l_inactive"
	if(mymob && mymob.hand) //Hand being true means the LEFT hand is active
		inv_box.icon_state = "hand_l_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = 19
	l_hand_hud_object = inv_box
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = "drone_storage_slot"
	inv_box.layer = 19
	adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head/mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_drone_head
	inv_box.slot_id = slot_head
	inv_box.layer = 19
	adding += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand1
	using.layer = 19
	adding += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.layer = 19
	adding += using

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.update_icon()

	mymob.client.screen = null
	mymob.client.screen += adding

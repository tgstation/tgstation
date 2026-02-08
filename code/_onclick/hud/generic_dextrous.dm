//Used for normal mobs that have hands.
/datum/hud/dextrous/initialize_screen_objects()
	. = ..()
	var/atom/movable/screen/using
	add_screen_object(/atom/movable/screen/drop, HUD_MOB_DROP, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 1))
	using = add_screen_object(/atom/movable/screen/swap_hand, HUD_MOB_SWAPHAND_2, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 2))
	using.icon_state = "act_swap"

	mymob.canon_client?.clear_screen()

	build_hand_slots()

	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style, ui_drone_pull)
	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style, ui_movi)
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/zone_sel, HUD_MOB_ZONE_SELECTOR, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/area_creator, HUD_MOB_AREA_CREATOR, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/healthdoll/living, HUD_MOB_HEALTH, HUD_GROUP_INFO)

	if(HAS_TRAIT(mymob, TRAIT_CAN_THROW_ITEMS))
		add_screen_object(/atom/movable/screen/throw_catch, HUD_MOB_THROW, HUD_GROUP_HOTKEYS, ui_style, ui_drop_throw)

/datum/hud/dextrous/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/owner = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/held in owner.held_items)
			held.screen_loc = ui_hand_position(owner.get_held_index_of_item(held))
			owner.client.screen += held
		return

	for(var/obj/item/held in owner.held_items)
		held.screen_loc = null
		owner.client.screen -= held

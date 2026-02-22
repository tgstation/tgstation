/datum/hud/alien
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/alien/initialize_screen_objects()
	. = ..()
	build_hand_slots()

	var/atom/movable/screen/using
	using = add_screen_object(/atom/movable/screen/swap_hand, HUD_MOB_SWAPHAND_1, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 1))
	using.icon_state = "swap_1"
	using = add_screen_object(/atom/movable/screen/swap_hand, HUD_MOB_SWAPHAND_2, HUD_GROUP_STATIC, ui_style, ui_swaphand_position(mymob, 2))
	using.icon_state = "swap_2"

	add_screen_object(/atom/movable/screen/combattoggle/flashy, HUD_MOB_INTENTS, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/floor_changer, HUD_MOB_FLOOR_CHANGER, HUD_GROUP_STATIC, ui_style, ui_alien_floor_change)
	add_screen_object(/atom/movable/screen/language_menu, HUD_MOB_LANGUAGE_MENU, ui_loc = ui_alien_language_menu)
	add_screen_object(/atom/movable/screen/navigate, HUD_MOB_NAVIGATE_MENU, ui_loc = ui_alien_navigate_menu)
	add_screen_object(/atom/movable/screen/zone_sel/alien, HUD_MOB_ZONE_SELECTOR)
	add_screen_object(/atom/movable/screen/drop, HUD_MOB_DROP, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/pull, HUD_MOB_PULL, HUD_GROUP_STATIC, ui_style)
	add_screen_object(/atom/movable/screen/resist, HUD_MOB_RESIST, HUD_GROUP_HOTKEYS, ui_style)
	add_screen_object(/atom/movable/screen/throw_catch, HUD_MOB_THROW, HUD_GROUP_HOTKEYS, ui_style)
	add_screen_object(/atom/movable/screen/rest, HUD_MOB_REST, HUD_GROUP_HOTKEYS, ui_style)
	add_screen_object(/atom/movable/screen/sleep, HUD_MOB_SLEEP, HUD_GROUP_HOTKEYS, ui_style)
	add_screen_object(/atom/movable/screen/healths/alien, HUD_MOB_HEALTH, HUD_GROUP_INFO)
	add_screen_object(/atom/movable/screen/alien/plasma_display, HUD_ALIEN_PLASMA_DISPLAY, HUD_GROUP_INFO)

	if(isalienhunter(mymob))
		add_screen_object(/atom/movable/screen/alien/leap, HUD_ALIEN_HUNTER_LEAP, HUD_GROUP_STATIC, ui_style)

	if(!isalienqueen(mymob))
		add_screen_object(/atom/movable/screen/alien/plasma_display, HUD_ALIEN_QUEEN_FINDER, HUD_GROUP_INFO)

/datum/hud/alien/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/alien/adult/H = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in H.held_items)
			I.screen_loc = ui_hand_position(H.get_held_index_of_item(I))
			H.client.screen += I
	else
		for(var/obj/item/I in H.held_items)
			I.screen_loc = null
			H.client.screen -= I

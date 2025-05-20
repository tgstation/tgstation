/atom/movable/screen/alien
	icon = 'icons/hud/screen_alien.dmi'

/atom/movable/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/atom/movable/screen/alien/leap/Click()
	if(isalienhunter(usr))
		var/mob/living/carbon/alien/adult/hunter/AH = usr
		AH.toggle_leap()

/atom/movable/screen/alien/plasma_display
	name = "plasma stored"
	icon_state = "power_display"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/alien/alien_queen_finder
	name = "queen sense"
	desc = "Allows you to sense the general direction of your Queen."
	icon_state = "queen_finder"
	screen_loc = ui_alien_queen_finder

/datum/hud/alien
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/alien/New(mob/living/carbon/alien/adult/owner)
	..()

	var/atom/movable/screen/using

//equippable shit

//hands
	build_hand_slots()

//begin buttons

	using = new /atom/movable/screen/swap_hand(null, src)
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand_position(owner, 1)
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(null, src)
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner, 2)
	static_inventory += using

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	if(isalienhunter(mymob))
		var/mob/living/carbon/alien/adult/hunter/H = mymob
		H.leap_icon = new /atom/movable/screen/alien/leap()
		H.leap_icon.screen_loc = ui_alien_storage_r
		static_inventory += H.leap_icon

	floor_change = new /atom/movable/screen/floor_changer(null, src)
	floor_change.icon = ui_style
	floor_change.screen_loc = ui_alien_floor_change
	static_inventory += floor_change

	using = new/atom/movable/screen/language_menu(null, src)
	using.screen_loc = ui_alien_language_menu
	static_inventory += using

	using = new /atom/movable/screen/navigate(null, src)
	using.screen_loc = ui_alien_navigate_menu
	static_inventory += using

	using = new /atom/movable/screen/drop(null, src)
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	static_inventory += using

	resist_icon = new /atom/movable/screen/resist(null, src)
	resist_icon.icon = ui_style
	resist_icon.screen_loc = ui_above_movement
	resist_icon.update_appearance()
	hotkeybuttons += resist_icon

	throw_icon = new /atom/movable/screen/throw_catch(null, src)
	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_drop_throw
	hotkeybuttons += throw_icon

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_above_movement
	static_inventory += pull_icon

	rest_icon = new /atom/movable/screen/rest(null, src)
	rest_icon.icon = ui_style
	rest_icon.screen_loc = ui_rest
	rest_icon.update_appearance()
	static_inventory += rest_icon

	sleep_icon = new /atom/movable/screen/sleep(null, src)
	sleep_icon.icon = ui_style
	sleep_icon.screen_loc = ui_above_throw

//begin indicators

	healths = new /atom/movable/screen/healths/alien(null, src)
	infodisplay += healths

	alien_plasma_display = new /atom/movable/screen/alien/plasma_display(null, src)
	infodisplay += alien_plasma_display

	if(!isalienqueen(mymob))
		alien_queen_finder = new /atom/movable/screen/alien/alien_queen_finder(null, src)
		infodisplay += alien_queen_finder

	zone_select = new /atom/movable/screen/zone_sel/alien(null, src)
	zone_select.update_appearance()
	static_inventory += zone_select

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

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

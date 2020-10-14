/datum/hud/larva
	ui_style = 'icons/mob/screen_alien.dmi'

/datum/hud/larva/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/act_intent/alien()
	using.icon_state = mymob.a_intent
	using.hud = src
	static_inventory += using
	action_intent = using

	healths = new /atom/movable/screen/healths/alien()
	healths.hud = src
	infodisplay += healths

	alien_queen_finder = new /atom/movable/screen/alien/alien_queen_finder()
	alien_queen_finder.hud = src
	infodisplay += alien_queen_finder

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_above_movement
	pull_icon.hud = src
	hotkeybuttons += pull_icon

	using = new/atom/movable/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	using.hud = src
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel/alien()
	zone_select.hud = src
	zone_select.update_icon()
	static_inventory += zone_select

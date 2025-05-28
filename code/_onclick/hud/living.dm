/datum/hud/living/New(mob/living/owner)
	..()

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = 'icons/hud/screen_gen.dmi'
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_basic_combat_toggle
	static_inventory += action_intent

	floor_change = new /atom/movable/screen/floor_changer(null, src)
	floor_change.icon = ui_style
	floor_change.screen_loc = ui_floor_change
	static_inventory += floor_change

	var/atom/movable/screen/using

	using = new /atom/movable/screen/language_menu(null, src)
	using.icon = ui_style
	using.screen_loc = ui_basic_language_menu
	static_inventory += using

	using = new /atom/movable/screen/memories(null, src)
	using.icon = ui_style
	using.screen_loc = ui_basic_memories_menu
	static_inventory += using

	//mob health doll assumes whatever sprite the mob is
	healthdoll = new /atom/movable/screen/healthdoll/living(null, src)
	infodisplay += healthdoll

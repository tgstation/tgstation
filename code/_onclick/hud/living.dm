/datum/hud/living
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/living/New(mob/living/owner)
	..()

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = 'icons/hud/screen_midnight.dmi'
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	floor_change = new /atom/movable/screen/floor_changer(null, src)
	floor_change.icon = 'icons/hud/screen_midnight.dmi'
	static_inventory += floor_change

	//mob health doll! assumes whatever sprite the mob is
	healthdoll = new /atom/movable/screen/healthdoll/living(null, src)
	infodisplay += healthdoll

/datum/hud/dextrous/voidwalker
	ui_style = 'icons/hud/screen_voidwalker.dmi'

/datum/hud/dextrous/voidwalker/New(mob/living/owner)
	. = ..()

	floor_change.icon = ui_style
	floor_change.screen_loc = ui_above_movement
	static_inventory += floor_change

	action_intent = new /atom/movable/screen/combattoggle/flashy/voidwalker(null, src)
	action_intent.icon = ui_style
	static_inventory += action_intent

	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_rest
	static_inventory += throw_icon

	var/atom/movable/screen/space_camo_toggle = new /atom/movable/screen/space_camo(null, src)
	space_camo_toggle.screen_loc = ui_combat_toggle
	static_inventory += space_camo_toggle

/// This exists because for some reason only the combat indicator screen_loc is constantly set to initial
/atom/movable/screen/combattoggle/flashy/voidwalker
	screen_loc = ui_movi

/atom/movable/screen/space_camo
	name = "space camouflage toggle"
	icon = 'icons/hud/screen_voidwalker.dmi'
	icon_state = "camo_toggle"

	/// Wheter or not we're toggled on or off
	var/invisibility_toggle = TRUE

/atom/movable/screen/space_camo/Click()
	if(isliving(usr))
		invisibility_toggle = !invisibility_toggle
		update_appearance()

		if(invisibility_toggle)
			REMOVE_TRAIT(usr, TRAIT_INVISIBILITY_BLOCKED, type)
		else
			ADD_TRAIT(usr, TRAIT_INVISIBILITY_BLOCKED, type)

/atom/movable/screen/space_camo/update_icon_state()
	icon_state = initial(icon_state) + (invisibility_toggle ? "" : "_off")
	return ..()

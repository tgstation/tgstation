/datum/hud/ghost/initialize_screen_objects()
	. = ..()
	add_screen_object(/atom/movable/screen/ghost/spawners_menu, HUD_GHOST_SPAWNERS)
	add_screen_object(/atom/movable/screen/ghost/orbit, HUD_GHOST_ORBIT)
	add_screen_object(/atom/movable/screen/ghost/reenter_corpse, HUD_GHOST_REENTER_CORPSE)
	add_screen_object(/atom/movable/screen/ghost/dnr, HUD_GHOST_DNR)
	add_screen_object(/atom/movable/screen/ghost/teleport, HUD_GHOST_TELEPORT)
	add_screen_object(/atom/movable/screen/ghost/settings, HUD_GHOST_SETTINGS)
	add_screen_object(/atom/movable/screen/ghost/minigames_menu, HUD_GHOST_MINIGAMES)
	add_screen_object(/atom/movable/screen/language_menu/ghost, HUD_MOB_LANGUAGE_MENU)
	add_screen_object(/atom/movable/screen/floor_changer/vertical/ghost, HUD_MOB_FLOOR_CHANGER)

	var/list/hudboxes = valid_subtypesof(/atom/movable/screen/ghost/hudbox)
	for(var/i in 1 to length(hudboxes))
		add_screen_object(hudboxes[i], HUD_KEY_GHOST_HUDBOX(i), ui_loc = position_hudbox(i - 1))

/datum/hud/ghost/proc/position_hudbox(i)
	var/row = floor(i / 3)
	var/column = i % 3
	return "SOUTH:[6 + row * 16], CENTER+5:[7 + column * 15]"

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(screenmob.client.prefs.read_preference(/datum/preference/toggle/ghost_hud))
		screenmob.client.screen |= screen_groups[HUD_GROUP_STATIC]
		for(var/atom/movable/screen/ghost/hudbox/hud in screen_groups[HUD_GROUP_STATIC])
			hud.update_appearance()
	else
		screenmob.client.screen -= screen_groups[HUD_GROUP_STATIC]

//We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		return
	return ..()

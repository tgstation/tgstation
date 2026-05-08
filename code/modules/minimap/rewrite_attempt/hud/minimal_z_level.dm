/atom/movable/screen/minimap_z_indicator
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "zindicator"
	screen_loc = "BOTTOM+4,RIGHT"

/atom/movable/screen/minimap_z_indicator/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(!isnull(hud_owner.mymob))
		RegisterSignal(hud_owner.mymob, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_level_change))
		RegisterSignal(hud_owner.mymob, COMSIG_MINIMAP_CHANGE_Z_LEVEL, PROC_REF(on_minimap_change_request))
		var/current_turf = get_turf(hud_owner.mymob)
		on_z_level_change(null, current_turf, FALSE)

///sets the currently indicated relative floor
/atom/movable/screen/minimap_z_indicator/proc/on_z_level_change(turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	var/used_z = get_displayed_z_level(new_turf)
	set_floor_text(used_z)

/atom/movable/screen/minimap_z_indicator/proc/on_minimap_change_request(mob/hud_owner, new_z_change)
	SIGNAL_HANDLER
	var/atom/movable/screen/minimap_display/current_display = hud?.screen_objects[HUD_TAC_MINIMAP]
	if(isnull(current_display))
		var/current_turf = get_turf(hud_owner)
		on_z_level_change(null, current_turf, FALSE)
		return
	var/current_z = current_display.get_viewed_z_level()
	if(isnull(current_z))
		return
	var/requested_z = current_display.get_clamped_connected_z(current_z + new_z_change, current_z)
	set_floor_text(requested_z)

/atom/movable/screen/minimap_z_indicator/proc/get_displayed_z_level(turf/current_turf)
	var/atom/movable/screen/minimap_display/current_display = hud?.screen_objects[HUD_TAC_MINIMAP]
	if(!isnull(current_display?.fixed_z_level))
		return current_display.minimap?.z
	return current_turf?.z

/atom/movable/screen/minimap_z_indicator/proc/set_floor_text(used_z)
	if(isnull(used_z))
		return
	var/bottom_z = used_z
	while(SSmapping.multiz_levels?[bottom_z]?[Z_LEVEL_DOWN]) // just keep going down
		bottom_z--
	var/text = "Floor<br/>[(used_z - bottom_z) + 1]"
	maptext = MAPTEXT_TINY_UNICODE("<div align='center' valign='middle' style='position:relative; top:0px; left:0px'>[text]</div>")

/atom/movable/screen/minimap_z_up
	name = "go up"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "up"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = "BOTTOM+4,RIGHT-1"

/atom/movable/screen/minimap_z_up/Click(location, control, params)
	flick("uppressed", src)
	SEND_SIGNAL(hud.mymob, COMSIG_MINIMAP_CHANGE_Z_LEVEL, 1) // +1 z level

/atom/movable/screen/minimap_z_down
	name = "go down"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "down"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = "BOTTOM+4,RIGHT-1"

/atom/movable/screen/minimap_z_down/Click(location, control, params)
	flick("downpressed", src)
	SEND_SIGNAL(hud.mymob, COMSIG_MINIMAP_CHANGE_Z_LEVEL, -1) // -1 z level

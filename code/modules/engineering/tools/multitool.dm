/atom/movable/screen/multitool_arrow
	icon = 'icons/effects/96x96.dmi'
	icon_state = "multitool_arrow"
	pixel_x = -32
	pixel_y = -32

/atom/movable/screen/multitool_arrow/Destroy()
	if(hud)
		hud.infodisplay -= src
		INVOKE_ASYNC(hud, TYPE_PROC_REF(/datum/hud, show_hud), hud.hud_version)
	return ..()

/image/visual_maptext
	maptext_x = 0
	maptext_y = 0
	maptext_width = 160
	maptext_height = 48
	alpha = 0
	icon = null
	appearance_flags = PIXEL_SCALE
	///keeps track of upward height
	var/height_increase = 0
	///since this is an image we need to actually send this to clients
	var/list/client/current_viewers = list()

/image/visual_maptext/proc/destroy_holder()
	qdel(src)

/image/visual_maptext/proc/animate_upwards(height = 8, invisibility = 0)
	height_increase++
	if(invisibility)
		animate(src, alpha = 0, maptext_y = src.maptext_y + height, time = 4)
	else
		animate(src, maptext_y = src.maptext_y + height, time = 4)



/proc/generate_maptext(atom/target, message, style = "", alpha = 255, time = 0, x_offset = 0, y_offset = 0)
	var/image/visual_maptext/created = new /image/visual_maptext
	animate(created, maptext_y = y_offset - 4, time = 0.01)

	created.maptext = "<span style=\"[style]\">[message]</span>"
	created.loc = target
	created.maptext_x = x_offset
	animate(created, alpha = alpha, maptext_y = y_offset, time = 4, flags = ANIMATION_END_NOW)

	if(time)
		addtimer(CALLBACK(created, TYPE_PROC_REF(/image/visual_maptext, destroy_holder)), time)
	return created

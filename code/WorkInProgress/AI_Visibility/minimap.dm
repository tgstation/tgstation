
/obj/minimap_obj/Click(location, control, params)
	if(!istype(usr, /mob/dead) && !istype(usr, /mob/living/silicon/ai) && !(usr.client && usr.client.holder && usr.client.holder.level >= 4))
		return

	var/list/par = params2list(params)
	var/screen_loc = par["screen-loc"]

	if(findtext(screen_loc, "minimap:") != 1)
		return

	screen_loc = copytext(screen_loc, length("minimap:") + 1)

	var/x_text = copytext(screen_loc, 1, findtext(screen_loc, ","))
	var/y_text = copytext(screen_loc, findtext(screen_loc, ",") + 1)

	var/x = (text2num(copytext(x_text, 1, findtext(x_text, ":"))) - 1) * 16
	x += round((text2num(copytext(x_text, findtext(x_text, ":") + 1)) + 1) / 2)

	var/y = (text2num(copytext(y_text, 1, findtext(y_text, ":"))) - 1) * 16
	y += round((text2num(copytext(y_text, findtext(y_text, ":") + 1)) + 1) / 2)

	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = usr
		ai.freelook()
		ai.eyeobj.loc = locate(max(1, x - 1), max(1, y - 1), ai.eyeobj.z)
		cameranet.visibility(ai.eyeobj)

	else
		usr.loc = locate(max(1, x - 1), max(1, y - 1), usr.z)

/mob/dead/verb/Open_Minimap()
	set category = "Ghost"
	winshow(src, "minimapwindow", 1)
	client.screen |= cameranet.minimap

	if(cameranet.generating_minimap)
		cameranet.minimap_viewers += src

/mob/living/silicon/ai/verb/Open_Minimap()
	set category = "AI Commands"
	winshow(src, "minimapwindow", 1)
	client.screen |= cameranet.minimap

	if(cameranet.generating_minimap)
		cameranet.minimap_viewers += src

/client/proc/Open_Minimap()
	set category = "Admin"
	winshow(src, "minimapwindow", 1)
	screen |= cameranet.minimap

	if(cameranet.generating_minimap)
		cameranet.minimap_viewers += src.mob

/datum/camerachunk/proc/update_minimap()
	if(changed && !updating)
		update()

	minimap_icon.Blend(rgb(255, 0, 0), ICON_MULTIPLY)

	var/list/turfs = visibleTurfs | dimTurfs

	for(var/turf/turf in turfs)
		var/x = (turf.x & 0xf) * 2
		var/y = (turf.y & 0xf) * 2

		if(turf.density)
			minimap_icon.DrawBox(rgb(100, 100, 100), x + 1, y + 1, x + 2, y + 2)
			continue

		else if(istype(turf, /turf/space))
			minimap_icon.DrawBox(rgb(0, 0, 0), x + 1, y + 1, x + 2, y + 2)

		else
			minimap_icon.DrawBox(rgb(200, 200, 200), x + 1, y + 1, x + 2, y + 2)

		for(var/obj/structure/o in turf)
			if(o.density)
				if(istype(o, /obj/structure/window) && (o.dir == NORTH || o.dir == SOUTH || o.dir == EAST || o.dir == WEST))
					if(o.dir == NORTH)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 1, y + 2, x + 2, y + 2)
					else if(o.dir == SOUTH)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 1, y + 1, x + 2, y + 1)
					else if(o.dir == EAST)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 3, y + 1, x + 2, y + 2)
					else if(o.dir == WEST)
						minimap_icon.DrawBox(rgb(150, 150, 200), x + 1, y + 1, x + 1, y + 2)

				else
					minimap_icon.DrawBox(rgb(150, 150, 150), x + 1, y + 1, x + 2, y + 2)
					break

		for(var/obj/machinery/door/o in turf)
			if(istype(o, /obj/machinery/door/window))
				if(o.dir == NORTH)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 2, x + 2, y + 2)
				else if(o.dir == SOUTH)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 1, x + 2, y + 1)
				else if(o.dir == EAST)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 2, y + 1, x + 2, y + 2)
				else if(o.dir == WEST)
					minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 1, x + 1, y + 2)

			else
				minimap_icon.DrawBox(rgb(100, 150, 100), x + 1, y + 1, x + 2, y + 2)
				break

	minimap_obj.screen_loc = "minimap:[src.x / 16],[src.y / 16]"
	minimap_obj.icon = minimap_icon

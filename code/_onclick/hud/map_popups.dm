/client/
	var/list/screen_maps = list() //assoc list with all the active maps - when a screen obj is added to a map, it's put in here as well. "mapname" = list(screen objs in map)

/obj/abstract/screen
	var/assigned_map = null
	var/list/screen_info = list()//x,x pix, y, y pix || x,y

/client/proc/clear_all_popups(var/map_to_clear = null)//not really needed most of the time, as the client's screen list gets reset on relog. any of the buttons are going to get caught by garbage collection anyway. they're effectively qdel'd.
	if(!map_to_clear)
		return FALSE
	for(var/obj/abstract/screen/searched in screen)
		if(searched.assigned_map == map_to_clear)
			qdel(searched)

/client/verb/handle_popup_close(window_id as text) //when the popup closes, it calls this.
	set hidden = 1
	for(var/obj/abstract/screen/screenobj in screen_maps["[window_id]_map"])
		screen -= screenobj
		qdel(screenobj)


/client/proc/create_popup(var/name = null, var/ratiox = 100, var/ratioy=100) //ratio is how many pixels by how many pixels. keep it simple
	winclone(src,"popupwindow",name)
	var/list/winparams = new
	winparams["size"] = "[ratiox]x[ratioy]"
	winparams["command"] = "handle-popup-close [name]"
	winset(src,"[name]",list2params(winparams))
	winshow(src,"[name]",1)

	var/list/params = new
	params["parent"] = "[name]"
	params["type"] = "map"
	params["size"] = "[ratiox]x[ratioy]"
	params["anchor1"] = "0,0"
	params["anchor2"] = "[ratiox],[ratioy]"
	winset(src, "[name]_map", list2params(params))

	screen_maps["[name]_map"] = list()//initialized on the popup level, if we did it in setup_popup, we'd need to add code for the few situations where a background isn't desired.

	return "[name]_map"


/client/proc/setup_popup(var/popup_name = null,var/width = 9,var/height = 9,var/tilesize = 2) //create the popup, and get it ready for generic use by giving it a background. width/height are multiplied by 64 by degfault.
	if(!popup_name)
		return
	clear_all_popups(popup_name)
	var/x_value = world.icon_size*tilesize*width
	var/y_value = world.icon_size*tilesize*height
	var/newmap = create_popup(popup_name,x_value,y_value)
	var/obj/abstract/screen/background = new
	background.name = "background"
	background.assigned_map = newmap
	background.screen_loc = "[newmap]:1,1 TO [width],[height]"
	background.icon = 'icons/mob/actions.dmi' //change the icon to a proper one. this'll look like SHIT.
	background.icon_state = "bg_default"
	background.layer = -1
	background.plane = -1

	screen += background

	return newmap

/client/proc/add_objs_to_map(var/list/to_add)
	if(!to_add.len) return
	for(var/obj/abstract/screen/adding in to_add)
		var/len = adding.screen_info.len
		var/list/data = adding.screen_info
		switch (len)
			if(4) //set up for x/y offsets.
				if(adding.assigned_map)
					adding.screen_loc = "[adding.assigned_map]:[data[1]]:[data[2]],[data[3]],[data[4]]"
				else
					adding.screen_loc = "[data[1]]:[data[2]],[data[3]],[data[4]]"
			if(2) //set up for simple.
				if(adding.assigned_map)
					adding.screen_loc = "[adding.assigned_map]:[data[1]],[data[2]]"
				else
					adding.screen_loc = "[data[1]],[data[2]]"
			if(0) //legacy - screen_loc is already set up. don't add the map here, assumed to be old HUD code, or some custom overwrite (eg, x TO y) so it'd probably break it.

			else
				//error("[adding]'s screen_data has an invalid length. should be either 4,2,0 - it is [len]")
				continue

		screen_maps[adding.assigned_map] += adding
		screen += adding

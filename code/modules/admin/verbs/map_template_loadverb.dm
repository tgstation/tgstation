/client/proc/map_template_load()
	set category = "Debug"
	set name = "Map template - Place"

	var/datum/map_template/template

	var/map = input(src, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in SSmapping.map_templates
	if(!map)
		return
	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(mob)
	if(!T)
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		var/image/item = image('icons/turf/overlays.dmi',S,"greenOverlay")
		item.plane = ABOVE_LIGHTING_PLANE
		preview += item
	images += preview
	if(alert(src,"Confirm location.","Template Confirm","Yes","No") == "Yes")
		if(template.load(T, centered = TRUE))
			message_admins("<span class='adminnotice'>[key_name_admin(src)] has placed a map template ([template.name]) at [ADMIN_COORDJMP(T)]</span>")
		else
			to_chat(src, "Failed to place map")
	images -= preview

/client/proc/map_template_upload()
	set category = "Debug"
	set name = "Map Template - Upload"

	var/map = input(src, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]",-4) != ".dmm")
		to_chat(src, "Bad map file: [map]")
		return
	var/datum/map_template/M
	switch(alert(src, "What kind of map is this?", "Map type", "Normal", "Shuttle", "Cancel"))
		if("Normal")
			M = new /datum/map_template(map, "[map]")
		if("Shuttle")
			M = new /datum/map_template/shuttle(map, "[map]")
		else
			return
	if(M.preload_size(map))
		to_chat(src, "Map template '[map]' ready to place ([M.width]x[M.height])")
		SSmapping.map_templates[M.name] = M
		message_admins("<span class='adminnotice'>[key_name_admin(src)] has uploaded a map template ([map])</span>")
	else
		to_chat(src, "Map template '[map]' failed to load properly")

/datum/buildmode_mode/mapgen
	key = "mapgen"

	use_corner_selection = TRUE
	var/generator_path

/datum/buildmode_mode/mapgen/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select corner</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Select generator</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/mapgen/change_settings(mob/user)
	var/list/gen_paths = subtypesof(/datum/mapGenerator)
	var/list/options = list()
	for(var/path in gen_paths)
		var/datum/mapGenerator/MP = path
		options[initial(MP.buildmode_name)] = path
	var/type = input(user,"Select Generator Type","Type") as null|anything in options
	if(!type)
		return

	generator_path = options[type]
	deselect_region()

/datum/buildmode_mode/mapgen/handle_click(mob/user, params, obj/object)
	if(isnull(generator_path))
		to_chat(user, "<span class='warning'>Select generator type first.</span>")
		deselect_region()
		return
	..()

/datum/buildmode_mode/mapgen/handle_selected_area(user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	if(left_click)
		var/datum/mapGenerator/G = new generator_path
		if(istype(G, /datum/mapGenerator/repair/reload_station_map))
			if(GLOB.reloading_map)
				to_chat(user, "<span class='boldwarning'>You are already reloading an area! Please wait for it to fully finish loading before trying to load another!</span>")
				deselect_region()
				return
		G.defineRegion(cornerA, cornerB, 1)
		highlight_region(G.map)
		var/confirm = alert("Are you sure you want run the map generator?", "Run generator", "Yes", "No")
		if(confirm == "Yes")
			G.generate()
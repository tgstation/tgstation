/obj/machinery/pipedispenser
	name = "pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses countless types of pipes. Very useful if you need pipes."
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_OFFLINE
	var/wait = 0
	var/piping_layer = PIPING_LAYER_DEFAULT
	///color of pipe
	var/paint_color = "green"
	///type of dispenser
	var/category = 0
	///smart pipe directions
	var/p_init_dir = ALL_CARDINALS

/obj/machinery/pipedispenser/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/machinery/pipedispenser/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/pipes),
	)

/obj/machinery/pipedispenser/ui_static_data(mob/user)
	var/list/data = list("paint_colors" = GLOB.pipe_paint_colors)
	return data

/obj/machinery/pipedispenser/ui_data()
	var/list/data = list(
		"category" = category,
		"piping_layer" = piping_layer,
		"categories" = list(),
		"selected_color" = paint_color,
	)

	// The get the recipies for this dispenser
	var/list/recipes
	switch(category)
		if(0) // TODO: Remove magic number
			recipes = GLOB.atmos_pipe_recipes
		if(1)
			recipes = GLOB.disposal_pipe_recipes
		if(2)
			recipes = GLOB.transit_tube_recipes
	// Generate pipe categories
	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to cat.len)
			var/datum/pipe_info/info = cat[i]
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "all_layers" = info.all_layers))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))
	var/list/init_directions = list("north" = FALSE, "south" = FALSE, "east" = FALSE, "west" = FALSE)
	for(var/direction in GLOB.cardinals)
		if(p_init_dir & direction)
			init_directions[dir2text(direction)] = TRUE
	data["init_directions"] = init_directions
	return data

/obj/machinery/pipedispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("color")
			paint_color = params["paint_color"]
		if("pipe_type")
			if(wait < world.time)
				var/rec = GLOB.atmos_pipe_recipes[params["category"]][params["pipe_type"]].type
				var/p_type = GLOB.atmos_pipe_recipes[params["category"]][params["pipe_type"]].id
				
				// No spawning arbitrary paths (literally 1984)
				if(!verify_recipe(GLOB.atmos_pipe_recipes, p_type))
					return
				
				// If this is a meter, make that.
				if(rec == /datum/pipe_info/meter)
					new /obj/item/pipe_meter(loc)
					wait = world.time + 1 SECONDS
					return
				
				// Otherwise, make a pipe/device
				var/p_dir = NORTH
				var/obj/item/pipe/P = new (loc, p_type, p_dir)
				P.p_init_dir = p_init_dir
				P.pipe_color = GLOB.pipe_paint_colors[paint_color]
				P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)
				P.set_piping_layer(piping_layer)
				P.add_fingerprint(usr)
				wait = world.time + 1 SECONDS
		if("piping_layer")
			piping_layer = text2num(params["piping_layer"])
		if("init_dir_setting")
			var/target_dir = p_init_dir ^ text2dir(params["dir_flag"])
			// Refuse to create a smart pipe that can only connect in one direction (it would act weirdly and lack an icon)
			if (ISNOTSTUB(target_dir))
				p_init_dir = target_dir
			else
				to_chat(usr, span_warning("\The [src]'s screen flashes a warning: Can't configure a pipe to only connect in one direction."))
		if("init_reset")
			p_init_dir = ALL_CARDINALS
	return TRUE

/obj/machinery/pipedispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PipeDispenser", name)
		ui.open()

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		to_chat(usr, span_notice("You put [W] back into [src]."))
		qdel(W)
		return
	else
		return ..()

/obj/machinery/pipedispenser/proc/verify_recipe(recipes, path)
	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		for(var/i in cat_recipes)
			var/datum/pipe_info/info = i
			if (path == info.id)
				return TRUE
	return FALSE

/obj/machinery/pipedispenser/wrench_act(mob/living/user, obj/item/I)
	..()
	if(default_unfasten_wrench(user, I, 40))
		user << browse(null, "window=pipedispenser")

	return TRUE


/obj/machinery/pipedispenser/disposal
	name = "disposal pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses pipes that will ultimately be used to move trash around."
	density = TRUE
	category = 1


//Allow you to drag-drop disposal pipes and transit tubes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/pipe, mob/usr)
	if(!usr.incapacitated())
		return

	if (!istype(pipe, /obj/structure/disposalconstruct) && !istype(pipe, /obj/structure/c_transit_tube) && !istype(pipe, /obj/structure/c_transit_tube_pod))
		return

	if (get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	qdel(pipe)

/obj/machinery/pipedispenser/ui_act(action, params)
	switch(action)
		if("pipe_type")
			if(wait < world.time)
				var/rec = GLOB.disposal_pipe_recipes[params["category"]][params["pipe_type"]].type
				var/p_type = GLOB.disposal_pipe_recipes[params["category"]][params["pipe_type"]].id
				
				// No spawning arbitrary paths (literally 1984)
				if(!verify_recipe(GLOB.disposal_pipe_recipes, p_type))
					return
				
				var/obj/structure/disposalconstruct/C = new (loc, p_type)
				if(!C.can_place())
					to_chat(usr, span_warning("There's not enough room to build that here!"))
					qdel(C)
					return
				
				C.add_fingerprint(usr)
				C.update_appearance()
				
				wait = world.time + 1 SECONDS
	return TRUE

//transit tube dispenser
//inherit disposal for the dragging proc
/obj/machinery/pipedispenser/disposal/transit_tube
	name = "transit tube dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	desc = "Dispenses pipes that will move beings around."

/obj/machinery/pipedispenser/disposal/transit_tube/interact(mob/user)

	var/dat = {"<B>Transit Tubes:</B><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_STRAIGHT]'>Straight Tube</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_STRAIGHT_CROSSING]'>Straight Tube with Crossing</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_CURVED]'>Curved Tube</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_DIAGONAL]'>Diagonal Tube</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_DIAGONAL_CROSSING]'>Diagonal Tube with Crossing</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_JUNCTION]'>Junction</A><BR>
<b>Station Equipment:</b><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_STATION]'>Through Tube Station</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_TERMINUS]'>Terminus Tube Station</A><BR>
<A href='?src=[REF(src)];tube=[TRANSIT_TUBE_POD]'>Transit Tube Pod</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return


/obj/machinery/pipedispenser/disposal/transit_tube/Topic(href, href_list)
	if(..())
		return 1
	usr.set_machine(src)
	add_fingerprint(usr)
	if(wait < world.time)
		if(href_list["tube"])
			var/tube_type = text2num(href_list["tube"])
			var/obj/structure/C
			switch(tube_type)
				if(TRANSIT_TUBE_STRAIGHT)
					C = new /obj/structure/c_transit_tube(loc)
				if(TRANSIT_TUBE_STRAIGHT_CROSSING)
					C = new /obj/structure/c_transit_tube/crossing(loc)
				if(TRANSIT_TUBE_CURVED)
					C = new /obj/structure/c_transit_tube/curved(loc)
				if(TRANSIT_TUBE_DIAGONAL)
					C = new /obj/structure/c_transit_tube/diagonal(loc)
				if(TRANSIT_TUBE_DIAGONAL_CROSSING)
					C = new /obj/structure/c_transit_tube/diagonal/crossing(loc)
				if(TRANSIT_TUBE_JUNCTION)
					C = new /obj/structure/c_transit_tube/junction(loc)
				if(TRANSIT_TUBE_STATION)
					C = new /obj/structure/c_transit_tube/station(loc)
				if(TRANSIT_TUBE_TERMINUS)
					C = new /obj/structure/c_transit_tube/station/reverse(loc)
				if(TRANSIT_TUBE_POD)
					C = new /obj/structure/c_transit_tube_pod(loc)
			if(C)
				C.add_fingerprint(usr)
			wait = world.time + 15
	return

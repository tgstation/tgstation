/obj/machinery/pipedispenser
	name = "pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses countless types of pipes. Very useful if you need pipes."
	density = TRUE
	anchored = TRUE
	var/wait = 0
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/recipes
	var/paint_color = "Grey"
	var/atmos = TRUE

/obj/machinery/pipedispenser/Initialize()
	. = ..()
	recipes = GLOB.atmos_pipe_recipes

/obj/machinery/pipedispenser/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/pipedispenser/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/pipedispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "pipe_dispenser", name, 300, 550, master_ui, state)
		ui.open()

/obj/machinery/pipedispenser/ui_data(mob/user)
	var/list/data = list(
		"piping_layer" = piping_layer,
		"categories" = list(),
		"paint_colors" = list(),
		"atmos" = atmos
	)

	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to cat.len)
			var/datum/pipe_info/info = cat[i]
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "selected" = FALSE))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))

	data["paint_colors"] = list()
	for(var/c in GLOB.pipe_paint_colors)
		data["paint_colors"] += list(list("color_name" = c, "color_hex" = GLOB.pipe_paint_colors[c], "selected" = (c == paint_color)))

/obj/machinery/pipedispenser/ui_act(action, params)
	if(..())
		return
	if(!usr.canUseTopic(src))
		return
	switch(action)
		if("color")
			paint_color = params["paint_color"]
		if("piping_layer")
			piping_layer = text2num(params["piping_layer"])
		if("pipe_type")
			var/datum/pipe_info/recipe = recipes[params["category"]][text2num(params["pipe_type"])]
			make_pipe(recipe)

/obj/machinery/pipedispenser/proc/make_pipe(datum/pipe_info/recipe)
	if(istype(recipe, /datum/pipe_info/meter))
		var/obj/item/pipe_meter/PM = new(loc)
		PM.setAttachLayer(piping_layer)
		return

	var/obj/machinery/atmospherics/A = recipe.id
	var/p_type = initial(A.construction_type)
	var/obj/item/pipe/P = new p_type(loc, A, SOUTH)
	P.setPipingLayer(piping_layer)
	P.add_fingerprint(usr)
	P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		to_chat(usr, "<span class='notice'>You put [W] back into [src].</span>")
		qdel(W)
		return
	else if (istype(W, /obj/item/wrench))
		if (!anchored && !isinspace())
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if (do_after(user, 40*W.toolspeed, target = src))
				add_fingerprint(user)
				user.visible_message( \
					"[user] fastens \the [src].", \
					"<span class='notice'>You fasten \the [src]. Now it can dispense pipes.</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				anchored = TRUE
				stat &= MAINT
				if (usr.machine==src)
					usr << browse(null, "window=pipedispenser")
		else if(anchored)
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if (do_after(user, 20*W.toolspeed, target = src))
				add_fingerprint(user)
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"<span class='notice'>You unfasten \the [src]. Now it can be pulled somewhere else.</span>", \
					"<span class='italics'>You hear ratchet.</span>")
				anchored = FALSE
				stat |= ~MAINT
				power_change()
	else
		return ..()


/obj/machinery/pipedispenser/disposal
	name = "disposal pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses pipes that will ultimately be used to move trash around."
	density = TRUE
	anchored = TRUE
	atmos = FALSE

/obj/machinery/pipedispenser/disposal/Initialize()
	. = ..()
	recipes = GLOB.disposal_pipe_recipes

//Allow you to drag-drop disposal pipes and transit tubes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/pipe, mob/usr)
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if (!istype(pipe, /obj/structure/disposalconstruct) && !istype(pipe, /obj/structure/c_transit_tube) && !istype(pipe, /obj/structure/c_transit_tube_pod))
		return

	if (get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	qdel(pipe)

/obj/machinery/pipedispenser/disposal/make_pipe(datum/pipe_info/recipe)
	var/obj/structure/disposalconstruct/C = new (loc, recipe.id)

	if(!C.can_place())
		to_chat(usr, "<span class='warning'>There's not enough room to build that here!</span>")
		qdel(C)
		return

	C.add_fingerprint(usr)
	C.update_icon()

//transit tube dispenser
//inherit disposal for the dragging proc
/obj/machinery/pipedispenser/disposal/transit_tube
	name = "transit tube dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	desc = "Dispenses pipes that will move beings around."
	anchored = TRUE

/obj/machinery/pipedispenser/disposal/transit_tube/ui_interact()
	return

/obj/machinery/pipedispenser/disposal/transit_tube/attack_hand(mob/user)
	if(..())
		return 1

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

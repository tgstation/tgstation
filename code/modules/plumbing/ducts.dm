/*
All the important duct code:
/code/datums/components/plumbing/plumbing.dm
/code/datums/ductnet.dm
*/
/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/pipes_n_cables/hydrochem/fluid_ducts.dmi'
	icon_state = "nduct"
	layer = PLUMBING_PIPE_VISIBILE_LAYER
	use_power = NO_POWER_USE

	///bitfield with the directions we're connected in
	var/connects
	///set to TRUE to disable smart duct behaviour
	var/dumb = FALSE
	///wheter we allow our connects to be changed after initialization or not
	var/lock_connects = FALSE
	///our ductnet, wich tracks what we're connected to
	var/datum/ductnet/duct
	///amount we can transfer per process. note that the ductnet can carry as much as the lowest capacity duct
	var/capacity = 10

	///the color of our duct
	var/duct_color = COLOR_VERY_LIGHT_GRAY
	///TRUE to ignore colors, so yeah we also connect with other colors without issue
	var/ignore_colors = FALSE
	///1,2,4,8,16
	var/duct_layer = DUCT_LAYER_DEFAULT
	///whether we allow our layers to be altered
	var/lock_layers = FALSE
	///TRUE to let colors connect when forced with a wrench, false to just not do that at all
	var/color_to_color_support = TRUE
	///wheter to even bother with plumbing code or not
	var/active = TRUE
	///track ducts we're connected to. Mainly for ducts we connect to that we normally wouldn't, like different layers and colors, for when we regenerate the ducts
	var/list/neighbours = list()
	///what stack to drop when disconnected. Must be /obj/item/stack/ducts or a subtype
	var/drop_on_wrench = /obj/item/stack/ducts

/obj/machinery/duct/Initialize(mapload, no_anchor, color_of_duct = null, layer_of_duct = null, force_connects, force_ignore_colors)
	. = ..()

	if(force_connects)
		connects = force_connects //skip change_connects() because we're still initializing and we need to set our connects at one point
	if(!lock_layers && layer_of_duct)
		duct_layer = layer_of_duct
	if(force_ignore_colors)
		ignore_colors = force_ignore_colors
	if(!ignore_colors && color_of_duct)
		duct_color = color_of_duct
	if(duct_color)
		add_atom_colour(duct_color, FIXED_COLOUR_PRIORITY)

	if(no_anchor)
		active = FALSE
		set_anchored(FALSE)
	else if(!can_anchor())
		if(mapload)
			log_mapping("Overlapping ducts detected at [AREACOORD(src)], unanchoring one.")
		// Note that qdeling automatically drops a duct stack
		return INITIALIZE_HINT_QDEL

	handle_layer()

	attempt_connect()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

///start looking around us for stuff to connect to
/obj/machinery/duct/proc/attempt_connect()
	for(var/direction in GLOB.cardinals)
		if(dumb && !(direction & connects))
			continue
		for(var/atom/movable/duct_candidate in get_step(src, direction))
			if(connect_network(duct_candidate, direction))
				add_connects(direction)
	update_appearance()

///see if whatever we found can be connected to
/obj/machinery/duct/proc/connect_network(atom/movable/plumbable, direction)
	if(istype(plumbable, /obj/machinery/duct))
		return connect_duct(plumbable, direction)

	for(var/datum/component/plumbing/plumber as anything in plumbable.GetComponents(/datum/component/plumbing))
		. += connect_plumber(plumber, direction) //so that if one is true, all is true. beautiful.

///connect to a duct
/obj/machinery/duct/proc/connect_duct(obj/machinery/duct/other, direction)
	var/opposite_dir = REVERSE_DIR(direction)
	if(!active || !other.active)
		return

	if(!dumb && other.dumb && !(opposite_dir & other.connects))
		return
	if(dumb && other.dumb && !(connects & other.connects)) //we eliminated a few more scenarios in attempt connect
		return

	if((duct == other.duct) && duct)//check if we're not just comparing two null values
		add_neighbour(other, direction)

		other.add_connects(opposite_dir)
		other.update_appearance()
		return TRUE //tell the current pipe to also update its sprite
	if(!(other in neighbours)) //we cool
		if((duct_color != other.duct_color) && !(ignore_colors || other.ignore_colors))
			return
		if(!(duct_layer & other.duct_layer))
			return

	if(other.duct)
		if(duct)
			duct.assimilate(other.duct)
		else
			other.duct.add_duct(src)
	else
		if(duct)
			duct.add_duct(other)
		else
			create_duct()
			duct.add_duct(other)

	add_neighbour(other, direction)

	//Delegate to timer subsystem so its handled the next tick and doesnt cause byond to mistake it for an infinite loop and kill the game
	addtimer(CALLBACK(other, PROC_REF(attempt_connect)))

	return TRUE

///connect to a plumbing object
/obj/machinery/duct/proc/connect_plumber(datum/component/plumbing/plumbing, direction)
	var/opposite_dir = REVERSE_DIR(direction)

	if(!(duct_layer & plumbing.ducting_layer))
		return FALSE

	if(!plumbing.active)
		return

	var/comp_directions = plumbing.supply_connects + plumbing.demand_connects //they should never, ever have supply and demand connects overlap or catastrophic failure
	if(opposite_dir & comp_directions)
		if(!duct)
			create_duct()
		if(duct.add_plumber(plumbing, opposite_dir))
			neighbours[plumbing.parent] = direction
			return TRUE

///we disconnect ourself from our neighbours. we also destroy our ductnet and tell our neighbours to make a new one
/obj/machinery/duct/proc/disconnect_duct(skipanchor)
	if(!skipanchor) //since set_anchored calls us too.
		set_anchored(FALSE)
	active = FALSE
	if(duct)
		duct.remove_duct(src)
	lose_neighbours()
	reset_connects(0)
	update_appearance()
	if(ispath(drop_on_wrench))
		var/obj/item/stack/ducts/duct_stack = new drop_on_wrench(drop_location())
		duct_stack.duct_color = GLOB.pipe_color_name[duct_color] || DUCT_COLOR_OMNI
		duct_stack.duct_layer = GLOB.plumbing_layer_names["[duct_layer]"] || GLOB.plumbing_layer_names["[DUCT_LAYER_DEFAULT]"]
		duct_stack.add_atom_colour(duct_color, FIXED_COLOUR_PRIORITY)
		drop_on_wrench = null
	if(!QDELING(src))
		qdel(src)

///Special proc to draw a new connect frame based on neighbours. not the norm so we can support multiple duct kinds
/obj/machinery/duct/proc/generate_connects()
	if(lock_connects)
		return
	connects = 0
	for(var/A in neighbours)
		connects |= neighbours[A]
	update_appearance()

///create a new duct datum
/obj/machinery/duct/proc/create_duct()
	duct = new()
	duct.add_duct(src)

///add a duct as neighbour. this means we're connected and will connect again if we ever regenerate
/obj/machinery/duct/proc/add_neighbour(obj/machinery/duct/other, direction)
	if(!(other in neighbours))
		neighbours[other] = direction
	if(!(src in other.neighbours))
		other.neighbours[src] = REVERSE_DIR(direction)

///remove all our neighbours, and remove us from our neighbours aswell
/obj/machinery/duct/proc/lose_neighbours()
	for(var/obj/machinery/duct/other in neighbours)
		other.neighbours.Remove(src)
		other.generate_connects()
	neighbours = list()

///add a connect direction
/obj/machinery/duct/proc/add_connects(new_connects) //make this a define to cut proc calls?
	if(!lock_connects)
		connects |= new_connects

///remove a connect direction
/obj/machinery/duct/proc/remove_connects(dead_connects)
	if(!lock_connects)
		connects &= ~dead_connects

///remove our connects
/obj/machinery/duct/proc/reset_connects()
	if(!lock_connects)
		connects = 0

///get a list of the ducts we can connect to if we are dumb
/obj/machinery/duct/proc/get_adjacent_ducts()
	var/list/adjacents = list()
	for(var/direction in GLOB.cardinals)
		if(direction & connects)
			for(var/obj/machinery/duct/other in get_step(src, direction))
				if((REVERSE_DIR(direction) & other.connects) && other.active)
					adjacents += other
	return adjacents

/obj/machinery/duct/update_icon_state()
	var/temp_icon = initial(icon_state)
	for(var/direction in GLOB.cardinals)
		switch(direction & connects)
			if(NORTH)
				temp_icon += "_n"
			if(SOUTH)
				temp_icon += "_s"
			if(EAST)
				temp_icon += "_e"
			if(WEST)
				temp_icon += "_w"
	icon_state = temp_icon
	return ..()

///update the layer we are on
/obj/machinery/duct/proc/handle_layer()
	var/offset
	//it's a bitfield, but it's fine because ducts themselves are only on one layer
	switch(duct_layer)
		if(FIRST_DUCT_LAYER)
			offset = -10
		if(SECOND_DUCT_LAYER)
			offset = -5
		if(THIRD_DUCT_LAYER)
			offset = 0
		if(FOURTH_DUCT_LAYER)
			offset = 5
		if(FIFTH_DUCT_LAYER)
			offset = 10
	pixel_x = offset
	pixel_y = offset

	layer = initial(layer) + duct_layer * 0.0003

/obj/machinery/duct/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	if(anchorvalue)
		active = TRUE
		attempt_connect()
	else
		disconnect_duct(TRUE)

/obj/machinery/duct/wrench_act(mob/living/user, obj/item/wrench) //I can also be the RPD
	..()
	add_fingerprint(user)
	wrench.play_tool_sound(src)
	if(anchored || can_anchor())
		set_anchored(!anchored)
		user.visible_message( \
		"[user] [anchored ? null : "un"]fastens \the [src].", \
		span_notice("You [anchored ? null : "un"]fasten \the [src]."), \
		span_hear("You hear ratcheting."))
	return TRUE

///collection of all the sanity checks to prevent us from stacking ducts that shouldn't be stacked
/obj/machinery/duct/proc/can_anchor(turf/destination)
	if(!destination)
		destination = get_turf(src)
	for(var/obj/machinery/duct/other in destination)
		if(other.anchored && other != src && (duct_layer & other.duct_layer))
			return FALSE
	for(var/obj/machinery/machine in destination)
		for(var/datum/component/plumbing/plumber as anything in machine.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & duct_layer)
				return FALSE
	return TRUE

/obj/machinery/duct/doMove(destination)
	. = ..()
	disconnect_duct()
	set_anchored(FALSE)

/obj/machinery/duct/Destroy()
	disconnect_duct()
	return ..()

/obj/machinery/duct/mouse_drop_receive(atom/drag_source, mob/living/user, params)
	if(!istype(drag_source, /obj/machinery/duct))
		return
	var/obj/machinery/duct/other = drag_source
	if(get_dist(src, other) != 1)
		return
	var/direction = get_dir(src, other)
	if(!(direction in GLOB.cardinals))
		return
	if(!(duct_layer & other.duct_layer))
		to_chat(user, span_warning("The ducts must be on the same layer to connect them!"))
		return
	var/obj/item/held_item = user.get_active_held_item()
	if(held_item?.tool_behaviour != TOOL_WRENCH)
		to_chat(user, span_warning("You need to be holding a wrench in your active hand to do that!"))
		return

	add_connects(direction) //the connect of the other duct is handled in connect_network, but do this here for the parent duct because it's not necessary in normal cases
	add_neighbour(other, direction)
	connect_network(other, direction)
	update_appearance()
	held_item.play_tool_sound(src)
	to_chat(user, span_notice("You connect the two plumbing ducts."))

/obj/item/stack/ducts
	name = "stack of duct"
	desc = "A stack of fluid ducts."
	singular_name = "duct"
	icon = 'icons/obj/pipes_n_cables/hydrochem/fluid_ducts.dmi'
	icon_state = "ducts"
	mats_per_unit = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*5)
	w_class = WEIGHT_CLASS_TINY
	novariants = FALSE
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/ducts
	matter_amount = 1
	///Color of our duct
	var/duct_color = "omni"
	///Default layer of our duct
	var/duct_layer = "Default Layer"

/obj/item/stack/ducts/examine(mob/user)
	. = ..()
	. += span_notice("Its current color and layer are [duct_color] and [duct_layer]. Use in-hand to change.")

/obj/item/stack/ducts/attack_self(mob/user)
	var/new_layer = tgui_input_list(user, "Select a layer", "Layer", GLOB.plumbing_layers, duct_layer)
	if(!user.is_holding(src))
		return
	if(new_layer)
		duct_layer = new_layer
	var/new_color = tgui_input_list(user, "Select a color", "Color", GLOB.pipe_paint_colors, duct_color)
	if(!user.is_holding(src))
		return
	if(new_color)
		duct_color = new_color
		add_atom_colour(GLOB.pipe_paint_colors[new_color], FIXED_COLOUR_PRIORITY)

/obj/item/stack/ducts/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/machinery/duct))
		var/obj/machinery/duct/duct = interacting_with
		if(duct.anchored)
			to_chat(user, span_warning("The duct must be unanchored before it can be picked up."))
			return ITEM_INTERACT_BLOCKING

		// Turn into a duct stack and then merge to the in-hand stack.
		var/obj/item/stack/ducts/stack = new(duct.loc, 1, FALSE)
		qdel(duct)
		if(stack.can_merge(src))
			stack.merge(src)
		return ITEM_INTERACT_SUCCESS

	check_attach_turf(interacting_with)
	return ITEM_INTERACT_SUCCESS


/obj/item/stack/ducts/proc/check_attach_turf(atom/target)
	if(isopenturf(target) && use(1))
		var/turf/open/open_turf = target
		var/is_omni = duct_color == DUCT_COLOR_OMNI
		new /obj/machinery/duct(open_turf, FALSE, GLOB.pipe_paint_colors[duct_color], GLOB.plumbing_layers[duct_layer], null, is_omni)
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)

/obj/item/stack/ducts/fifty
	amount = 50

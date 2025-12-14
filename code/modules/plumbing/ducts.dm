/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/pipes_n_cables/hydrochem/fluid_ducts.dmi'
	icon_state = "nduct"
	layer = PLUMBING_PIPE_VISIBILE_LAYER
	use_power = NO_POWER_USE

	///our ductnet, wich tracks what we're connected to
	var/datum/ductnet/net
	///the color of our duct
	var/duct_color = ATMOS_COLOR_OMNI
	///the layer of the duct
	var/duct_layer = DUCT_LAYER_DEFAULT
	///track machines we're connected to.
	var/list/atom/movable/neighbours

/obj/machinery/duct/Initialize(mapload, color_of_duct, layer_of_duct)
	if(GLOB.plumbing_layer_names["[layer_of_duct]"])
		duct_layer = layer_of_duct

	var/turf/destination = get_turf(src)
	//check for overlapping ducts
	for(var/obj/machinery/duct/other in destination)
		if(other != src && (duct_layer & other.duct_layer))
			if(mapload)
				log_mapping("Overlapping ducts detected at [AREACOORD(src)].")
			return INITIALIZE_HINT_QDEL
	//check for overlapping machines
	for(var/obj/machinery/machine in destination)
		for(var/datum/component/plumbing/plumber as anything in machine.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & duct_layer)
				if(mapload)
					log_mapping("Overlapping machine detected at [AREACOORD(src)].")
				return INITIALIZE_HINT_QDEL

	. = ..()

	net = new (src)

	if(GLOB.pipe_color_name[color_of_duct])
		duct_color = color_of_duct
	add_atom_colour(duct_color, FIXED_COLOUR_PRIORITY)

	var/offset
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

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

/obj/machinery/duct/post_machine_initialize()
	. = ..()
	attempt_connect()
	LAZYINITLIST(neighbours)

///we disconnect ourself from our neighbours. we also destroy our ductnet and tell our neighbours to make a new one
/obj/machinery/duct/on_deconstruction()
	var/obj/item/stack/ducts/duct_stack = new (drop_location())
	duct_stack.duct_color = duct_color
	duct_stack.duct_layer = duct_layer
	duct_stack.add_atom_colour(duct_color, FIXED_COLOUR_PRIORITY)

///Removes duct from ductnet
/obj/machinery/duct/proc/disconnect()
	//remove ourself from the duct
	net.ducts -= src
	if(!net.ducts.len)
		qdel(net) //destroy the pipeline. Suppliers aren't important if there are ducts
	net = null

/obj/machinery/duct/Destroy()
	//object was early deleted
	if(!net)
		return ..()

	var/list/atom/movable/visited = list(src = TRUE)
	for(var/atom/movable/neighbour as anything in neighbours)
		//disconnect ourself from our neighbours
		var/obj/machinery/duct/pipe = neighbour
		if(istype(pipe))
			pipe.neighbours -= src
			pipe.update_appearance(UPDATE_ICON_STATE)

		//find every node that can be reached from our neighbour making sure to not revisit it again in circles
		if(visited[neighbour])
			continue
		var/list/atom/movable/network = list()
		var/list/atom/movable/queue = list(neighbour)
		while(queue.len)
			var/atom/movable/target = popleft(queue)
			if(visited[target])
				continue
			visited[target] = TRUE
			network += target

			//visit all neighbours of this pipe as well
			pipe = target
			if(istype(pipe))
				for(var/atom/movable/node in pipe.neighbours)
					queue += node

		//first move all ducts to the new network
		var/datum/ductnet/newnet
		for(var/atom/movable/node as anything in network)
			//assign duct to new network
			pipe = node
			if(istype(pipe))
				pipe.disconnect()
				if(!newnet)
					newnet = new
				newnet.ducts += pipe
				pipe.net = newnet
				continue

			//assign machines to new network
			for(var/datum/component/plumbing/plumbing as anything in node.GetComponents(/datum/component/plumbing))
				for(var/dirtext in plumbing.ducts)
					if(plumbing.ducts[dirtext] == net)
						net.remove_plumber(plumbing)
						if(newnet)
							newnet.add_plumber(plumbing, text2num(dirtext))
	neighbours.Cut()

	disconnect()

	return ..()

/obj/machinery/duct/update_icon_state()
	var/temp_icon = initial(icon_state)

	//compute connections
	var/connects = NONE
	for(var/A in neighbours)
		connects |= neighbours[A]

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

///start looking around us for stuff to connect to
/obj/machinery/duct/proc/attempt_connect()
	for(var/direction in GLOB.cardinals)
		for(var/atom/movable/plumbable in get_step(src, direction))
			var/opposite_dir = REVERSE_DIR(direction)

			//we have already connected. happens in circular connections
			if(LAZYACCESS(neighbours, plumbable))
				continue

			if(istype(plumbable, /obj/machinery/duct))
				var/obj/machinery/duct/other = plumbable

				//must be same duct color
				if((duct_color != other.duct_color) && !(duct_color == ATMOS_COLOR_OMNI || other.duct_color == ATMOS_COLOR_OMNI))
					continue
				//must be same duct layer
				if(!(duct_layer & other.duct_layer))
					continue

				//connecting ductnets but only for non circular connections where we don't merge ourselves
				if(net != other.net)
					net.assimilate(other.net)

				//connecting us to duct
				LAZYADDASSOC(neighbours, other, direction)
				//connecting duct to us
				LAZYADDASSOC(other.neighbours, src, opposite_dir)
				other.update_appearance(UPDATE_ICON_STATE)

				continue

			for(var/datum/component/plumbing/plumbing as anything in plumbable.GetComponents(/datum/component/plumbing))
				//not anchored
				if(!plumbing.active())
					continue

				//not on the same layer
				if(!(duct_layer & plumbing.ducting_layer))
					continue

				//does the duct backend connect to either supplier or demander
				if(!(opposite_dir & (plumbing.supply_connects | plumbing.demand_connects)))
					continue

				//connect duct to plumber
				if(!net.add_plumber(plumbing, opposite_dir))
					continue

				//assign neighbour
				LAZYADDASSOC(neighbours, plumbing.parent, direction)

	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/duct/wrench_act(mob/living/user, obj/item/wrench) //I can also be the RPD
	wrench.play_tool_sound(src)

	user.visible_message( \
	"[user] ununfastens \the [src].", \
	span_notice("You unfasten \the [src]."), \
	span_hear("You hear ratcheting."))

	deconstruct()
	return ITEM_INTERACT_SUCCESS

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
	var/duct_color = ATMOS_COLOR_OMNI
	///Default layer of our duct
	var/duct_layer = THIRD_DUCT_LAYER

/obj/item/stack/ducts/examine(mob/user)
	. = ..()
	. += span_notice("Its current color and layer are [GLOB.pipe_color_name[duct_color]] and [GLOB.plumbing_layer_names["[duct_layer]"]]. Use in-hand to change.")

/obj/item/stack/ducts/attack_self(mob/user)
	var/new_layer = tgui_input_list(user, "Select a layer", "Layer", GLOB.plumbing_layers, GLOB.plumbing_layer_names["[duct_layer]"])
	if(!user.is_holding(src))
		return
	if(new_layer)
		duct_layer = new_layer
	var/new_color = tgui_input_list(user, "Select a color", "Color", GLOB.pipe_paint_colors, GLOB.pipe_color_name[duct_color])
	if(!user.is_holding(src))
		return
	if(new_color)
		duct_color = new_color
		add_atom_colour(GLOB.pipe_paint_colors[new_color], FIXED_COLOUR_PRIORITY)

/obj/item/stack/ducts/wrench_act(mob/living/user, obj/item/tool)
	. = check_attach_turf(loc)
	if(!.)
		. = ITEM_INTERACT_FAILURE

/obj/item/stack/ducts/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = NONE
	if(istype(interacting_with, /obj/machinery/duct))
		var/obj/machinery/duct/duct = interacting_with

		// Turn into a duct stack and then merge to the in-hand stack.
		var/obj/item/stack/ducts/stack = new(duct.loc, 1, FALSE)
		qdel(duct)
		if(stack.can_merge(src))
			stack.merge(src)
		return ITEM_INTERACT_SUCCESS

	return check_attach_turf(interacting_with)

/obj/item/stack/ducts/proc/check_attach_turf(turf/open_turf)
	. = NONE
	if(isopenturf(open_turf) && use(1))
		new /obj/machinery/duct(open_turf, duct_color, duct_layer)
		playsound(open_turf, 'sound/machines/click.ogg', 50, TRUE)
		qdel(src)
		return ITEM_INTERACT_SUCCESS

/obj/item/stack/ducts/fifty
	amount = 50

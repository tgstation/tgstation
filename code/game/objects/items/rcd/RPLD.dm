///The plumbing RCD. All the blueprints are located in _globalvars > lists > construction.dm
/obj/item/construction/plumbing
	name = "Plumbing Constructor"
	desc = "An expertly modified RCD outfitted to construct plumbing machinery."
	icon_state = "plumberer2"
	inhand_icon_state = "plumberer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	worn_icon_state = "plumbing"
	icon = 'icons/obj/tools.dmi'
	slot_flags = ITEM_SLOT_BELT
	///it does not make sense why any of these should be installed.
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS  | RCD_UPGRADE_FURNISHING
	matter = 200
	max_matter = 200

	///type of the plumbing machine
	var/obj/machinery/blueprint = null
	///index, used in the attack self to get the type. stored here since it doesnt change
	var/list/choices = list()
	///All info for construction
	var/list/machinery_data = list("cost" = list())
	///This list that holds all the plumbing design types the plumberer can construct. Its purpose is to make it easy to make new plumberer subtypes with a different selection of machines.
	var/list/plumbing_design_types
	///Current selected layer
	var/current_layer = "Default Layer"
	///Current selected color, for ducts
	var/current_color = "omni"
	///maps layer name to layer number value. didnt make this global cause only this class needs it
	var/static/list/name_to_number = list(
		"First Layer" = 1,
		"Second Layer" = 2,
		"Default Layer" = 3,
		"Fourth Layer" = 4,
		"Fifth Layer" = 5,
	)

/obj/item/construction/plumbing/Initialize(mapload)
	. = ..()

	//design types supported for this plumbing rcd
	set_plumbing_designs()

	//set cost of each machine & initial blueprint
	for(var/obj/machinery/plumbing/plumbing_type as anything in plumbing_design_types)
		machinery_data["cost"][plumbing_type] = plumbing_design_types[plumbing_type]
	blueprint =  plumbing_design_types[1]

/obj/item/construction/plumbing/proc/set_plumbing_designs()
	plumbing_design_types = list(
		//category 1 Synthesizers i.e devices which creates , reacts & destroys chemicals
		/obj/machinery/plumbing/synthesizer = 15,
		/obj/machinery/plumbing/reaction_chamber/chem = 15,
		/obj/machinery/plumbing/grinder_chemical = 30,
		/obj/machinery/plumbing/growing_vat = 20,
		/obj/machinery/plumbing/fermenter = 30,
		/obj/machinery/plumbing/liquid_pump = 35, //extracting chemicals from ground is one way of creation
		/obj/machinery/plumbing/disposer = 10,
		/obj/machinery/plumbing/buffer = 10, //creates chemicals as it waits for other buffers containing other chemicals and when mixed creates new chemicals

		//category 2 distributors i.e devices which inject , move around , remove chemicals from the network
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/layer_manifold = 5,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/sender = 20,
		/obj/machinery/plumbing/output = 5,

		//category 3 Storage i.e devices which stores & makes the processed chemicals ready for consumption
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
		/obj/machinery/plumbing/bottler = 50,
		/obj/machinery/plumbing/pill_press = 20,
		/obj/machinery/iv_drip/plumbing = 20
	)

/obj/item/construction/plumbing/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_MOUSE_SCROLL_ON, PROC_REF(mouse_wheeled))
	else
		UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)

/obj/item/construction/plumbing/dropped(mob/user, silent)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/construction/plumbing/cyborg_unequip(mob/user)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/construction/plumbing/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/construction/plumbing/examine(mob/user)
	. = ..()
	. += "You can scroll your mouse wheel to change the piping layer."
	. += "You can right click a fluid duct to set the Plumbing RPD to its color and layer."

/obj/item/construction/plumbing/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlumbingService", name)
		ui.open()

/obj/item/construction/plumbing/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/plumbing),
	)

/obj/item/construction/plumbing/ui_static_data(mob/user)
	return list("paint_colors" = GLOB.pipe_paint_colors)

///find which category this design belongs to
/obj/item/construction/plumbing/proc/get_category(obj/machinery/recipe)
	if(ispath(recipe, /obj/machinery/plumbing))
		var/obj/machinery/plumbing/plumbing_design = recipe
		return initial(plumbing_design.category)
	else if(ispath(recipe , /obj/machinery/duct))
		return "Distribution"
	else
		return "Storage"

/obj/item/construction/plumbing/ui_data(mob/user)
	var/list/data = ..()

	data["piping_layer"] = name_to_number[current_layer] //maps layer name to layer number's 1,2,3,4,5
	data["selected_color"] = current_color
	data["layer_icon"] = "plumbing_layer[GLOB.plumbing_layers[current_layer]]"
	data["selected_category"] = get_category(blueprint)
	data["selected_recipe"] = initial(blueprint.name)

	var/list/category_list = list()
	var/category_name = ""
	var/obj/machinery/recipe = null

	for(var/i in 1 to plumbing_design_types.len)
		recipe = plumbing_design_types[i]

		category_name = get_category(recipe) //get category of design
		if(!category_list[category_name])
			var/list/item_list = list()
			item_list["cat_name"] = category_name //used by RapidPipeDispenser.js
			item_list["recipes"] = list() //used by RapidPipeDispenser.js
			category_list[category_name] = item_list

		//add item to category
		category_list[category_name]["recipes"] += list(list(
			"index" = i,
			"icon" = initial(recipe.icon_state),
			"name" = initial(recipe.name),
		))

	data["categories"] = list()
	for(category_name in category_list)
		data["categories"] += list(category_list[category_name])

	return data

/obj/item/construction/plumbing/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("color")
			var/color = params["paint_color"]
			if(GLOB.pipe_paint_colors[color] != null) //validate if the color is in the allowed list of values
				current_color = color
		if("piping_layer")
			var/bitflag = text2num(params["piping_layer"])  //convert from layer number back to layer string
			bitflag = 1 << (bitflag - 1)
			var/layer = GLOB.plumbing_layer_names["[bitflag]"]
			if(layer != null) //validate if this value exists in the list
				current_layer = layer
		if("recipe")
			var/design = plumbing_design_types[text2num(params["id"])]
			if(design != null) //validate if design is valid
				blueprint = design
			playsound(src, 'sound/effects/pop.ogg', 50, vary = FALSE)

	return TRUE


///pretty much rcd_create, but named differently to make myself feel less bad for copypasting from a sibling-type
/obj/item/construction/plumbing/proc/create_machine(atom/destination, mob/user)
	if(!machinery_data || !isopenturf(destination))
		return FALSE

	//resource & placement sanity check before & after delay
	var/is_allowed = TRUE
	if(!checkResource(machinery_data["cost"][blueprint], user) || !(is_allowed = canPlace(destination)))
		if(!is_allowed)
			balloon_alert(user, "turf is blocked!")
			return FALSE
	if(!do_after(user, machinery_data["cost"][blueprint], target = destination)) //"cost" is relative to delay at a rate of 10 matter/second  (1matter/decisecond) rather than playing with 2 different variables since everyone set it to this rate anyways.
		return FALSE
	if(!checkResource(machinery_data["cost"][blueprint], user) || !(is_allowed = canPlace(destination)))
		if(!is_allowed)
			balloon_alert(user, "turf is blocked!")
			return FALSE

	if(!useResource(machinery_data["cost"][blueprint], user))
		return FALSE
	activate()
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	if(ispath(blueprint, /obj/machinery/duct))
		var/is_omni = current_color == DUCT_COLOR_OMNI
		new blueprint(destination, FALSE, GLOB.pipe_paint_colors[current_color], GLOB.plumbing_layers[current_layer], null, is_omni)
	else
		new blueprint(destination, FALSE, GLOB.plumbing_layers[current_layer])
	return TRUE

/obj/item/construction/plumbing/proc/canPlace(turf/destination)
	if(!isopenturf(destination))
		return FALSE
	if(initial(blueprint.density) && destination.is_blocked_turf(exclude_mobs = FALSE, source_atom = null, ignore_atoms = null))
		return FALSE
	. = TRUE

	var/layer_id = GLOB.plumbing_layers[current_layer]
	for(var/obj/content_obj in destination.contents)
		// Make sure plumbling isn't overlapping.
		for(var/datum/component/plumbing/plumber as anything in content_obj.GetComponents(/datum/component/plumbing))
			if(plumber.ducting_layer & layer_id)
				return FALSE

		// Make sure ducts aren't overlapping.
		if(istype(content_obj, /obj/machinery/duct))
			var/obj/machinery/duct/duct_machine = content_obj
			if(duct_machine.duct_layer & layer_id)
				return FALSE

/obj/item/construction/plumbing/pre_attack_secondary(obj/machinery/target, mob/user, params)
	if(!istype(target, /obj/machinery/duct))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/obj/machinery/duct/duct = target
	if(duct.duct_layer && duct.duct_color)
		current_color = GLOB.pipe_color_name[duct.duct_color]
		current_layer = GLOB.plumbing_layer_names["[duct.duct_layer]"]
		balloon_alert(user, "using [current_color], layer [current_layer]")

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/plumbing/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(target.type in plumbing_design_types)
		var/obj/machinery/machine_target = target
		if(machine_target.anchored)
			balloon_alert(user, "anchor first!")
			return
		if(do_after(user, 20, target = target))
			machine_target.deconstruct() //Let's not substract matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE) //this is just such a great sound effect
	else
		create_machine(target, user)

/obj/item/construction/plumbing/AltClick(mob/user)
	ui_interact(user)

/obj/item/construction/plumbing/proc/mouse_wheeled(mob/source, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	if(source.incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
		return
	if(delta_y == 0)
		return

	if(delta_y < 0)
		var/current_loc = GLOB.plumbing_layers.Find(current_layer) + 1
		if(current_loc > GLOB.plumbing_layers.len)
			current_loc = 1
		current_layer = GLOB.plumbing_layers[current_loc]
	else
		var/current_loc = GLOB.plumbing_layers.Find(current_layer) - 1
		if(current_loc < 1)
			current_loc = GLOB.plumbing_layers.len
		current_layer = GLOB.plumbing_layers[current_loc]
	to_chat(source, span_notice("You set the layer to [current_layer]."))

/obj/item/construction/plumbing/research
	name = "research plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed to conduct cytological research."
	icon_state = "plumberer_sci"
	inhand_icon_state = "plumberer_sci"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

/obj/item/construction/plumbing/research/set_plumbing_designs()
	plumbing_design_types = list(
		//category 1 synthesizers
		/obj/machinery/plumbing/reaction_chamber = 15,
		/obj/machinery/plumbing/grinder_chemical = 30,
		/obj/machinery/plumbing/disposer = 10,
		/obj/machinery/plumbing/growing_vat = 20,

		//category 2 Distributors
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/output = 5,

		//category 3 storage
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
	)

/obj/item/construction/plumbing/service
	name = "service plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed to make a brewery."
	icon_state = "plumberer_service"

/obj/item/construction/plumbing/service/set_plumbing_designs()
	plumbing_design_types = list(
		//category 1 synthesizers
		/obj/machinery/plumbing/synthesizer/soda = 15,
		/obj/machinery/plumbing/synthesizer/beer = 15,
		/obj/machinery/plumbing/reaction_chamber = 15,
		/obj/machinery/plumbing/buffer = 10,
		/obj/machinery/plumbing/fermenter = 30,
		/obj/machinery/plumbing/grinder_chemical = 30,
		/obj/machinery/plumbing/disposer = 10,


		//category 2 distributors
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/layer_manifold = 5,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/output/tap = 5,
		/obj/machinery/plumbing/sender = 20,

		//category 3 storage
		/obj/machinery/plumbing/bottler = 50,
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
	)

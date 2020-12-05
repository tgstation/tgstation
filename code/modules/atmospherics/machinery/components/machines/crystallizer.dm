/obj/machinery/atmospherics/components/unary/crystallizer
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	name = "crystallizer"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	var/recipe_type = null

	pipe_flags = PIPING_ONE_PER_TURF

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"

/obj/machinery/atmospherics/components/unary/crystallizer/Initialize()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/crystallizer/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/crystallizer/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/crystallizer/update_icon()
	cut_overlays()

	if(panel_open)
		icon_state = icon_state_open
	else if(on && is_operational)
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

	add_overlay(getpipeimage(icon, "pipe", dir, , piping_layer))

/obj/machinery/atmospherics/components/unary/crystallizer/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/crystallizer/proc/check_gas_requirements()
	. = FALSE
	var/gas_check = 0
	var/datum/gas_mixture/air_contents = airs[1]
	if(!air_contents.total_moles())
		return FALSE
	var/list/recipe = GLOB.gas_recipe_meta[recipe_type]
	message_admins("[recipe]")
	for(var/datum/gas/gas in air_contents.gases)
		if(gas in (recipe[META_RECIPE_REQUIREMENTS]))
			gas_check++
	message_admins("[gas_check]")
	if(gas_check == (recipe[META_RECIPE_REQUIREMENTS].len))
		. = TRUE

/obj/machinery/atmospherics/components/unary/crystallizer/process_atmos()
	if(!on || !nodes[1] || !is_operational || recipe_type == null)
		return

	if(!check_gas_requirements())
		return
	message_admins("AHHHHHHHHHHHHH IT WOOOOOORKKKKKKKKKKKSSSSSSS")

/obj/machinery/atmospherics/components/unary/crystallizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Crystallizer", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/crystallizer/ui_data()
	var/data = list()
	data["on"] = on

	data["recipe_types"] = list()
	data["recipe_types"] += list(list("name" = "Nothing", "path" = "", "selected" = !recipe_type))
	for(var/path in GLOB.gas_recipe_meta)
		var/list/recipe = GLOB.gas_recipe_meta[path]
		data["recipe_types"] += list(list("name" = recipe[META_RECIPE_NAME], "id" = recipe[META_RECIPE_ID], "requirements" = recipe[META_RECIPE_REQUIREMENTS], "selected" = (path == gas_id2path(recipe_type))))

	return data

/obj/machinery/atmospherics/components/unary/crystallizer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("recipe")
			recipe_type = null
			var/recipe_name = "nothing"
			var/recipe = recipe_id2path(params["mode"])
			if(recipe in GLOB.gas_recipe_meta)
				recipe_type = recipe
				recipe_name	= GLOB.gas_recipe_meta[recipe][META_RECIPE_NAME]
			investigate_log("was set to recipe [recipe_name] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
	update_icon()

/obj/machinery/atmospherics/components/unary/bluespace_sender
	icon = 'icons/obj/atmospherics/components/bluespace_gas_selling.dmi'
	icon_state = "bluespace_sender_off"
	name = "Bluespace Gas Sender"
	desc = "Sends gases to the bluespace network to be shared with the connected vendors, who knows what's beyond!"

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/bluespace_sender
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	///Base icon name for updating the appearance
	var/base_icon = "bluespace_sender"
	///Gas mixture containing the inserted gases and that is connected to the vendors
	var/datum/gas_mixture/bluespace_network
	///Rate of gas transfer inside the network (from 0 to 1)
	var/gas_transfer_rate = 0.5
	///A base price for each and every gases, in case you don't want to change them
	var/list/base_prices = list()
	///List storing all the vendors connected to the machine
	var/list/vendors
	///Amount of credits gained from each vendor
	var/credits_gained = 0

/obj/machinery/atmospherics/components/unary/bluespace_sender/Initialize(mapload)
	. = ..()
	initialize_directions = dir
	bluespace_network = new
	for(var/gas_id in GLOB.meta_gas_info)
		bluespace_network.assert_gas(gas_id)
	for(var/gas_id in GLOB.meta_gas_info)
		var/datum/gas/gas = gas_id
		base_prices[gas_id] = initial(gas.base_value)

	update_appearance()

/obj/machinery/atmospherics/components/unary/bluespace_sender/Destroy()
	if(bluespace_network.total_moles())
		var/turf/local_turf = get_turf(src)
		local_turf.assume_air(bluespace_network)
	return ..()

/obj/machinery/atmospherics/components/unary/bluespace_sender/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon]_open"
		return ..()
	if(on && is_operational)
		icon_state = "[base_icon]_on"
		return ..()
	icon_state = "[base_icon]_off"
	return ..()

/obj/machinery/atmospherics/components/unary/bluespace_sender/update_overlays()
	. = ..()
	. += get_pipe_image(icon, "pipe", dir, , piping_layer)
	if(showpipe)
		. += get_pipe_image(icon, "pipe", initialize_directions)

/obj/machinery/atmospherics/components/unary/bluespace_sender/process_atmos()
	if(!is_operational || !on || !nodes[1])  //if it has no power or its switched off, dont process atmos
		return

	var/datum/gas_mixture/content = airs[1]
	var/datum/gas_mixture/remove = content.remove_ratio(gas_transfer_rate)
	bluespace_network.merge(remove)
	bluespace_network.temperature = T20C
	update_parents()

/obj/machinery/atmospherics/components/unary/bluespace_sender/attackby(obj/item/item, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon]_open", "[base_icon]_off", item))
			update_appearance()
			return
	if(default_change_direction_wrench(user, item))
		return
	if(item.tool_behaviour == TOOL_CROWBAR && panel_open && bluespace_network.total_moles() > 0)
		say("WARNING - Bluespace network can contain hazardous gases, deconstruct with caution!")
		if(!do_after(user, 3 SECONDS, src))
			return
	if(default_deconstruction_crowbar(item))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/bluespace_sender/default_change_direction_wrench(mob/user, obj/item/item)
	if(!..())
		return FALSE
	set_init_directions()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullify_pipenet(parents[1])

	atmos_init()
	node = nodes[1]
	if(node)
		node.atmos_init()
		node.add_member(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/bluespace_sender/multitool_act(mob/living/user, obj/item/item)
	var/obj/item/multitool/multitool = item
	multitool.buffer = src
	to_chat(user, span_notice("You store linkage information in [item]'s buffer."))
	return TRUE

/obj/machinery/atmospherics/components/unary/bluespace_sender/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceSender", name)
		ui.open()

/obj/machinery/atmospherics/components/unary/bluespace_sender/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["gas_transfer_rate"] = gas_transfer_rate
	var/list/bluespace_gasdata = list()
	if(bluespace_network.total_moles())
		for(var/gas_id in bluespace_network.gases)
			bluespace_gasdata.Add(list(list(
			"name" = bluespace_network.gases[gas_id][GAS_META][META_GAS_NAME],
			"id" = bluespace_network.gases[gas_id][GAS_META][META_GAS_ID],
			"amount" = round(bluespace_network.gases[gas_id][MOLES], 0.01),
			"price" = base_prices[gas_id],
			)))
	else
		for(var/gas_id in bluespace_network.gases)
			bluespace_gasdata.Add(list(list(
				"name" = bluespace_network.gases[gas_id][GAS_META][META_GAS_NAME],
				"id" = "",
				"amount" = 0,
				"price" = 0,
				)))
	data["bluespace_network_gases"] = bluespace_gasdata
	var/list/vendors_list = list()
	if(vendors)
		for(var/obj/machinery/bluespace_vendor/vendor in vendors)
			vendors_list.Add(list(list(
				"name" = vendor.name,
				"area" = get_area(vendor),
			)))
	data["vendors_list"] = vendors_list
	data["credits"] = credits_gained
	return data

/obj/machinery/atmospherics/components/unary/bluespace_sender/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			update_appearance()
			. = TRUE

		if("rate")
			gas_transfer_rate = clamp(params["rate"], 0, 1)
			. = TRUE

		if("price")
			var/gas_type = gas_id2path(params["gas_type"])
			base_prices[gas_type] = clamp(params["gas_price"], 0, 100)
			. = TRUE

		if("retrieve")
			if(bluespace_network.total_moles() > 0)
				var/datum/gas_mixture/remove = bluespace_network.remove(bluespace_network.total_moles())
				airs[1].merge(remove)
				update_parents()
				bluespace_network.garbage_collect()
			. = TRUE

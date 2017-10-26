/obj/machinery/exonet_node
	name = "exonet node"
	desc = null // Gets written in New()
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "exonet_node"
	idle_power_usage = 2500
	density = 1
	var/on = 1
	var/toggle = 1

	var/allow_external_PDAs = 1
	var/allow_external_communicators = 1
	var/allow_external_newscasters = 1

	var/opened = 0

	var/list/logs = list() // Gets written to by exonet's send_message() function.

// Proc: New()
// Parameters: None
// Description: Adds components to the machine for deconstruction.
/obj/machinery/exonet_node/map/New()
	..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telecomms/exonet_node(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/ansible(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/filter(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/crystal(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/treatment(src)
	component_parts += new /obj/item/weapon/stock_parts/subspace/treatment(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)
	RefreshParts()

	desc = "This machine is one of many, many nodes inside [using_map.starsys_name]'s section of the Exonet, connecting the [using_map.station_short] to the rest of the system, at least \
	electronically."

// Proc: update_icon()
// Parameters: None
// Description: Self explanatory.
/obj/machinery/exonet_node/update_icon()
	if(on)
		if(!allow_external_PDAs && !allow_external_communicators && !allow_external_newscasters)
			icon_state = "[initial(icon_state)]_idle"
		else
			icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_off"

// Proc: update_power()
// Parameters: None
// Description: Sets the device on/off and adjusts power draw based on stat and toggle variables.
/obj/machinery/exonet_node/proc/update_power()
	if(toggle)
		if(stat & (BROKEN|NOPOWER|EMPED))
			on = 0
			idle_power_usage = 0
		else
			on = 1
			idle_power_usage = 2500
	else
		on = 0
		idle_power_usage = 0
	update_icon()

// Proc: emp_act()
// Parameters: 1 (severity - how strong the EMP is, with lower numbers being stronger)
// Description: Shuts off the machine for awhile if an EMP hits it.  Ion anomalies also call this to turn it off.
/obj/machinery/exonet_node/emp_act(severity)
	if(!(stat & EMPED))
		stat |= EMPED
		var/duration = (300 * 10)/severity
		spawn(rand(duration - 20, duration + 20))
			stat &= ~EMPED
	update_icon()
	..()

// Proc: process()
// Parameters: None
// Description: Calls the procs below every tick.
/obj/machinery/exonet_node/process()
	update_power()

// Proc: attackby()
// Parameters: 2 (I - the item being whacked against the machine, user - the person doing the whacking)
// Description: Handles deconstruction.
/obj/machinery/exonet_node/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user, I)
	else if(istype(I, /obj/item/weapon/crowbar))
		default_deconstruction_crowbar(user, I)
	else
		..()

// Proc: attack_ai()
// Parameters: 1 (user - the AI clicking on the machine)
// Description: Redirects to attack_hand()
/obj/machinery/exonet_node/attack_ai(mob/user)
	attack_hand(user)

// Proc: attack_hand()
// Parameters: 1 (user - the person clicking on the machine)
// Description: Opens the NanoUI interface with ui_interact()
/obj/machinery/exonet_node/attack_hand(mob/user)
	ui_interact(user)

// Proc: ui_interact()
// Parameters: 4 (standard NanoUI arguments)
// Description: Allows the user to turn the machine on or off, or open or close certain 'ports' for things like external PDA messages, newscasters, etc.
/obj/machinery/exonet_node/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// this is the data which will be sent to the ui
	var/data[0]


	data["on"] = toggle ? 1 : 0
	data["allowPDAs"] = allow_external_PDAs
	data["allowCommunicators"] = allow_external_communicators
	data["allowNewscasters"] = allow_external_newscasters
	data["logs"] = logs


	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "exonet_node.tmpl", "Exonet Node #157", 400, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

// Proc: Topic()
// Parameters: 2 (standard Topic arguments)
// Description: Responds to button presses on the NanoUI interface.
/obj/machinery/exonet_node/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["toggle_power"])
		toggle = !toggle
		update_power()
		if(!toggle)
			var/msg = "[usr.client.key] ([usr]) has turned [src] off, at [x],[y],[z]."
			message_admins(msg)
			log_game(msg)

	if(href_list["toggle_PDA_port"])
		allow_external_PDAs = !allow_external_PDAs

	if(href_list["toggle_communicator_port"])
		allow_external_communicators = !allow_external_communicators
		if(!allow_external_communicators)
			var/msg = "[usr.client.key] ([usr]) has turned [src]'s communicator port off, at [x],[y],[z]."
			message_admins(msg)
			log_game(msg)

	if(href_list["toggle_newscaster_port"])
		allow_external_newscasters = !allow_external_newscasters
		if(!allow_external_newscasters)
			var/msg = "[usr.client.key] ([usr]) has turned [src]'s newscaster port off, at [x],[y],[z]."
			message_admins(msg)
			log_game(msg)

	update_icon()
	nanomanager.update_uis(src)
	add_fingerprint(usr)

// Proc: get_exonet_node()
// Parameters: None
// Description: Helper proc to get a reference to an Exonet node.
/proc/get_exonet_node()
	for(var/obj/machinery/exonet_node/E in GLOB.machines)
		if(E.on)
			return E

// Proc: write_log()
// Parameters: 4 (origin_address - Where the message is from, target_address - Where the message is going, data_type - Instructions on how to interpet content,
// 		content - The actual message.
// Description: This writes to the logs list, so that people can see what people are doing on the Exonet ingame.  Note that this is not an admin logging function.
// 		Communicators are already logged seperately.
/obj/machinery/exonet_node/proc/write_log(var/origin_address, var/target_address, var/data_type, var/content)
	//var/timestamp = time2text(station_time_in_ticks, "hh:mm:ss")
	var/timestamp = "[stationdate2text()] [stationtime2text()]"
	var/msg = "[timestamp] | FROM [origin_address] TO [target_address] | TYPE: [data_type] | CONTENT: [content]"
	logs.Add(msg)

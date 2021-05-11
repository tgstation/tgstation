#define EXTRACTION_ORE_AMOUNT 1

/obj/machinery/drill
	name = "drilling apparatus"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	use_power = NO_POWER_USE
	density = TRUE
	anchored = TRUE
	var/ore_extraction_rate = 0.1
	var/extraction_amount
	var/obj/structure/ore_vein/current_vein
	var/obj/item/stack/ore/ore_to_spawn
	var/operating = FALSE
	var/is_powered = FALSE

	var/obj/machinery/ore_exit_port/port
	var/obj/machinery/drills_controller/controller

	var/connected = FALSE

/obj/machinery/drill/Initialize()
	. = ..()
	current_vein = locate(/obj/structure/ore_vein) in loc
	if(!current_vein || !current_vein.discovered)
		repack()
		return
	if(!id_tag)
		id_tag = SSnetworks.assign_random_name()
	ore_to_spawn = current_vein.ore_type
	RegisterSignal(current_vein, COMSIG_PARENT_QDELETING, .proc/consumed_vein)

/obj/machinery/drill/Destroy()
	if(controller)
		controller.drills -= src
	if(current_vein)
		current_vein = null
		ore_to_spawn = null
	if(port)
		port = null
	return ..()

/obj/machinery/drill/process(delta_time)
	if(!current_vein || !operating || !is_powered || !connected)
		return
	if(!port)
		return
	extract_ores(delta_time)

/obj/machinery/drill/proc/extract_ores(delta_time)
	extraction_amount += ore_extraction_rate * EXTRACTION_ORE_AMOUNT * delta_time
	if(extraction_amount >= 1)
		var/ore_amount = round(extraction_amount, 1)
		extraction_amount -= ore_amount
		current_vein.reduce_ore_amount(ore_amount)
		if(port)
			new ore_to_spawn(port.loc, ore_amount)

/obj/machinery/drill/proc/consumed_vein()
	UnregisterSignal(current_vein, COMSIG_PARENT_QDELETING)
	repack()

/obj/machinery/drill/proc/repack()
	if(current_vein)
		current_vein = null
	new/obj/item/drill_package(loc)
	qdel(src)

/obj/machinery/drill/proc/connect_port()
	if(connected)
		return
	for(var/obj/machinery/ore_exit_port/port_to_find in GLOB.machines)
		if(port_to_find)
			connected = TRUE
			port = port_to_find
			RegisterSignal(port, COMSIG_PARENT_QDELETING, .proc/disconnect_port)
			break

/obj/machinery/drill/proc/disconnect_port()
	UnregisterSignal(port, COMSIG_PARENT_QDELETING)
	connected = FALSE
	port = null

/obj/item/drill_package
	name = "drill pack"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "box_corner"

/obj/item/drill_package/Initialize()
	. = ..()
	AddComponent(/datum/component/gps, name)

/obj/item/drill_package/attack_self(mob/user, modifiers)
	var/turf/user_location = get_turf(user.loc)
	if(locate(/obj/machinery/drill) in user_location)
		to_chat(user, "<span class='warning'>A drill is already present!</span>")
		return
	if(locate(/obj/structure/ore_vein) in user_location)
		new/obj/machinery/drill(user_location)
		qdel(src)

/obj/machinery/drills_controller
	name = "mining drills controller"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE
	var/list/obj/machinery/drill/drills = list()
	var/connecting = FALSE

/obj/machinery/drills_controller/process()
	if(!drills.len)
		return

	if(!is_operational)
		remove_drills()

	var/power_drill = 0
	for(var/obj/machinery/drill/considered_drill in drills)
		if(considered_drill.operating && considered_drill.is_powered && considered_drill.ore_extraction_rate > 0 && considered_drill.connected)
			power_drill += considered_drill.ore_extraction_rate * 20000

	if(power_drill > 0)
		use_power(power_drill, AREA_USAGE_EQUIP)

/obj/machinery/drills_controller/proc/get_drills()
	for(var/obj/machinery/drill/drill_to_check in GLOB.machines)
		drills |= drill_to_check
		drill_to_check.controller = src
		drill_to_check.connect_port()

/obj/machinery/drills_controller/proc/remove_drills()
	for(var/obj/machinery/drill/considered_drill in drills)
		considered_drill.is_powered = FALSE
		considered_drill.operating = FALSE
		considered_drill.controller = null
		drills -= considered_drill

/obj/machinery/drills_controller/proc/connected()
	get_drills()
	connecting = FALSE
	if(drills.len)
		visible_message("<span class='notice'>Drills reconnected successfully.</span>")
	else
		visible_message("<span class='notice'>No drills found.</span>")

/obj/machinery/drills_controller/ui_interact(mob/user, datum/tgui/ui)
	if(panel_open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DrillsController", name)
		ui.open()

/obj/machinery/drills_controller/ui_data()
	var/data = list()
	for(var/obj/machinery/drill/considered_drill in drills)
		data["online_drills"] += list(list(
			"name" = considered_drill.name,
			"coord" = "[considered_drill.x], [considered_drill.y], [considered_drill.z]",
			"operating" = considered_drill.operating,
			"powered" = considered_drill.is_powered,
			"connected" = considered_drill.connected,
			"extraction_rate" = considered_drill.ore_extraction_rate * 10,
			"ore_type" = considered_drill.current_vein.true_name,
			"ore_amount" = considered_drill.current_vein.ore_amount_current,
			"power_consumption" = considered_drill.ore_extraction_rate * 20000,
			"drill_id" = considered_drill.id_tag
			))
	return data

/obj/machinery/drills_controller/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("operating")
			var/drill_id = params["drill_id"]
			for(var/obj/machinery/drill/considered_drill in drills)
				if(drill_id == considered_drill.id_tag)
					considered_drill.operating = !considered_drill.operating
					break
			. = TRUE
		if("power")
			var/drill_id = params["drill_id"]
			for(var/obj/machinery/drill/considered_drill in drills)
				if(drill_id == considered_drill.id_tag)
					considered_drill.is_powered = !considered_drill.is_powered
					break
			. = TRUE
		if("rate")
			var/amount = params["amount"]
			var/drill_id = params["drill_id"]
			if(text2num(amount) != null)
				amount = text2num(amount)
				. = TRUE
			if(.)
				for(var/obj/machinery/drill/considered_drill in drills)
					if(drill_id == considered_drill.id_tag)
						considered_drill.ore_extraction_rate = clamp(amount * 0.1, 0, 2)
		if("reconnect")
			if(!connecting)
				connecting = TRUE
				visible_message("<span class='notice'>Searching for available drills.</span>")
				addtimer(CALLBACK(src, .proc/connected), 2.5 SECONDS)
				. = TRUE
			else
				visible_message("<span class='warning'>Operation not available.</span>")

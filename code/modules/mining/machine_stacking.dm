/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "Controls a stacking machine... in theory."
	density = FALSE
	circuit = /obj/item/circuitboard/machine/stacking_unit_console
	/// Connected stacking machine
	var/obj/machinery/mineral/stacking_machine/machine

/obj/machinery/mineral/stacking_unit_console/Initialize(mapload)
	. = ..()
	var/area/our_area = get_area(src)
	if(!isnull(our_area))
		return
	var/list/turf_list = our_area.get_turfs_by_zlevel(z)
	if(!islist(turf_list))
		return
	for (var/turf/area_turf as anything in turf_list)
		var/obj/machinery/mineral/stacking_machine/found_machine = locate(/obj/machinery/mineral/stacking_machine) in area_turf
		if(!isnull(found_machine) && isnull(found_machine.console))
			found_machine.console = src
			machine = found_machine
			break

/obj/machinery/mineral/stacking_unit_console/Destroy()
	if(!isnull(machine))
		machine.console = null
		machine = null
	return ..()

/obj/machinery/mineral/stacking_unit_console/multitool_act(mob/living/user, obj/item/multitool/M)
	M.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mineral/stacking_unit_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StackingConsole", name)
		ui.open()

/obj/machinery/mineral/stacking_unit_console/ui_data(mob/user)
	var/list/data = list()
	data["machine"] = machine ? TRUE : FALSE
	data["stacking_amount"] = null
	data["contents"] = list()
	if(machine)
		data["stacking_amount"] = machine.stack_amt
		data["input_direction"] = dir2text(machine.input_dir)
		data["output_direction"] = dir2text(machine.output_dir)
		for(var/stack_type in machine.stack_list)
			var/obj/item/stack/sheet/stored_sheet = machine.stack_list[stack_type]
			if(stored_sheet.amount <= 0)
				continue
			data["contents"] += list(list(
				"type" = stored_sheet.type,
				"name" = capitalize(stored_sheet.name),
				"amount" = stored_sheet.amount,
			))
	return data

/obj/machinery/mineral/stacking_unit_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("release")
			var/obj/item/stack/sheet/released_type = text2path(params["type"])
			if(!released_type || !(initial(released_type.merge_type) in machine.stack_list))
				return //someone tried to spawn materials by spoofing hrefs
			var/obj/item/stack/sheet/inp = machine.stack_list[initial(released_type.merge_type)]
			var/obj/item/stack/sheet/out = new inp.type(null, inp.amount)
			inp.amount = 0
			machine.unload_mineral(out)
			return TRUE
		if("rotate")
			var/input = text2num(params["input"])
			machine.rotate(input)
			return TRUE

/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	desc = "A machine that automatically stacks acquired materials. Controlled by a nearby console."
	density = TRUE
	circuit = /obj/item/circuitboard/machine/stacking_machine
	input_dir = EAST
	output_dir = WEST
	var/obj/machinery/mineral/stacking_unit_console/console
	var/stk_types = list()
	var/stk_amt = list()
	var/stack_list[0] //Key: Type. Value: Instance of type.
	var/stack_amt = 50 //amount to stack before releassing
	var/datum/component/remote_materials/materials
	var/force_connect = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/machinery/mineral/stacking_machine/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	materials = AddComponent(
		/datum/component/remote_materials, \
		mapload, \
		FALSE, \
		(mapload && force_connect) \
	)

/obj/machinery/mineral/stacking_machine/Destroy()
	if(!isnull(console))
		console.machine = null
		console = null
	materials = null
	return ..()

/obj/machinery/mineral/stacking_machine/HasProximity(atom/movable/AM)
	if(QDELETED(AM))
		return
	if(istype(AM, /obj/item/stack/sheet) && AM.loc == get_step(src, input_dir))
		process_sheet(AM)

/obj/machinery/mineral/stacking_machine/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	if(user.combat_mode || multi_tool.item_flags & ABSTRACT || multi_tool.flags_1 & HOLOGRAM_1)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	. = ITEM_INTERACT_BLOCKING
	if(istype(multi_tool.buffer, /obj/machinery/mineral/stacking_unit_console))
		console = multi_tool.buffer
		console.machine = src
		to_chat(user, span_notice("You link [src] to the console in [multi_tool]'s buffer."))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/mineral/stacking_machine/proc/rotate(input)
	if (input)
		input_dir = turn(input_dir, 90)
	else
		output_dir = turn(output_dir, 90)
	if (input_dir == output_dir)
		rotate(input)

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/input)
	if(QDELETED(input))
		return

	// Dump the sheets to the silo if attached
	if(materials.silo && !materials.on_hold())
		var/matlist = input.custom_materials & materials.mat_container.materials
		if (length(matlist))
			materials.insert_item(input)
			return

	// No silo attached process to internal storage
	var/key = input.merge_type
	var/obj/item/stack/sheet/storage = stack_list[key]
	if(!storage) //It's the first of this sheet added
		stack_list[key] = storage = new input.type(src, 0)
	storage.amount += input.amount //Stack the sheets
	qdel(input)

	while(storage.amount >= stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new input.type(null, stack_amt)
		unload_mineral(out)
		storage.amount -= stack_amt

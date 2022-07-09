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
	/// Direction for which console looks for stacking machine to connect to
	var/machinedir = SOUTHEAST

/obj/machinery/mineral/stacking_unit_console/Initialize(mapload)
	. = ..()
	machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
	if (machine)
		machine.console = src

/obj/machinery/mineral/stacking_unit_console/Destroy()
	if(machine)
		machine.console = null
		machine = null
	return ..()

/obj/machinery/mineral/stacking_unit_console/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, span_notice("You store linkage information in [I]'s buffer."))
	return TRUE

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
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50 //amount to stack before releassing
	var/datum/component/remote_materials/materials
	var/force_connect = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/machinery/mineral/stacking_machine/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	materials = AddComponent(/datum/component/remote_materials, "stacking", mapload, FALSE, mapload && force_connect)

/obj/machinery/mineral/stacking_machine/Destroy()
	if(console)
		console.machine = null
		console = null
	materials = null
	return ..()

/obj/machinery/mineral/stacking_machine/HasProximity(atom/movable/AM)
	if(QDELETED(AM))
		return
	if(istype(AM, /obj/item/stack/sheet) && AM.loc == get_step(src, input_dir))
		process_sheet(AM)

/obj/machinery/mineral/stacking_machine/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(istype(M.buffer, /obj/machinery/mineral/stacking_unit_console))
			console = M.buffer
			console.machine = src
			to_chat(user, span_notice("You link [src] to the console in [M]'s buffer."))
			return TRUE

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/inp)
	if(QDELETED(inp))
		return

	// Dump the sheets to the silo if attached
	if(materials.silo && !materials.on_hold())
		var/matlist = inp.custom_materials & materials.mat_container.materials
		if (length(matlist))
			var/inserted = materials.mat_container.insert_item(inp)
			materials.silo_log(src, "collected", inserted, "sheets", matlist)
			qdel(inp)
			return

	// No silo attached process to internal storage
	var/key = inp.merge_type
	var/obj/item/stack/sheet/storage = stack_list[key]
	if(!storage) //It's the first of this sheet added
		stack_list[key] = storage = new inp.type(src, 0)
	storage.amount += inp.amount //Stack the sheets
	qdel(inp)

	while(storage.amount >= stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new inp.type(null, stack_amt)
		unload_mineral(out)
		storage.amount -= stack_amt

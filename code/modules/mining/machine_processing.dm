/// Smelt amount per second
#define SMELT_AMOUNT 5

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	/// The current direction of `input_turf`, in relation to the machine.
	var/input_dir = NORTH
	/// The current direction, in relation to the machine, that items will be output to.
	var/output_dir = SOUTH
	/// The turf the machines listens to for items to pick up. Calls the `pickup_item()` proc.
	var/turf/input_turf = null
	/// Determines if this machine needs to pick up items. Used to avoid registering signals to `/mineral` machines that don't pickup items.
	var/needs_item_input = FALSE

/obj/machinery/mineral/Initialize(mapload)
	. = ..()
	if(needs_item_input && anchored)
		register_input_turf()

/// Gets the turf in the `input_dir` direction adjacent to the machine, and registers signals for ATOM_ENTERED and ATOM_CREATED. Calls the `pickup_item()` proc when it receives these signals.
/obj/machinery/mineral/proc/register_input_turf()
	input_turf = get_step(src, input_dir)
	if(input_turf) // make sure there is actually a turf
		RegisterSignals(input_turf, list(COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_ENTERED), PROC_REF(pickup_item))

/// Unregisters signals that are registered the machine's input turf, if it has one.
/obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		UnregisterSignal(input_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))

/obj/machinery/mineral/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!needs_item_input || !anchored)
		return
	unregister_input_turf()
	register_input_turf()

/obj/machinery/mineral/shuttleRotate(rotation, params)
	. = ..()
	input_dir = angle2dir(rotation + dir2angle(input_dir))
	output_dir = angle2dir(rotation + dir2angle(output_dir))

/**
	Base proc for all `/mineral` subtype machines to use. Place your item pickup behavior in this proc when you override it for your specific machine.

	Called when the COMSIG_ATOM_ENTERED and COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON signals are sent.

	Arguments:
	* source - the turf that is listening for the signals.
	* target - the atom that just moved onto the `source` turf.
	* oldLoc - the old location that `target` was at before moving onto `source`.
*/
/obj/machinery/mineral/proc/pickup_item(datum/source, atom/movable/target, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	return

/// Generic unloading proc. Takes an atom as an argument and forceMove's it to the turf adjacent to this machine in the `output_dir` direction.
/obj/machinery/mineral/proc/unload_mineral(atom/movable/unloaded_mineral)
	unloaded_mineral.forceMove(drop_location())
	var/turf/unload_turf = get_step(src, output_dir)
	if(unload_turf)
		unloaded_mineral.forceMove(unload_turf)

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN|INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_OPEN_SILICON
	/// Connected ore processing machine.
	var/obj/machinery/mineral/processing_unit/processing_machine

/obj/machinery/mineral/processing_unit_console/Initialize(mapload)
	. = ..()
	processing_machine = locate(/obj/machinery/mineral/processing_unit) in view(2, src)
	if (processing_machine)
		processing_machine.mineral_machine = src
	else
		return INITIALIZE_HINT_QDEL

/obj/machinery/mineral/processing_unit_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProcessingConsole")
		ui.open()

/obj/machinery/mineral/processing_unit_console/ui_static_data(mob/user)
	return processing_machine.ui_static_data()

/obj/machinery/mineral/processing_unit_console/ui_data(mob/user)
	return processing_machine.ui_data()

/obj/machinery/mineral/processing_unit_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("setMaterial")
			var/datum/material/new_material = locate(params["value"])
			if(!istype(new_material))
				return

			processing_machine.selected_material = new_material
			processing_machine.selected_alloy = null
			return TRUE

		if("setAlloy")
			processing_machine.selected_material = null
			processing_machine.selected_alloy = params["value"]
			return TRUE

		if("toggle")
			processing_machine.on = !processing_machine.on
			if(processing_machine.on)
				processing_machine.begin_processing()
			return TRUE

/obj/machinery/mineral/processing_unit_console/Destroy()
	processing_machine = null
	return ..()


/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	needs_item_input = TRUE
	var/on = FALSE
	var/selected_alloy
	var/obj/machinery/mineral/mineral_machine
	var/datum/material/selected_material
	var/datum/techweb/stored_research
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor
	///Material container for materials
	var/datum/component/material_container/materials
	/// What can be input into the machine?
	var/accepted_type = /obj/item/stack

/obj/machinery/mineral/processing_unit/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)

	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		INFINITY, \
		MATCONTAINER_EXAMINE, \
		allowed_items = accepted_type \
	)
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter] = new /datum/techweb/autounlocking/smelter
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter]
	selected_material = GET_MATERIAL_REF(/datum/material/iron)

/obj/machinery/mineral/processing_unit/Destroy()
	materials = null
	mineral_machine = null
	stored_research = null
	return ..()

/obj/machinery/mineral/processing_unit/proc/process_ore(obj/item/stack/O)
	if(QDELETED(O))
		return
	var/material_amount = materials.get_item_material_amount(O)
	if(!materials.has_space(material_amount))
		unload_mineral(O)
	else
		materials.insert_item(O)

/obj/machinery/mineral/processing_unit/ui_static_data()
	var/list/data = list()

	for(var/datum/material/material as anything in materials.materials)
		var/obj/display = initial(material.sheet_type)
		data["materialIcons"] += list(
			list(
				"id" = REF(material),
				"icon" = icon2base64(icon(initial(display.icon), icon_state = initial(display.icon_state), frame = 1)),
				)
			)

	for(var/research in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(research)
		var/obj/display = initial(design.build_path)
		data["alloyIcons"] += list(
			list(
				"id" = design.id,
				"icon" = icon2base64(icon(initial(display.icon), icon_state = initial(display.icon_state), frame = 1)),
				)
			)

	data += materials.ui_static_data()

	return data

/obj/machinery/mineral/processing_unit/ui_data()
	var/list/data = list()

	data["materials"] = materials.ui_data()
	data["selectedMaterial"] = selected_material?.name

	data["alloys"] = list()
	for(var/research in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(research)
		data["alloys"] += list(
			list(
				"name" = design.name,
				"id" = design.id,
				)
			)
	data["selectedAlloy"] = selected_alloy

	data["state"] = on

	return data

/obj/machinery/mineral/processing_unit/pickup_item(datum/source, atom/movable/target, direction)
	if(QDELETED(target))
		return
	if(istype(target, accepted_type))
		process_ore(target)

/obj/machinery/mineral/processing_unit/process(seconds_per_tick)
	if(!on)
		return PROCESS_KILL

	if(selected_material)
		smelt_ore(seconds_per_tick)
	else if(selected_alloy)
		smelt_alloy(seconds_per_tick)

/obj/machinery/mineral/processing_unit/proc/smelt_ore(seconds_per_tick = 2)
	var/datum/material/mat = selected_material
	if(!mat)
		return
	var/sheets_to_remove = (materials.materials[mat] >= (SHEET_MATERIAL_AMOUNT * SMELT_AMOUNT * seconds_per_tick) ) ? SMELT_AMOUNT * seconds_per_tick : round(materials.materials[mat] /  SHEET_MATERIAL_AMOUNT)
	if(!sheets_to_remove)
		on = FALSE
	else
		var/out = get_step(src, output_dir)
		materials.retrieve_sheets(sheets_to_remove, mat, out)

/obj/machinery/mineral/processing_unit/proc/smelt_alloy(seconds_per_tick = 2)
	var/datum/design/alloy = stored_research.isDesignResearchedID(selected_alloy) //check if it's a valid design
	if(!alloy)
		on = FALSE
		return

	var/amount = can_smelt(alloy, seconds_per_tick)

	if(!amount)
		on = FALSE
		return

	materials.use_materials(alloy.materials, multiplier = amount)

	generate_mineral(alloy.build_path)

/obj/machinery/mineral/processing_unit/proc/can_smelt(datum/design/D, seconds_per_tick = 2)
	if(D.make_reagent)
		return FALSE

	var/build_amount = SMELT_AMOUNT * seconds_per_tick

	for(var/mat_cat in D.materials)
		var/required_amount = D.materials[mat_cat]
		var/amount = materials.materials[mat_cat]

		build_amount = min(build_amount, round(amount / required_amount))

	return build_amount

/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)

/// Only accepts ore, for the work camp
/obj/machinery/mineral/processing_unit/gulag
	accepted_type = /obj/item/stack/ore

#undef SMELT_AMOUNT

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
		RegisterSignals(input_turf, list(COMSIG_ATOM_INITIALIZED_ON, COMSIG_ATOM_ENTERED), PROC_REF(pickup_item))

/// Unregisters signals that are registered the machine's input turf, if it has one.
/obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		UnregisterSignal(input_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON))

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

	Called when the COMSIG_ATOM_ENTERED and COMSIG_ATOM_INITIALIZED_ON signals are sent.

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
	/// Connected ore processing machine.
	var/obj/machinery/mineral/processing_unit/processing_machine

/obj/machinery/mineral/processing_unit_console/Initialize(mapload)
	. = ..()
	processing_machine = locate(/obj/machinery/mineral/processing_unit) in view(2, src)
	if (processing_machine)
		processing_machine.mineral_machine = src
	else
		return INITIALIZE_HINT_QDEL

/obj/machinery/mineral/processing_unit_console/ui_interact(mob/user)
	. = ..()
	if(!processing_machine)
		return

	var/dat = processing_machine.get_machine_data()

	var/datum/browser/popup = new(user, "processing", "Smelting Console", 300, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["material"])
		var/datum/material/new_material = locate(href_list["material"])
		if(istype(new_material))
			processing_machine.selected_material = new_material
			processing_machine.selected_alloy = null

	if(href_list["alloy"])
		processing_machine.selected_material = null
		processing_machine.selected_alloy = href_list["alloy"]

	if(href_list["set_on"])
		processing_machine.on = (href_list["set_on"] == "on")
		processing_machine.begin_processing()

	updateUsrDialog()
	return

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

/obj/machinery/mineral/processing_unit/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	var/list/allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
	)
	AddComponent(/datum/component/material_container, allowed_materials, INFINITY, MATCONTAINER_EXAMINE|BREAKDOWN_FLAGS_ORE_PROCESSOR, allowed_items=/obj/item/stack)
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter] = new /datum/techweb/autounlocking/smelter
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/smelter]
	selected_material = GET_MATERIAL_REF(/datum/material/iron)

/obj/machinery/mineral/processing_unit/Destroy()
	mineral_machine = null
	stored_research = null
	return ..()

/obj/machinery/mineral/processing_unit/proc/process_ore(obj/item/stack/ore/O)
	if(QDELETED(O))
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/material_amount = materials.get_item_material_amount(O, BREAKDOWN_FLAGS_ORE_PROCESSOR)
	if(!materials.has_space(material_amount))
		unload_mineral(O)
	else
		materials.insert_item(O, breakdown_flags=BREAKDOWN_FLAGS_ORE_PROCESSOR)
		qdel(O)
		if(mineral_machine)
			mineral_machine.updateUsrDialog()

/obj/machinery/mineral/processing_unit/proc/get_machine_data()
	var/dat = "<b>Smelter control console</b><br><br>"
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/datum/material/all_materials as anything in materials.materials)
		var/amount = materials.materials[all_materials]
		dat += "<span class=\"res_name\">[all_materials.name]: </span>[amount] cm&sup3;"
		if (selected_material == all_materials)
			dat += " <i>Smelting</i>"
		else
			dat += " <A href='?src=[REF(mineral_machine)];material=[REF(all_materials)]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br><br>"
	dat += "<b>Smelt Alloys</b><br>"

	for(var/research in stored_research.researched_designs)
		var/datum/design/designs = SSresearch.techweb_design_by_id(research)
		dat += "<span class=\"res_name\">[designs.name] "
		if (selected_alloy == designs.id)
			dat += " <i>Smelting</i>"
		else
			dat += " <A href='?src=[REF(mineral_machine)];alloy=[designs.id]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br><br>"
	//On or off
	dat += "Machine is currently "
	if (on)
		dat += "<A href='?src=[REF(mineral_machine)];set_on=off'>On</A> "
	else
		dat += "<A href='?src=[REF(mineral_machine)];set_on=on'>Off</A> "

	return dat

/obj/machinery/mineral/processing_unit/pickup_item(datum/source, atom/movable/target, direction)
	if(QDELETED(target))
		return
	if(istype(target, /obj/item/stack/ore))
		process_ore(target)

/obj/machinery/mineral/processing_unit/process(delta_time)
	if(!on)
		end_processing()
		if(mineral_machine)
			mineral_machine.updateUsrDialog()
		return

	if(selected_material)
		smelt_ore(delta_time)
	else if(selected_alloy)
		smelt_alloy(delta_time)

	if(mineral_machine)
		mineral_machine.updateUsrDialog()

/obj/machinery/mineral/processing_unit/proc/smelt_ore(delta_time = 2)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/datum/material/mat = selected_material
	if(!mat)
		return
	var/sheets_to_remove = (materials.materials[mat] >= (MINERAL_MATERIAL_AMOUNT * SMELT_AMOUNT * delta_time) ) ? SMELT_AMOUNT * delta_time : round(materials.materials[mat] /  MINERAL_MATERIAL_AMOUNT)
	if(!sheets_to_remove)
		on = FALSE
	else
		var/out = get_step(src, output_dir)
		materials.retrieve_sheets(sheets_to_remove, mat, out)

/obj/machinery/mineral/processing_unit/proc/smelt_alloy(delta_time = 2)
	var/datum/design/alloy = stored_research.isDesignResearchedID(selected_alloy) //check if it's a valid design
	if(!alloy)
		on = FALSE
		return

	var/amount = can_smelt(alloy, delta_time)

	if(!amount)
		on = FALSE
		return

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.use_materials(alloy.materials, amount)

	generate_mineral(alloy.build_path)

/obj/machinery/mineral/processing_unit/proc/can_smelt(datum/design/D, delta_time = 2)
	if(D.make_reagent)
		return FALSE

	var/build_amount = SMELT_AMOUNT * delta_time

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	for(var/mat_cat in D.materials)
		var/required_amount = D.materials[mat_cat]
		var/amount = materials.materials[mat_cat]

		build_amount = min(build_amount, round(amount / required_amount))

	return build_amount

/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)

/obj/machinery/mineral/processing_unit/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	return ..()

#undef SMELT_AMOUNT

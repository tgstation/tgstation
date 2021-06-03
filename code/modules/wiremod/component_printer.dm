/// Component printer, creates components for integrated circuits.
/obj/machinery/component_printer
	name = "component printer"
	desc = "Produces components for the creation of integrated circuits."
	icon = 'icons/obj/wiremod_fab.dmi'
	icon_state = "fab-idle"
	circuit = /obj/item/circuitboard/machine/component_printer

	/// The internal material bus
	var/datum/component/remote_materials/materials

	density = TRUE

	/// The techweb the printer will get researched designs from
	var/datum/techweb/techweb

/obj/machinery/component_printer/Initialize(mapload)
	. = ..()

	techweb = SSresearch.science_tech

	materials = AddComponent( \
		/datum/component/remote_materials, \
		"component_printer", \
		mapload, \
		mat_container_flags = BREAKDOWN_FLAGS_LATHE, \
	)

/obj/machinery/component_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ComponentPrinter", name)
		ui.open()

/obj/machinery/component_printer/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials)
	)

/obj/machinery/component_printer/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("print")
			var/design_id = params["designId"]
			if (!techweb.researched_designs[design_id])
				return TRUE

			var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
			if (!(design.build_type & COMPONENT_PRINTER))
				return TRUE

			if (materials.on_hold())
				say("Mineral access is on hold, please contact the quartermaster.")
				return TRUE

			if (!materials.mat_container?.has_materials(design.materials))
				say("Not enough materials.")
				return TRUE

			balloon_alert_to_viewers("printed [design.name]")
			materials.mat_container?.use_materials(design.materials)
			materials.silo_log(src, "printed", -1, design.name, design.materials)
			var/atom/printed_design = new design.build_path(drop_location())
			printed_design.pixel_x = printed_design.base_pixel_x + rand(-5, 5)
			printed_design.pixel_y = printed_design.base_pixel_y + rand(-5, 5)
		if ("remove_mat")
			var/datum/material/material = locate(params["ref"])
			var/amount = text2num(params["amount"])

			if (!amount)
				return TRUE

			// SAFETY: eject_sheets checks for valid mats
			materials.eject_sheets(material, amount)

	return TRUE

/obj/machinery/component_printer/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = materials.mat_container.ui_data()
	return data

/obj/machinery/component_printer/ui_static_data(mob/user)
	var/list/data = list()

	var/list/designs = list()

	// for (var/datum/design/component/component_design_type as anything in subtypesof(/datum/design/component))
	for (var/researched_design_id in techweb.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(researched_design_id)
		if (!(design.build_type & COMPONENT_PRINTER))
			continue

		designs[researched_design_id] = list(
			"name" = design.name,
			"description" = design.desc,
			"materials" = get_material_cost_data(design.materials),
			"categories" = design.category,
		)

	data["designs"] = designs

	return data

/obj/machinery/component_printer/crowbar_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_crowbar(tool)

/obj/machinery/component_printer/screwdriver_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", tool)

/obj/machinery/component_printer/proc/get_material_cost_data(list/materials)
	var/list/data = list()

	for (var/datum/material/material_type as anything in materials)
		data[initial(material_type.name)] = materials[material_type]

	return data

/obj/item/circuitboard/machine/component_printer
	name = "\improper Component Printer (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/component_printer
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
	)

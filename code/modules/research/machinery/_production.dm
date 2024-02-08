/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER

	/// The efficiency coefficient. Material costs and print times are multiplied by this number;
	/// better parts result in a higher efficiency (and lower value).
	var/efficiency_coeff = 1

	/// The material storage used by this fabricator.
	var/datum/component/remote_materials/materials

	/// Which departments are allowed to process this design
	var/allowed_department_flags = ALL

	/// What's flick()'d on print.
	var/production_animation

	/// The types of designs this fabricator can print.
	var/allowed_buildtypes = NONE

	/// All designs in the techweb that can be fabricated by this machine, since the last update.
	var/list/datum/design/cached_designs

	/// What color is this machine's stripe? Leave null to not have a stripe.
	var/stripe_color = null

	/// Does this charge the user's ID on fabrication?
	var/charges_tax = TRUE

/obj/machinery/rnd/production/Initialize(mapload)
	. = ..()

	cached_designs = list()
	materials = AddComponent(/datum/component/remote_materials, mapload)

	AddComponent(
		/datum/component/payment, \
		0, \
		SSeconomy.get_dep_account(payment_department), \
		PAYMENT_CLINICAL, \
		TRUE, \
	)

	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/rnd/production/connect_techweb(datum/techweb/new_techweb)
	if(stored_research)
		UnregisterSignal(stored_research, list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN))
	return ..()

/obj/machinery/rnd/production/on_connected_techweb()
	. = ..()
	RegisterSignals(
		stored_research,
		list(COMSIG_TECHWEB_ADD_DESIGN, COMSIG_TECHWEB_REMOVE_DESIGN),
		PROC_REF(on_techweb_update)
	)
	update_designs()

/obj/machinery/rnd/production/Destroy()
	materials = null
	cached_designs = null
	return ..()

/obj/machinery/rnd/production/proc/on_techweb_update()
	SIGNAL_HANDLER

	// We're probably going to get more than one update (design) at a time, so batch
	// them together.
	addtimer(CALLBACK(src, PROC_REF(update_designs)), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Updates the list of designs this fabricator can print.
/obj/machinery/rnd/production/proc/update_designs()
	var/previous_design_count = cached_designs.len

	cached_designs.Cut()

	for(var/design_id in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)

		if((isnull(allowed_department_flags) || (design.departmental_flags & allowed_department_flags)) && (design.build_type & allowed_buildtypes))
			cached_designs |= design

	var/design_delta = cached_designs.len - previous_design_count

	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

/obj/machinery/rnd/production/RefreshParts()
	. = ..()

	calculate_efficiency()
	update_static_data_for_all_viewers()

/obj/machinery/rnd/production/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs)
	)

/obj/machinery/rnd/production/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fabricator")
		ui.open()

/obj/machinery/rnd/production/ui_static_data(mob/user)
	var/list/data = materials.mat_container.ui_static_data()

	var/list/designs = list()

	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"

	var/max_multiplier = INFINITY
	var/coefficient
	for(var/datum/design/design in cached_designs)
		var/cost = list()

		max_multiplier = INFINITY
		coefficient = build_efficiency(design.build_path)
		for(var/datum/material/mat in design.materials)
			cost[mat.name] = OPTIMAL_COST(design.materials[mat] * coefficient)
			max_multiplier = min(max_multiplier, 50, round(materials.mat_container.get_material_amount(mat) / cost[mat.name]))

		var/icon_size = spritesheet.icon_size_id(design.id)
		designs[design.id] = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == size32x32 ? "" : "[icon_size] "][design.id]",
			"constructionTime" = 0,
			"maxmult" = max_multiplier
		)

	data["designs"] = designs
	data["fabName"] = name

	return data

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = materials.mat_container.ui_data()
	data["onHold"] = materials.on_hold()
	data["busy"] = busy
	data["materialMaximum"] = materials.local_size
	data["queue"] = list()

	return data

/obj/machinery/rnd/production/ui_act(action, list/params, datum/tgui/ui)
	. = ..()

	if(.)
		return

	. = TRUE

	switch (action)
		if("remove_mat")
			var/datum/material/material = locate(params["ref"])
			var/amount = text2num(params["amount"])
			// SAFETY: eject_sheets checks for valid mats
			materials.eject_sheets(material, amount)

		if("build")
			user_try_print_id(ui.user, params["ref"], params["amount"])

/// Updates the fabricator's efficiency coefficient based on the installed parts.
/obj/machinery/rnd/production/proc/calculate_efficiency()
	efficiency_coeff = 1

	if(materials)
		var/total_storage = 0

		for(var/datum/stock_part/matter_bin/bin in component_parts)
			total_storage += bin.tier * (37.5*SHEET_MATERIAL_AMOUNT)

		materials.set_local_size(total_storage)

	var/total_rating = 1.2

	for(var/datum/stock_part/servo/servo in component_parts)
		total_rating -= servo.tier * 0.1

	efficiency_coeff = max(total_rating, 0)

/obj/machinery/rnd/production/proc/build_efficiency(path)
	if(ispath(path, /obj/item/stack/sheet) || ispath(path, /obj/item/stack/ore/bluespace_crystal))
		return 1
	else
		return efficiency_coeff

/obj/machinery/rnd/production/proc/user_try_print_id(mob/user, design_id, print_quantity)
	if(!design_id)
		return FALSE

	if(istext(print_quantity))
		print_quantity = text2num(print_quantity)

	if(isnull(print_quantity))
		print_quantity = 1

	var/datum/design/design = stored_research.researched_designs[design_id] ? SSresearch.techweb_design_by_id(design_id) : null

	if(!istype(design))
		return FALSE

	if(busy)
		say("Warning: fabricator is busy!")
		return FALSE

	if(!(isnull(allowed_department_flags) || (design.departmental_flags & allowed_department_flags)))
		say("This fabricator does not have the necessary keys to decrypt this design.")
		return FALSE

	if(design.build_type && !(design.build_type & allowed_buildtypes))
		say("This fabricator does not have the necessary manipulation systems for this design.")
		return FALSE

	if(!materials.mat_container)
		say("No connection to material storage, please contact the quartermaster.")
		return FALSE

	if(materials.on_hold())
		say("Mineral access is on hold, please contact the quartermaster.")
		return FALSE

	print_quantity = clamp(print_quantity, 1, 50)
	var/coefficient = build_efficiency(design.build_path)

	// check if sufficient materials are available.
	if(!materials.mat_container.has_materials(design.materials, coefficient, print_quantity))
		say("Not enough materials to complete prototype[print_quantity > 1 ? "s" : ""].")
		return FALSE

	//use power
	var/total_charge = 0
	for(var/material in design.materials)
		total_charge += round(design.materials[material] * coefficient * print_quantity / 35)
	var/charge_per_item = total_charge / print_quantity

	if(production_animation)
		flick(production_animation, src)

	var/total_time = (design.construction_time * design.lathe_time_factor * print_quantity) ** 0.8
	var/time_per_item = total_time / print_quantity
	start_making(design, print_quantity, time_per_item, coefficient, charge_per_item)

	return TRUE

/// Begins the act of making the given design the given number of items
/// Does not check or use materials/power/etc
/obj/machinery/rnd/production/proc/start_making(datum/design/design, build_count, build_time_per_item, build_efficiency, charge_per_item)
	PROTECTED_PROC(TRUE)

	busy = TRUE
	update_static_data_for_all_viewers()
	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, build_efficiency, build_time_per_item, charge_per_item, build_count), build_time_per_item)

/// Callback for start_making, actually makes the item
/// Called using timers started by start_making
/obj/machinery/rnd/production/proc/do_make_item(datum/design/design, build_efficiency, time_per_item, charge_per_item, items_remaining)
	PROTECTED_PROC(TRUE)

	if(!items_remaining) // how
		finalize_build()
		return

	if(!directly_use_power(charge_per_item))
		say("Unable to continue production, power failure.")
		finalize_build()
		return

	var/is_stack = ispath(design.build_path, /obj/item/stack)
	var/list/design_materials = design.materials
	if(!materials.mat_container.has_materials(design_materials, build_efficiency, is_stack ? items_remaining : 1))
		say("Unable to continue production, missing materials.")
		return
	materials.use_materials(design_materials, build_efficiency, is_stack ? items_remaining : 1, "built", "[design.name]")

	var/atom/movable/created
	if(is_stack)
		created = new design.build_path(get_turf(src), items_remaining)
	else
		created = new design.build_path(get_turf(src))
		split_materials_uniformly(design_materials, build_efficiency, created)

	created.pixel_x = created.base_pixel_x + rand(-6, 6)
	created.pixel_y = created.base_pixel_y + rand(-6, 6)

	if(is_stack)
		items_remaining = 0
	else
		items_remaining -= 1

	if(!items_remaining)
		finalize_build()
		return
	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, build_efficiency, time_per_item, items_remaining), time_per_item)

/// Resets the busy flag
/// Called at the end of do_make_item's timer loop
/obj/machinery/rnd/production/proc/finalize_build()
	PROTECTED_PROC(TRUE)
	busy = FALSE
	update_static_data_for_all_viewers()

// Stuff for the stripe on the department machines
/obj/machinery/rnd/production/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()

	update_icon(UPDATE_OVERLAYS)

/obj/machinery/rnd/production/update_overlays()
	. = ..()

	if(!stripe_color)
		return

	var/mutable_appearance/stripe = mutable_appearance('icons/obj/machines/research.dmi', "protolate_stripe")

	if(!panel_open)
		stripe.icon_state = "protolathe_stripe"
	else
		stripe.icon_state = "protolathe_stripe_t"

	stripe.color = stripe_color

	. += stripe

/obj/machinery/rnd/production/examine(mob/user)
	. = ..()

	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[materials.local_size]</b> material units.<br>Material consumption at <b>[efficiency_coeff * 100]%</b>.<br>Build time reduced by <b>[100 - efficiency_coeff * 100]%</b>.")

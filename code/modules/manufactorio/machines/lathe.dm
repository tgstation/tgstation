/obj/machinery/power/manufacturing/lathe // this is a heavily gutted autolathe
	name = "manufacturing lathe"
	desc = "Lathes the set recipe until it runs out of resources. Only accepts sheets or other kinds of material stacks."
	icon_state = "lathe"
	circuit = /obj/item/circuitboard/machine/manulathe
	/// power cost for lathing
	var/power_cost = 5 KILO WATTS
	/// design id we print
	var/design_id
	///The container to hold materials
	var/datum/component/material_container/materials
	//looping sound for printing items
	var/datum/looping_sound/lathe_print/print_sound
	///Designs related to the autolathe
	var/datum/techweb/autounlocking/stored_research
	/// timer id of printing
	var/busy = FALSE
	/// our output, if the way out was blocked is held here
	var/atom/movable/withheld

/obj/machinery/power/manufacturing/lathe/Initialize(mapload)
	. = ..()
	print_sound = new(src,  FALSE)
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL], \
		SHEET_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, \
		MATCONTAINER_EXAMINE|MATCONTAINER_NO_INSERT, \
	)
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe] = new /datum/techweb/autounlocking/autolathe
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe]

/obj/machinery/power/manufacturing/lathe/examine(mob/user)
	. = ..()
	var/datum/design/design
	if(!isnull(design_id))
		design = SSresearch.techweb_design_by_id(design_id)
	. += span_notice("It is set to print [!isnull(design) ? design.name : "nothing, set with a multitool"].")
	if(isnull(design))
		return
	. += span_notice("It needs:")
	for(var/valid_type in design.materials)
		var/atom/ingredient = valid_type
		var/amount = design.materials[ingredient] / SHEET_MATERIAL_AMOUNT

		. += "[amount] sheets of [initial(ingredient.name)]"

/obj/machinery/power/manufacturing/lathe/update_overlays()
	. = ..()
	. += generate_io_overlays(dir, COLOR_ORANGE) // OUT - stuff in it
	. += generate_io_overlays(REVERSE_DIR(dir), COLOR_MODERATE_BLUE) // IN - to crush

/obj/machinery/power/manufacturing/lathe/Destroy()
	. = ..()
	stored_research = null
	QDEL_NULL(print_sound)
	materials = null
	QDEL_NULL(withheld)

/obj/machinery/power/manufacturing/lathe/atom_destruction(damage_flag)
	withheld?.Move(drop_location())
	return ..()

/obj/machinery/power/manufacturing/lathe/receive_resource(atom/movable/receiving, atom/from, receive_dir)
	if(!isstack(receiving) || receiving.resistance_flags & INDESTRUCTIBLE || receive_dir != REVERSE_DIR(dir))
		return MANUFACTURING_FAIL
	materials.insert_item(receiving)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/lathe/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	var/list/name_to_id = list()
	for(var/id in stored_research.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(id)
		name_to_id[design.name] = id
	var/result = tgui_input_list(user, "Select Design", "Select Design", sort_list(name_to_id))
	if(isnull(result))
		return ITEM_INTERACT_FAILURE
	design_id = name_to_id[result]
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/manufacturing/lathe/process()
	if(!isnull(withheld) && !send_resource(withheld, dir))
		return

	var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
	if(isnull(design) || !(design.build_type & AUTOLATHE))
		return
	if(surplus() < power_cost)
		finalize_build()
		return
	//check for materials required. For custom material items decode their required materials
	var/list/materials_needed = list()
	for(var/material in design.materials)
		var/amount_needed = design.materials[material]
		if(istext(material)) // category
			for(var/datum/material/valid_candidate as anything in SSmaterials.materials_by_category[material])
				if(materials.get_material_amount(valid_candidate) < amount_needed)
					continue
				material = valid_candidate
				break
		if(isnull(material))
			return
		materials_needed[material] = amount_needed

	if(!materials.has_materials(materials_needed))
		return

	var/craft_time = (design.construction_time * design.lathe_time_factor) ** 0.8
	flick_overlay_view(mutable_appearance(icon, "crafter_printing"), craft_time)
	print_sound.start()
	add_load(power_cost)
	busy = addtimer(CALLBACK(src, PROC_REF(do_make_item), design, materials_needed), craft_time, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_DELETE_ME)

/obj/machinery/power/manufacturing/lathe/proc/do_make_item(datum/design/design, list/materials_needed)
	finalize_build()
	if(surplus() < power_cost)
		return

	var/is_stack = ispath(design.build_path, /obj/item/stack)
	if(!materials.has_materials(materials_needed))
		return
	materials.use_materials(materials_needed)

	var/atom/movable/created
	if(is_stack)
		var/obj/item/stack/stack_item = initial(design.build_path)
		created = new stack_item(null, 1)
	else
		created = new design.build_path(null)
		split_materials_uniformly(materials_needed, target_object = created)
	if(isitem(created))
		created.pixel_x = created.base_pixel_x + rand(-6, 6)
		created.pixel_y = created.base_pixel_y + rand(-6, 6)
	SSblackbox.record_feedback("nested tally", "lathe_printed_items", 1, list("[type]", "[created.type]"))

	if(!send_resource(created, dir))
		withheld = created


/obj/machinery/power/manufacturing/lathe/proc/finalize_build()
	print_sound.stop()
	deltimer(busy)
	busy = null

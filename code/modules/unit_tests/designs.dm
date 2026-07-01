/datum/unit_test/designs

/datum/unit_test/designs/Run()
//Can't use allocate because of bug with certain datums
	var/datum/design/default_design = new /datum/design()

	for(var/design_id in SSresearch.techweb_designs) //We are checking surgery design separatly later since they work differently
		var/datum/design/current_design = SSresearch.techweb_designs[design_id]
		if(istype(current_design, /datum/design/surgery))
			return
		if (isnull(current_design.name) || current_design.name == default_design.name) //Designs with ID must have non default/null Name
			TEST_FAIL("Design [current_design.type] has default or null name var but has an ID")
		if ((!isnull(current_design.materials) && LAZYLEN(current_design.materials)) || (!isnull(current_design.reagents_list) && LAZYLEN(current_design.reagents_list))) //Design requires materials
			if ((isnull(current_design.build_path) || current_design.build_path == default_design.build_path) && (isnull(current_design.make_reagent) || current_design.make_reagent == default_design.make_reagent)) //Check if design gives any output
				TEST_FAIL("Design [current_design.type] requires materials but does not have either build_path or make_reagent set")
		else if (!isnull(current_design.build_path) || !isnull(current_design.build_path)) // //Design requires no materials but creates stuff
			TEST_FAIL("Design [current_design.type] requires NO materials but has build_path or make_reagent set")
		if (length(current_design.reagents_list) && !(current_design.build_type & LIMBGROWER))
			TEST_FAIL("Design [current_design.type] requires reagents but isn't a limb grower design. Reagent costs are only supported by limb grower designs")

	for(var/datum/design/surgery/path as anything in subtypesof(/datum/design/surgery))
		if (path::id == DESIGN_ID_IGNORE)
			TEST_FAIL("Surgery Design [path] has no ID set")
		if (isnull(path::surgery))
			TEST_FAIL("Surgery Design [path] has null surgery var")
			continue
		if (isnull(path::name) && isnull(path::surgery::rnd_name) && isnull(path::surgery::name))
			TEST_FAIL("Surgery Design [path] has no name set or inferable from surgery type")
		if (isnull(path::desc) && isnull(path::surgery::rnd_desc) && isnull(path::surgery::desc))
			TEST_FAIL("Surgery Design [path] has no desc set or inferable from surgery type")

///Check that all designs have a corresponding id and viceversa, and that they're actually implemented (techweb or disks)
/datum/unit_test/design_source

/datum/unit_test/design_source/Run()
	var/list/all_designs = list()

	for(var/id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[id]
		all_designs[design.id] = design.type

	for (var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for (var/design_id in node.design_ids)
			if (!all_designs[design_id])
				TEST_FAIL("Techweb node [node.display_name] ([node.id]) has a design_id \"[design_id]\" which doesn't correspond to any existing design!")
				continue
			all_designs -= design_id

	// Designs can also be disk-exclusive
	for (var/obj/item/disk/design_disk/design_disk as anything in subtypesof(/obj/item/disk/design_disk))
		design_disk = new design_disk()
		for (var/datum/design/design as anything in design_disk.blueprints)
			all_designs -= design.id
		qdel(design_disk)

	for (var/obj/item/disk/surgery/design_disk as anything in subtypesof(/obj/item/disk/surgery))
		design_disk = new design_disk()
		for (var/surgery_type in design_disk.surgeries)
			for (var/design_id in all_designs)
				var/datum/design/surgery/design = all_designs[design_id]
				if (ispath(design, /datum/design/surgery) && design::surgery == surgery_type)
					all_designs -= design::id
		qdel(design_disk)

	// Or machine-exclusive
	for (var/datum/techweb/autounlocking/techweb as anything in subtypesof(/datum/techweb/autounlocking))
		techweb = new techweb()
		for (var/design_id in techweb.researched_designs + techweb.hacked_designs)
			var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
			// If we have a design thats supposed to be printable from a protolathe and an autolathe, but only autolathes can print it
			// then we still should error because then we either have a missing design_id or redundant build flags
			if (!(design.build_type & (~techweb.allowed_buildtypes)))
				all_designs -= design_id
		qdel(techweb)

	for (var/missing_id in all_designs)
		TEST_FAIL("Design [all_designs[missing_id]] has an ID \"[missing_id]\" which is not in any of the techweb nodes or tech disks, or it is possibly misconfigured!")

///Check that the materials present in the printed objects are consistent with the materials used in techweb design that prints said object.
/datum/unit_test/design_mats

/datum/unit_test/design_mats/Run()
	var/list/special_types = typesof(/datum/material_requirement) + typesof(/datum/material_slot) //we skip designs that can be printed with non-specific materials.

	for (var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_id]

		var/mat_requirement_design = length(special_types & design.materials)

		if(mat_requirement_design && length(design.transfered_materials))
			TEST_FAIL("'transfer_materials' doesn't work for [design.type] and other designs that have [/datum/material_slot] or [/datum/material_requirement] in their 'materials' var yet")
			continue

		//Do not perform further checks if it doesn't have a built path, mat requirements or if it's one of those designs with choosable requirements (harder to implement checks for those)
		if(mat_requirement_design || !design.build_path || !length(design.materials))
			continue

		if(length(design.transfered_materials))
			var/list/mats_total = list()
			for(var/object_type in design.transfered_materials)
				var/list/transfered_to_obj = design.transfered_materials[object_type]
				for(var/mat in design.transfered_materials[object_type])
					if(!(mat in design.materials))
						TEST_FAIL("Found material type [mat] in the 'transfered_materials' var of [design.type] that isn't present in its 'materials' var")
						continue
					mats_total[mat] += transfered_to_obj[mat]
			for(var/mat in mats_total)
				if(round(mats_total[mat]) > design.materials[mat]) // some sneaky weird bug may require rounding the value down
					TEST_FAIL("Amount of [mat] in the 'transfered_materials' var of [design.type] exceeds what present in its 'materials' var \
					([transcribe_mat_value_as_sheet(mats_total[mat])] vs [transcribe_mat_value_as_sheet(design.materials[mat])])")

		//The design is exempted from the unit test if it doesn't have the standard inherit_materials val.
		if(design.inherit_materials != DESIGN_INHERIT_MATS)
			continue

		// The object that represents the type of object that can be built from the design, though it's simple spawned in this case
		var/atom/movable/generic_instance = allocate_build_path_for_design(design.build_path)

		// The object that represents the type of object built from the design.
		var/atom/movable/printed_instance = allocate_build_path_for_design(design.build_path)

		design.transfer_materials(design.materials, 1, printed_instance)

		if(generic_instance.compare_materials(printed_instance))
			continue

		var/target_var = NAMEOF(generic_instance, custom_materials)
		var/warning = "[target_var] of [generic_instance.type] differs from the materials of [design.type]"

		var/what_it_should_be
		var/what_it_is
		if(isstack(generic_instance))
			var/obj/item/stack/generic_stack = generic_instance
			var/obj/item/stack/printed_stack = printed_instance
			target_var = NAMEOF(generic_stack, mats_per_unit)
			what_it_should_be = printed_stack.transcribe_materials_list(printed_stack.mats_per_unit)
			what_it_is = generic_stack.transcribe_materials_list(generic_stack.mats_per_unit)
		else
			what_it_should_be = printed_instance.transcribe_materials_list()
			what_it_is = generic_instance.transcribe_materials_list()

		TEST_FAIL("[warning]. should be: [target_var] = [what_it_should_be] (current value: [what_it_is]). \
			Fix it or change the value of the [NAMEOF(design, inherit_materials)] var of [design.type]. \
			You can also edit the [NAMEOF(design, transfered_materials)] list of the design")

		if(!length(printed_instance.contents))
			continue

		var/list/all_mats = printed_instance.get_contents_custom_materials(/obj/item, TRAIT_IGNORED_BY_MAT_REDEMPTION)
		for(var/datum/material/mat as anything in all_mats)
			if(all_mats[mat] > design.materials[mat])
				var/sheet_val = transcribe_mat_value_as_sheet(all_mats[mat])
				var/design_val = transcribe_mat_value_as_sheet(design.materials[mat])
				TEST_FAIL("The [mat.name] ([mat.type] = [sheet_val]) of [printed_instance.type] plus its contents exceeds what presents in [design.type] ([design_val]). Review the code of the object and fix that.")

///Proc made to reduce copypasted code when allocating an object from a design, because stacks have a tendency to merge with each other, and we don't want that.
/datum/unit_test/design_mats/proc/allocate_build_path_for_design(build_path)
	var/is_stack = ispath(build_path)
	if(is_stack) //If this is a stack, we don't want it to merge with any other stack on the same location
		var/obj/item/stack/stack_path = build_path
		var/stack_amount = initial(stack_path.amount)
		//So we need to specify the args up to the merge argument to avoid issues
		return allocate(stack_path, run_loc_floor_bottom_left, /*new_amount =*/ stack_amount, /*merge =*/ FALSE)
	return allocate(build_path)

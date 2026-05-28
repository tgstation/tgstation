/datum/unit_test/designs

/datum/unit_test/designs/Run()
//Can't use allocate because of bug with certain datums
	var/datum/design/default_design = new /datum/design()

	for(var/path in subtypesof(/datum/design) - typesof(/datum/design/surgery)) //We are checking surgery design separatly later since they work differently
		var/datum/design/current_design = new path //Create an instance of each design
		if (current_design.id == DESIGN_ID_IGNORE) //Don't check designs with ignore ID
			continue
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

/datum/unit_test/design_source

/datum/unit_test/design_source/Run()
	var/list/all_designs = list()
	var/list/generic_types = typesof(/datum/material_requirement) + typesof(/datum/material_slot) //we skip designs that can be printed with non-specific materials.

	for (var/datum/design/design as anything in subtypesof(/datum/design))
		design = new design()
		if (design.id == DESIGN_ID_IGNORE)
			continue
		if (design.id in all_designs)
			TEST_FAIL("Design [design.type] shares an ID \"[design.id]\" with another design")
			continue
		all_designs[design.id] = design.type

		//Perform material checks onto the design if needed to ensure the required materials (minus the removed_materials) match the custom materials of the object.
		if(design.inherit_materials != DESIGN_INHERIT_MATS || !design.build_path || !length(design.materials) || length(generic_types & design.materials))
			continue

		var/atom/generic_instance // The object that represents the type of object that can be built from the design, though it's simple spawned in this case
		var/is_stack = ispath(design.build_path)
		var/stack_amount = 1
		if(is_stack) //If this is a stack, we don't want it to merge with the other stack
			var/obj/item/stack/stack_path = design.build_path
			stack_amount = initial(stack_path.amount)
			//So we need to specify the args up to the merge argument to avoid issues
			generic_instance = allocate(stack_path, run_loc_floor_bottom_left, /*new_amount =*/ stack_amount, /*merge =*/ FALSE)
		else
			generic_instance = allocate(design.build_path)

		var/atom/printed_instance // The object that represents the type of object built from the design.
		if(is_stack) //If this is a stack, we don't want it to merge with the other stack
			printed_instance = allocate(design.build_path, run_loc_floor_bottom_left, /*new_amount =*/ stack_amount, /*merge =*/ FALSE)
		else
			printed_instance = allocate(design.build_path)

		var/list/expected_materials = design.materials.Copy()
		for(var/mat_type, amount in design.removed_materials)
			expected_materials[mat_type] -= amount
			if(expected_materials[mat_type] <= 0)
				expected_materials -= mat_type
		split_materials_uniformly(expected_materials, 1, printed_instance)

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
			You can also edit the [NAMEOF(design, removed_materials)] alist of the design.")

	for (var/datum/techweb_node/node as anything in subtypesof(/datum/techweb_node))
		node = new node()
		for (var/design_id in node.design_ids)
			if (!all_designs[design_id])
				TEST_FAIL("Techweb node [node.display_name] ([node.id]) has a design_id \"[design_id]\" which doesn't correspond to any existing design!")
				continue
			all_designs -= design_id
		qdel(node)

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

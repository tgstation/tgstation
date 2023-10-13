/datum/unit_test/designs

/datum/unit_test/designs/Run()
//Can't use allocate because of bug with certain datums
	var/datum/design/default_design = new /datum/design()
	var/datum/design/surgery/default_design_surgery = new /datum/design/surgery()

	for(var/path in subtypesof(/datum/design))
		if (ispath(path, /datum/design/surgery)) //We are checking surgery design separatly later since they work differently
			continue
		var/datum/design/current_design = new path //Create an instance of each design
		if (current_design.id == DESIGN_ID_IGNORE) //Don't check designs with ignore ID
			continue
		if (isnull(current_design.name) || current_design.name == default_design.name) //Designs with ID must have non default/null Name
			TEST_FAIL("Design [current_design.type] has default or null name var but has an ID")
		if ((!isnull(current_design.materials) && LAZYLEN(current_design.materials)) || (!isnull(current_design.reagents_list) && LAZYLEN(current_design.reagents_list))) //Design requires materials
			if ((isnull(current_design.build_path) || current_design.build_path == default_design.build_path) && (isnull(current_design.make_reagent) || current_design.make_reagent == default_design.make_reagent)) //Check if design gives any output
				TEST_FAIL("Design [current_design.type] requires materials but does not have have any build_path or make_reagent set")
		else if (!isnull(current_design.build_path) || !isnull(current_design.build_path)) // //Design requires no materials but creates stuff
			TEST_FAIL("Design [current_design.type] requires NO materials but has build_path or make_reagent set")
		if (length(current_design.reagents_list) && !(current_design.build_type & LIMBGROWER))
			TEST_FAIL("Design [current_design.type] requires reagents but isn't a limb grower design. Reagent costs are only supported by limb grower designs")

	for(var/path in subtypesof(/datum/design/surgery))
		var/datum/design/surgery/current_design = new path //Create an instance of each design
		if (isnull(current_design.id) || current_design.id == default_design_surgery.id) //Check if ID was not set
			TEST_FAIL("Surgery Design [current_design.type] has no ID set")
		if (isnull(current_design.id) || current_design.name == default_design_surgery.name) //Check if name was not set
			TEST_FAIL("Surgery Design [current_design.type] has default or null name var")
		if (isnull(current_design.desc) || current_design.desc == default_design_surgery.desc) //Check if desc was not set
			TEST_FAIL("Surgery Design [current_design.type] has default or null desc var")
		if (isnull(current_design.surgery) || current_design.surgery == default_design_surgery.surgery) //Check if surgery was not set
			TEST_FAIL("Surgery Design [current_design.type] has default or null surgery var")


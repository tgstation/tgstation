/datum/unit_test/designs

/datum/unit_test/designs/Run()
	var/datum/design/defaultDesign = new /datum/design()
	var/datum/design/nanites/defaultDesignNanites = new /datum/design/nanites()
	var/datum/design/surgery/defaultDesignSurgery = new /datum/design/surgery()

	for(var/path in subtypesof(/datum/design))
		if (ispath(path, /datum/design/nanites) || ispath(path, /datum/design/surgery)) //We are checking nanites and surgery design separatly later since they work differently
			continue
		var/datum/design/currentDesign = new path //Create an instance of each design
		if (currentDesign.id == DESIGN_ID_IGNORE) //Don't check designs with ignore ID
			continue
		if (isnull(currentDesign.name) || currentDesign.name == defaultDesign.name) //Designs with ID must have non default/null Name
			Fail("Design [currentDesign.type] has default or null name var but has an ID")
		if ((!isnull(currentDesign.materials) && currentDesign.materials.len != 0) || (!isnull(currentDesign.reagents_list) && currentDesign.reagents_list.len != 0)) //Design requires materials
			if ((isnull(currentDesign.build_path) || currentDesign.build_path == defaultDesign.build_path) && (isnull(currentDesign.make_reagents) || currentDesign.make_reagents == defaultDesign.make_reagents)) //Check if design gives any output
				Fail("Design [currentDesign.type] requires materials but does not have have any build_path or make_reagents set")
		else //Design requires no materials
			if (!isnull(currentDesign.build_path) || !isnull(currentDesign.build_path)) //But gives stuff
				Fail("Design [currentDesign.type] requires NO materials but has build_path or make_reagents set")

	for(var/path in subtypesof(/datum/design/nanites))
		var/datum/design/nanites/currentDesign = new path //Create an instance of each design
		if (isnull(currentDesign.program_type) || currentDesign.program_type == defaultDesignNanites.program_type) //Check if the Nanite design provides a program
			Fail("Nanite Design [currentDesign.type] does not have have any program_type set")

	for(var/path in subtypesof(/datum/design/surgery))
		var/datum/design/surgery/currentDesign = new path //Create an instance of each design
		if (isnull(currentDesign.id) || currentDesign.id == defaultDesignSurgery.id) //Check if ID was not set
			Fail("Surgery Design [currentDesign.type] has no ID set")
		if (isnull(currentDesign.id) || currentDesign.name == defaultDesignSurgery.name ) //Check if name was not set
			Fail("Surgery Design [currentDesign.type] has default or null name var")
		if (isnull(currentDesign.desc) || currentDesign.desc == defaultDesignSurgery.desc) //Check if desc was not set
			Fail("Surgery Design [currentDesign.type] has default or null desc var")
		if (isnull(currentDesign.surgery) || currentDesign.surgery == defaultDesignSurgery.surgery) //Check if surgery was not set
			Fail("Surgery Design [currentDesign.type] has default or null surgery var")


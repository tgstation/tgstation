SUBSYSTEM_DEF(materials)
	name = "Materials"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_MATERIALS
	var/list/materials = list() //Dictionary of material.type || material ref
	var/list/materials_by_category = list() //Dictionary of material category || material refs of that category

/datum/controller/subsystem/materials/Initialize(timeofday)
	InitializeMaterials()
	return ..()

/datum/controller/subsystem/materials/proc/InitializeMaterials(timeofday)
	for(var/type in subtypesof(/datum/material))
		var/datum/material/ref = new type
		materials[type] = ref
		for(var/cat in ref.categories)
			materials_by_category[cat] += list(ref)

/datum/controller/subsystem/materials/proc/get_materials_of_category(category)
	return materials_by_category[category]

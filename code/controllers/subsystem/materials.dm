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
	for(var/i in subtypesof(/datum/material))
		var/datum/material/mat = new i
		materials[i] = mat
		for(var/c in mat.categories)
			materials_by_category[c] += list(mat)


/datum/controller/subsystem/materials/proc/get_material(material)
	return materials[material]

/datum/controller/subsystem/materials/proc/get_materials_of_category(category)
	return materials_by_category[category]

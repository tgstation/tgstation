SUBSYSTEM_DEF(materials)
	name = "Materials"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_MATERIALS
	var/list/materials = list() //Dictionary of material.type || material ref
	var/list/materials_by_category = list() //Dictionary of category || list of material refs

/datum/controller/subsystem/materials/Initialize(timeofday)
	InitializeMaterials()
	for(var/i in SSresearch.techweb_designs) //This is currently broken and I'm not sure why.
		var/datum/design/D = i
		D.InitializeMaterials()
		to_chat(world, "initialized [i] design") 
	return ..()
	
/datum/controller/subsystem/materials/proc/InitializeMaterials(timeofday)
	for(var/type in subtypesof(/datum/material))
		var/datum/material/ref = new type
		materials[type] = ref
		for(var/c in ref.categories)
			materials_by_category[c] += list(ref)

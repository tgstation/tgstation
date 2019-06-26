SUBSYSTEM_DEF(materials)
	name = "Materials"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_MATERIALS
	var/list/materials = list() //Dictionary of material.type || material ref

/datum/controller/subsystem/materials/Initialize(timeofday)
	InitializeMaterials()
	for(var/i in SSresearch.techweb_designs)
		var/datum/design/D = i
		D.InitializeMaterials()
	return ..()
	

/datum/controller/subsystem/materials/proc/InitializeMaterials(timeofday)
	for(var/type in subtypesof(/datum/material))
		var/datum/material/ref = new type
		materials[type] = ref
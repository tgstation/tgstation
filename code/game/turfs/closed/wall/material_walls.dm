/turf/closed/wall/material
	name = "wall"
	desc = "A solid wall made out of a certain material"
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall"
	canSmoothWith = /turf/closed/wall/material
	smooth = SMOOTH_TRUE
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/closed/wall/proc/break_wall()
	for(var/i in custom_materials)
		var/datum/material/M = i
		new M.sheet_type(T, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
	return new girder_type(src)

/turf/closed/wall/material/devastate_wall()
	for(var/i in custom_materials)
		var/datum/material/M = i
		new M.sheet_type(T, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))

			if(do_after(user, 20, target = src) && material.use(1))
				var/list/material_list = list()
				if(material.material_type)
					material_list[material.material_type] = MINERAL_MATERIAL_AMOUNT
				make_new_table(/obj/structure/table/greyscale, material_list)

/obj/item/merged_material/mineral_sample
	name = "generic mineral sample"
	desc = "Excavated from stone, it seems to have some unusal properties."

	icon = 'goon/icons/materials.dmi'
	icon_state = "mauxite"

	var/randomized_name = "???"

	var/static/list/starting_datums = list()


/obj/item/merged_material/mineral_sample/Initialize(mapload)
	. = ..()

	create_random_mineral_stats(200)

	if(!length(starting_datums))
		for(var/datum/mineral_sample_datum/datum as anything in subtypesof(/datum/mineral_sample_datum))
			var/datum/mineral_sample_datum/new_datum = new datum
			starting_datums += new_datum
			starting_datums[new_datum] = new_datum.weight

	var/datum/mineral_sample_datum/picked = pick(starting_datums)
	if(length(picked.base_traits))
		for(var/datum/material_trait/trait as anything in picked.base_traits)
			material_stats.add_trait(trait)
	randomized_name = picked.name

	icon_state = picked.icon_state

	for(var/i = 1 to 4)
		var/datum/material/material = pick(subtypesof(/datum/material) - /datum/material/alloy)
		var/datum/material/refed = GET_MATERIAL_REF(material)
		if(!refed)
			continue
		generate_name(refed)

	material_stats.material_name = randomized_name
	name = "[randomized_name] sample"

/obj/item/merged_material/mineral_sample/proc/generate_name(datum/material/material_type)
	var/name_1 = ""
	var/name_2 = ""
	name_1 = copytext(randomized_name, 1, round((length(randomized_name) * 0.5) + 0.5))
	name_2 = copytext(material_type.name, round((length(material_type.name) * 0.5) + 0.5), 0)
	randomized_name = "[name_1][name_2]"

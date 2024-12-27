/datum/experiment/scanning/random/material
	name = "Material Scanning Experiment"
	description = "Base experiment for scanning atoms with materials"
	exp_tag = "Material Scan"
	total_requirement = 8
	possible_types = list(/obj/structure/chair, /obj/structure/toilet, /obj/structure/table, /turf/closed/wall, /turf/open/floor)
	///List of materials that can be required.
	var/possible_material_types = list()
	///List of materials actually required, indexed by the atom that is required.
	var/required_materials = list()

/datum/experiment/scanning/random/material/New(datum/techweb/techweb)
	. = ..()
	for(var/req_atom in required_atoms)
		var/chosen_material = pick(possible_material_types)
		required_materials[req_atom] = chosen_material

/datum/experiment/scanning/random/material/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, atom/target, typepath)
	return ..() && target.custom_materials && target.has_material_type(required_materials[typepath])

/datum/experiment/scanning/random/material/serialize_progress_stage(atom/target, list/seen_instances)
	var/datum/material/required_material = GET_MATERIAL_REF(required_materials[target])
	return EXPERIMENT_PROG_INT("Scan samples of \a [required_material.name] [initial(target.name)]", \
		traits & EXPERIMENT_TRAIT_DESTRUCTIVE ? scanned[target] : seen_instances.len, required_atoms[target])

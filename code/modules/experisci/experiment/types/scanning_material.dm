
/datum/experiment/scanning/random/material
	name = "Material Scanning Experiment"
	description = "Base experiment for scanning atoms with materials"
	exp_tag = "Material Scan"
	total_requirement = 8
	possible_types = list(/obj/structure/chair, /obj/structure/toilet, /obj/structure/table, /turf/closed/wall, /turf/open/floor)
	///List of materials that can be required.
	var/possible_material_types = list(/datum/material/meat)
	///List of materials actually required, indexed by the atom that is required.
	var/required_materials = list()

/datum/experiment/scanning/random/material/New()
	. = ..()
	for(var/i in required_atoms)
		var/chosen_material = pick(possible_material_types)
		required_materials[i] = chosen_material

/datum/experiment/scanning/random/material/is_complete()
	. = TRUE
	for (var/a in required_atoms)
		var/list/seen = scanned[a]
		if (!seen || seen.len != required_atoms[a])
			return FALSE

/datum/experiment/scanning/random/material/get_contributing_index(atom/target)
	for (var/i in required_atoms)
		var/atom/required_atom = i
		var/list/seen = scanned[required_atom]
		if (istype(target, required_atom) && seen && seen.len < required_atoms[required_atom] && !(target in seen))
			if(target.custom_materials[SSmaterials.GetMaterialRef(required_materials[required_atom])]) //Checks if the material required for this atom is present in the atom. if its not, return null (As this object is not valid in that case)
				return required_atom

/datum/experiment/scanning/random/material/check_progress()
	var/list/status = list()
	for (var/a_type in required_atoms)
		var/atom/a = a_type
		var/list/seen = scanned[a]
		var/remaining = required_atoms[a] - (seen ? seen.len : 0)
		var/datum/material/required_material = SSmaterials.GetMaterialRef(required_materials[a])
		if (remaining)
			status += " - Scan [remaining] more [required_material.name] [initial(a.name)][remaining > 1 ? "s" : ""]"
	return "The following items must be scanned:\n" + jointext(status, ", \n")

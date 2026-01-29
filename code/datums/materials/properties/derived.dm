/// Derived properties aren't present on materials, and are instead just centralized holders for formulas
/datum/material_property/derived
	abstract_type = /datum/material_property/derived

/datum/material_property/derived/proc/get_value(datum/material/material)
	return 0

/datum/material_property/derived/beauty
	id = MATERIAL_BEAUTY

/datum/material_property/derived/beauty/get_value(datum/material/material)
	// Requires the material to be especially shiny or dull
	var/reflectivity = material.get_property(MATERIAL_REFLECTIVITY) / MATERIAL_PROPERTY_MAX - 0.5
	if (abs(reflectivity) < 0.25)
		return 0
	return (abs(reflectivity) - 0.25) * 2 * sign(reflectivity)

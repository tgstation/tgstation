/// Derived properties aren't present on materials, and are instead just centralized holders for formulas
/datum/material_property/derived
	abstract_type = /datum/material_property/derived

/// Does this property apply to our material?
/datum/material_property/derived/proc/is_present(datum/material/material)
	return TRUE

/// Calculate and fetch the value of the property on this material
/datum/material_property/derived/proc/get_value(datum/material/material)
	return 0

#define INTEGRITY_MIN 0.1
// This results in iron being almost exactly 1
#define INTEGRITY_COEFF 1.57

/// Base atom integrity multiplier of items made from this material
/datum/material_property/derived/integrity
	id = MATERIAL_INTEGRITY

/datum/material_property/derived/integrity/get_value(datum/material/material)
	// Integrity is a combination of density, hardness and flexibility
	var/density = material.get_property(MATERIAL_DENSITY)
	var/hardness = material.get_property(MATERIAL_HARDNESS)
	var/flexibility = material.get_property(MATERIAL_FLEXIBILITY)
	// Its primarily hardness - the harder a material is, the more it is resistant to direct impacts
	// But unless it has enough bend to it, it'll also fracture - which is why flexibility needs to be in a sweetspot, based on density
	var/hardness_coeff = (2 + max(0, hardness - 4) * 2 - max(0, 2 - hardness)) / MATERIAL_PROPERTY_MAX
	var/bend_coeff =  1 - abs(flexibility - sqrt(density)) * 0.1
	// Check the math for yourself in https://www.desmos.com/calculator/ez2n34w772
	return round(INTEGRITY_MIN + hardness_coeff * bend_coeff * INTEGRITY_COEFF, 0.01)

#undef INTEGRITY_MIN
#undef INTEGRITY_COEFF

/// How pretty a material is
/datum/material_property/derived/beauty
	id = MATERIAL_BEAUTY

/datum/material_property/derived/beauty/is_present(datum/material/material)
	return abs(material.get_property(MATERIAL_REFLECTIVITY)) > MATERIAL_PROPERTY_MAX / 2

/datum/material_property/derived/beauty/get_value(datum/material/material)
	// Requires the material to be especially shiny or dull
	var/reflectivity = material.get_property(MATERIAL_REFLECTIVITY)
	return MATERIAL_PROPERTY_DIVERGENCE(reflectivity, 3, 6) * 0.05

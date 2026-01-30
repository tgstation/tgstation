/// Singleton datums used to hold material property info
/datum/material_property
	abstract_type = /datum/material_property
	var/name = "Error"
	/// Associated property ID
	var/id = null

/datum/material_property/proc/get_descriptor(value)
	return null

/// How dense a material is
/datum/material_property/density
	name = "Density"
	id = MATERIAL_DENSITY

/datum/material_property/density/get_descriptor(value)
	// Just for reference, IRL density of ABS plastic and water is ~1g/cm3, glass is 2.5, iron is 7.5 and lead is 11
	// So 0 ~ 1 would be paper/cardboard, then wood at 2, plastic at 3, glass at 4, iron at 6 and lead at 8 ~ 9
	switch(value)
		if (0 to 1)
			return "extremely light"
		if (1 to 2)
			return "very light"
		if (2 to 3)
			return "light"
		if (3 to 4)
			return "slightly dense"
		if (4 to 6)
			return "dense"
		if (6 to 8)
			return "very dense"
		if (8 to INFINITY)
			return "extremely dense"

/// How hard to deformation a material is, pierce/slashing impacts
/datum/material_property/hardness
	name = "Hardness"
	id = MATERIAL_HARDNESS

/datum/material_property/hardness/get_descriptor(value)
	switch(value)
		if (0 to 1)
			return "extremely soft"
		if (1 to 2)
			return "very soft"
		if (2 to 3)
			return "soft"
		if (3 to 4)
			return "slightly hard"
		if (4 to 6)
			return "hard"
		if (6 to 8)
			return "very hard"
		if (8 to INFINITY)
			return "extremely hard"

/// How well a material bends and sustains deformation
/datum/material_property/flexibility
	name = "Flexibility"
	id = MATERIAL_FLEXIBILITY

/datum/material_property/flexibility/get_descriptor(value)
	switch(value)
		if (0 to 1)
			return "extremely rigid"
		if (1 to 2)
			return "very rigid"
		if (2 to 3)
			return "rigid"
		if (3 to 4)
			return "slightly flexible"
		if (4 to 6)
			return "flexible"
		if (6 to 8)
			return "very flexible"
		if (8 to INFINITY)
			return "extremely flexible"

/// How shiny a material is
/datum/material_property/reflectivity
	name = "Reflectivity"
	id = MATERIAL_REFLECTIVITY

/datum/material_property/reflectivity/get_descriptor(value)
	switch(value)
		if (0 to 1)
			return "extremely dull"
		if (1 to 2)
			return "very dull"
		if (2 to 3)
			return "dull"
		if (3 to 4)
			return "matte"
		if (4 to 6)
			return "reflective"
		if (6 to 8)
			return "very reflective"
		if (8 to INFINITY)
			return "extremely reflective"

/// How electrically conductive a material is (siemens coeff)
/datum/material_property/electric_conductivity
	name = "Electric Conductivity"
	id = MATERIAL_ELECTRICAL

/datum/material_property/electric_conductivity/get_descriptor(value)
	switch(value)
		if (0)
			return "perfectly insulating"
		if (0 to 1)
			return "highly insulating"
		if (1 to 2)
			return "insulating"
		if (2 to 3)
			return "poorly insulating"
		if (3 to 4)
			return "mildly conductive"
		if (4 to 6)
			return "conductive"
		if (6 to 8)
			return "highly conductive"
		if (8 to INFINITY)
			return "extremely conductive"

/// How well a material conducts heat
/datum/material_property/thermal_conductivity
	name = "Thermal Conductivity"
	id = MATERIAL_THERMAL

/datum/material_property/thermal_conductivity/get_descriptor(value)
	switch(value)
		if (0 to 1)
			return "extremely temperature-resistant"
		if (1 to 2)
			return "very temperature-resistant"
		if (2 to 3)
			return "temperature-resistant"
		if (3 to 4)
			return "slightly thermally conductive"
		if (4 to 6)
			return "thermally conductive"
		if (6 to 8)
			return "very thermally conductive"
		if (8 to INFINITY)
			return "extremely thermally conductive"

/// How well the material resists acids and other similar chemicals
/datum/material_property/chemical_resistance
	name = "Chemical Resistance"
	id = MATERIAL_CHEMICAL

/datum/material_property/chemical_resistance/get_descriptor(value)
	switch(value)
		if (0 to 1)
			return "extremely reactive"
		if (1 to 2)
			return "reactive"
		if (2 to 3)
			return "slightly reactive"
		if (3 to 4)
			return "mildly chemically resistant"
		if (4 to 6)
			return "chemically resistant"
		if (6 to 8)
			return "highly chemically resistant"
		if (8 to INFINITY)
			return "extremely chemically resistant"

// Optional properties

/// If a material has this property, it is flammable and has reduced fire protection.
/datum/material_property/flammability
	name = "Flammability"
	id = MATERIAL_FLAMMABILITY

/datum/material_property/flammability/get_descriptor(value)
	switch(value)
		if (0)
			return "nonflammable"
		if (0 to 1)
			return "mostly nonflammable"
		if (1 to 2)
			return "mildly nonflammable"
		if (2 to 3)
			return "somewhat flammable"
		if (3 to 4)
			return "flammable"
		if (4 to 6)
			return "highly flammable"
		if (6 to 8)
			return "extremely flammable"
		if (8 to INFINITY)
			return "insanely flammable"

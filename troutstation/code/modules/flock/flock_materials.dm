/datum/material/flockmetal
	name = "sonorous metal"
	desc = "Gently humming metal of unknown alien origin. Faintly warm to the touch."
	color = "#3c8c64"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 6,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 2,
		MATERIAL_REFLECTIVITY = 5,
		MATERIAL_ELECTRICAL = 8,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 10,
		MATERIAL_BEAUTY = 0.2,
	)
	// sheet_type = TODO
	// ore_type = TODO
	value_per_unit = 300 / SHEET_MATERIAL_AMOUNT
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	mineral_rarity =  MATERIAL_RARITY_UNDISCOVERED

/datum/material/flockglass
	name = "resonant crystal"
	desc = "Alien glass. It glimmers with rivulets of light through geometric lines."
	color = "#3c8c64"
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_RIGID
	mat_properties = list(
		MATERIAL_DENSITY = 3,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 3,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 1,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 10,
		MATERIAL_BEAUTY = 0.2,
	)
	// sheet_type = TODO
	// ore_type = TODO
	value_per_unit = 300 / SHEET_MATERIAL_AMOUNT
	points_per_unit = 100 / SHEET_MATERIAL_AMOUNT
	mineral_rarity =  MATERIAL_RARITY_UNDISCOVERED

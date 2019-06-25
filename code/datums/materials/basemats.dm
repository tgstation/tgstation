/datum/material/hematite
	name = "Hematite"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_IRON = TRUE)

/datum/material/glass
	name = "Glass"
	desc = "Glass forged by melting sand."
	categories = list(MAT_CATEGORY_TRANSPARENT = TRUE)

/datum/material/silver
	name = "Silver"
	desc = "Silver"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_SILVER = TRUE)

/datum/material/gold
	name = "Gold"
	desc = "Gold"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_GOLD = TRUE)

/datum/material/diamond
	name = "Diamond"
	desc = "Highly pressurized carbon"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_DIAMOND = TRUE)

/datum/material/uranium
	name = "Uranium"
	desc = "Uranium"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_URANIUM = TRUE)

/datum/material/uranium/on_applied(atom/source, amount)
	source.AddComponent(/datum/component/radioactive, amount / 100, source)

/datum/material/plasma
	name = "Plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_PLASMA = TRUE)

/datum/material/bluespace
	name = "Bluespace Crystal"
	desc = "Crystals with bluespace properties"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_BLUESPACE = TRUE)

/datum/material/bananium
	name = "Bananium"
	desc = "Material with hilarious properties"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_BANANIUM = TRUE)

/datum/material/titanium
	name = "Titanium"
	desc = "Titanium"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_TITANIUM = TRUE)

/datum/material/plastic
	name = "plastic"
	desc = "plastic"
	categories = list(MAT_CATEGORY_PLASTIC = TRUE)

/datum/material/biomass
	name = "Biomass"
	desc = "Organic matter"
	categories = list(MAT_CATEGORY_BIOMASS = TRUE)
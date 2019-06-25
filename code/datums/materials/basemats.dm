/datum/material/hematite
	name = "Hematite"
	id = "hematite"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_IRON = TRUE)
	sheet_type = /obj/item/stack/sheet/metal
	coin_type = /obj/item/coin/iron

/datum/material/glass
	name = "Glass"
	id = "glass"
	desc = "Glass forged by melting sand."
	categories = list(MAT_CATEGORY_TRANSPARENT = TRUE)
	sheet_type = /obj/item/stack/sheet/glass

/datum/material/silver
	name = "Silver"
	id = "silver"
	desc = "Silver"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_SILVER = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	coin_type = /obj/item/coin/silver

/datum/material/gold
	name = "Gold"
	id = "gold"
	desc = "Gold"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_GOLD = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/gold
	coin_type = /obj/item/coin/gold

/datum/material/diamond
	name = "Diamond"
	id = "diamond"
	desc = "Highly pressurized carbon"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_DIAMOND = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	coin_type = /obj/item/coin/diamond

/datum/material/uranium
	name = "Uranium"
	id = "uranium"
	desc = "Uranium"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_URANIUM = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	coin_type = /obj/item/coin/uranium

/datum/material/uranium/on_applied(atom/source, amount)
	source.AddComponent(/datum/component/radioactive, amount / 100, source)

/datum/material/plasma
	name = "Plasma"
	id = "plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_PLASMA = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	coin_type = /obj/item/coin/plasma

/datum/material/bluespace
	name = "Bluespace Crystal"
	id = "bluespace_crystal"
	desc = "Crystals with bluespace properties"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_BLUESPACE = TRUE)
	sheet_type = /obj/item/stack/sheet/bluespace_crystal

/datum/material/bananium
	name = "Bananium"
	id = "bananium"
	desc = "Material with hilarious properties"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_BANANIUM = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	coin_type = /obj/item/coin/bananium

/datum/material/titanium
	name = "Titanium"
	id = "titanium"
	desc = "Titanium"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_TITANIUM = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/titanium

/datum/material/plastic
	name = "plastic"
	id = "plastic"
	desc = "plastic"
	categories = list(MAT_CATEGORY_PLASTIC = TRUE)
	sheet_type = /obj/item/stack/sheet/plastic

/datum/material/biomass
	name = "Biomass"
	id = "biomass"
	desc = "Organic matter"
	categories = list(MAT_CATEGORY_BIOMASS = TRUE)
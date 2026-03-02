/datum/material/cloth
	name = "cloth"
	desc = "What sort of cloth is this? Who do you think I am, a tailor?" // Its cotton, the answer is cotton
	color = "#EAEAE1"
	mat_flags = MATERIAL_CLASS_FABRIC | MATERIAL_CLASS_ORGANIC
	mat_properties = list(
		MATERIAL_DENSITY = 3,
		MATERIAL_HARDNESS = 0,
		MATERIAL_FLEXIBILITY = 9,
		MATERIAL_REFLECTIVITY = 0,
		MATERIAL_ELECTRICAL = 7, // Its an organic compound, its pretty conductive actually
		MATERIAL_THERMAL = 2,
		MATERIAL_CHEMICAL = 0,
		MATERIAL_FLAMMABILITY = 8,
	)
	sheet_type = /obj/item/stack/sheet/cloth
	material_reagent = /datum/reagent/cellulose
	value_per_unit = 10 / SHEET_MATERIAL_AMOUNT

// Doesn't break down into actual titanium (as of now) for my own sanity's sake, otherwise we'd have to deal with questionable material composition on clothing
// And I really don't wanna go hunting down all edge cases this can birth, especially with slots which are already fragile
/datum/material/cloth/durathread
	name = "durathread"
	desc = "An incredibly tough and dense titanium-infused fabric."
	color = "#8B9BB4"
	mat_properties = list(
		MATERIAL_DENSITY = 5,
		MATERIAL_HARDNESS = 4,
		MATERIAL_FLEXIBILITY = 8,
		MATERIAL_REFLECTIVITY = 3,
		MATERIAL_ELECTRICAL = 9,
		MATERIAL_THERMAL = 5,
		MATERIAL_CHEMICAL = 2,
		MATERIAL_FLAMMABILITY = 4,
	)
	sheet_type = /obj/item/stack/sheet/durathread
	value_per_unit = 200 / SHEET_MATERIAL_AMOUNT

/datum/material/cloth/wool
	name = "wool"
	desc = "Made with love and animal cruelty."
	color = "#E2E1DE"
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 1,
		MATERIAL_FLEXIBILITY = 9,
		MATERIAL_REFLECTIVITY = 0,
		MATERIAL_ELECTRICAL = 5,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 0,
		MATERIAL_FLAMMABILITY = 9,
	)
	sheet_type = /obj/item/stack/sheet/cotton/wool
	value_per_unit = 20 / SHEET_MATERIAL_AMOUNT

/datum/material/leather
	name = "leather"
	desc = "Is it synthetic, or did this leather moo at one point? You'll never know."
	color = "#AC793E"
	mat_flags = MATERIAL_CLASS_FABRIC | MATERIAL_CLASS_ORGANIC
	mat_properties = list(
		MATERIAL_DENSITY = 2, // Much lighter than cotton, actually
		MATERIAL_HARDNESS = 3,
		MATERIAL_FLEXIBILITY = 8,
		MATERIAL_REFLECTIVITY = 0,
		MATERIAL_ELECTRICAL = 6,
		MATERIAL_THERMAL = 3,
		MATERIAL_CHEMICAL = 2,
		MATERIAL_FLAMMABILITY = 2,
	)
	sheet_type = /obj/item/stack/sheet/leather
	value_per_unit = 30 / SHEET_MATERIAL_AMOUNT

/datum/material/leather/xeno_chitin
	name = "alien chitin"
	desc = "Pitch-black chitin with a bright green membrane underneath."
	mat_flags = MATERIAL_CLASS_FABRIC | MATERIAL_CLASS_ORGANIC | MATERIAL_CLASS_POLYMER
	color = "#34334B"
	mat_properties = list(
		MATERIAL_DENSITY = 5,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 6,
		MATERIAL_REFLECTIVITY = 6,
		MATERIAL_ELECTRICAL = 2,
		MATERIAL_THERMAL = 2,
		MATERIAL_CHEMICAL = 8,
		MATERIAL_FLAMMABILITY = 6,
	)
	sheet_type = /obj/item/stack/sheet/animalhide/xeno
	value_per_unit = 150 / SHEET_MATERIAL_AMOUNT

/datum/material/leather/carp_scales
	name = "carp scales"
	desc = "Scales from a not-really-a-space-dragon."
	color = "#77548F"
	mat_properties = list(
		MATERIAL_DENSITY = 4,
		MATERIAL_HARDNESS = 5,
		MATERIAL_FLEXIBILITY = 7,
		MATERIAL_REFLECTIVITY = 8,
		MATERIAL_ELECTRICAL = 4,
		MATERIAL_THERMAL = 1,
		MATERIAL_CHEMICAL = 6,
	)
	sheet_type = /obj/item/stack/sheet/animalhide/carp
	value_per_unit = 50 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "scales"

// Shared with the ash drake
/datum/material/leather/goliath
	name = "ashen hide"
	desc = "Hide of a deadly beast."
	color = "#6D252F"
	mat_properties = list(
		MATERIAL_DENSITY = 6, // Uncomfortably heavy and rigid
		MATERIAL_HARDNESS = 7,
		MATERIAL_FLEXIBILITY = 6,
		MATERIAL_REFLECTIVITY = 0,
		MATERIAL_ELECTRICAL = 4,
		MATERIAL_THERMAL = 0,
		MATERIAL_CHEMICAL = 6,
	)
	sheet_type = /obj/item/stack/sheet/animalhide/goliath_hide
	value_per_unit = 80 / SHEET_MATERIAL_AMOUNT

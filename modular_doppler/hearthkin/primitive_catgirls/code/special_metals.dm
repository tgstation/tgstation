// Completely made up materials to be sold in bar form by jarnsmiour in cargo, *should* be unobtainable otherwise

// Darkish blue kinda material

/datum/material/cobolterium
	name = "cobolterium"
	desc = "Cobolterium"
	color = list(0.2,0.5,0.7,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#264d61"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL = TRUE)
	sheet_type = /obj/item/stack/sheet/cobolterium

/datum/material/cobolterium/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/obj/item/stack/sheet/cobolterium
	name = "cobolterium bars"
	desc = "Cobalt-blue metal that might actually just be cobalt."
	singular_name = "cobolterium bar"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/special_metals_stack.dmi'
	icon_state = "precious-metals"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	mats_per_unit = list(/datum/material/cobolterium = SHEET_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/cobolterium
	material_type = /datum/material/cobolterium
	material_modifier = 1

/obj/item/stack/sheet/cobolterium/three
	amount = 3

// More copper colored material

/datum/material/copporcitite
	name = "copporcitite"
	desc = "Copporcitite"
	color = list(0.8,0.35,0.1,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#c55a1d"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL = TRUE)
	sheet_type = /obj/item/stack/sheet/copporcitite

/datum/material/copporcitite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/obj/item/stack/sheet/copporcitite
	name = "copporcitite bars"
	desc = "Copper colored metal that might actually just be copper."
	singular_name = "copporcitite bar"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/special_metals_stack.dmi'
	icon_state = "precious-metals"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	mats_per_unit = list(/datum/material/copporcitite = SHEET_MATERIAL_AMOUNT)
	merge_type = /obj/item/stack/sheet/copporcitite
	material_type = /datum/material/copporcitite
	material_modifier = 1

/obj/item/stack/sheet/copporcitite/three
	amount = 3

// Super blued-silver color

/datum/material/tinumium
	name = "tinumium"
	desc = "Tinumium"
	color = list(0.45,0.5,0.6,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#717e97"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL = TRUE)
	sheet_type = /obj/item/stack/sheet/tinumium

/datum/material/tinumium/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/obj/item/stack/sheet/tinumium
	name = "tinumium bars"
	desc = "Heavily blued, silver colored metal."
	singular_name = "tinumium bar"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/special_metals_stack.dmi'
	icon_state = "precious-metals"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	mats_per_unit = list(/datum/material/tinumium = SHEET_MATERIAL_AMOUNT )
	merge_type = /obj/item/stack/sheet/tinumium
	material_type = /datum/material/tinumium
	material_modifier = 1

/obj/item/stack/sheet/tinumium/three
	amount = 3

// Brassy yellow color

/datum/material/brussite
	name = "brussite"
	desc = "Brussite"
	color = list(0.9,0.75,0.4,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#E1C16E"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL = TRUE)
	sheet_type = /obj/item/stack/sheet/brussite

/datum/material/brussite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = 5)
	return TRUE

/obj/item/stack/sheet/brussite
	name = "brussite bars"
	desc = "Brassy-yellow metal that might actually just be brass."
	singular_name = "brussite bar"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/special_metals_stack.dmi'
	icon_state = "precious-metals"
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	mats_per_unit = list(/datum/material/brussite = SHEET_MATERIAL_AMOUNT )
	merge_type = /obj/item/stack/sheet/brussite
	material_type = /datum/material/brussite
	material_modifier = 1

/obj/item/stack/sheet/brussite/three
	amount = 3

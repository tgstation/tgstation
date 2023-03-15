/datum/material/metalhydrogen
	name = "Metal Hydrogen"
	id = "metal hydrogen"
	desc = "Solid metallic hydrogen. Some say it should be impossible"
	color = "#f2d5d7"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/metal_hydrogen


//formed when freon react with o2, emits a lot of plasma when heated
/datum/material/hot_ice
	name = "hot ice"
	id = "hot ice"
	desc = "A weird kind of ice, feels warm to the touch"
	color = "#88cdf1"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/hot_ice

/datum/material/hot_ice/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/hot_ice, "plasma", amount*50, amount*20+300)

/datum/material/hot_ice/on_removed(atom/source, amount, material_flags)
	qdel(source.GetComponent(/datum/component/hot_ice, "plasma", amount*50, amount*20+300))
	return ..()

/datum/material/zaukerite
	name = "zaukerite"
	desc = "A light absorbing crystal"
	color = COLOR_ALMOST_BLACK
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/zaukerite

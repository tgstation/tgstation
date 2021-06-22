/datum/material/hauntium
	name = "hauntium"
	desc = "very scary!"
	color = list(460/255, 464/255, 460/255, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#FFFFFF"
	alpha = 100
	categories = list(MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/hauntium
	value_per_unit = 0.05
	beauty_modifier = 0.25
	strength_modifier = 1
	armor_modifiers = list(MELEE = 1, BULLET = 1, LASER = 1, ENERGY = 1, BOMB = 1, BIO = 1, RAD = 1, FIRE = 1, ACID = 1)


/datum/material/hauntium/on_applied_obj(obj/o, amount, material_flags)
	. = ..()
	if(isitem(o))
		o.AddElement(/datum/element/haunted)

/datum/material/hauntium/on_removed_obj(obj/o, amount, material_flags)
	. = ..()
	if(isitem(o))
		o.RemoveElement(/datum/element/haunted)

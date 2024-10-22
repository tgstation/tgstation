/datum/material/hauntium
	name = "hauntium"
	desc = "very scary!"
	color = list(460/255, 464/255, 460/255, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_color = "#FFFFFF"
	alpha = 100
	starlight_color = COLOR_ALMOST_BLACK
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/hauntium
	value_per_unit = 0.05
	beauty_modifier = 0.25
	//pretty good but only the undead can actually make use of these modifiers
	strength_modifier = 1.2
	armor_modifiers = list(MELEE = 1.1, BULLET = 1.1, LASER = 1.15, ENERGY = 1.15, BOMB = 1, BIO = 1, FIRE = 1, ACID = 0.7)

/datum/material/hauntium/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(isobj(source))
		var/obj/obj = source
		obj.make_haunted(INNATE_TRAIT, "#f8f8ff")

/datum/material/hauntium/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(isobj(source))
		var/obj/obj = source
		obj.remove_haunted(INNATE_TRAIT)

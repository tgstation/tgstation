/datum/material/pizza
	name = "pizza"
	desc = "~Jamme, jamme, n'coppa, jamme ja! Jamme, jamme, n'coppa jamme ja, funi-culi funi-cala funi-culi funi-cala!! Jamme jamme ja funiculi funicula!~"
	color = "#FF9F23"
	greyscale_colors = "#FF9F23"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/pizza
	value_per_unit = 0.05
	strength_modifier = 0.7
	armor_modifiers = list(MELEE = 0.3, BULLET = 0.3, LASER = 1.2, ENERGY = 1.2, BOMB = 0.3, BIO = 0, RAD = 0.7, FIRE = 1, ACID = 1)
	item_sound_override = 'sound/effects/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "pizza"

/datum/material/pizza/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/edible))

/datum/material/pizza/on_applied_obj(obj/O, amount, material_flags)
	. = ..()
	make_edible(O, amount, material_flags)

/datum/material/pizza/on_applied_turf(turf/T, amount, material_flags)
	. = ..()
	make_edible(T, amount, material_flags)

/datum/material/pizza/proc/make_edible(atom/source, amount, material_flags)
	var/nutriment_count = 3 * (amount / MINERAL_MATERIAL_AMOUNT)
	var/oil_count = 2 * (amount / MINERAL_MATERIAL_AMOUNT)
	source.AddComponent(/datum/component/edible, list(/datum/reagent/consumable/nutriment = nutriment_count, /datum/reagent/consumable/cooking_oil = oil_count), null, GRAIN | MEAT | DAIRY | VEGETABLES, null, 30, list("crust", "tomato", "cheese", "meat"))

/datum/material/pizza
	name = "pizza"
	desc = "~Jamme, jamme, n'coppa, jamme ja! Jamme, jamme, n'coppa jamme ja, funi-culi funi-cala funi-culi funi-cala!! Jamme jamme ja funiculi funicula!~"
	color = "#FF9F23"
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/pizza
	value_per_unit = 0.05
	beauty_modifier = 0.1
	strength_modifier = 0.7
	armor_modifiers = list(MELEE = 0.3, BULLET = 0.3, LASER = 1.2, ENERGY = 1.2, BOMB = 0.3, FIRE = 1, ACID = 1)
	item_sound_override = 'sound/effects/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "pizza"

/datum/material/pizza/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(!IS_EDIBLE(source))
		make_edible(source, mat_amount)

/datum/material/pizza/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(IS_EDIBLE(source))
		make_edible(source, mat_amount)

/datum/material/pizza/proc/make_edible(atom/source, mat_amount)
	var/nutriment_count = 3 * (mat_amount / SHEET_MATERIAL_AMOUNT)
	var/oil_count = 2 * (mat_amount / SHEET_MATERIAL_AMOUNT)
	source.AddComponent(/datum/component/edible, \
		initial_reagents = list(/datum/reagent/consumable/nutriment = nutriment_count, /datum/reagent/consumable/nutriment/fat/oil = oil_count), \
		foodtypes = GRAIN | MEAT | DAIRY | VEGETABLES, \
		eat_time = 3 SECONDS, \
		tastes = list("crust", "tomato", "cheese", "meat"))

/datum/material/pizza/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	qdel(source.GetComponent(/datum/component/edible))

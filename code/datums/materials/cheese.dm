/datum/material/cheese
	name = "cheese"
	desc = "The moon is made out of this. You're pretty sure."
	color = "#fff023"
	greyscale_colors = "#fff023"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/cheese
	value_per_unit = 0.05
	beauty_modifier = 0.2
	strength_modifier = 0.5 // less structural stability than pizza
	armor_modifiers = list(MELEE = 0.1, BULLET = 0.1, LASER = 1.3, ENERGY = 1.3, BOMB = 0.3, FIRE = 1, ACID = 1)
	item_sound_override = 'sound/effects/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "cheese"

/datum/material/cheese/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/edible))

/datum/material/cheese/on_applied_obj(obj/O, amount, material_flags)
	. = ..()
	make_edible(O, amount, material_flags)

/datum/material/cheese/on_applied_turf(turf/T, amount, material_flags)
	. = ..()
	make_edible(T, amount, material_flags)

/datum/material/cheese/proc/make_edible(atom/source, amount, material_flags)
	var/protein_vitamin_count = 2 * (amount / SHEET_MATERIAL_AMOUNT)
	var/fat_count = 4 * (amount / SHEET_MATERIAL_AMOUNT)
	var/ingredients = list(
		/datum/reagent/consumable/nutriment/fat = fat_count,
		/datum/reagent/consumable/nutriment/protein = protein_vitamin_count,
		/datum/reagent/consumable/nutriment/vitamin = protein_vitamin_count,
	)

	// cheese is easier to chew through
	source.AddComponent(/datum/component/edible, \
		initial_reagents = ingredients, \
		foodtypes = DAIRY, \
		eat_time = 1 SECONDS, \
		tastes = list("cheese", "brie", "camembert", "feta", "gouda", "cheddar", "mozzarella", "parmesan"))

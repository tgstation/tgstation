///It's gross, gets the name of it's owner, and is all kinds of fucked up
/datum/material/meat
	name = "meat"
	id = "meat"
	desc = "Meat"
	color = rgb(214, 67, 67)
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/meat
	value_per_unit = 0.05
	beauty_modifier = -0.3
	strength_modifier = 0.7
	armor_modifiers = list("melee" = 0.3, "bullet" = 0.3, "laser" = 1.2, "energy" = 1.2, "bomb" = 0.3, "bio" = 0, "rad" = 0.7, "fire" = 1, "acid" = 1)
	item_sound_override = 'sound/effects/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "meat"

/datum/material/meat/on_removed(atom/source, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/edible))

/datum/material/meat/on_applied_obj(obj/O, amount, material_flags)
	. = ..()
	O.obj_flags |= UNIQUE_RENAME //So you can name it after the person its made from, a depressing comprimise.
	make_edible(O, amount, material_flags)

/datum/material/meat/on_applied_turf(turf/T, amount, material_flags)
	. = ..()
	make_edible(T, amount, material_flags)

/datum/material/meat/proc/make_edible(atom/source, amount, material_flags)
	var/nutriment_count = 3 * (amount / MINERAL_MATERIAL_AMOUNT)
	var/oil_count = 2 * (amount / MINERAL_MATERIAL_AMOUNT)
	source.AddComponent(/datum/component/edible, list(/datum/reagent/consumable/nutriment = nutriment_count, /datum/reagent/consumable/cooking_oil = oil_count), null, RAW | MEAT | GROSS, null, 30, list("Fleshy"))


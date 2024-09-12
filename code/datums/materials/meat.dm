///It's gross, gets the name of its owner, and is all kinds of fucked up
/datum/material/meat
	name = "meat"
	desc = "Meat"
	id = /datum/material/meat // So the bespoke versions are categorized under this
	color = rgb(214, 67, 67)
	greyscale_colors = rgb(214, 67, 67)
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/meat
	value_per_unit = 0.05
	beauty_modifier = -0.3
	strength_modifier = 0.7
	armor_modifiers = list(MELEE = 0.3, BULLET = 0.3, LASER = 1.2, ENERGY = 1.2, BOMB = 0.3, FIRE = 1, ACID = 1)
	item_sound_override = 'sound/effects/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "meat"

/datum/material/meat/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/edible))
	qdel(source.GetComponent(/datum/component/blood_walk))
	qdel(source.GetComponent(/datum/component/bloody_spreader))

/datum/material/meat/on_applied_obj(obj/O, amount, material_flags)
	. = ..()
	make_meaty(O, amount, material_flags)

/datum/material/meat/on_applied_turf(turf/T, amount, material_flags)
	. = ..()
	make_meaty(T, amount, material_flags)

/datum/material/meat/proc/make_meaty(atom/source, amount, material_flags)
	var/nutriment_count = 3 * (amount / SHEET_MATERIAL_AMOUNT)
	var/oil_count = 2 * (amount / SHEET_MATERIAL_AMOUNT)
	source.AddComponent(/datum/component/edible, \
		initial_reagents = list(/datum/reagent/consumable/nutriment = nutriment_count, /datum/reagent/consumable/nutriment/fat/oil = oil_count), \
		foodtypes = RAW | MEAT | GROSS, \
		eat_time = 3 SECONDS, \
		tastes = list("Meaty"))


	source.AddComponent(
		/datum/component/bloody_spreader,\
		blood_left = (nutriment_count + oil_count) * 0.3,\
		blood_dna = list("meaty DNA" = "MT-"),\
		diseases = null,\
	)

	// Turfs can't handle the meaty goodness of blood walk.
	if(!ismovable(source))
		return

	source.AddComponent(
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood,\
		blood_spawn_chance = 35,\
		max_blood = (nutriment_count + oil_count) * 0.3,\
	)

/datum/material/meat/mob_meat
	init_flags = MATERIAL_INIT_BESPOKE
	var/subjectname = ""
	var/subjectjob = null

/datum/material/meat/mob_meat/Initialize(_id, mob/living/source)
	if(!istype(source))
		return FALSE

	name = "[source?.name ? "[source.name]'s" : "mystery"] [initial(name)]"

	if(source.real_name)
		subjectname = source.real_name
	else if(source.name)
		subjectname = source.name

	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		subjectjob = human_source.job

	return ..()

/datum/material/meat/species_meat
	init_flags = MATERIAL_INIT_BESPOKE

/datum/material/meat/species_meat/Initialize(_id, datum/species/source)
	if(!istype(source))
		return FALSE

	name = "[source?.name || "mystery"] [initial(name)]"
	return ..()

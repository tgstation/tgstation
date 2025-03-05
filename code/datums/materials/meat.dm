///It's gross, gets the name of its owner, and is all kinds of fucked up
/datum/material/meat
	name = "meat"
	desc = "Meat"
	id = /datum/material/meat // So the bespoke versions are categorized under this
	color = rgb(214, 67, 67)
	categories = list(
		MAT_CATEGORY_RIGID = TRUE,
		MAT_CATEGORY_BASE_RECIPES = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL = TRUE,
		MAT_CATEGORY_ITEM_MATERIAL_COMPLEMENTARY = TRUE,
		)
	sheet_type = /obj/item/stack/sheet/meat
	value_per_unit = 0.05
	beauty_modifier = -0.3
	strength_modifier = 0.7
	armor_modifiers = list(MELEE = 0.3, BULLET = 0.3, LASER = 1.2, ENERGY = 1.2, BOMB = 0.3, FIRE = 1, ACID = 1)
	item_sound_override = 'sound/effects/meatslap.ogg'
	turf_sound_override = FOOTSTEP_MEAT
	texture_layer_icon_state = "meat"
	fishing_difficulty_modifier = 13
	fishing_cast_range = -2
	fishing_experience_multiplier = 0.8
	fishing_bait_speed_mult = 0.9
	fishing_deceleration_mult = 0.9
	fishing_bounciness_mult = 0.9
	fishing_gravity_mult = 0.85

/datum/material/meat/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(!IS_EDIBLE(source))
		make_edible(source, mat_amount, multiplier)
	ADD_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src)) //The rod itself is the bait... sorta.

/datum/material/meat/on_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(IS_EDIBLE(source))
		make_edible(source, mat_amount, multiplier)

/datum/material/meat/proc/make_edible(atom/source, mat_amount, multiplier)
	var/protein_count = 3 * (mat_amount / SHEET_MATERIAL_AMOUNT) * multiplier
	var/fat_count = 2 * (mat_amount / SHEET_MATERIAL_AMOUNT) * multiplier

	source.AddComponentFrom(
		SOURCE_EDIBLE_MEAT_MAT, \
		/datum/component/edible, \
		initial_reagents = list(/datum/reagent/consumable/nutriment/protein = protein_count, /datum/reagent/consumable/nutriment/fat = fat_count), \
		foodtypes = RAW | MEAT, \
		eat_time = 3 SECONDS, \
		tastes = list("meat"))

	source.AddComponent(
		/datum/component/bloody_spreader,\
		blood_left = (protein_count + fat_count) * 0.3,\
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
		max_blood = (protein_count + fat_count) * 0.3,\
	)

/datum/material/meat/on_removed(atom/source, mat_amount, multiplier)
	. = ..()
	source.RemoveComponentSource(SOURCE_EDIBLE_MEAT_MAT, /datum/component/edible)
	qdel(source.GetComponent(/datum/component/blood_walk))
	qdel(source.GetComponent(/datum/component/bloody_spreader))

/datum/material/meat/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	REMOVE_TRAIT(source, TRAIT_ROD_REMOVE_FISHING_DUD, REF(src))

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

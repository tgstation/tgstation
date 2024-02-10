/mob/living/basic/butterfly
	name = "butterfly"
	desc = "A colorful butterfly, how'd it get up here?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"

	response_help_continuous = "shoos"
	response_help_simple = "shoo"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brush aside"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"
	speak_emote = list("flutters")
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"

	maxHealth = 2
	health = 2

	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	gold_core_spawnable = FRIENDLY_SPAWN

	var/fixed_color = FALSE //monkestation edit - for fixed butterfly colors
	ai_controller = /datum/ai_controller/basic_controller/butterfly

/mob/living/basic/butterfly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)

	if(!fixed_color) //monkestation edit - for fixed butterfly colors
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BUTTERFLY, CELL_VIRUS_TABLE_GENERIC_MOB, cell_line_amount = 1, virus_chance = 5)

/mob/living/basic/butterfly/bee_friendly()
	return TRUE //treaty signed at the Beeneeva convention

/datum/ai_controller/basic_controller/butterfly
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/mob/living/basic/butterfly/lavaland
	unsuitable_atmos_damage = 0

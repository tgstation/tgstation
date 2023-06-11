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

	ai_controller = /datum/ai_controller/basic_controller/butterfly

/mob/living/basic/butterfly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)

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

/mob/living/basic/butterfly/lavaland/temporary
	name = "strange butterfly"
	basic_mob_flags = DEL_ON_DEATH
	/// The atom that's spawning the butterflies
	var/obj/item/mod/core/plasma/lavaland/source
	/// Max distance in tiles before the butterfly despawns
	var/max_distance = 5
	var/will_be_destroyed = FALSE
	var/despawn_timer = 0

/mob/living/basic/butterfly/lavaland/temporary/Initialize(mapload, creator)
	. = ..()
	source = creator
	START_PROCESSING(SSprocessing, src)

/mob/living/basic/butterfly/lavaland/temporary/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(source)
		source.child_despawned()
		source.children -= src
	. = ..()

/mob/living/basic/butterfly/lavaland/temporary/process()
	if(should_despawn())
		will_be_destroyed = TRUE
		despawn_timer = addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/basic/butterfly/lavaland/temporary, fadeout)), 5 SECONDS, TIMER_STOPPABLE)
	else
		if(will_be_destroyed)
			// Cancels the butterfly being destroyed
			will_be_destroyed = FALSE
			deltimer(despawn_timer)

/mob/living/basic/butterfly/lavaland/temporary/proc/should_despawn()
	if(!source.mod.active)
		return TRUE
	if(get_dist(source, src) > max_distance)
		return TRUE
	return FALSE

/mob/living/basic/butterfly/lavaland/temporary/proc/fadeout()
	animate(src, alpha = 0, 1 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/basic/butterfly/lavaland/temporary, despawn)), 1 SECONDS)

/mob/living/basic/butterfly/lavaland/temporary/proc/despawn()
	qdel(src)

/mob/living/basic/butterfly/lavaland/temporary/examine(mob/user)
	. = ..()
	. += span_notice("Something about it seems unreal...")

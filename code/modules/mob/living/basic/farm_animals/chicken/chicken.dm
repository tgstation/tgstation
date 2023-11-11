/// Counter for number of chicken mobs in the universe. Chickens will not lay fertile eggs if it exceeds the MAX_CHICKENS define.
GLOBAL_VAR_INIT(chicken_count, 0)

/* ## Chickens
*
*
* Not-entirely-flightless domesticated birds that lay eggs, which are then consumed by humans and other animals.
*/
/mob/living/basic/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "pecks"
	response_harm_simple = "peck"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	friendly_verb_continuous = "headbutts"
	friendly_verb_simple = "headbutt"
	speak_emote = list("clucks", "croons")
	health = 15
	maxHealth = 15
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/chicken

	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/fertile = TRUE

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	GLOB.chicken_count++
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "clucks happily!")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/animal_variety, "chicken", pick("brown", "black", "white"), modify_pixels = TRUE)
	AddComponent(\
		/datum/component/egg_layer,\
		/obj/item/food/egg/organic,\
		list(/obj/item/food/grown/wheat),\
		feed_messages = list("She clucks contently."),\
		lay_messages = EGG_LAYING_MESSAGES,\
		eggs_left = 0,\
		eggs_added_from_eating = rand(1, 4),\
		max_eggs_held = 8,\
		egg_laid_callback = CALLBACK(src, PROC_REF(egg_laid)),\
	)

/mob/living/basic/chicken/Destroy()
	GLOB.chicken_count--
	return ..()

/mob/living/basic/chicken/proc/egg_laid(obj/item/egg)
	if(GLOB.chicken_count <= MAX_CHICKENS && fertile && prob(25))
		egg.AddComponent(\
			/datum/component/fertile_egg,\
			embryo_type = /mob/living/basic/chick,\
			minimum_growth_rate = 1,\
			maximum_growth_rate = 2,\
			total_growth_required = 200,\
			current_growth = 0,\
			location_allowlist = typecacheof(list(/turf)),\
			spoilable = TRUE,\
		)

/datum/ai_controller/basic_controller/chicken
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/chicken,
	)


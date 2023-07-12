/mob/living/basic/pet/penguin

	icon = 'icons/mob/simple/penguins.dmi'
	gender = FEMALE

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	faction = list(FACTION_NEUTRAL)
	ai_controller = /datum/ai_controller/basic_controller/penguin
	///he can lay a egg?
	var/can_lay_eggs = TRUE

/mob/living/basic/pet/penguin/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/pet_bonus, "honks happily!")
	AddElement(/datum/element/waddling)
	AddComponent(\
		/datum/component/egg_layer,\
		/obj/item/food/egg/penguin_egg,\
		list(/obj/item/food/fishmeat),\
		lay_messages = EGG_LAYING_MESSAGES,\
		eggs_left = 0,\
		eggs_added_from_eating = 1,\
		max_eggs_held = 1,\
		egg_laid_callback = CALLBACK(src, PROC_REF(lay_penguin_egg)),\
	)

/mob/living/basic/pet/penguin/proc/lay_penguin_egg(obj/item/penguin_egg)
	if(prob(30))
		penguin_egg.AddComponent(\
			/datum/component/fertile_egg,\
			embryo_type = /mob/living/basic/pet/penguin/baby,\
			minimum_growth_rate = 1,\
			maximum_growth_rate = 1,\
			total_growth_required = 400,\
			current_growth = 0,\
			location_allowlist = typecacheof(list(/turf)),\
			spoilable = TRUE,\
		)

/datum/ai_controller/basic_controller/penguin
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/penguin,
	)


/mob/living/basic/pet/penguin/emperor
	name = "Emperor penguin"
	real_name = "penguin"
	desc = "Emperor of all she surveys."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/basic/pet/penguin/emperor/shamebrero
	name = "Shamebrero penguin"
	icon_state = "penguin_shamebrero"
	icon_living = "penguin_shamebrero"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/penguin/baby
	name = "Penguin chick"
	real_name = "penguin"
	desc = "Can't fly and barely waddles, yet the prince of all chicks."
	icon_state = "penguin_baby"
	icon_living = "penguin_baby"
	icon_dead = "penguin_baby_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/organ/internal/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 1)
	ai_controller = /datum/ai_controller/basic_controller/penguin/baby
	///he will grow or not
	var/grow_up = TRUE


/mob/living/basic/pet/penguin/baby/Initialize(mapload)
	. = ..()
	if(!grow_up)
		return
	var/grown_type
	if(prob(95))
		grown_type = /mob/living/basic/pet/penguin/emperor
	else
		grown_type = /mob/living/basic/pet/penguin/emperor/shamebrero

	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = null,\
		growth_path = grown_type,\
		growth_probability = 100,\
		lower_growth_value = 0.5,\
		upper_growth_value = 1,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
	)

/mob/living/basic/pet/penguin/baby/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/datum/ai_controller/basic_controller/penguin/baby
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_MOM_TYPES = list(/mob/living/basic/pet/penguin),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

/mob/living/basic/pet/penguin/baby/permanent
	grow_up = FALSE



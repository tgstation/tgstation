/mob/living/basic/ghost
	name = "ghost"
	desc = "A soul of the dead, spooky."
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "ghost"
	icon_living = "ghost"
	mob_biotypes = MOB_SPIRIT
	speak_emote = list("wails","weeps")
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	combat_mode = TRUE
	maxHealth = 40
	health = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	response_harm_continuous = "grips"
	response_harm_simple = "grip"
	unsuitable_atmos_damage = 0
	attack_sound = 'sound/hallucinations/growl1.ogg'
	death_message = "wails, disintegrating into a pile of ectoplasm!"
	gold_core_spawnable = NO_SPAWN //too spooky for science
	light_system = MOVABLE_LIGHT
	light_range = 1 // same glowing as visible player ghosts
	light_power = 2
	///What hairstyle will this ghost have
	var/ghost_hairstyle
	///What color will this ghost's hair be
	var/ghost_hair_color
	///The resulting hair to be displayed on the ghost
	var/mutable_appearance/ghost_hair
	///What facial hairstyle will this ghost have
	var/ghost_facial_hairstyle
	///What color will this ghost's facial hair be
	var/ghost_facial_hair_color
	///The resulting facial hair to be displayed on the ghost
	var/mutable_appearance/ghost_facial_hair
	///Will ghosts recieve a randomly generated name or not
	var/random = TRUE
	///What will this ghost drop on death
	var/list/death_loot = list(/obj/item/ectoplasm)

/mob/living/basic/ghost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/simple_flying)
	give_hair()
	if(random)
		switch(rand(0,1))
			if(0)
				name = "ghost of [pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			if(1)
				name = "ghost of [pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"

/**
 * Generates and displays the ghost's hair/facial hair
 *
 * Picks a random hair type, hair color, facial hair type, facial hair color.
 * Adds results as an overlay on the ghost.
 */

/mob/living/basic/ghost/proc/give_hair()
	if(ghost_hairstyle != null)
		ghost_hair = mutable_appearance('icons/mob/species/human/human_face.dmi', "hair_[ghost_hairstyle]", -HAIR_LAYER)
		ghost_hair.alpha = 200
		ghost_hair.color = ghost_hair_color
		add_overlay(ghost_hair)
	if(ghost_facial_hairstyle != null)
		ghost_facial_hair = mutable_appearance('icons/mob/species/human/human_face.dmi', "facial_[ghost_facial_hairstyle]", -HAIR_LAYER)
		ghost_facial_hair.alpha = 200
		ghost_facial_hair.color = ghost_facial_hair_color
		add_overlay(ghost_facial_hair)


//VERY RAW.
/datum/ai_controller/basic_controller/ghost
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED //change
	ai_movement = /datum/ai_movement/basic_avoidance //change
	idle_behavior = /datum/idle_behavior/idle_random_walk //come up with soemthing cooler

	planning_subtrees = list( //review
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/ghost,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/ghost
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/ghost

/datum/ai_behavior/basic_melee_attack/ghost
	action_cooldown = 2 SECONDS

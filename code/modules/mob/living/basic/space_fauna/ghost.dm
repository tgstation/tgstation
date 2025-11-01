/mob/living/basic/ghost
	name = "ghost"
	desc = "A soul of the dead, spooky."
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "ghost"
	icon_living = "ghost"
	mob_biotypes = MOB_SPIRIT | MOB_UNDEAD
	speak_emote = list("wails", "weeps")
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	combat_mode = TRUE
	basic_mob_flags = DEL_ON_DEATH
	status_flags = CANPUSH
	maxHealth = 40
	health = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	attack_sound = 'sound/effects/hallucinations/growl1.ogg'
	death_message = "wails, disintegrating into a pile of ectoplasm!"
	gold_core_spawnable = NO_SPAWN //too spooky for science
	light_system = OVERLAY_LIGHT
	light_range = 2.5 // same glowing as visible player ghosts
	light_power = 0.6
	ai_controller = /datum/ai_controller/basic_controller/ghost
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)

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
	///Will this ghost spawn with a randomly generated name and hair?
	var/random_identity = TRUE

/mob/living/basic/ghost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, /obj/item/ectoplasm)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)

	give_identity()

/**
 * Generates hair, facial hair, and a random name for ghosts if one is needed.
 *
 * Handles generating the mutable_appearance objects for a ghost's hair/facial hair,
 * as well as assigning a random name if needed. If random_identity is false, it will only create and display
 * the hair as defined by ghost_hairstyle/ghost_facial_hairstyle variables, without changing the name.
 * If random_identity is true, hair/facial/name will all be randomly generated and displayed.
 * When creating a ghost with a custom identity (for away missions, ruins, etc.) be sure random_identity is false.
 */

/mob/living/basic/ghost/proc/give_identity()
	if(random_identity)
		ghost_hairstyle = random_hairstyle() //This only gives us the hairstyle name, not the icon_state (which we need).
		ghost_hair_color = random_hair_color()

		if(prob(50)) //Only a chance at also getting facial hair
			ghost_facial_hairstyle = random_facial_hairstyle()
			ghost_facial_hair_color = ghost_hair_color

	if(!isnull(ghost_hairstyle) && ghost_hairstyle != "Bald") //Bald hairstyle and the Shaved facial hairstyle lack an associated sprite and will not properly generate hair, and just cause runtimes.
		var/datum/sprite_accessory/hair/hair_style = SSaccessories.hairstyles_list[ghost_hairstyle] //We use the hairstyle name to get the sprite accessory, which we copy the icon_state from.
		ghost_hair = mutable_appearance('icons/mob/human/human_face.dmi', "[hair_style.icon_state]", -HAIR_LAYER)
		ghost_hair.alpha = 200
		ghost_hair.color = ghost_hair_color
		ghost_hair.pixel_z = hair_style.y_offset
		add_overlay(ghost_hair)

	if(!isnull(ghost_facial_hairstyle) && ghost_facial_hairstyle != "Shaved")
		var/datum/sprite_accessory/facial_hair_style = SSaccessories.facial_hairstyles_list[ghost_facial_hairstyle]
		ghost_facial_hair = mutable_appearance('icons/mob/human/human_face.dmi', "[facial_hair_style.icon_state]", -HAIR_LAYER)
		ghost_facial_hair.alpha = 200
		ghost_facial_hair.color = ghost_facial_hair_color
		add_overlay(ghost_facial_hair)

	if(random_identity)
		switch(rand(0,1))
			if(0)
				name = "ghost of [pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			if(1)
				name = "ghost of [pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"

/datum/ai_controller/basic_controller/ghost
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Weaker variant of ghosts. Meant to be summoned in swarms via the ectoplasmic anomaly and associated ghost portal.
/mob/living/basic/ghost/swarm
	name = "vengeful spirit"
	desc = "Back from the grave, and not happy about it."
	maxHealth = 30
	health = 30
	attack_verb_continuous = "smashes"
	attack_verb_simple = "smash"
	melee_damage_lower = 10
	melee_damage_upper = 10
	death_message = "wails as it is torn back to the realm from which it came!"
	random_identity = FALSE

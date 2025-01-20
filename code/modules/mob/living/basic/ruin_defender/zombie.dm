/// Everyone knows what a zombie is
/mob/living/basic/zombie
	name = "Shambling Corpse"
	desc = "When there is no more room in hell, the dead will walk in outer space."
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 100
	health = 100
	melee_damage_lower = 21
	melee_damage_upper = 21
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/effects/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	combat_mode = TRUE
	speed = 4
	status_flags = CANPUSH
	death_message = "rapidly decays into a pile of bones!"
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	faction = list(FACTION_HOSTILE)
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/zombie
	/// Outfit the zombie spawns with for visuals.
	var/outfit = /datum/outfit/corpse_doctor
	/// Chance to spread zombieism on hit
	/// Only for admins because we don't actually want romerol to get into the round from space ruins generally speaking
	var/infection_chance = 0

/mob/living/basic/zombie/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, outfit, /datum/species/zombie, bloody_slots = ITEM_SLOT_OCLOTHING)
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/decal/remains/human)))

/mob/living/basic/zombie/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !infection_chance || !ishuman(target) || !prob(infection_chance))
		return
	try_to_zombie_infect(target)

/// Weaker variant used if you want to put more of them in one place, won't attack obstacles
/mob/living/basic/zombie/rotten
	name = "Rotting Carcass"
	desc = "This undead fiend looks to be badly decomposed."
	health = 60
	melee_damage_lower = 11
	melee_damage_upper = 11
	ai_controller = /datum/ai_controller/basic_controller/zombie/stupid

/mob/living/basic/zombie/rotten/assistant
	outfit = /datum/outfit/corpse_assistant

/datum/outfit/corpse_doctor
	name = "Corpse Doctor"
	suit = /obj/item/clothing/suit/toggle/labcoat
	uniform = /obj/item/clothing/under/rank/medical/doctor
	shoes = /obj/item/clothing/shoes/sneakers/white
	back = /obj/item/storage/backpack/medic

/datum/outfit/corpse_assistant
	name = "Corpse Assistant"
	mask = /obj/item/clothing/mask/gas
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	back = /obj/item/storage/backpack

/datum/ai_planning_subtree/random_speech/zombie
	speech_chance = 1
	emote_hear = list("groans.", "moans.", "grunts.")
	emote_see = list("twitches.", "shudders.")

/datum/ai_controller/basic_controller/zombie
	blackboard = list(
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/zombie,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/zombie/stupid
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/zombie,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/revolutionary
	name = "Revolutionary"
	desc = "He stands for a cause..."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_HOSTILE)
	icon = 'icons/mob/simple/simple_human.dmi'
	gender = MALE
	attack_verb_continuous = "robusts"
	attack_verb_simple = "robust"
	maxHealth = 50
	health = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	obj_damage = 20
	attack_sound = 'sound/weapons/smash.ogg'
	ai_controller = /datum/ai_controller/basic_controller/revolutionary
	/// list of weapons we can have
	var/static/list/possible_weapons = list(
		/obj/item/storage/toolbox/mechanical = "robust",
		/obj/item/spear = "pierce",
	)
	/// List of causes we support
	var/static/list/causes = list(
		"The revolution will not be televized!",
		"VIVA!",
		"Dirty pig!",
		"Gondola meat is murder!",
		"Free Cargonia!",
		"Mime rights are human rights!",
		"猫女 Free Terry!",
	)


/mob/living/basic/revolutionary/Initialize(mapload)
	. = ..()
	var/static/list/display_emote = list(
		BB_EMOTE_SAY = causes,
		BB_EMOTE_SOUND = list(
			'sound/creatures/monkey/monkey_screech_1.ogg',
			'sound/creatures/monkey/monkey_screech_2.ogg',
			'sound/creatures/monkey/monkey_screech_3.ogg',
			'sound/creatures/monkey/monkey_screech_4.ogg',
		),
		BB_SPEAK_CHANCE = 5,
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)
	var/obj/item/weapon_of_choice = pick(possible_weapons)
	attack_sound = weapon_of_choice::hitsound
	attack_verb_simple = possible_weapons[weapon_of_choice]
	attack_verb_continuous = "[attack_verb_simple]s"
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/revolutionary, l_hand = weapon_of_choice)


/obj/effect/mob_spawn/corpse/human/revolutionary
	name = "Revolutionary"
	outfit = /datum/outfit/revolution


/datum/outfit/revolution
	name = "Revolution"
	uniform = /obj/item/clothing/under/color/grey
	mask = /obj/item/clothing/mask/gas
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots


/datum/ai_controller/basic_controller/revolutionary
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/blackboard,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

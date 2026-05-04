/mob/living/basic/revolutionary
	name = "Revolutionary"
	desc = "They stand for a cause..."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_HOSTILE)
	icon = 'icons/mob/simple/simple_human.dmi'
	gender = MALE
	basic_mob_flags = DEL_ON_DEATH
	attack_verb_continuous = "robusts"
	attack_verb_simple = "robust"
	maxHealth = 50
	health = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	obj_damage = 20
	attack_sound = 'sound/items/weapons/smash.ogg'
	ai_controller = /datum/ai_controller/basic_controller/revolutionary
	/// list of weapons we can have
	var/static/list/possible_weapons = list(
		/obj/item/storage/toolbox/mechanical = "robust",
		/obj/item/spear = "pierce",
		/obj/item/fireaxe = "slice",
		/obj/item/melee/baseball_bat = "bat",
		/obj/item/melee/baton = "discipline",
	)
	/// List of things to shout
	var/static/list/phrases = list(
		"The revolution will not be televized!",
		"VIVA!",
		"Dirty pig!",
		"Gondola meat is murder!",
		"Free Cargonia!",
		"Mime rights are human rights!",
		"猫娘 Free Terry!",
	)
	/// List of causes to #support
	var/static/list/causes = list(
		"Worker's rights",
		"Icemoon climate change",
		"Fair clown treatment",
		"Lizards",
		"Moths",
		"Stop Lavaland drilling",
		"The Captain has been replaced by a robot",
		"Free Cargonia",
		"Befriend all space dragons",
		"The Grey Tide",
		"Rising cost of medbay",
	)
	/// Monkey screeches
	var/static/list/monkey_screeches = list(
		'sound/mobs/non-humanoids/monkey/monkey_screech_1.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_2.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_3.ogg',
		'sound/mobs/non-humanoids/monkey/monkey_screech_4.ogg',
	)
	/// Male screams
	var/static/list/male_screams = list(
		'sound/mobs/humanoids/human/scream/malescream_1.ogg',
		'sound/mobs/humanoids/human/scream/malescream_2.ogg',
		'sound/mobs/humanoids/human/scream/malescream_3.ogg',
		'sound/mobs/humanoids/human/scream/malescream_4.ogg',
		'sound/mobs/humanoids/human/scream/malescream_5.ogg',
	)
	/// Female screams
	var/static/list/female_screams = list(
		'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
	)


/mob/living/basic/revolutionary/Initialize(mapload)
	. = ..()
	shuffle_inplace(phrases)
	var/static/list/display_emote = list(
		BB_EMOTE_SAY = phrases,
		BB_EMOTE_SOUND = monkey_screeches,
		BB_SPEAK_CHANCE = 5,
	)
	ai_controller.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, display_emote)
	var/obj/item/weapon_of_choice = pick(possible_weapons)
	attack_sound = weapon_of_choice::hitsound
	attack_verb_simple = possible_weapons[weapon_of_choice]
	attack_verb_continuous = "[attack_verb_simple]s"

	AddElement(/datum/element/death_drops, /obj/effect/mob_spawn/corpse/human/revolutionary)
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/revolutionary, l_hand = weapon_of_choice)

	gender = pick(MALE, FEMALE, PLURAL)
	var/first_name
	switch(gender)
		if(MALE)
			first_name = pick(GLOB.first_names_male)
			death_sound = pick(male_screams + monkey_screeches)
		if(FEMALE)
			first_name = pick(GLOB.first_names_female)
			death_sound = pick(female_screams + monkey_screeches)
		if(PLURAL)
			first_name = pick(GLOB.first_names)
			death_sound = pick(male_screams + female_screams + monkey_screeches)

	fully_replace_character_name(name, "[first_name] [pick(GLOB.last_names)]")
	desc += span_infoplain("\nToday, that cause is: ")
	shuffle_inplace(causes)
	desc += span_notice("#[pick(causes)].")


/obj/effect/mob_spawn/corpse/human/revolutionary
	name = "Revolutionary"
	outfit = /datum/outfit/revolution


/datum/outfit/revolution
	name = "Revolution"
	uniform = /obj/item/clothing/under/color/grey
	head = /obj/item/clothing/head/costume/ushanka
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
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/random_speech/blackboard/revolutionary,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)


/datum/ai_planning_subtree/random_speech/blackboard/revolutionary


/datum/ai_planning_subtree/random_speech/blackboard/revolutionary/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	return ..()

/mob/living/basic/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach_no_animation"
	density = FALSE
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	mob_size = MOB_SIZE_TINY
	held_w_class = WEIGHT_CLASS_TINY
	health = 1
	maxHealth = 1
	speed = 1.25
	can_be_held = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB

	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	speak_emote = list("chitters")

	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)

	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 270
	maximum_survivable_temperature = INFINITY

	ai_controller = /datum/ai_controller/basic_controller/cockroach

	var/cockroach_cell_line = CELL_LINE_TABLE_COCKROACH

/mob/living/basic/cockroach/Initialize(mapload)
	. = ..()
	var/static/list/roach_drops = list(/obj/effect/decal/cleanable/insectguts)
	AddElement(/datum/element/death_drops, roach_drops)
	AddElement(/datum/element/swabable, cockroach_cell_line, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 7)
	AddElement(/datum/element/basic_body_temp_sensitive, 270, INFINITY)
	AddComponent( \
		/datum/component/squashable, \
		squash_chance = 50, \
		squash_damage = 1, \
		squash_flags = SQUASHED_SHOULD_BE_GIBBED|SQUASHED_ALWAYS_IF_DEAD|SQUASHED_DONT_SQUASH_IN_CONTENTS, \
	)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NUKEIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_RADIMMUNE, INNATE_TRAIT)

/mob/living/basic/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return FALSE

// Roach goop is the gibs to drop
/mob/living/basic/cockroach/spawn_gibs()
	return

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/obj/projectile/glockroachbullet
	damage = 10 //same damage as a hivebot
	damage_type = BRUTE

/obj/item/ammo_casing/glockroach
	name = "0.9mm bullet casing"
	desc = "A... 0.9mm bullet casing? What?"
	projectile_type = /obj/projectile/glockroachbullet


/mob/living/basic/cockroach/glockroach
	name = "glockroach"
	desc = "HOLY SHIT, THAT COCKROACH HAS A GUN!"
	icon_state = "glockroach"
	melee_damage_lower = 2.5
	melee_damage_upper = 10
	obj_damage = 10
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)
	ai_controller = /datum/ai_controller/basic_controller/cockroach/glockroach
	cockroach_cell_line = CELL_LINE_TABLE_GLOCKROACH
	///number of burst shots
	var/burst_shots
	///cooldown between attacks
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/cockroach/glockroach/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = /obj/item/ammo_casing/glockroach,\
		burst_shots = burst_shots,\
		cooldown_time = ranged_cooldown,\
	)

/datum/ai_controller/basic_controller/cockroach/glockroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/glockroach, //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/glockroach
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/glockroach

/datum/ai_behavior/basic_ranged_attack/glockroach //Slightly slower, as this is being made in feature freeze ;)
	action_cooldown = 1 SECONDS

/mob/living/basic/cockroach/hauberoach
	name = "hauberoach"
	desc = "Is that cockroach wearing a tiny yet immaculate replica 19th century Prussian spiked helmet? ...Is that a bad thing?"
	icon_state = "hauberoach"
	attack_verb_continuous = "rams its spike into"
	attack_verb_simple = "ram your spike into"
	melee_damage_lower = 2.5
	melee_damage_upper = 10
	obj_damage = 10
	melee_attack_cooldown = 1 SECONDS
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)
	sharpness = SHARP_POINTY
	ai_controller = /datum/ai_controller/basic_controller/cockroach/hauberoach
	cockroach_cell_line = CELL_LINE_TABLE_HAUBEROACH

/mob/living/basic/cockroach/hauberoach/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 10, max_damage = 15, flags = (CALTROP_BYPASS_SHOES | CALTROP_SILENT))
	AddComponent( \
		/datum/component/squashable, \
		squash_chance = 100, \
		squash_damage = 1, \
		squash_flags = SQUASHED_SHOULD_BE_GIBBED|SQUASHED_ALWAYS_IF_DEAD|SQUASHED_DONT_SQUASH_IN_CONTENTS, \
		squash_callback = TYPE_PROC_REF(/mob/living/basic/cockroach/hauberoach, on_squish), \
	)

///Proc used to override the squashing behavior of the normal cockroach.
/mob/living/basic/cockroach/hauberoach/proc/on_squish(mob/living/cockroach, mob/living/living_target)
	if(!istype(living_target))
		return FALSE //We failed to run the invoke. Might be because we're a structure. Let the squashable element handle it then!
	if(!HAS_TRAIT(living_target, TRAIT_PIERCEIMMUNE))
		living_target.visible_message(span_danger("[living_target] steps onto [cockroach]'s spike!"), span_userdanger("You step onto [cockroach]'s spike!"))
		return TRUE
	living_target.visible_message(span_notice("[living_target] squashes [cockroach], not even noticing its spike."), span_notice("You squashed [cockroach], not even noticing its spike."))
	return FALSE

/datum/ai_controller/basic_controller/cockroach/hauberoach
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,  //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_controller/basic_controller/cockroach/sewer
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/mob/living/basic/cockroach/glockroach/mobroach
	name = "mobroach"
	desc = "WE'RE FUCKED, THAT GLOCKROACH HAS A TOMMYGUN!"
	icon_state = "mobroach"
	ai_controller = /datum/ai_controller/basic_controller/cockroach/mobroach
	burst_shots = 4
	ranged_cooldown = 2 SECONDS

/datum/ai_controller/basic_controller/cockroach/mobroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/mobroach, //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/mobroach
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/mobroach

/datum/ai_behavior/basic_ranged_attack/mobroach
	action_cooldown = 2 SECONDS

/mob/living/basic/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach" //Make this work
	density = FALSE
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	mob_size = MOB_SIZE_TINY
	health = 1
	maxHealth = 1
	speed = 1.25
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
	faction = list("hostile", FACTION_MAINT_CREATURES)

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
	AddComponent(/datum/component/squashable, squash_chance = 50, squash_damage = 1)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/basic/cockroach/death(gibbed)
	if(GLOB.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/basic/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return FALSE


/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
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
	faction = list("hostile", FACTION_MAINT_CREATURES)
	ai_controller = /datum/ai_controller/basic_controller/cockroach/glockroach
	cockroach_cell_line = CELL_LINE_TABLE_GLOCKROACH

/mob/living/basic/cockroach/glockroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ranged_attacks, /obj/item/ammo_casing/glockroach)

/datum/ai_controller/basic_controller/cockroach/glockroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/cockroach,
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
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list("hostile", FACTION_MAINT_CREATURES)
	sharpness = SHARP_POINTY
	ai_controller = /datum/ai_controller/basic_controller/cockroach/hauberoach
	cockroach_cell_line = CELL_LINE_TABLE_HAUBEROACH

/mob/living/basic/cockroach/hauberoach/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 10, max_damage = 15, flags = (CALTROP_BYPASS_SHOES | CALTROP_SILENT))
	AddComponent(/datum/component/squashable, squash_chance = 100, squash_damage = 1, squash_callback = TYPE_PROC_REF(/mob/living/basic/cockroach/hauberoach, on_squish))

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
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/hauberoach,  //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/hauberoach
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/hauberoach

/datum/ai_behavior/basic_melee_attack/hauberoach //Slightly slower, as this is being made in feature freeze ;)
	action_cooldown = 1 SECONDS

/datum/ai_controller/basic_controller/cockroach/sewer
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/sewer,
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/sewer
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/sewer

/datum/ai_behavior/basic_melee_attack/sewer
	action_cooldown = 0.8 SECONDS

/mob/living/basic/cockroach/glockroach/mobroach
	name = "mobroach"
	desc = "WE'RE FUCKED, THAT GLOCKROACH HAS A TOMMYGUN!"
	icon_state = "mobroach"
	ai_controller = /datum/ai_controller/basic_controller/cockroach/mobroach

/datum/ai_controller/basic_controller/cockroach/mobroach
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/mobroach, //If we are attacking someone, this will prevent us from hunting
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/mobroach
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/mobroach

/datum/ai_behavior/basic_ranged_attack/mobroach
	shots = 4
	action_cooldown = 2 SECONDS

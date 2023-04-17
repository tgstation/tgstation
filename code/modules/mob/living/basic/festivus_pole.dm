/mob/living/basic/festivus
	name = "festivus pole"
	desc = "Serenity now... SERENITY NOW!"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	health_doll_icon = "festivus_pole"
	gender = NEUTER
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH

	response_help_continuous = "rubs"
	response_help_simple = "rub"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	base_pixel_x = -16

	speed = 1
	maxHealth = 200
	health = 200
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_HOSTILE)
	speak_emote = list("polls")

	death_message = "is hacked into pieces!"

	ai_controller = /datum/ai_controller/basic_controller/festivus_pole

/mob/living/basic/festivus/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/item/stack/rods))

/datum/ai_controller/basic_controller/festivus_pole
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // APCs
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_apcs,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/festivus/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(!user.combat_mode)
		visible_message(span_warning("[src] crackles with static electricity!"))
		for(var/obj/item/stock_parts/cell/cell in range(2, get_turf(src)))
			cell.give(75)
		for(var/mob/living/silicon/robot/robot in range(2, get_turf(src)))
			if(robot.cell)
				robot.cell.give(75)
		for(var/obj/machinery/power/apc/apc_target in range(2, get_turf(src)))
			if(apc_target.cell)
				apc_target.cell.give(75)

/datum/ai_planning_subtree/find_and_hunt_target/look_for_apcs
	hunting_behavior = /datum/ai_behavior/hunt_target/apcs
	hunt_targets = list(/obj/machinery/power/apc)
	hunt_range = 6


/datum/ai_planning_subtree/find_and_hunt_target/look_for_apcs
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/apcs
	hunting_behavior = /datum/ai_behavior/hunt_target/apcs
	hunt_targets = list(/obj/machinery/power/apc)
	hunt_range = 6

/datum/ai_behavior/hunt_target/apcs
	hunt_cooldown = 10 SECONDS

/datum/ai_behavior/hunt_target/apcs/target_caught(mob/living/hunter, obj/machinery/power/apc/hunted)
	new /obj/effect/particle_effect/sparks(hunted.loc)
	hunted.cell.give(75)


/datum/ai_behavior/find_hunt_target/apcs

/datum/ai_behavior/find_hunt_target/apcs/valid_dinner(mob/living/source, obj/machinery/power/apc/dinner, radius)
	if(istype(dinner, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc_target = dinner
		if(!apc_target.cell)
			return FALSE
		var/obj/item/stock_parts/cell/apc_cell = apc_target.cell
		if(apc_cell.charge == apc_cell.maxcharge) //if its full charge we no longer feed it
			return FALSE

	return can_see(source, dinner, radius)

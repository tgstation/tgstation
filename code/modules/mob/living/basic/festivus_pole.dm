///how much charge we give off to cells around us when rubbed
#define FESTIVUS_RECHARGE_VALUE (0.075 * STANDARD_CELL_CHARGE)

/mob/living/basic/festivus
	name = "festivus pole"
	desc = "Serenity now... SERENITY NOW!"
	icon = 'icons/obj/fluff/flora/pinetrees.dmi'
	icon_state = "festivus_pole"
	icon_living = "festivus_pole"
	icon_dead = "festivus_pole"
	icon_gib = "festivus_pole"
	health_doll_icon = "festivus_pole"
	gender = NEUTER
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	status_flags = CANPUSH

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
	attack_sound = 'sound/items/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	faction = list(FACTION_HOSTILE)
	speak_emote = list("polls")

	death_message = "is hacked into pieces!"

	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	ai_controller = /datum/ai_controller/basic_controller/festivus_pole

/mob/living/basic/festivus/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/death_drops, /obj/item/stack/rods)
	AddComponent(/datum/component/aggro_emote, emote_list = string_list(list("growls")), emote_chance = 20)
	grant_actions_by_list(list(/datum/action/cooldown/mob_cooldown/charge_apc = BB_FESTIVE_APC))

/datum/ai_controller/basic_controller/festivus_pole
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // APCs
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_apcs,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/festivus/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		return
	visible_message(span_warning("[src] crackles with static electricity!"))
	for(var/atom/affected in range(2, get_turf(src)))
		if(istype(affected, /obj/item/stock_parts/power_store/cell))
			var/obj/item/stock_parts/power_store/cell/cell = affected
			cell.give(FESTIVUS_RECHARGE_VALUE)
			cell.update_appearance()
		if(istype(affected, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/robot = affected
			if(robot.cell)
				robot.cell.give(FESTIVUS_RECHARGE_VALUE)
		if(istype(affected, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc_target = affected
			if(apc_target.cell)
				apc_target.cell.give(FESTIVUS_RECHARGE_VALUE)

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
	hunt_cooldown = 15 SECONDS
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/apcs/target_caught(mob/living/basic/hunter, obj/machinery/power/apc/hunted)
	var/datum/action/cooldown/mob_cooldown/charge_ability = hunter.ai_controller.blackboard[BB_FESTIVE_APC]
	if(isnull(charge_ability))
		return
	charge_ability.Activate(hunted)


/datum/ai_behavior/find_hunt_target/apcs

/datum/ai_behavior/find_hunt_target/apcs/valid_dinner(mob/living/source, obj/machinery/power/apc/dinner, radius)
	if(istype(dinner, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc_target = dinner
		if(!apc_target.cell)
			return FALSE
		var/obj/item/stock_parts/power_store/cell/apc_cell = apc_target.cell
		if(apc_cell.charge == apc_cell.maxcharge) //if its full charge we no longer feed it
			return FALSE

	return can_see(source, dinner, radius)

#undef FESTIVUS_RECHARGE_VALUE

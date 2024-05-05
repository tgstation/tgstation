///////////////Donk Exenteration Drone - DED////////////
//A patrolling bot that cuts you up if you get close. Use ranged weapons or avoid it.

#define SPIN_SLASH_ABILITY_TYPEPATH /datum/action/cooldown/mob_cooldown/spell/aoe/exenterate

/mob/living/basic/bot/dedbot
	name = "\improper Donk Exenteration Drone" //Exenteration means ripping entrails out, ouch!
	desc = "A quad-bladed commercial defence drone, often called an 'Ex-Drone' or 'D.E.D.bot'. It follows a simple programmed patrol route, and slashes at anyone who doesn't have a syndicate identity implant."
	icon_state = "ded_drone0"
	base_icon_state = "ded_drone"
	req_one_access = list(ACCESS_SYNDICATE)
	health = 50
	maxHealth = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	light_power = 0
	ai_controller = /datum/ai_controller/basic_controller/bot/dedbot
	faction = list(ROLE_SYNDICATE, FACTION_SILICON, FACTION_TURRET)
	sharpness = SHARP_EDGED
	attack_verb_continuous = "eviscerates"
	attack_verb_simple = "eviscerate"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	gold_core_spawnable = HOSTILE_SPAWN
	limb_destroyer = 1
	bubble_icon = "machine"
	pass_flags = PASSMOB | PASSFLAPS
	maximum_survivable_temperature = 360 //prone to overheating
	possessed_message = "You are an exenteration drone. Exenterate."
	additional_access = /datum/id_trim/away/hauntedtradingpost/boss
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL
	mob_size = MOB_SIZE_SMALL
	robot_arm = /obj/item/hatchet/cutterblade
	density = FALSE

	//aoe slash ability
	var/datum/action/cooldown/mob_cooldown/bot/exenterate

/mob/living/basic/bot/dedbot/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/gibspawner/robot)
	AddElement(/datum/element/death_drops, death_loot)
	AddComponent(/datum/component/connect_range, tracked = src, range = 1, works_in_containers = FALSE)
	var/static/list/innate_actions = list(
		SPIN_SLASH_ABILITY_TYPEPATH = BB_DEDBOT_SLASH,
	)
	grant_actions_by_list(innate_actions)

/mob/living/basic/bot/dedbot/proc/aggro(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) || !istype(victim, /mob/living/carbon) || victim.stat == DEAD || in_faction(victim))
		return


/mob/living/basic/bot/dedbot/proc/in_faction(mob/target)
	for(var/faction1 in faction)
		if(faction1 in target.faction)
			return TRUE
	return FALSE

/datum/ai_controller/basic_controller/bot/dedbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/jps/bot
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/mob_cooldown/bot/exenterate,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/find_patrol_beacon,
		/datum/ai_planning_subtree/manage_unreachable_list,
	)
	max_target_distance = AI_BOT_PATH_LENGTH
	///keys to be reset when the bot is reseted
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)


/datum/ai_planning_subtree/mob_cooldown/bot/exenterate
//	ability_key = BB_DEDBOT_SLASH
//	finish_planning = FALSE
// why aint dis workin




/datum/action/cooldown/mob_cooldown/spell/aoe/exenterate
	name = "Exenterate"
	desc = "Disembowel every living thing in range with your blades."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	click_to_activate = TRUE
	background_icon = 'icons/hud/guardian.dmi'
	background_icon_state = "base"
	cooldown_time = 0.5 SECONDS
	//how much damage this ability does
	var/damage_dealt = 18
	//range of the spin ability's aoe
	var/exenteration_reach = 1
	/// weighted list of body zones this can hit
	var/static/list/valid_targets = list(
		BODY_ZONE_CHEST = 2,
		BODY_ZONE_R_ARM = 1,
		BODY_ZONE_L_ARM = 1,
		BODY_ZONE_R_LEG = 1,
		BODY_ZONE_L_LEG = 1,
	)
	/// list of things this ability doesn't damage
	var/list/damage_blacklist_typecache = list(
		/mob/living/basic/bot/dedbot,
		/mob/living/basic/viscerator,
		/mob/living/basic/pet/dog,
		)

/datum/action/cooldown/mob_cooldown/spell/aoe/exenterate/Activate(mob/living/source)
	. = ..()
	source.Shake(2, 0, 0.2 SECONDS)
	for(var/mob/living/living_mob in range(exenteration_reach, src))
		if (is_type_in_typecache(living_mob, damage_blacklist_typecache))
			continue
		to_chat(living_mob, span_warning("You are cut by the drone's blades!"))
		living_mob.apply_damage(damage_dealt, damagetype = BRUTE, def_zone = valid_targets, sharpness = SHARP_EDGED)


#undef SPIN_SLASH_ABILITY_TYPEPATH

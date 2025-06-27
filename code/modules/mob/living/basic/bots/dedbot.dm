///////////////Donk Exenteration Drone - DED////////////
//A patrolling bot that cuts you up if you get close. Use ranged weapons or avoid it.

#define SPIN_SLASH_ABILITY_TYPEPATH /datum/action/cooldown/mob_cooldown/exenterate

/mob/living/basic/bot/dedbot
	name = "\improper Donk Exenteration Drone" //Exenteration means ripping entrails out, ouch!
	desc = "A bladed commercial defence drone, often called an 'Ex-Drone' or 'D.E.D.bot'. It follows a simple programmed patrol route, and slashes at anyone who doesn't have an identity implant."
	icon_state = "ded_drone0"
	base_icon_state = "ded_drone"
	req_one_access = list(ACCESS_SYNDICATE)
	health = 50
	maxHealth = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	light_range = 1
	light_power = 0.3
	light_color = "#eb1809"
	ai_controller = /datum/ai_controller/basic_controller/bot/dedbot
	faction = list(ROLE_SYNDICATE)
	sharpness = SHARP_EDGED
	attack_verb_continuous = "eviscerates"
	attack_verb_simple = "eviscerate"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	gold_core_spawnable = HOSTILE_SPAWN
	limb_destroyer = TRUE
	bubble_icon = "machine"
	pass_flags = PASSMOB | PASSFLAPS
	maximum_survivable_temperature = 360 //prone to overheating
	possessed_message = "You are an exenteration drone. Exenterate."
	additional_access = /datum/id_trim/away/hauntedtradingpost/boss
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL
	mob_size = MOB_SIZE_SMALL
	robot_arm = /obj/item/hatchet/cutterblade
	density = FALSE
	COOLDOWN_DECLARE(trigger_cooldown)
	//time between exenteration uses
	var/exenteration_cooldown_duration = 0.5 SECONDS
	//aoe slash ability
	var/datum/action/cooldown/mob_cooldown/bot/exenterate
	var/list/remains = list(/obj/effect/gibspawner/robot)

/mob/living/basic/bot/dedbot/Initialize(mapload)
	. = ..()
	if(length(remains))
		remains = string_list(remains)
		AddElement(/datum/element/death_drops, remains)
	var/static/list/innate_actions = list(
	SPIN_SLASH_ABILITY_TYPEPATH = BB_DEDBOT_SLASH,
	)
	grant_actions_by_list(innate_actions)

/datum/ai_controller/basic_controller/bot/dedbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_AGGRO_RANGE = 2,
	)
	ai_movement = /datum/ai_movement/jps/bot
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/exenterate,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	max_target_distance = AI_BOT_PATH_LENGTH
	///keys to be reset when the bot is reseted
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)

/datum/ai_planning_subtree/targeted_mob_ability/exenterate
	ability_key = BB_DEDBOT_SLASH
	finish_planning = FALSE

/datum/action/cooldown/mob_cooldown/exenterate
	name = "Exenterate"
	desc = "Disembowel every living thing in range with your blades."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	click_to_activate = FALSE
	background_icon = 'icons/hud/guardian.dmi'
	background_icon_state = "base"
	cooldown_time = 0.5 SECONDS
	// radius in tiles of AOE effect
	var/ability_range = 1
	// how much damage this ability does
	var/damage_dealt = 18
	// factions we dont attack
	var/immune_factions = list(ROLE_SYNDICATE)
	// weighted list of body zones this can hit
	var/static/list/valid_targets = list(
		BODY_ZONE_CHEST = 2,
		BODY_ZONE_R_ARM = 1,
		BODY_ZONE_L_ARM = 1,
		BODY_ZONE_R_LEG = 1,
		BODY_ZONE_L_LEG = 1,
	)

/datum/action/cooldown/mob_cooldown/exenterate/Activate(atom/caster)
	if(!COOLDOWN_FINISHED(src, cooldown_time))
		return FALSE
	caster.Shake(1.4, 0.8, 0.3 SECONDS)
	caster.visible_message(span_danger("[caster] shakes violently!"))
	playsound(caster, 'sound/items/weapons/drill.ogg', 120 , TRUE)
	slash_em(caster)
	StartCooldown(cooldown_time)

/datum/action/cooldown/mob_cooldown/exenterate/proc/slash_em(atom/caster)
	for(var/mob/living/victim in range(ability_range, caster))
		if(faction_check(victim.faction, immune_factions) && owner.CanReach(victim))
			continue
		to_chat(caster, span_warning("You slice [victim]!"))
		to_chat(victim, span_warning("You are cut by [caster]'s blades!"))
		victim.apply_damage(damage = damage_dealt, damagetype = BRUTE, def_zone = pick(valid_targets), sharpness = SHARP_EDGED)

#undef SPIN_SLASH_ABILITY_TYPEPATH

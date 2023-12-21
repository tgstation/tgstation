#define MARAUDER_SHIELD_MAX 5
#define WELDER_REPAIR_AMOUNT 15

GLOBAL_LIST_EMPTY(clockwork_marauders)

/mob/living/basic/clockwork_marauder
	name = "clockwork marauder"
	desc = "A brass machine of destruction."
	icon = 'monkestation/icons/mob/clock_cult/clockwork_mobs.dmi'
	icon_state = "clockwork_marauder"
	icon_living = "clockwork_marauder"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 140
	health = 140
	basic_mob_flags = DEL_ON_DEATH
	speed = 1.25
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	melee_damage_lower = 24
	melee_damage_upper = 24
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	istate = ISTATE_HARM
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_LARGE
	move_resist = MOVE_FORCE_OVERPOWERING
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	obj_damage = 80
	faction = list(FACTION_CLOCK)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	ai_controller = /datum/ai_controller/basic_controller/clockwork_marauder
	initial_language_holder = /datum/language_holder/clockmob

	/// Items to be dropped on death
	var/static/list/loot = list(
		/obj/structure/fluff/clockwork/alloy_shards/large = 1,
		/obj/structure/fluff/clockwork/alloy_shards/medium = 2,
		/obj/structure/fluff/clockwork/alloy_shards/small = 3,
	)

	/// How many hits the shield can take before it breaks.
	var/shield_health = MARAUDER_SHIELD_MAX


/mob/living/basic/clockwork_marauder/Initialize(mapload)
	. = ..()
	if(length(loot))
		AddElement(/datum/element/death_drops, loot)

	var/datum/action/innate/clockcult/comm/communicate = new
	communicate.Grant(src)

	GLOB.clockwork_marauders += src


/mob/living/basic/clockwork_marauder/Destroy()
	GLOB.clockwork_marauders -= src
	return ..()

/mob/living/basic/clockwork_marauder/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user))
		. += span_brass("[src]'s shield is at [shield_health] / [MARAUDER_SHIELD_MAX] charges.")

		if(shield_health < MARAUDER_SHIELD_MAX)
			. += span_brass("It can be repaired with a <b>welding tool</b>.")

/mob/living/basic/clockwork_marauder/attacked_by(obj/item/attacking_item, mob/living/user)
	if(shield_health)
		damage_shield()

		playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 40, 1)

	if(attacking_item == TOOL_WELDER)
		welder_act(user, attacking_item)
		return

	return ..()


/mob/living/basic/clockwork_marauder/bullet_act(obj/projectile/proj)
	//Block Ranged Attacks
	if(shield_health)
		damage_shield()
		to_chat(src, span_warning("Your shield blocks the attack."))
		return BULLET_ACT_BLOCK
	return ..()


/// Damage the marauder's shield by one tick
/mob/living/basic/clockwork_marauder/proc/damage_shield()
	shield_health--
	playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 60, TRUE)
	if(!shield_health)
		to_chat(src, span_userdanger("Your shield breaks!"))
		to_chat(src, span_brass("You require a <b>welding tool</b> to repair your damaged shield!"))


/mob/living/basic/clockwork_marauder/welder_act(mob/living/user, obj/item/tool)
	if(!tool.use_tool(src, user, 2.5 SECONDS))
		return TRUE

	health = min(health + WELDER_REPAIR_AMOUNT, maxHealth)
	to_chat(user, span_notice("You repair some of [src]'s damage."))
	if(shield_health < MARAUDER_SHIELD_MAX)
		shield_health++
		playsound(src, 'sound/magic/charge.ogg', 60, TRUE)
	return TRUE


/datum/language_holder/clockmob
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/ratvar = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/ratvar = list(LANGUAGE_ATOM))



/datum/ai_controller/basic_controller/clockwork_marauder
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/clockwork_marauder,
	)


/datum/ai_planning_subtree/basic_melee_attack_subtree/clockwork_marauder
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/clockwork_marauder


/datum/ai_behavior/basic_melee_attack/clockwork_marauder
	action_cooldown = 1.2 SECONDS


/obj/item/nullrod/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bane, /mob/living/basic/clockwork_marauder, 1, 15, FALSE)

#undef MARAUDER_SHIELD_MAX
#undef WELDER_REPAIR_AMOUNT

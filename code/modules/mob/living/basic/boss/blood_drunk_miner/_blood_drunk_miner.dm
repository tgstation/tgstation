/*

BLOOD-DRUNK MINER

Effectively a highly aggressive miner, the blood-drunk miner has very few attacks but compensates by being highly aggressive in its AI as well as damage.

When the blood-drunk miner dies, it leaves behind the cleaving saw it was using and its kinetic accelerator.

Difficulty: Medium

*/
/mob/living/basic/boss/blood_drunk_miner
	name = "blood-drunk miner"
	desc = "A miner destined to wander forever, engaged in an endless hunt."
	health = 900
	maxHealth = 900
	icon_state = "miner"
	icon_living = "miner"
	icon = 'icons/mob/simple/broadMobs.dmi'
	health_doll_icon = "miner"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_SPECIAL|MOB_MINING
	light_color = COLOR_LIGHT_GRAYISH_RED
	speak_emote = list("roars")
	speed = 3
	pixel_x = -16
	base_pixel_x = -16
	basic_mob_flags = DEL_ON_DEATH
	default_blood_volume = BLOOD_VOLUME_NORMAL
	gps_name = "Resonant Signal"
	death_message = "falls to the ground, decaying into glowing particles."
	death_sound = SFX_BODYFALL
	move_force = MOVE_FORCE_NORMAL //Miner beeing able to just move structures like bolted doors and glass looks kinda strange

	ai_controller = /datum/ai_controller/blood_drunk_miner

	achievements = list(
		/datum/award/achievement/boss/blood_miner_kill,
		/datum/award/achievement/boss/boss_killer,
		/datum/award/score/blood_miner_score,
		/datum/award/score/boss_score,
	)
	crusher_achievement_type = /datum/award/achievement/boss/blood_miner_crusher
	victor_memory_type = /datum/memory/megafauna_slayer

	crusher_loot = list(/obj/item/crusher_trophy/miner_eye, /obj/item/knife/hunting/wildhunter)

	/// Loot dropped on death in normal circumstances
	var/list/regular_loot = list(/obj/item/melee/cleaving_saw, /obj/item/gun/energy/recharge/kinetic_accelerator)

	/// Their little saw
	var/obj/item/melee/cleaving_saw/miner/miner_saw
	/// How many hits of our saw we inflict on the target when we melee on them. Get mutated via the transform weapon ability.
	var/rapid_melee_hits = 5
	/// How long must we wait between ranged attacks
	var/ranged_attack_cooldown_duration = 1.6 SECONDS

/mob/living/basic/boss/blood_drunk_miner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_premove))
	AddElement(/datum/element/relay_attackers)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_HEAVY)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(attack_override))

	miner_saw = new(src)
	RegisterSignal(miner_saw, COMSIG_PREQDELETED, PROC_REF(on_saw_deleted))
	RegisterSignal(miner_saw, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_saw_premove))

	grant_actions_by_list(get_innate_actions())
	ai_controller.set_blackboard_key(BB_BDM_RANGED_ATTACK_COOLDOWN, ranged_attack_cooldown_duration)
	RegisterSignals(ai_controller, list(AI_CONTROLLER_BEHAVIOR_QUEUED(/datum/ai_behavior/basic_melee_attack), AI_CONTROLLER_BEHAVIOR_QUEUED(/datum/ai_behavior/targeted_mob_ability)), PROC_REF(handle_saw_transformation))

	AddElement(/datum/element/death_drops, string_list(regular_loot))
	RegisterSignal(src, COMSIG_LIVING_DROP_LOOT, PROC_REF(death_effect))

	AddComponent(/datum/component/boss_music, 'sound/music/boss/bdm_boss.ogg', COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_CURRENT_TARGET))

/// Block deletion of their saw under normal circumstances. It is fused to their hands as far as we're concerned.
/mob/living/basic/boss/blood_drunk_miner/proc/on_saw_deleted(datum/source, force)
	SIGNAL_HANDLER

	if(!force)
		return TRUE

/mob/living/basic/boss/blood_drunk_miner/Destroy(force)
	UnregisterSignal(miner_saw, list(COMSIG_PREQDELETED, COMSIG_MOVABLE_PRE_MOVE)) // unblock deletion, we are dead.
	QDEL_NULL(miner_saw)
	return ..()

/// Returns a list of innate actions for the blood-drunk miner.
/mob/living/basic/boss/blood_drunk_miner/proc/get_innate_actions()
	var/static/list/innate_abilities = list(
		/datum/action/cooldown/mob_cooldown/dash = BB_BDM_DASH_ABILITY,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = BB_BDM_KINETIC_ACCELERATOR_ABILITY,
		/datum/action/cooldown/mob_cooldown/dash_attack = BB_BDM_DASH_ATTACK_ABILITY,
		/datum/action/cooldown/mob_cooldown/transform_weapon = BB_BDM_TRANSFORM_WEAPON_ABILITY,
	)
	return innate_abilities

/// Invokes the transform weapon ability when signaled by the AI controller.
/mob/living/basic/boss/blood_drunk_miner/proc/handle_saw_transformation()
	SIGNAL_HANDLER

	INVOKE_ASYNC(ai_controller.blackboard[BB_BDM_TRANSFORM_WEAPON_ABILITY], TYPE_PROC_REF(/datum/action, Trigger), src, NONE)

/mob/living/basic/boss/blood_drunk_miner/ex_act(severity, target)
	var/datum/action/cooldown/mob_cooldown/dash_ability = ai_controller.blackboard[BB_BDM_DASH_ABILITY]
	if(dash_ability.Trigger(target = target))
		return FALSE
	return ..()

/mob/living/basic/boss/blood_drunk_miner/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(attacked_atom))
		used_item = miner_saw
	return ..()

/mob/living/basic/boss/blood_drunk_miner/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	var/adjustment_amount = amount * 0.1
	if(world.time + adjustment_amount > next_move)
		changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	return ..()

/// Handles spawning a death effect when the blood-drunk miner dies. Tied to COMSIG_LIVING_DROP_LOOT so the timings of spawning the effect should approximately work out with the loot appearing.
/mob/living/basic/boss/blood_drunk_miner/proc/death_effect(datum/source, list/spawn_loot, gibbed)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/dir_setting/miner_death(loc, dir)

/// Prevent running into a chasm and other undesirable movements.
/mob/living/basic/boss/blood_drunk_miner/proc/on_premove(datum/source, atom/new_location)
	if(isnull(new_location))
		return

	if(new_location.z != z)
		return

	var/turf/open/locus = get_turf(new_location)
	if(!ischasm(locus) || locus.can_cross_safely(src)) // if it's not a chasm we don't care to check the proc.
		return

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Prevent their saw from being moved at all
/mob/living/basic/boss/blood_drunk_miner/proc/on_saw_premove(datum/source, atom/new_location)
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Handles our attack behavior when we're doing melee attacks to override the default basic melee attack behavior when our AI calls upon us to use it.
/// Namely, we just use the miner saw to rapidly hit the target multiple times
/mob/living/basic/boss/blood_drunk_miner/proc/attack_override(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!istype(target, /mob/living))
		return

	var/mob/living/victim = target
	if(should_devour(target))
		devour(target)
		return COMPONENT_HOSTILE_NO_ATTACK

	changeNext_move(CLICK_CD_MELEE)
	victim.visible_message(
		span_danger("[src] slashes at [victim] with [p_their()] cleaving saw!"),
		span_userdanger("You are slashed at by [src]'s cleaving saw!"),
	)

	var/datum/callback/melee_callback = CALLBACK(miner_saw, TYPE_PROC_REF(/obj/item/melee/cleaving_saw/miner, melee_attack_chain), src, victim, modifiers)
	var/delay = 0.2 SECONDS
	for(var/i in 1 to rapid_melee_hits)
		addtimer(melee_callback, (i - 1) * delay)

	post_attack_effects(victim, modifiers)

	return COMPONENT_HOSTILE_NO_ATTACK

/// Hook for potential additional behaviors after attacking
/mob/living/basic/boss/blood_drunk_miner/proc/post_attack_effects(mob/living/victim, list/modifiers)
	return

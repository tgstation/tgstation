/*

BLOOD-DRUNK MINER

Effectively a highly aggressive miner, the blood-drunk miner has very few attacks but compensates by being highly aggressive.

The blood-drunk miner's attacks are as follows
- If not in KA range, it will rapidly dash at its target
- If in KA range, it will fire its kinetic accelerator
- If in melee range, will rapidly attack, akin to an actual player
- After any of these attacks, may transform its cleaving saw:
	Untransformed, it attacks very rapidly for smaller amounts of damage
	Transformed, it attacks at normal speed for higher damage and cleaves enemies hit

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
	move_to_delay = 3
	ranged = TRUE
	ranged_cooldown_time = 1.6 SECONDS
	rapid_melee = 5 // starts fast because the saw's closed. gets reduced appropriately when extended, see their transform_weapon ability
	pixel_x = -16
	base_pixel_x = -16
	crusher_loot = list(/obj/item/crusher_trophy/miner_eye, /obj/item/knife/hunting/wildhunter)
	basic_mob_flags = DEL_ON_DEATH
	default_blood_volume = BLOOD_VOLUME_NORMAL
	gps_name = "Resonant Signal"
	death_message = "falls to the ground, decaying into glowing particles."
	death_sound = SFX_BODYFALL
	move_force = MOVE_FORCE_NORMAL //Miner beeing able to just move structures like bolted doors and glass looks kinda strange

	ai_controller = /datum/ai_controller/blood_drunk_miner

	achievements = list(
		/datum/award/achievement/boss/boss_killer,
		/datum/award/achievement/boss/blood_miner_kill,
		/datum/award/achievement/boss/blood_miner_crusher,
		/datum/award/score/blood_miner_score,
	)
	crusher_achievement_type = /datum/award/achievement/boss/blood_miner_crusher
	victor_memory_type = /datum/memory/megafauna_slayer

	/// Does this blood-drunk miner heal slightly while attacking and heal more when gibbing people?
	var/guidance = FALSE
	/// Dash ability
	var/datum/action/cooldown/mob_cooldown/dash/dash
	/// Kinetic accelerator ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator/kinetic_accelerator
	/// Dash Attack Ability
	var/datum/action/cooldown/mob_cooldown/dash_attack/dash_attack
	/// Transform weapon ability
	var/datum/action/cooldown/mob_cooldown/transform_weapon/transform_weapon
	/// Their little saw
	var/obj/item/melee/cleaving_saw/miner/miner_saw

/mob/living/basic/boss/blood_drunk_miner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_premove))

	miner_saw = new(src)
	RegisterSignal(miner_saw, COMSIG_PREQDELETED, PROC_REF(on_saw_deleted))

	grant_actions_by_list(get_innate_actions())

	AddComponent(/datum/component/boss_music, 'sound/music/boss/bdm_boss.ogg')
	AddElement(/datum/element/death_drops, string_list(list(/obj/item/melee/cleaving_saw, /obj/item/gun/energy/recharge/kinetic_accelerator)))
	RegisterSignal(src, COMSIG_LIVING_DROP_LOOT, PROC_REF(death_effect))
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_HEAVY)

/// Block deletion of their saw under normal circumstances. It is fused to their hands as far as we're concerned.
/mob/living/basic/boss/blood_drunk_miner/proc/on_saw_deleted(datum/source, force)
	SIGNAL_HANDLER

	if(!force)
		return TRUE

/mob/living/basic/boss/blood_drunk_miner/Destroy(force)
	dash = null
	kinetic_accelerator = null
	dash_attack = null
	transform_weapon = null
	UnregisterSignal(miner_saw, COMSIG_PREQDELETED) // unblock deletion, we are dead.
	QDEL_NULL(miner_saw)
	return ..()

/mob/living/basic/boss/blood_drunk_miner/proc/get_innate_actions()
	var/static/list/innate_abilities = list(
		/datum/action/cooldown/mob_cooldown/dash = BB_BDM_DASH_ABILITY,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = BB_BDM_KINETIC_ACCELERATOR_ABILITY,
		/datum/action/cooldown/mob_cooldown/dash_attack = BB_BDM_DASH_ATTACK_ABILITY,
		/datum/action/cooldown/mob_cooldown/transform_weapon = BB_BDM_TRANSFORM_WEAPON_ABILITY,
	)
	return innate_abilities

/mob/living/basic/boss/blood_drunk_miner/OpenFire()
	if(client)
		return

	Goto(target, move_to_delay, minimum_distance)
	if(get_dist(src, target) > 4 && dash_attack.IsAvailable())
		dash_attack.Trigger(target = target)
	else
		kinetic_accelerator.Trigger(target = target)
	transform_weapon.Trigger(target = target)

/mob/living/basic/boss/blood_drunk_miner/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	var/adjustment_amount = amount * 0.1
	if(world.time + adjustment_amount > next_move)
		changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	. = ..()

/mob/living/basic/boss/blood_drunk_miner/ex_act(severity, target)
	if(dash.Trigger(target = target))
		return FALSE
	return ..()

/// Handles spawning a death effect when the blood-drunk miner dies. Tied to COMSIG_LIVING_DROP_LOOT so the timings of spawning the effect should approximately work out with the loot appearing.
/mob/living/basic/boss/blood_drunk_miner/proc/death_effect(datum/source, list/spawn_loot, gibbed)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/dir_setting/miner_death(loc, dir)

/// Prevent running into a chasm and other undesirable movements.
/mob/living/basic/boss/blood_drunk_miner/proc/on_premove(datum/source, atom/new_location)
	if(new_location && new_location.z == z && ischasm(new_location)) //we're not stupid!
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/mob/living/basic/boss/blood_drunk_miner/AttackingTarget(atom/attacked_target)
	if(QDELETED(target))
		return
	face_atom(target)
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			if(!is_station_level(z) || client) //NPC monsters won't heal while on station
				if(guidance)
					adjustHealth(-living_target.maxHealth)
				else
					adjustHealth(-(living_target.maxHealth * 0.5))
			devour(living_target)
			return TRUE
	changeNext_move(CLICK_CD_MELEE)
	miner_saw.melee_attack_chain(src, target)
	if(guidance)
		adjustHealth(-2)
	return TRUE

/mob/living/basic/boss/blood_drunk_miner/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(attacked_atom))
		used_item = miner_saw
	..()

/mob/living/basic/boss/blood_drunk_miner/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		wander = TRUE



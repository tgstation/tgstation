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

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner
	name = "blood-drunk miner"
	desc = "A miner destined to wander forever, engaged in an endless hunt."
	health = 900
	maxHealth = 900
	icon_state = "miner"
	icon_living = "miner"
	icon = 'icons/mob/simple/broadMobs.dmi'
	health_doll_icon = "miner"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	light_color = COLOR_LIGHT_GRAYISH_RED
	movement_type = GROUND
	speak_emote = list("roars")
	speed = 3
	move_to_delay = 3
	ranged = TRUE
	ranged_cooldown_time = 1.6 SECONDS
	rapid_melee = 5 // starts fast because the saw's closed. gets reduced appropriately when extended, see their transform_weapon ability
	pixel_x = -16
	base_pixel_x = -16
	crusher_loot = list(/obj/item/melee/cleaving_saw, /obj/item/gun/energy/recharge/kinetic_accelerator, /obj/item/crusher_trophy/miner_eye)
	loot = list(/obj/item/melee/cleaving_saw, /obj/item/gun/energy/recharge/kinetic_accelerator)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	gps_name = "Resonant Signal"
	achievement_type = /datum/award/achievement/boss/blood_miner_kill
	crusher_achievement_type = /datum/award/achievement/boss/blood_miner_crusher
	score_achievement_type = /datum/award/score/blood_miner_score
	var/obj/item/melee/cleaving_saw/miner/miner_saw
	death_message = "falls to the ground, decaying into glowing particles."
	death_sound = SFX_BODYFALL
	footstep_type = FOOTSTEP_MOB_HEAVY
	move_force = MOVE_FORCE_NORMAL //Miner beeing able to just move structures like bolted doors and glass looks kinda strange
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

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Initialize(mapload)
	. = ..()
	miner_saw = new(src)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	dash = new /datum/action/cooldown/mob_cooldown/dash()
	kinetic_accelerator = new /datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator()
	dash_attack = new /datum/action/cooldown/mob_cooldown/dash_attack()
	transform_weapon = new /datum/action/cooldown/mob_cooldown/transform_weapon()
	dash.Grant(src)
	kinetic_accelerator.Grant(src)
	dash_attack.Grant(src)
	transform_weapon.Grant(src)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Destroy()
	QDEL_NULL(dash)
	QDEL_NULL(kinetic_accelerator)
	QDEL_NULL(dash_attack)
	QDEL_NULL(transform_weapon)
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/OpenFire()
	if(client)
		return

	Goto(target, move_to_delay, minimum_distance)
	if(get_dist(src, target) > 4 && dash_attack.IsAvailable())
		dash_attack.Trigger(target = target)
	else
		kinetic_accelerator.Trigger(target = target)
	transform_weapon.Trigger(target = target)

/obj/item/melee/cleaving_saw/miner //nerfed saw because it is very murdery
	force = 6
	open_force = 10

/obj/item/melee/cleaving_saw/miner/attack(mob/living/target, mob/living/carbon/human/user)
	target.add_stun_absorption(source = "miner", duration = 1 SECONDS, priority = INFINITY)
	return ..()

/obj/projectile/kinetic/miner
	damage = 20
	speed = 0.9
	icon_state = "ka_tracer"
	range = 4

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	var/adjustment_amount = amount * 0.1
	if(world.time + adjustment_amount > next_move)
		changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	. = ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/death()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/dir_setting/miner_death(loc, dir)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Move(atom/newloc)
	if(newloc && newloc.z == z && (islava(newloc) || ischasm(newloc))) //we're not stupid!
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/ex_act(severity, target)
	if(dash.Trigger(target = target))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/AttackingTarget()
	if(QDELETED(target))
		return
	face_atom(target)
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			visible_message(span_danger("[src] butchers [living_target]!"),
			span_userdanger("You butcher [living_target], restoring your health!"))
			if(!is_station_level(z) || client) //NPC monsters won't heal while on station
				if(guidance)
					adjustHealth(-living_target.maxHealth)
				else
					adjustHealth(-(living_target.maxHealth * 0.5))
			living_target.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			living_target.gib()
			return TRUE
	changeNext_move(CLICK_CD_MELEE)
	miner_saw.melee_attack_chain(src, target)
	if(guidance)
		adjustHealth(-2)
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(attacked_atom))
		used_item = miner_saw
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		wander = TRUE

/obj/effect/temp_visual/dir_setting/miner_death
	icon_state = "miner_death"
	duration = 15

/obj/effect/temp_visual/dir_setting/miner_death/Initialize(mapload, set_dir)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fade_out))

/obj/effect/temp_visual/dir_setting/miner_death/proc/fade_out()
	var/matrix/our_matrix = new
	our_matrix.Turn(pick(90, 270))
	var/final_dir = dir
	if(dir & (EAST|WEST)) //Facing east or west
		final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	animate(src, transform = our_matrix, pixel_y = -6, dir = final_dir, time = 2, easing = EASE_IN|EASE_OUT)
	sleep(0.5 SECONDS)
	animate(src, color = list("#A7A19E", "#A7A19E", "#A7A19E", list(0, 0, 0)), time = 10, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(0.4 SECONDS)
	animate(src, alpha = 0, time = 6, easing = EASE_OUT, flags = ANIMATION_PARALLEL)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance
	guidance = TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter/AttackingTarget()
	. = ..()
	if(. && prob(12))
		INVOKE_ASYNC(dash, TYPE_PROC_REF(/datum/action, Trigger), target)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/doom
	name = "hostile-environment miner"
	desc = "A miner destined to hop across dimensions for all eternity, hunting anomalous creatures."
	speed = 8
	move_to_delay = 8
	ranged_cooldown_time = 0.8 SECONDS

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/doom/Initialize(mapload)
	. = ..()
	dash.cooldown_time = 0.8 SECONDS

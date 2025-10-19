#define BUBBLEGUM_SMASH (health <= maxHealth*0.5) // angery
#define BUBBLEGUM_CAN_ENRAGE (enrage_till + (enrage_time * 2) <= world.time)
#define BUBBLEGUM_IS_ENRAGED (enrage_till > world.time)

/*

BUBBLEGUM

Bubblegum spawns randomly wherever a lavaland creature is able to spawn. It is the most powerful slaughter demon in existence.
Bubblegum's footsteps are heralded by shaking booms, proving its tremendous size.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power

It leaves blood trails behind wherever it goes, its clones do as well.
It tries to strike at its target through any bloodpools under them; if it fails to do that.
If it does warp it will enter an enraged state, becoming immune to all projectiles, becoming much faster, and dealing damage and knockback to anything that gets in the cloud around it.
It may summon clones charging from all sides, one of these charges being bubblegum himself.
It can charge at its target, and also heavily damaging anything directly hit in the charge.
If at half health it will start to charge from all sides with clones.

When Bubblegum dies, it leaves behind a H.E.C.K. mining suit as well as a chest that can contain three things:
A. A bottle that, when activated, drives everyone nearby into a frenzy
B. A contract that marks for death the chosen target
C. A spellblade that can slice off limbs at range

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/bubblegum
	name = "bubblegum"
	desc = "In what passes for a hierarchy among slaughter demons, this one is king."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "rends"
	attack_verb_simple = "rend"
	attack_sound = 'sound/effects/magic/demon_attack1.ogg'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = ""
	health_doll_icon = "bubblegum"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	speak_emote = list("gurgles")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	move_to_delay = 5
	retreat_distance = 5
	minimum_distance = 5
	rapid_melee = 8 // every 1/4 second
	melee_queue_distance = 20 // as far as possible really, need this because of blood warp
	ranged = TRUE
	pixel_x = -32
	base_pixel_x = -32
	maptext_height = 96
	maptext_width = 96
	del_on_death = TRUE
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	crusher_loot = /obj/structure/closet/crate/necropolis/bubblegum/crusher
	replace_crusher_drop = TRUE
	blood_volume = BLOOD_VOLUME_MAXIMUM //BLEED FOR ME
	gps_name = "Bloody Signal"
	achievement_type = /datum/award/achievement/boss/bubblegum_kill
	crusher_achievement_type = /datum/award/achievement/boss/bubblegum_crusher
	score_achievement_type = /datum/award/score/bubblegum_score
	death_message = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	death_sound = 'sound/effects/magic/enter_blood.ogg'
	faction = list(FACTION_MINING, FACTION_BOSS, FACTION_HELL)
	summon_line = "GRAAAAAAAHHHHHHHHH!"
	/// Check to see if we should spawn blood
	var/spawn_blood = TRUE
	/// Actual time where enrage ends
	var/enrage_till = 0
	/// Duration of enrage ability
	var/enrage_time = 7 SECONDS
	/// Triple charge ability
	var/datum/action/cooldown/mob_cooldown/charge/triple_charge/triple_charge
	/// Hallucination charge ability
	var/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/hallucination_charge
	/// Hallucination charge surround ability
	var/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/hallucination_surround/hallucination_charge_surround
	/// Blood warp ability
	var/datum/action/cooldown/mob_cooldown/blood_warp/blood_warp

/mob/living/simple_animal/hostile/megafauna/bubblegum/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	triple_charge = new(src)
	hallucination_charge = new(src)
	hallucination_charge_surround = new(src)
	blood_warp = new(src)
	triple_charge.Grant(src)
	hallucination_charge.Grant(src)
	hallucination_charge_surround.Grant(src)
	blood_warp.Grant(src)
	hallucination_charge.spawn_blood = TRUE
	hallucination_charge_surround.spawn_blood = TRUE
	RegisterSignal(src, COMSIG_BLOOD_WARP, PROC_REF(blood_enrage))
	RegisterSignal(src, COMSIG_FINISHED_CHARGE, PROC_REF(after_charge))
	if(spawn_blood)
		AddComponent(/datum/component/blood_walk, \
			blood_type = /obj/effect/decal/cleanable/blood/bubblegum, \
			sound_played = 'sound/effects/meteorimpact.ogg', \
			sound_volume = 200)

/mob/living/simple_animal/hostile/megafauna/bubblegum/Destroy()
	triple_charge = null
	hallucination_charge = null
	hallucination_charge_surround = null
	blood_warp = null
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/update_cooldowns(list/cooldown_updates, ignore_staggered = FALSE)
	. = ..()
	if(cooldown_updates[COOLDOWN_UPDATE_SET_ENRAGE])
		enrage_till = world.time + cooldown_updates[COOLDOWN_UPDATE_SET_ENRAGE]
	if(cooldown_updates[COOLDOWN_UPDATE_ADD_ENRAGE])
		enrage_till += cooldown_updates[COOLDOWN_UPDATE_ADD_ENRAGE]

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	if(client)
		return

	if(!try_bloodattack() || prob(25 + anger_modifier))
		blood_warp.Trigger(target = target)

	if(!BUBBLEGUM_SMASH)
		triple_charge.Trigger(target = target)
	else if(prob(50 + anger_modifier))
		hallucination_charge.Trigger(target = target)
	else
		hallucination_charge_surround.Trigger(target = target)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_mobs_on_blood()
	var/list/targets = ListTargets()
	. = list()
	for(var/mob/living/L in targets)
		var/list/bloodpool = get_bloodcrawlable_pools(get_turf(L), 0)
		if(bloodpool.len && (!faction_check_atom(L) || L.stat == DEAD))
			. += L

/**
 * Attack by override for bubblegum
 *
 * This is used to award the frenching achievement for hitting bubblegum with a tongue
 *
 * Arguments:
 * * obj/item/W the item hitting bubblegum
 * * mob/user The user of the item
 * * params, extra parameters
 */
/mob/living/simple_animal/hostile/megafauna/bubblegum/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(istype(W, /obj/item/organ/tongue))
		user.client?.give_award(/datum/award/achievement/jobs/frenching, user)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/try_bloodattack()
	var/list/targets = get_mobs_on_blood()
	if(targets.len)
		INVOKE_ASYNC(src, PROC_REF(bloodattack), targets, prob(50))
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodattack(list/targets, handedness)
	var/mob/living/target_one = pick_n_take(targets)
	var/turf/target_one_turf = get_turf(target_one)
	var/mob/living/target_two
	if(targets.len)
		target_two = pick_n_take(targets)
		var/turf/target_two_turf = get_turf(target_two)
		if(target_two.stat != CONSCIOUS || prob(10))
			bloodgrab(target_two_turf, handedness)
		else
			bloodsmack(target_two_turf, handedness)

	if(target_one)
		var/list/pools = get_bloodcrawlable_pools(get_turf(target_one), 0)
		if(pools.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, !handedness)
				else
					bloodsmack(target_one_turf, !handedness)

	if(!target_two && target_one)
		var/list/poolstwo = get_bloodcrawlable_pools(get_turf(target_one), 0)
		if(poolstwo.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, handedness)
				else
					bloodsmack(target_one_turf, handedness)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodsmack(turf/T, handedness)
	if(handedness)
		new /obj/effect/temp_visual/bubblegum_hands/rightsmack(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftsmack(T)
	SLEEP_CHECK_DEATH(4, src)
	for(var/mob/living/L in T)
		if(!faction_check_atom(L))
			to_chat(L, span_userdanger("[src] rends you!"))
			playsound(T, attack_sound, 100, TRUE, -1)
			var/limb_to_hit = L.get_bodypart(L.get_random_valid_zone(even_weights = TRUE))
			L.apply_damage(10, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration), wound_bonus = CANT_WOUND)
	SLEEP_CHECK_DEATH(3, src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodgrab(turf/T, handedness)
	if(handedness)
		new /obj/effect/temp_visual/bubblegum_hands/rightpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/rightthumb(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
	SLEEP_CHECK_DEATH(6, src)
	for(var/mob/living/L in T)
		if(!faction_check_atom(L))
			if(L.stat != CONSCIOUS)
				to_chat(L, span_userdanger("[src] drags you through the blood!"))
				playsound(T, 'sound/effects/magic/enter_blood.ogg', 100, TRUE, -1)
				var/turf/targetturf = get_step(src, dir)
				L.forceMove(targetturf)
				playsound(targetturf, 'sound/effects/magic/exit_blood.ogg', 100, TRUE, -1)
				addtimer(CALLBACK(src, PROC_REF(devour), L), 0.2 SECONDS)
	SLEEP_CHECK_DEATH(1, src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/devour(mob/living/yummy_food)
	. = ..()
	if(. == TRUE) // a corpse was devoured
		// bubblegum bubblegum in a dish, how many corpses do you wish?
		new /obj/item/food/bubblegum/bubblegum(loc)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/be_aggressive()
	if(BUBBLEGUM_IS_ENRAGED)
		return TRUE
	return isliving(target) && HAS_TRAIT(target, TRAIT_INCAPACITATED)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_retreat_distance()
	return (be_aggressive() ? null : initial(retreat_distance))

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_minimum_distance()
	return (be_aggressive() ? 1 : initial(minimum_distance))

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/update_approach()
	retreat_distance = get_retreat_distance()
	minimum_distance = get_minimum_distance()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_enrage()
	SIGNAL_HANDLER
	if(!BUBBLEGUM_CAN_ENRAGE)
		return FALSE
	enrage_till = world.time + enrage_time
	update_approach()
	INVOKE_ASYNC(src, PROC_REF(change_move_delay), 3.75)
	add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
	var/datum/callback/cb = CALLBACK(src, PROC_REF(blood_enrage_end))
	addtimer(cb, enrage_time)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/after_charge()
	SIGNAL_HANDLER
	try_bloodattack()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_enrage_end()
	update_approach()
	change_move_delay()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/change_move_delay(newmove = initial(move_to_delay))
	move_to_delay = newmove
	set_varspeed(move_to_delay)
	handle_automated_action() // need to recheck movement otherwise move_to_delay won't update until the next checking aka will be wrong speed for a bit

/mob/living/simple_animal/hostile/megafauna/bubblegum/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = ..()
	anger_modifier = clamp(((maxHealth - health)/60),0,20)
	enrage_time = initial(enrage_time) * clamp(anger_modifier / 20, 0.5, 1)
	if(hallucination_charge)
		hallucination_charge.enraged = BUBBLEGUM_SMASH
	if(. > 0 && prob(25))
		var/obj/effect/decal/cleanable/blood/gibs/bubblegum/B = new /obj/effect/decal/cleanable/blood/gibs/bubblegum(loc)
		if(prob(40))
			step(B, pick(GLOB.cardinals))
		else
			B.setDir(pick(GLOB.cardinals))

/mob/living/simple_animal/hostile/megafauna/bubblegum/death(gibbed)
	. = ..()
	if(!gibbed && health > 0 && true_spawn && !(flags_1 & ADMIN_SPAWNED_1))
		SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_BUBBLEGUM] = TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget(atom/attacked_target)
	. = ..()
	if(.)
		recovery_time = world.time + 20 // can only attack melee once every 2 seconds but rapid_melee gives higher priority

/mob/living/simple_animal/hostile/megafauna/bubblegum/projectile_hit(obj/projectile/hitting_projectile, def_zone, piercing_hit, blocked)
	if(BUBBLEGUM_IS_ENRAGED)
		visible_message(span_danger("[src] deflects the [hitting_projectile]! [p_They()] can't be hit with ranged weapons while enraged!"), span_userdanger("You deflect the projectile!"))
		playsound(src, SFX_BULLET_MISS, 300, TRUE)
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE

	severity = EXPLODE_LIGHT // puny mortals
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Move()
	update_approach()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination
	name = "bubblegum's hallucination"
	desc = "Is that really just a hallucination?"
	health = 1
	maxHealth = 1
	alpha = 127.5
	crusher_loot = null
	loot = null
	achievement_type = null
	crusher_achievement_type = null
	score_achievement_type = null
	death_message = "Explodes into a pool of blood!"
	death_sound = 'sound/effects/splat.ogg'
	true_spawn = FALSE
	var/move_through_mob

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Initialize(mapload)
	. = ..()
	toggle_ai(AI_OFF)

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Destroy()
	if(spawn_blood)
		new /obj/effect/decal/cleanable/blood(get_turf(src))
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/OpenFire()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/AttackingTarget(atom/attacked_target)
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/try_bloodattack()
	return

/obj/effect/decal/cleanable/blood/bubblegum
	bloodiness = 0

/obj/effect/decal/cleanable/blood/bubblegum/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/gibs/bubblegum
	name = "thick blood"
	desc = "Thick, splattered blood."
	random_icon_states = list("gib3", "gib5", "gib6")
	bloodiness = 20

/obj/effect/decal/cleanable/blood/gibs/bubblegum/can_bloodcrawl_in()
	return TRUE

/obj/effect/temp_visual/dragon_swoop/bubblegum
	duration = 10

/obj/effect/temp_visual/bubblegum_hands
	icon = 'icons/effects/bubblegum.dmi'
	duration = 9

/obj/effect/temp_visual/bubblegum_hands/rightthumb
	icon_state = "rightthumbgrab"

/obj/effect/temp_visual/bubblegum_hands/leftthumb
	icon_state = "leftthumbgrab"

/obj/effect/temp_visual/bubblegum_hands/rightpaw
	icon_state = "rightpawgrab"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/temp_visual/bubblegum_hands/leftpaw
	icon_state = "leftpawgrab"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/temp_visual/bubblegum_hands/rightsmack
	icon_state = "rightsmack"

/obj/effect/temp_visual/bubblegum_hands/leftsmack
	icon_state = "leftsmack"

#undef BUBBLEGUM_CAN_ENRAGE
#undef BUBBLEGUM_IS_ENRAGED
#undef BUBBLEGUM_SMASH

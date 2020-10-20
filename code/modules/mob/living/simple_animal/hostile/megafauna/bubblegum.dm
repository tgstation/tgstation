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
 1. A bottle that, when activated, drives everyone nearby into a frenzy
 2. A contract that marks for death the chosen target
 3. A spellblade that can slice off limbs at range

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/bubblegum
	name = "bubblegum"
	desc = "In what passes for a hierarchy among slaughter demons, this one is king."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "rends"
	attack_verb_simple = "rend"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = ""
	health_doll_icon = "bubblegum"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
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
	del_on_death = TRUE
	crusher_loot = list(/obj/structure/closet/crate/necropolis/bubblegum/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	blood_volume = BLOOD_VOLUME_MAXIMUM //BLEED FOR ME
	gps_name = "Bloody Signal"
	achievement_type = /datum/award/achievement/boss/bubblegum_kill
	crusher_achievement_type = /datum/award/achievement/boss/bubblegum_crusher
	score_achievement_type = /datum/award/score/bubblegum_score
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	deathsound = 'sound/magic/enter_blood.ogg'
	small_sprite_type = /datum/action/small_sprite/megafauna/bubblegum
	faction = list("mining", "boss", "hell")
	var/enrage_till = 0
	var/enrage_time = 70

/mob/living/simple_animal/hostile/megafauna/bubblegum/Initialize()
	. = ..()
	new /datum/action/cooldown/charge/triple_charge().Grant(src)
	new /datum/action/cooldown/charge/hallucination_charge().Grant(src)
	new /datum/action/cooldown/charge/hallucination_charge/hallucination_surround().Grant(src)
	new /datum/action/cooldown/blood_warp().Grant(src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	if(client)
		return

	if(!try_bloodattack() || prob(25 + anger_modifier))
		blood_warp()

	if(!BUBBLEGUM_SMASH)
		var/datum/action/cooldown/TC = locate(/datum/action/cooldown/charge/triple_charge) in actions
		TC.Trigger(target)
		try_bloodattack()
	else
		if(prob(50 + anger_modifier))
			var/datum/action/cooldown/HC = locate(/datum/action/cooldown/charge/hallucination_charge) in actions
			HC.Trigger(target)
		else
			var/datum/action/cooldown/HCS = locate(/datum/action/cooldown/charge/hallucination_charge/hallucination_surround) in actions
			HCS.Trigger(target)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/try_bloodattack()
	var/list/targets = list()//get_mobs_on_blood()
	if(targets.len)
		INVOKE_ASYNC(src, .proc/bloodattack, targets, prob(50))
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
		var/list/pools = list()//get_pools(get_turf(target_one), 0)
		if(pools.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, !handedness)
				else
					bloodsmack(target_one_turf, !handedness)

	if(!target_two && target_one)
		var/list/poolstwo = list()//get_pools(get_turf(target_one), 0)
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
		if(!faction_check_mob(L))
			to_chat(L, "<span class='userdanger'>[src] rends you!</span>")
			playsound(T, attack_sound, 100, TRUE, -1)
			var/limb_to_hit = L.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
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
		if(!faction_check_mob(L))
			if(L.stat != CONSCIOUS)
				to_chat(L, "<span class='userdanger'>[src] drags you through the blood!</span>")
				playsound(T, 'sound/magic/enter_blood.ogg', 100, TRUE, -1)
				var/turf/targetturf = get_step(src, dir)
				L.forceMove(targetturf)
				playsound(targetturf, 'sound/magic/exit_blood.ogg', 100, TRUE, -1)
				addtimer(CALLBACK(src, .proc/devour, L), 2)
	SLEEP_CHECK_DEATH(1, src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_warp()
	if(Adjacent(target))
		return FALSE
	var/list/can_jaunt = list()//get_pools(get_turf(src), 1)
	if(!can_jaunt.len)
		return FALSE

	var/list/pools = list()//get_pools(get_turf(target), 5)
	var/list/pools_to_remove = list()//get_pools(get_turf(target), 4)
	pools -= pools_to_remove
	if(!pools.len)
		return FALSE

	var/obj/effect/temp_visual/decoy/DA = new /obj/effect/temp_visual/decoy(loc,src)
	DA.color = "#FF0000"
	var/oldtransform = DA.transform
	DA.transform = matrix()*2
	animate(DA, alpha = 255, color = initial(DA.color), transform = oldtransform, time = 3)
	SLEEP_CHECK_DEATH(3, src)
	qdel(DA)

	var/obj/effect/decal/cleanable/blood/found_bloodpool
	pools = list()//get_pools(get_turf(target), 5)
	pools_to_remove = list()//get_pools(get_turf(target), 4)
	pools -= pools_to_remove
	if(pools.len)
		shuffle_inplace(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		visible_message("<span class='danger'>[src] sinks into the blood...</span>")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, TRUE, -1)
		forceMove(get_turf(found_bloodpool))
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, TRUE, -1)
		visible_message("<span class='danger'>And springs back out!</span>")
		blood_enrage()
		return TRUE
	return FALSE

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
/mob/living/simple_animal/hostile/megafauna/bubblegum/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/organ/tongue))
		user.client?.give_award(/datum/award/achievement/misc/frenching, user)

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
	if(!BUBBLEGUM_CAN_ENRAGE)
		return FALSE
	enrage_till = world.time + enrage_time
	update_approach()
	change_move_delay(3.75)
	var/newcolor = rgb(149, 10, 10)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	var/datum/callback/cb = CALLBACK(src, .proc/blood_enrage_end)
	addtimer(cb, enrage_time)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_enrage_end(newcolor = rgb(149, 10, 10))
	update_approach()
	change_move_delay()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, newcolor)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/change_move_delay(newmove = initial(move_to_delay))
	move_to_delay = newmove
	set_varspeed(move_to_delay)
	handle_automated_action() // need to recheck movement otherwise move_to_delay won't update until the next checking aka will be wrong speed for a bit

/obj/effect/decal/cleanable/blood/bubblegum
	bloodiness = 0

/obj/effect/decal/cleanable/blood/bubblegum/can_bloodcrawl_in()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	anger_modifier = clamp(((maxHealth - health)/60),0,20)
	enrage_time = initial(enrage_time) * clamp(anger_modifier / 20, 0.5, 1)
	var/datum/action/cooldown/charge/hallucination_charge/HC = locate(/datum/action/cooldown/charge/hallucination_charge) in actions
	HC.enraged = BUBBLEGUM_SMASH
	if(. > 0 && prob(25))
		var/obj/effect/decal/cleanable/blood/gibs/bubblegum/B = new /obj/effect/decal/cleanable/blood/gibs/bubblegum(loc)
		if(prob(40))
			step(B, pick(GLOB.cardinals))
		else
			B.setDir(pick(GLOB.cardinals))

/obj/effect/decal/cleanable/blood/gibs/bubblegum
	name = "thick blood"
	desc = "Thick, splattered blood."
	random_icon_states = list("gib3", "gib5", "gib6")
	bloodiness = 20

/obj/effect/decal/cleanable/blood/gibs/bubblegum/can_bloodcrawl_in()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/grant_achievement(medaltype,scoretype)
	. = ..()
	if(.)
		SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_BUBBLEGUM] = TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget()
	. = ..()
	if(.)
		recovery_time = world.time + 20 // can only attack melee once every 2 seconds but rapid_melee gives higher priority

/mob/living/simple_animal/hostile/megafauna/bubblegum/bullet_act(obj/projectile/P)
	if(BUBBLEGUM_IS_ENRAGED)
		visible_message("<span class='danger'>[src] deflects the projectile; [p_they()] can't be hit with ranged weapons while enraged!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 300, TRUE)
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/ex_act(severity, target)
	if(severity >= EXPLODE_LIGHT)
		return
	severity = EXPLODE_LIGHT // puny mortals
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination))
		return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/Move()
	update_approach()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	new /obj/effect/decal/cleanable/blood/bubblegum(src.loc)
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)

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

/obj/effect/temp_visual/bubblegum_hands/leftpaw
	icon_state = "leftpawgrab"
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/bubblegum_hands/rightsmack
	icon_state = "rightsmack"

/obj/effect/temp_visual/bubblegum_hands/leftsmack
	icon_state = "leftsmack"

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
	deathmessage = "Explodes into a pool of blood!"
	deathsound = 'sound/effects/splat.ogg'
	true_spawn = FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Initialize()
	..()
	toggle_ai(AI_OFF)

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Destroy()
	new /obj/effect/decal/cleanable/blood(get_turf(src))
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /mob/living/simple_animal/hostile/megafauna/bubblegum)) // hallucinations should not be stopping bubblegum or eachother
		return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/Life()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/OpenFire()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/AttackingTarget()
	return

/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/try_bloodattack()
	return

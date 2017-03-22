#define MEDAL_PREFIX "Bubblegum"

/*

BUBBLEGUM

Bubblegum spawns randomly wherever a lavaland creature is able to spawn. It is the most powerful slaughter demon in existence.
Bubblegum's footsteps are heralded by shaking booms, proving its tremendous size.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

It tries to strike at its target through any bloodpools under them; if it fails to do that, it will spray blood and then attempt to warp to a bloodpool near the target.
If it fails to warp to a target, it may summon up to 6 slaughterlings from the blood around it.
If it does not summon all 6 slaughterlings, it will instead charge at its target, dealing massive damage to anything it hits and spraying a stream of blood.
At half health, it will either charge three times or warp, then charge, instead of doing a single charge.

When Bubblegum dies, it leaves behind a chest that can contain three things:
 1. A bottle that, when activated, drives everyone nearby into a frenzy
 2. A contract that marks for death the chosen target
 3. A spellblade that can slice off limbs at range

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/bubblegum
	name = "bubblegum"
	desc = "In what passes for a heirarchy among slaughter demons, this one is king."
	health = 2500
	maxHealth = 2500
	attacktext = "rends"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	speak_emote = list("gurgles")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -32
	del_on_death = 1
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	blood_volume = BLOOD_VOLUME_MAXIMUM //BLEED FOR ME
	var/charging = FALSE
	medal_type = MEDAL_PREFIX
	score_type = BUBBLEGUM_SCORE
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	death_sound = 'sound/magic/enter_blood.ogg'

/obj/item/device/gps/internal/bubblegum
	icon_state = null
	gpstag = "Bloody Signal"
	desc = "You're not quite sure how a signal can be bloody."
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/bubblegum/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && prob(25))
		var/obj/effect/decal/cleanable/blood/gibs/bubblegum/B = new /obj/effect/decal/cleanable/blood/gibs/bubblegum(loc)
		if(prob(40))
			step(B, pick(cardinal))
		else
			B.setDir(pick(cardinal))

/obj/effect/decal/cleanable/blood/gibs/bubblegum
	name = "thick blood"
	desc = "Thick, splattered blood."
	random_icon_states = list("gib3", "gib5", "gib6")
	bloodiness = 20

/obj/effect/decal/cleanable/blood/gibs/bubblegum/can_bloodcrawl_in()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/Life()
	..()
	move_to_delay = Clamp((health/maxHealth) * 10, 5, 10)

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/60),0,20)
	if(charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time

	var/warped = FALSE
	if(!try_bloodattack())
		INVOKE_ASYNC(src, .proc/blood_spray)
		warped = blood_warp()
		if(warped && prob(100 - anger_modifier))
			return

	if(prob(90 - anger_modifier) || slaughterlings())
		if(health > maxHealth * 0.5)
			INVOKE_ASYNC(src, .proc/charge)
		else
			if(prob(70) || warped)
				INVOKE_ASYNC(src, .proc/charge, 2)
			else
				INVOKE_ASYNC(src, .proc/warp_charge)


/mob/living/simple_animal/hostile/megafauna/bubblegum/Initialize()
	..()
	for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in mob_list)
		if(B != src)
			qdel(src) //There can be only one
			break
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = 1
	internal = new/obj/item/device/gps/internal/bubblegum(src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/grant_achievement(medaltype,scoretype)
	. = ..()
	if(.)
		SSshuttle.shuttle_purchase_requirements_met |= "bubblegum"

/mob/living/simple_animal/hostile/megafauna/bubblegum/do_attack_animation(atom/A, visual_effect_icon)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Goto(target, delay, minimum_distance)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Move()
	if(charging)
		new /obj/effect/overlay/temp/decoy/fading(loc,src)
		DestroySurroundings()
	. = ..()
	if(!stat && .)
		playsound(src, 'sound/effects/meteorimpact.ogg', 200, 1, 2, 1)
	if(charging)
		DestroySurroundings()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/warp_charge()
	blood_warp()
	charge()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge(bonus_charges)
	var/turf/T = get_turf(target)
	if(!T || T == loc)
		return
	new /obj/effect/overlay/temp/dragon_swoop(T)
	charging = TRUE
	DestroySurroundings()
	walk(src, 0)
	setDir(get_dir(src, T))
	var/obj/effect/overlay/temp/decoy/D = new /obj/effect/overlay/temp/decoy(loc,src)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)
	sleep(3)
	throw_at(T, get_dist(src, T), 1, src, 0, callback = CALLBACK(src, .charge_end, bonus_charges))

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge_end(bonus_charges, list/effects_to_destroy)
	charging = FALSE
	try_bloodattack()
	if(target)
		if(bonus_charges)
			bonus_charges--
			charge(bonus_charges)
		else
			Goto(target, move_to_delay, minimum_distance)


/mob/living/simple_animal/hostile/megafauna/bubblegum/Bump(atom/A)
	if(charging)
		if(isturf(A) || isobj(A) && A.density)
			A.ex_act(2)
		DestroySurroundings()
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/throw_impact(atom/A)
	if(!charging)
		return ..()

	else if(isliving(A))
		var/mob/living/L = A
		L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
		L.apply_damage(40, BRUTE)
		playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
		shake_camera(L, 4, 3)
		shake_camera(src, 2, 3)
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		L.throw_at(throwtarget, 3)

	charging = FALSE


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_mobs_on_blood()
	var/list/targets = ListTargets()
	. = list()
	for(var/mob/living/L in targets)
		var/list/bloodpool = get_pools(get_turf(L), 0)
		if(bloodpool.len && (!faction_check_mob(L) || L.stat == DEAD))
			. += L

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/try_bloodattack()
	var/list/targets = get_mobs_on_blood()
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
		var/list/pools = get_pools(get_turf(target_one), 0)
		if(pools.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, !handedness)
				else
					bloodsmack(target_one_turf, !handedness)

	if(!target_two && target_one)
		var/list/poolstwo = get_pools(get_turf(target_one), 0)
		if(poolstwo.len)
			target_one_turf = get_turf(target_one)
			if(target_one_turf)
				if(target_one.stat != CONSCIOUS || prob(10))
					bloodgrab(target_one_turf, handedness)
				else
					bloodsmack(target_one_turf, handedness)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodsmack(turf/T, handedness)
	if(handedness)
		new /obj/effect/overlay/temp/bubblegum_hands/rightsmack(T)
	else
		new /obj/effect/overlay/temp/bubblegum_hands/leftsmack(T)
	sleep(2.5)
	for(var/mob/living/L in T)
		if(!faction_check_mob(L))
			to_chat(L, "<span class='userdanger'>[src] rends you!</span>")
			playsound(T, attack_sound, 100, 1, -1)
			var/limb_to_hit = L.get_bodypart(pick("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg"))
			L.apply_damage(25, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, "melee", null, null, armour_penetration))
	sleep(3)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodgrab(turf/T, handedness)
	if(handedness)
		new /obj/effect/overlay/temp/bubblegum_hands/rightpaw(T)
		new /obj/effect/overlay/temp/bubblegum_hands/rightthumb(T)
	else
		new /obj/effect/overlay/temp/bubblegum_hands/leftpaw(T)
		new /obj/effect/overlay/temp/bubblegum_hands/leftthumb(T)
	sleep(6)
	for(var/mob/living/L in T)
		if(!faction_check_mob(L))
			to_chat(L, "<span class='userdanger'>[src] drags you through the blood!</span>")
			playsound(T, 'sound/magic/enter_blood.ogg', 100, 1, -1)
			var/turf/targetturf = get_step(src, dir)
			L.forceMove(targetturf)
			playsound(targetturf, 'sound/magic/exit_blood.ogg', 100, 1, -1)
			if(L.stat != CONSCIOUS)
				addtimer(CALLBACK(src, .proc/devour, L), 2)
	sleep(1)

/obj/effect/overlay/temp/bubblegum_hands
	icon = 'icons/effects/bubblegum.dmi'
	duration = 9

/obj/effect/overlay/temp/bubblegum_hands/rightthumb
	icon_state = "rightthumbgrab"

/obj/effect/overlay/temp/bubblegum_hands/leftthumb
	icon_state = "leftthumbgrab"

/obj/effect/overlay/temp/bubblegum_hands/rightpaw
	icon_state = "rightpawgrab"
	layer = BELOW_MOB_LAYER

/obj/effect/overlay/temp/bubblegum_hands/leftpaw
	icon_state = "leftpawgrab"
	layer = BELOW_MOB_LAYER

/obj/effect/overlay/temp/bubblegum_hands/rightsmack
	icon_state = "rightsmack"

/obj/effect/overlay/temp/bubblegum_hands/leftsmack
	icon_state = "leftsmack"

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_warp()
	if(Adjacent(target))
		return FALSE
	var/list/can_jaunt = get_pools(get_turf(src), 1)
	if(!can_jaunt.len)
		return FALSE

	var/list/pools = get_pools(get_turf(target), 2)
	var/list/pools_to_remove = get_pools(get_turf(target), 1)
	pools -= pools_to_remove
	if(!pools.len)
		return FALSE

	var/obj/effect/overlay/temp/decoy/DA = new /obj/effect/overlay/temp/decoy(loc,src)
	DA.color = "#FF0000"
	var/oldtransform = DA.transform
	DA.transform = matrix()*2
	animate(DA, alpha = 255, color = initial(DA.color), transform = oldtransform, time = 3)
	sleep(3)
	qdel(DA)

	var/obj/effect/decal/cleanable/blood/found_bloodpool
	pools = get_pools(get_turf(target), 2)
	pools_to_remove = get_pools(get_turf(target), 1)
	pools -= pools_to_remove
	if(pools.len)
		shuffle(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		visible_message("<span class='danger'>[src] sinks into the blood...</span>")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		forceMove(get_turf(found_bloodpool))
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
		visible_message("<span class='danger'>And springs back out!</span>")
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_pools(turf/T, range)
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(T, range))
		if(nearby.can_bloodcrawl_in())
			. += nearby

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_spray()
	visible_message("<span class='danger'>[src] sprays a stream of gore!</span>")
	var/range = 6 + round(anger_modifier * 0.4)
	var/turf/previousturf = get_turf(src)
	var/turf/J = previousturf
	var/targetdir = get_dir(src, target)
	if(target.loc == loc)
		targetdir = dir
	face_atom(target)
	new /obj/effect/decal/cleanable/blood/bubblegum(J)
	for(var/i in 1 to range)
		J = get_step(previousturf, targetdir)
		new /obj/effect/overlay/temp/dir_setting/bloodsplatter(previousturf, get_dir(previousturf, J))
		playsound(previousturf,'sound/effects/splat.ogg', 100, 1, -1)
		if(!J || !previousturf.atmos_adjacent_turfs || !previousturf.atmos_adjacent_turfs[J])
			break
		new /obj/effect/decal/cleanable/blood/bubblegum(J)
		previousturf = J
		sleep(1)

/obj/effect/decal/cleanable/blood/bubblegum
	bloodiness = 0

/obj/effect/decal/cleanable/blood/bubblegum/can_bloodcrawl_in()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/slaughterlings()
	visible_message("<span class='danger'>[src] summons a shoal of slaughterlings!</span>")
	var/max_amount = 6
	for(var/H in get_pools(get_turf(src), 1))
		if(!max_amount)
			break
		max_amount--
		var/obj/effect/decal/cleanable/blood/B = H
		new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/slaughter(B.loc)
	return max_amount

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/slaughter
	name = "slaughterling"
	desc = "Though not yet strong enough to create a true physical form, it's nonetheless determined to murder you."
	density = 0
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/slaughter/CanPass(atom/movable/mover, turf/target, height = 0)
	if(istype(mover, /mob/living/simple_animal/hostile/megafauna/bubblegum))
		return 1
	return 0

#undef MEDAL_PREFIX
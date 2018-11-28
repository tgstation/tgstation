/*

BUBBLEGUM

Bubblegum spawns randomly wherever a lavaland creature is able to spawn. It is the most powerful slaughter demon in existence.
Bubblegum's footsteps are heralded by shaking booms, proving its tremendous size.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

It tries to strike at its target through any bloodpools under them; if it fails to do that, it will spray blood and then attempt to warp to a bloodpool near the target.
If it fails to warp to a target, it may summon up to 6 slaughterlings from the blood around it.
If it does not summon all 6 slaughterlings, it will instead charge at its target, dealing massive damage to anything it hits and spraying a stream of blood.
At half health, it will either charge three times or warp, then charge, instead of doing a single charge.

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
	speed = 2
	move_to_delay = 10
	ranged = 1
	pixel_x = -32
	del_on_death = 1
	crusher_loot = list(/obj/structure/closet/crate/necropolis/bubblegum/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	blood_volume = BLOOD_VOLUME_MAXIMUM //BLEED FOR ME
	var/turf/charging = null
	medal_type = BOSS_MEDAL_BUBBLEGUM
	score_type = BUBBLEGUM_SCORE
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	deathsound = 'sound/magic/enter_blood.ogg'

/obj/item/gps/internal/bubblegum
	icon_state = null
	gpstag = "Bloody Signal"
	desc = "You're not quite sure how a signal can be bloody."
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/bubblegum/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
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

/mob/living/simple_animal/hostile/megafauna/bubblegum/Life()
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	anger_modifier = CLAMP(((maxHealth - health)/60),0,20)
	if(charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time

	var/warped = FALSE
	if(!try_bloodattack())
		warped = blood_warp()
		if(warped && prob(100 - anger_modifier))
			return
		else
			if(prob(25))
				INVOKE_ASYNC(src, .proc/blood_ball, max(5, anger_modifier))

	if(prob(90) || slaughterlings())
		if(health > maxHealth * 0.5)
			charge()
		else
			if(prob(70) || warped)
				charge()
				charge()
				charge()
			else
				warp_charge()


/mob/living/simple_animal/hostile/megafauna/bubblegum/Initialize()
	. = ..()
	for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in GLOB.mob_living_list)
		if(B != src)
			return INITIALIZE_HINT_QDEL //There can be only one
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/phased_mob/slaughter))
		bloodspell.phased = TRUE
	internal = new/obj/item/gps/internal/bubblegum(src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/grant_achievement(medaltype,scoretype)
	. = ..()
	if(.)
		SSshuttle.shuttle_purchase_requirements_met |= "bubblegum"

/mob/living/simple_animal/hostile/megafauna/bubblegum/do_attack_animation(atom/A, visual_effect_icon)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget()
	if(!charging)
		return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Goto(target, delay, minimum_distance)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc,src)
		DestroySurroundings()
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Moved()
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, 1, 2, 1)
	if(charging)
		DestroySurroundings()
	return ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/warp_charge()
	blood_warp()
	charge()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge()
	var/turf/T = get_turf(target)
	if(!T || T == loc)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(T)
	charging = T
	DestroySurroundings()
	walk(src, 0)
	setDir(get_dir(src, T))
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(loc,src)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)
	sleep(3)
	walk_towards(src, T, 1)
	sleep(get_dist(src, T))
	try_bloodattack()
	charging = null

/mob/living/simple_animal/hostile/megafauna/bubblegum/Bump(atom/A)
	if(charging)
		if(isturf(A) || isobj(A) && A.density)
			A.ex_act(EXPLODE_HEAVY)
		DestroySurroundings()
		if(isliving(A))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you and forces you to the side!</span>")
			var/move_dir = turn(dir, pick(-90, 90)) // to the left or right of bubblegum
			src.forceMove(get_turf(L))
			L.forceMove(get_step(src, move_dir))
			L.apply_damage(40, BRUTE)
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
	..()

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
		new /obj/effect/temp_visual/bubblegum_hands/rightsmack(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftsmack(T)
	sleep(2.5)
	for(var/mob/living/L in T)
		if(!faction_check_mob(L))
			to_chat(L, "<span class='userdanger'>[src] rends you!</span>")
			playsound(T, attack_sound, 100, 1, -1)
			var/limb_to_hit = L.get_bodypart(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			L.apply_damage(25, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, "melee", null, null, armour_penetration))
	sleep(3)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/bloodgrab(turf/T, handedness)
	if(handedness)
		new /obj/effect/temp_visual/bubblegum_hands/rightpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/rightthumb(T)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
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

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_warp()
	if(Adjacent(target) || move_to_delay != initial(move_to_delay))
		return FALSE
	var/list/can_jaunt = get_pools(get_turf(src), 1)
	if(!can_jaunt.len)
		return FALSE

	var/list/pools = get_pools(get_turf(target), 2)
	var/list/pools_to_remove = get_pools(get_turf(target), 1)
	pools -= pools_to_remove
	if(!pools.len)
		return FALSE

	var/obj/effect/temp_visual/decoy/DA = new /obj/effect/temp_visual/decoy(loc,src)
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
		shuffle_inplace(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		visible_message("<span class='danger'>[src] sinks into the blood...</span>")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		forceMove(get_turf(found_bloodpool))
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
		visible_message("<span class='danger'>And springs back out!</span>")
		INVOKE_ASYNC(src, .proc/blood_speed)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_speed()
	move_to_delay = 3
	var/newcolor = rgb(149, 10, 10)
	add_atom_colour(newcolor, TEMPORARY_COLOUR_PRIORITY)
	sleep(60)
	move_to_delay = initial(move_to_delay)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, newcolor)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/get_pools(turf/T, range)
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(T, range))
		if(nearby.can_bloodcrawl_in())
			. += nearby

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_ball(var/count = 5, var/atom/shootat = target)
	var/cooldown = max(10 - count, 1)
	var/directions = GLOB.cardinals + GLOB.diagonals
	SetRecoveryTime(count * cooldown + 10)
	for(var/i = 1 to count)
		if(!shootat || !isliving(shootat))
			return
		var/turf/endturf = get_turf(shootat)
		for(var/j = 1 to 3)
			var/turf/check = get_step(endturf, pick(directions))
			if(check)
				endturf = check
		var/obj/item/projectile/P = new /obj/item/projectile/blood_ball(src.loc)
		P.firer = src
		P.preparePixelProjectile(endturf, src)
		P.range = get_dist(endturf, get_turf(src))
		P.speed = 20 / P.range
		P.fire()
		new /obj/effect/temp_visual/blood_ball_target(endturf)
		sleep(cooldown)

/obj/effect/temp_visual/blood_ball_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 20

/obj/effect/temp_visual/blood_ball_target/ex_act()
	return

/obj/item/projectile/blood_ball
	name = "bloodball"
	desc = "You should probably get moving!"
	icon_state = "mini_leaper"
	layer = FLY_LAYER
	forcedodge = 1
	light_range = 2
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/blood_ball/ex_act()
	return

/obj/item/projectile/blood_ball/on_hit(atom/target, blocked = FALSE)
	return

/obj/item/projectile/blood_ball/Bump(atom/A)
	return

/obj/item/projectile/blood_ball/on_range()
	var/turf/T = get_turf(src)
	playsound(T,'sound/effects/splat.ogg', 100, 1, -1)

	// damage to living targets
	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/simple_animal/hostile/megafauna/bubblegum))
			continue
		L.adjustBruteLoss(10)
		to_chat(L, "<span class='userdanger'>You're hit directly by the blood ball!</span>")

	// deals damage to mechs
	for(var/obj/mecha/M in T.contents)
		M.take_damage(45, BRUTE, "melee", 1)

	// spawns blood around the end location
	new /obj/effect/decal/cleanable/blood(T)

	return ..()

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
		new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/slaughter(B.loc)
	return max_amount

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/slaughter
	name = "slaughterling"
	desc = "Though not yet strong enough to create a true physical form, it's nonetheless determined to murder you."
	icon_state = "bloodbrood"
	icon_living = "bloodbrood"
	icon_aggro = "bloodbrood"
	attacktext = "pierces"
	color = "#C80000"
	density = FALSE
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/slaughter/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/megafauna/bubblegum))
		return 1
	return 0
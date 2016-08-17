#define MEDAL_PREFIX "Hierophant"
/*

The Hierophant

The Hierophant spawns somewhere who knows

The Hierophant's attacks are as follows, and INTENSIFY at a random chance based on Hierophant's health or if the target is adjacent to Hierophant;
- Creates a cardinal or diagonal blast under its target, exploding after a short time.
	INTENSITY EFFECT: Creates whichever blast type was not picked under itself.
- If no chasers exist, creates a chaser that will seek its target, leaving a trail of blasts.
	INTENSITY EFFECT: Creates a second, slower chaser.
- Creates an expanding AoE burst.
- INTENSE ONLY: Blinks to the target after a very brief delay, damaging everything near the start and end points.
- IF TARGET WAS STRUCK IN MELEE AND TRIGGERED A RANGED ATTACK: Creates a 3x3 square of blasts under the target.

When The Hierophant dies, it leaves behind its staff, which, while much weaker than when wielded by The Hierophant itself, is still quite effective:

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/hierophant
	name = "Hierophant"
	desc = "Stolen from Hyper Light Drifter."
	health = 2500
	maxHealth = 2500
	attacktext = "clubs"
	attack_sound = "swing_hit"
	icon_state = "hierophant"
	icon_living = "hierophant"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/hierophant.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("preaches")
	armour_penetration = 100
	melee_damage_lower = 20
	melee_damage_upper = 20
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -16
	ranged_cooldown_time = 40
	aggro_vision_range = 18
	idle_vision_range = 5
	loot = list(/obj/item/weapon/hierophant_staff)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	var/anger_modifier = 0
	var/burst_range = 2
	var/beam_range = 3
	var/chaser_cooldown = 61
	var/blinking = FALSE
	var/obj/item/device/gps/internal
	medal_type = MEDAL_PREFIX
	score_type = BIRD_SCORE
	del_on_death = TRUE
	deathmessage = "disappears in a burst of magic, leaving only its staff."
	death_sound = 'sound/magic/Repulse.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

/mob/living/simple_animal/hostile/megafauna/hierophant/New()
	..()
	internal = new/obj/item/device/gps/internal/hierophant(src)

/mob/living/simple_animal/hostile/megafauna/hierophant/death()
	if(health > 0)
		return
	else
		melee_blast(src)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Destroy()
	qdel(internal)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/hierophant/attackby(obj/item/weapon/W, mob/user, params)
	if(W)
		W.force *= 2
		..()
		W.force *= 0.5

/mob/living/simple_animal/hostile/megafauna/hierophant/devour(mob/living/L)
	melee_blast(L)
	visible_message(
		"<span class='danger'>[src] annihilates [L]!</span>",
		"<span class='userdanger'>You annihilate [L], restoring your health!</span>")
	adjustHealth(-L.maxHealth)
	dust(L)

/mob/living/simple_animal/hostile/megafauna/hierophant/AttackingTarget()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/DestroySurroundings()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Move()
	if(!blinking)
		..()

/mob/living/simple_animal/hostile/megafauna/hierophant/Goto(target, delay, minimum_distance)
	if(!blinking)
		..()

/obj/effect/overlay/temp/hierophant
	layer = BELOW_MOB_LAYER
	var/mob/living/caster

/obj/effect/overlay/temp/hierophant/New(loc, new_caster)
	..()
	caster = new_caster

/obj/effect/overlay/temp/hierophant/chaser
	duration = 60
	var/mob/living/target
	var/moving_dir
	var/previous_moving_dir
	var/more_previouser_moving_dir
	var/moving = 0
	var/speed = 4

/obj/effect/overlay/temp/hierophant/chaser/New(loc, new_caster, new_target)
	..()
	target = new_target
	addtimer(src, "seek_target", 1)

/obj/effect/overlay/temp/hierophant/chaser/proc/get_target_dir()
	. = get_dir(get_cardinal_step_away(src, target), src)
	if(previous_moving_dir == .)
		var/list/cardinal_copy = cardinal.Copy()
		cardinal_copy -= previous_moving_dir
		. = pick(cardinal_copy)

/obj/effect/overlay/temp/hierophant/chaser/proc/seek_target()
	while(target && src && x && y && target.x && target.y)
		if(!moving)
			more_previouser_moving_dir = previous_moving_dir
			previous_moving_dir = moving_dir
			moving_dir = get_target_dir()
			if(previous_moving_dir != moving_dir && moving_dir == more_previouser_moving_dir)
				moving = 1
			else
				moving = 4
		if(moving)
			var/turf/T = get_step(src, moving_dir)
			forceMove(T)
			PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(loc, caster))
			moving--
			sleep(speed)

/obj/effect/overlay/temp/hierophant/telegraph
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hierophant_telegraph"
	pixel_x = -32
	pixel_y = -32
	duration = 2

/obj/effect/overlay/temp/hierophant/telegraph/diagonal
	icon_state = "hierophant_telegraph_diagonal"

/obj/effect/overlay/temp/hierophant/telegraph/cardinal
	icon_state = "hierophant_telegraph_cardinal"

/obj/effect/overlay/temp/hierophant/telegraph/teleport
	icon_state = "hierophant_telegraph_teleport"
	duration = 9

/obj/effect/overlay/temp/hierophant/blast
	icon_state = "hierophant_blast"
	name = "blast"
	luminosity = 1
	desc = "Get out of the way!"
	duration = 9
	var/damage = 10

/obj/effect/overlay/temp/hierophant/blast/New(loc, new_caster)
	..()
	if(istype(loc, /turf/closed/mineral))
		var/turf/closed/mineral/M = loc
		M.gets_drilled(caster)
	addtimer(src, "blast", 0)

/obj/effect/overlay/temp/hierophant/blast/proc/blast()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/Blind.ogg', 200, 1)
	sleep(6)
	for(var/mob/living/L in T.contents)
		if(L != caster)
			L << "<span class='userdanger'>You're struck by a hierophant blast!</span>"
			L.apply_damage(damage, BRUTE)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/calculate_rage()
	anger_modifier = Clamp(((maxHealth - health)/50),0,50)
	burst_range = initial(burst_range) + round(anger_modifier * 0.1)
	beam_range = initial(beam_range) + round(anger_modifier * 0.1)

/mob/living/simple_animal/hostile/megafauna/hierophant/OpenFire()
	calculate_rage()
	ranged_cooldown = world.time + max(5, ranged_cooldown_time - anger_modifier)

	if(prob(anger_modifier) && get_dist(src, target) > burst_range)
		blink(target)
		return

	if(prob(70-anger_modifier))
		if(prob(60))
			addtimer(src, "cardinal_blasts", 0, FALSE, target)
		else
			addtimer(src, "diagonal_blasts", 0, FALSE, target)
	else
		if(chaser_cooldown < world.time)
			var/obj/effect/overlay/temp/hierophant/chaser/C = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target))
			C.speed = max(1.5, speed - anger_modifier*0.1)
			chaser_cooldown = world.time + initial(chaser_cooldown)
			if(prob(anger_modifier) || (target.Adjacent(src) && target != src))
				var/obj/effect/overlay/temp/hierophant/chaser/OC = PoolOrNew(/obj/effect/overlay/temp/hierophant/chaser, list(loc, src, target))
				OC.speed = max(1.5, speed*2 - anger_modifier*0.1)
				OC.moving = 4
				OC.moving_dir = pick(cardinal - C.moving_dir)
		else
			addtimer(src, "burst", 0)

	if(Adjacent(target))
		melee_blast(target)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/diagonal_blasts(mob/victim)
	var/turf/T = get_turf(victim)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/diagonal, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	sleep(3)
	if((prob(anger_modifier) || victim.Adjacent(src)) && victim != src)
		addtimer(src, "cardinal_blasts", 0, FALSE, src)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src))
	for(var/d in diagonals)
		addtimer(src, "diagonal_blast", 0, FALSE, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/diagonal_blast(turf/T, dir)
	var/range = beam_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(J, src))
		previousturf = J
		J = get_step(previousturf, dir)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/cardinal_blasts(mob/victim)
	var/turf/T = get_turf(victim)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/cardinal, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	sleep(3)
	if((prob(anger_modifier) || victim.Adjacent(src)) && victim != src)
		addtimer(src, "diagonal_blasts", 0, FALSE, target)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src))
	for(var/d in cardinal)
		addtimer(src, "cardinal_blast", 0, FALSE, T, d)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/cardinal_blast(turf/T, dir)
	var/turf/E = get_edge_target_turf(T, dir)
	var/range = beam_range
	var/turf/previousturf = T
	for(var/turf/J in getline(previousturf,E) - previousturf)
		if(!range)
			break
		range--
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(J, src))
		previousturf = J
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/blink(mob/victim)
	if(blinking || !victim || get_dist(victim, src) > 2)
		return
	var/turf/T = get_turf(victim)
	var/turf/source = get_turf(src)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(T, src))
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph/teleport, list(source, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	playsound(source,'sound/magic/blink.ogg', 200, 1)
	blinking = TRUE
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src))
		B.damage = 30
	for(var/t in RANGE_TURFS(1, source))
		var/obj/effect/overlay/temp/hierophant/blast/B = PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src))
		B.damage = 30
	animate(src, alpha = 0, color = "660099", time = 2, easing = EASE_OUT)
	sleep(4)
	forceMove(T)
	animate(src, alpha = 255, color = initial(color), time = 2, easing = EASE_IN)
	sleep(2)
	blinking = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/melee_blast(mob/victim)
	var/turf/T = get_turf(victim)
	PoolOrNew(/obj/effect/overlay/temp/hierophant/telegraph, list(T, src))
	playsound(T,'sound/magic/blink.ogg', 200, 1)
	sleep(3)
	for(var/t in RANGE_TURFS(1, T))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(t, src))

/mob/living/simple_animal/hostile/megafauna/hierophant/proc/burst()
	playsound(src,'sound/magic/blink.ogg', 200, 1)
	var/last_dist = 0
	var/turf/original = get_turf(src)
	for(var/t in spiral_range_turfs(burst_range, original))
		var/turf/T = t
		if(!T)
			continue
		var/dist = get_dist(original, T)
		if(dist > last_dist)
			last_dist = dist
			sleep(rand(3, 5))
		PoolOrNew(/obj/effect/overlay/temp/hierophant/blast, list(T, src))

/mob/living/simple_animal/hostile/megafauna/hierophant/AltClickOn(atom/A)
	if(!istype(A))
		return
	blink(A)

/obj/item/device/gps/internal/hierophant
	icon_state = null
	gpstag = "Zealous Signal"
	desc = "Heed its words."
	invisibility = 100

#undef MEDAL_PREFIX
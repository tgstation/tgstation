#define MEDAL_PREFIX "Drake"
/*

ASH DRAKE

Ash drakes spawn randomly wherever a lavaland creature is able to spawn. They are the draconic guardians of the Necropolis.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

Whenever possible, the drake will breathe fire in the four cardinal directions, igniting and heavily damaging anything caught in the blast.
It also often causes fire to rain from the sky - many nearby turfs will flash red as a fireball crashes into them, dealing damage to anything on the turfs.
The drake also utilizes its wings to fly into the sky and crash down onto a specified point. Anything on this point takes tremendous damage.
 - Sometimes it will chain these swooping attacks over and over, making swiftness a necessity.

When an ash drake dies, it leaves behind a chest that can contain four things:
 1. A spectral blade that allows its wielder to call ghosts to it, enhancing its power
 2. A lava staff that allows its wielder to create lava
 3. A spellbook and wand of fireballs
 4. A bottle of dragon's blood with several effects, including turning its imbiber into a drake themselves.

When butchered, they leave behind diamonds, sinew, bone, and ash drake hide. Ash drake hide can be used to create a hooded cloak that protects its wearer from ash storms.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/dragon
	name = "ash drake"
	desc = "Guardians of the necropolis."
	health = 2500
	maxHealth = 2500
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/dragon.dmi'
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -16
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	var/swooping = 0
	var/swoop_cooldown = 0
	medal_type = MEDAL_PREFIX
	score_type = DRAKE_SCORE
	deathmessage = "collapses into a pile of bones, its flesh sloughing away."
	death_sound = 'sound/magic/demon_dies.ogg'

/mob/living/simple_animal/hostile/megafauna/dragon/Initialize()
	..()
	internal = new/obj/item/device/gps/internal/dragon(src)

/mob/living/simple_animal/hostile/megafauna/dragon/ex_act(severity, target)
	if(severity == 3)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/dragon/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && swooping)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/AttackingTarget()
	if(!swooping)
		return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/DestroySurroundings()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Move()
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Goto(target, delay, minimum_distance)
	if(!swooping)
		..()

/mob/living/simple_animal/hostile/megafauna/dragon/Process_Spacemove(movement_dir = 0)
	return 1

/obj/effect/overlay/temp/fireball
	icon = 'icons/obj/wizard.dmi'
	icon_state = "fireball"
	name = "fireball"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 12
	pixel_z = 500

/obj/effect/overlay/temp/fireball/Initialize(loc)
	..()
	animate(src, pixel_z = 0, time = 12)

/obj/effect/overlay/temp/target
	icon = 'icons/mob/actions.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 12

/obj/effect/overlay/temp/dragon_swoop
	name = "certain death"
	desc = "Don't just stand there, move!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landing"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	color = "#FF0000"
	duration = 10

/obj/effect/overlay/temp/target/ex_act()
	return

/obj/effect/overlay/temp/target/Initialize(loc)
	..()
	INVOKE_ASYNC(src, .proc/fall)

/obj/effect/overlay/temp/target/proc/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/Fireball.ogg', 200, 1)
	new /obj/effect/overlay/temp/fireball(T)
	sleep(12)
	explosion(T, 0, 0, 1, 0, 0, 0, 1)

/mob/living/simple_animal/hostile/megafauna/dragon/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time
	if(swooping)
		fire_rain()
		return

	if(prob(15 + anger_modifier) && !client)
		if(health < maxHealth/2)
			INVOKE_ASYNC(src, .proc/swoop_attack, 1)
		else
			fire_rain()

	else if(prob(10+anger_modifier) && !client)
		if(health > maxHealth/2)
			INVOKE_ASYNC(src, .proc/swoop_attack)
		else
			INVOKE_ASYNC(src, .proc/triple_swoop)
	else
		fire_walls()

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_rain()
	visible_message("<span class='boldwarning'>Fire rains from the sky!</span>")
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(10))
			new /obj/effect/overlay/temp/target(turf)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_walls()
	playsound(get_turf(src),'sound/magic/Fireball.ogg', 200, 1)

	for(var/d in cardinal)
		INVOKE_ASYNC(src, .proc/fire_wall, d)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/fire_wall(dir)
	var/list/hit_things = list(src)
	var/turf/E = get_edge_target_turf(src, dir)
	var/range = 10
	var/turf/previousturf = get_turf(src)
	for(var/turf/J in getline(src,E))
		if(!range || (J != previousturf && (!previousturf.atmos_adjacent_turfs || !previousturf.atmos_adjacent_turfs[J])))
			break
		range--
		new /obj/effect/hotspot(J)
		J.hotspot_expose(700,50,1)
		for(var/mob/living/L in J.contents - hit_things)
			L.adjustFireLoss(20)
			to_chat(L, "<span class='userdanger'>You're hit by the drake's fire breath!</span>")
			hit_things += L
		previousturf = J
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/dragon/proc/triple_swoop()
	swoop_attack()
	swoop_attack()
	swoop_attack()

/mob/living/simple_animal/hostile/megafauna/dragon/proc/swoop_attack(fire_rain = 0, atom/movable/manual_target)
	if(stat || swooping)
		return
	swoop_cooldown = world.time + 200
	var/atom/swoop_target
	if(manual_target)
		swoop_target = manual_target
	else
		swoop_target = target
	stop_automated_movement = TRUE
	swooping = 1
	density = 0
	icon_state = "swoop"
	visible_message("<span class='boldwarning'>[src] swoops up high!</span>")
	if(prob(50))
		animate(src, pixel_x = 500, pixel_z = 500, time = 10)
	else
		animate(src, pixel_x = -500, pixel_z = 500, time = 10)
	sleep(30)

	var/turf/tturf
	if(fire_rain)
		fire_rain()

	icon_state = "dragon"
	if(swoop_target && !QDELETED(swoop_target) && swoop_target.z == src.z)
		tturf = get_turf(swoop_target)
	else
		tturf = get_turf(src)
	forceMove(tturf)
	new /obj/effect/overlay/temp/dragon_swoop(tturf)
	animate(src, pixel_x = initial(pixel_x), pixel_z = 0, time = 10)
	sleep(10)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in orange(1, src))
		if(L.stat)
			visible_message("<span class='warning'>[src] slams down on [L], crushing them!</span>")
			L.gib()
		else
			L.adjustBruteLoss(75)
			if(L && !QDELETED(L)) // Some mobs are deleted on death
				var/throw_dir = get_dir(src, L)
				if(L.loc == loc)
					throw_dir = pick(alldirs)
				var/throwtarget = get_edge_target_turf(src, throw_dir)
				L.throw_at(throwtarget, 3)
				visible_message("<span class='warning'>[L] is thrown clear of [src]!</span>")

	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)

	stop_automated_movement = FALSE
	swooping = 0
	density = 1

/mob/living/simple_animal/hostile/megafauna/dragon/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(swoop_cooldown >= world.time)
		to_chat(src, "<span class='warning'>You need to wait 20 seconds between swoop attacks!</span>")
		return
	swoop_attack(1, A)

/obj/item/device/gps/internal/dragon
	icon_state = null
	gpstag = "Fiery Signal"
	desc = "Here there be dragons."
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/dragon/lesser
	name = "lesser ash drake"
	maxHealth = 200
	health = 200
	faction = list("neutral")
	obj_damage = 80
	melee_damage_upper = 30
	melee_damage_lower = 30
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	loot = list()

/mob/living/simple_animal/hostile/megafauna/dragon/lesser/grant_achievement(medaltype,scoretype)
	return

#undef MEDAL_PREFIX

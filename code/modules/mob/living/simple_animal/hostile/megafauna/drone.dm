/mob/living/simple_animal/hostile/megafauna/megadrone
	name = "Mega drone"
	desc = "Run!"
	health = 2500
	maxHealth = 2500
	attacktext = "smashes"
	//attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_sound = "swing_hit"
	icon_state = "drone"
	icon_living = "drone"
	friendly = "stares"
	icon = 'icons/mob/lavaland/drone.dmi'
	speak_emote = list("states")
	armour_penetration = 100
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 20
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -32
	pixel_y = -32
	aggro_vision_range = 20
	loot = list(/obj/item/weapon/gun/energy/white/cross_laser)
	wander = TRUE
	del_on_death = TRUE
	var/green = FALSE
	var/freeze = FALSE
	var/datum/action/innate/drone_attack/shots_action = new/datum/action/innate/drone_attack/shots_homing()
	var/datum/action/innate/drone_attack/rain_action = new/datum/action/innate/drone_attack/rain()
	var/datum/action/innate/drone_attack/homing_action = new/datum/action/innate/drone_attack/homing()
	var/datum/action/innate/drone_attack/burst_action = new/datum/action/innate/drone_attack/burst()
	var/attack_type = null
	var/got_action = null
	death_sound = 'sound/magic/Repulse.ogg'

/mob/living/simple_animal/hostile/megafauna/megadrone/updatehealth()
	if((health/maxHealth) < 0.2 && green == FALSE)
		green = TRUE
		playsound(get_turf(src), 'sound/magic/Repulse.ogg', 200, 1, 2)
		icon_state = "drone_green"
		icon_living = "drone_green"
		visible_message("<span class ='cult'>Extermination mode activated.</span>")
		shots_action.button_icon_state = "drone_laser_green"
		rain_action.button_icon_state = "drone_laser_green"
		homing_action.button_icon_state = "drone_laser_green"
		burst_action.button_icon_state = "drone_laser_green"
		damage_coeff = list(BRUTE = 0.3, BURN = 0.3, TOX = 0.3, CLONE = 0.3, STAMINA = 0, OXY = 0.3)
	..()
/turf/open/floor/plating/asteroid/airless/cave
	megafauna_spawn_list = list(/mob/living/simple_animal/hostile/megafauna/dragon = 4, /mob/living/simple_animal/hostile/megafauna/colossus = 2, \
	/mob/living/simple_animal/hostile/megafauna/bubblegum = 6, /mob/living/simple_animal/hostile/megafauna/megadrone = 3)

/obj/item/device/gps/internal/drone
	icon_state = null
	gpstag = "Drone beacon."
	desc = "You better run."
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/megadrone/AttackingTarget()
	if(!freeze)
		..()

/mob/living/simple_animal/hostile/megafauna/megadrone/DestroySurroundings()
	if(!freeze)
		..()

/mob/living/simple_animal/hostile/megafauna/megadrone/Move()
	if(!freeze)
		..()

/mob/living/simple_animal/hostile/megafauna/megadrone/Goto(target, delay, minimum_distance)
	if(!freeze)
		..()

/mob/living/simple_animal/hostile/megafauna/megadrone/devour(mob/living/L)
	if(!L)
		return
	visible_message(
		"<span class='danger'>[src] annihilates [L]!</span>",
		"<span class='userdanger'>You annihilate [L]!</span>")
	L.gib()

/mob/living/simple_animal/hostile/megafauna/megadrone/New()
	shots_action.Grant(src)
	rain_action.Grant(src)
	homing_action.Grant(src)
	burst_action.Grant(src)
	..()

/mob/living/simple_animal/hostile/megafauna/megadrone/OpenFire()
	freeze = TRUE
	if(attack_type == null)
		attack_type = rand(1, 4)
	if(green == FALSE)
		if(attack_type == 1)
			ranged_cooldown = world.time + 45
			homing_shots(20, src)
			sleep(45)
		else if(attack_type == 2)
			ranged_cooldown = world.time + 15
			laser_rain()
			sleep(15)
		else if(attack_type == 3)
			ranged_cooldown = world.time + 50
			homing_laser(20, src)
			sleep(50)
		else if(attack_type == 4)
			ranged_cooldown = world.time + 45
			smart_blast()
			sleep(45)
	else
		if(attack_type == 1)
			ranged_cooldown = world.time + 50
			homing_shots_green(20, src)
			sleep(50)
		else if(attack_type == 2)
			ranged_cooldown = world.time + 25
			laser_rain_green()
			sleep(25)
		else if(attack_type == 3)
			ranged_cooldown = world.time + 50
			homing_laser_green(20, src)
			sleep(50)
		else if(attack_type == 4)
			ranged_cooldown = world.time + 60
			smart_blast_green(2)
			sleep(60)
	if(client == null)
		attack_type = null
	freeze = FALSE

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/smart_blast()
	visible_message("<span class='boldwarning'>Drone releases wave of projectiles!</span>")
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	for(var/turf/turf in view(1,src))
		shoot_cross_projectile(turf)
		sleep(4)

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/smart_blast_green(var/timer)
	visible_message("<span class='boldwarning'>Drone releases wave of projectiles!</span>")
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	while(timer>0)
		for(var/turf/turf in view(1,src))
			shoot_green_cross_projectile(turf)
		sleep(20)
		timer--

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/homing_laser(var/timer, var/caster)
	visible_message("<span class='boldwarning'>Drone scans area!</span>")
	visible_message("<span class='boldwarning'>Laser rains from the sky!</span>")
	while(timer>0)
		for(var/turf/turf in view(12,src))
			if(prob(2))
				PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon, list(turf, src))
		for(var/mob/living/L in view(12,src) - caster)
			if( L.stat == DEAD)
				continue
			PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon, list(get_turf(L), src))
		sleep(2)
		timer--

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/homing_laser_green(var/timer, var/caster)
	visible_message("<span class='boldwarning'>Drone scans area!</span>")
	visible_message("<span class='boldwarning'>Laser rains from the sky!</span>")
	while(timer>0)
		for(var/turf/turf in view(12,src))
			if(prob(1/3))
				PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon/green_cross, list(turf, src))
		for(var/mob/living/L in view(12,src) - caster)
			if( L.stat == DEAD)
				continue
			PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon/green, list(get_turf(L), src))
		sleep(2)
		timer--

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/homing_shots(var/timer, var/caster)
	visible_message("<span class='boldwarning'>Drone scans area!</span>")
	visible_message("<span class='boldwarning'>Drone starts shooting!</span>")
	while(timer>0)
		for(var/mob/living/L in view(12,src) - caster)
			if(L.stat == DEAD)
				continue
			shoot_projectile(get_turf(L))
		for(var/turf/turf in view(12,src))
			if(prob(1/5))
				shoot_projectile(turf)
		sleep(2)
		timer--

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/homing_shots_green(var/timer, var/caster)
	visible_message("<span class='boldwarning'>Drone scans area!</span>")
	visible_message("<span class='boldwarning'>Drone starts shooting!</span>")
	while(timer>0)
		for(var/mob/living/L in view(12,src) - caster)
			if(L.stat == DEAD)
				continue
			shoot_green_projectile(get_turf(L))
		for(var/turf/turf in view(12,src))
			if(prob(1/7.5))
				shoot_green_cross_projectile(turf)
		sleep(2)
		timer--

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/laser_rain()
	visible_message("<span class='boldwarning'>Laser rains from the sky!</span>")
	for(var/turf/turf in view(12,src))
		if(prob(55))
			PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon, list(turf, src))

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/laser_rain_green()
	visible_message("<span class='boldwarning'>Laser rains from the sky!</span>")
	for(var/turf/turf in view(12,src))
		if(prob(7.5))
			PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon/green_cross, list(turf, src))

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/shoot_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/drone_laser(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/shoot_green_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/drone_laser/green(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/shoot_cross_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/white/cross_laser(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/shoot_green_cross_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/white/cross_laser_green(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/obj/item/projectile/drone_laser
	name ="drone laser"
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	icon_state= "drone_laser"
	damage = 20
	armour_penetration = 100
	speed = 3
	eyeblur = 1
	damage_type = BURN
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/drone_laser/green
	icon_state= "drone_laser_green"
	speed = 2.5
	damage = 30

/datum/action/innate/drone_attack
	name = "Drone Attack"
	icon_icon = 'icons/mob/lavaland/related_to_drone.dmi'
	button_icon_state = "drone_laser"

/datum/action/innate/drone_attack/Activate()
	var/mob/living/simple_animal/hostile/megafauna/megadrone/M = owner
	M.attack_type = null
	for(var/datum/action/innate/drone_attack/A in M.actions)
		A.background_icon_state = "bg_default"
		A.UpdateButtonIcon()
	background_icon_state = "bg_default_on"

/datum/action/innate/drone_attack/shots_homing
	name = "Homing shots"

/datum/action/innate/drone_attack/shots_homing/Activate()
	var/mob/living/simple_animal/hostile/megafauna/megadrone/M = owner
	M.attack_type = 1
	for(var/datum/action/innate/drone_attack/A in M.actions)
		A.background_icon_state = "bg_default"
		A.UpdateButtonIcon()
	background_icon_state = "bg_default_on"
	UpdateButtonIcon()

/datum/action/innate/drone_attack/rain
	name = "Laser rain"

/datum/action/innate/drone_attack/rain/Activate()
	var/mob/living/simple_animal/hostile/megafauna/megadrone/M = owner
	M.attack_type = 2
	for(var/datum/action/innate/drone_attack/A in M.actions)
		A.background_icon_state = "bg_default"
		A.UpdateButtonIcon()
	background_icon_state = "bg_default_on"
	UpdateButtonIcon()

/datum/action/innate/drone_attack/homing
	name = "Homing laser"

/datum/action/innate/drone_attack/homing/Activate()
	var/mob/living/simple_animal/hostile/megafauna/megadrone/M = owner
	M.attack_type = 3
	for(var/datum/action/innate/drone_attack/A in M.actions)
		A.background_icon_state = "bg_default"
		A.UpdateButtonIcon()
	background_icon_state = "bg_default_on"
	UpdateButtonIcon()

/datum/action/innate/drone_attack/burst
	name = "Splitting laser"

/datum/action/innate/drone_attack/burst/Activate()
	var/mob/living/simple_animal/hostile/megafauna/megadrone/M = owner
	M.attack_type = 4
	for(var/datum/action/innate/drone_attack/A in M.actions)
		A.background_icon_state = "bg_default"
		A.UpdateButtonIcon()
	background_icon_state = "bg_default_on"
	UpdateButtonIcon()

/obj/effect/overlay/temp/drone/laser
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	icon_state= "drone_laser"
	name = "laser"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 12
	pixel_z = 500

/obj/effect/overlay/temp/drone/laser/New(loc)
	..()
	animate(src, pixel_z = 0, time = 12)

/obj/effect/overlay/temp/drone/laser/green
	icon_state= "drone_laser_green"

/obj/effect/overlay/temp/drone/laser/green_cross
	icon_state= "cross_laser_green"

obj/effect/overlay/temp/drone/laser_beacon
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	icon_state = "laser_beacon"
	name = "drone laser beacon"
	layer = BELOW_MOB_LAYER
	luminosity = 1
	desc = "Get out of the way!"
	duration = 12
	var/damage = 20 //how much damage do we do?
	var/list/hit_things = list() //we hit these already, ignore them
	var/mob/living/caster

obj/effect/overlay/temp/drone/laser_beacon/New(loc, caster)
	..()
	if(caster)
		hit_things += caster
	if(ismineralturf(loc)) //drill mineral turfs
		var/turf/closed/mineral/M = loc
		M.gets_drilled(caster)
	addtimer(src, "fall", 0)


obj/effect/overlay/temp/drone/laser_beacon/proc/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/Blind.ogg', 200, 1)
	PoolOrNew(/obj/effect/overlay/temp/drone/laser,T)
	sleep(12)
	do_damage(T)

obj/effect/overlay/temp/drone/laser_beacon/proc/do_damage(turf/T)
	for(var/mob/living/L in T.contents - hit_things) //find and damage mobs...
		hit_things += L
		if((caster && caster.faction_check(L)) || L.stat == DEAD)
			continue
		if(L.client)
			flash_color(L.client, "#660099", 1)
		playsound(L,'sound/weapons/sear.ogg', 50, 1, -4)
		L << "<span class='userdanger'>You're struck by a [name]!</span>"
		var/limb_to_hit = L.get_bodypart(pick("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg"))
		var/armor = L.run_armor_check(limb_to_hit, "melee", "Your armor absorbs [src]!", "Your armor blocks part of [src]!", 50, "Your armor was penetrated by [src]!")
		L.apply_damage(damage, BURN, limb_to_hit, armor)
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
			L.adjustBruteLoss(damage)
		add_logs(caster, L, "struck with a [name]")
	for(var/obj/mecha/M in T.contents - hit_things) //and mechs.
		hit_things += M
		if(M.occupant)
			if(caster && caster.faction_check(M.occupant))
				continue
			M.occupant << "<span class='userdanger'>Your [M.name] is struck by a [name]!</span>"
		playsound(M,'sound/weapons/sear.ogg', 50, 1, -4)
		M.take_damage(damage, BURN, 0, 0)

obj/effect/overlay/temp/drone/laser_beacon/green
	icon_state = "laser_beacon_green"
	damage = 30

obj/effect/overlay/temp/drone/laser_beacon/green/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/Blind.ogg', 200, 1)
	PoolOrNew(/obj/effect/overlay/temp/drone/laser/green,T)
	sleep(12)
	do_damage(T)

obj/effect/overlay/temp/drone/laser_beacon/green_cross
	icon_state = "laser_beacon_green"
	damage = 50

obj/effect/overlay/temp/drone/laser_beacon/green_cross/proc/shoot_green_projectile(turf/marker, mob/caster)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/drone_laser/green(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = caster
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.original = marker
	P.fire()

obj/effect/overlay/temp/drone/laser_beacon/green_cross/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/Blind.ogg', 200, 1)
	PoolOrNew(/obj/effect/overlay/temp/drone/laser/green_cross,T)
	sleep(12)
	for(var/mob/living/L in view(12,src) - hit_things)
		if(L.stat == DEAD)
			continue
		shoot_green_projectile(get_turf(L), caster)


/obj/item/weapon/gun/energy/white/cross_laser
	name = "Laser staff"
	desc = "A  energy-based heat laser gun that fires concentrated orbs of very hot light which pass through glass and thin metal end explode into laser shots."
	icon = 'icons/obj/guns/white_only.dmi'
	icon_state = "cross_staff"
	item_state = "cross_staff"
	lefthand_file = 'icons/mob/inhands/white_only_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/white_only_righthand.dmi'
	fire_sound = 'sound/weapons/laser3.ogg'
	w_class = 4
	materials = list(MAT_METAL=5000)
	origin_tech = "combat=6;magnets=6"
	ammo_type = list(/obj/item/ammo_casing/energy/white/cross_laser)
	selfcharge = 1
	charge_delay = 2

/obj/item/ammo_casing/energy/white/cross_laser
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew"
	caliber = "energy"
	e_cost = 150 //The amount of energy a cell needs to expend to create this shot.
	select_name = "energy"
	fire_sound = 'sound/weapons/laser3.ogg'
	projectile_type = /obj/item/projectile/white/cross_laser

/obj/item/projectile/white/cross_laser
	name = "bursting laser"
	icon_state = "cross_laser"
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	speed = 3
	luminosity = 1
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "energy"
	eyeblur = 1

/obj/item/projectile/white/cross_laser/proc/shoot_projectile(turf/marker, mob/firer)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/drone_laser(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = firer
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.original = marker
	P.fire()

/obj/item/projectile/white/cross_laser/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	playsound(target,'sound/magic/blink.ogg', 200, 1)
	for(var/turf/turf in range(1,get_turf(src)))
		shoot_projectile(turf, firer)
	return 1

/obj/item/projectile/white/cross_laser_green
	speed = 3
	damage = 50
	icon_state = "cross_laser_green"
	name = "bursting laser"
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	luminosity = 1
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "energy"
	eyeblur = 1

/obj/item/projectile/white/cross_laser_green/proc/shoot_green_projectile(turf/marker, mob/firer)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/drone_laser/green(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = firer
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.original = marker
	P.fire()

/obj/item/projectile/white/cross_laser_green/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
	..()
	playsound(target,'sound/magic/blink.ogg', 200, 1)
	for(var/mob/living/L in view(12,src) - firer)
		if(L.stat == DEAD)
			continue
		shoot_green_projectile(get_turf(L), firer)
	return 1
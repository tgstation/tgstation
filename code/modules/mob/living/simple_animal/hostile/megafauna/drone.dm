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
	faction = list("boss")
	speak_emote = list("states")
	armour_penetration = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	see_in_dark = 20
	speed = 1
	move_to_delay = 10
	ranged = 1
	pixel_x = -32
	pixel_y = -32
	aggro_vision_range = 23
	loot = list(/obj/item/weapon/gun/energy/white_only/cross_laser)
	wander = TRUE
	score_type = BIRD_SCORE
	del_on_death = TRUE
	var/datum/action/innate/drone_attack/shots_action = new/datum/action/innate/drone_attack/shots_homing()
	var/datum/action/innate/drone_attack/rain_action = new/datum/action/innate/drone_attack/rain()
	var/datum/action/innate/drone_attack/homing_action = new/datum/action/innate/drone_attack/homing()
	var/datum/action/innate/drone_attack/burst_action = new/datum/action/innate/drone_attack/burst()
	var/attack_type = null
	var/got_action = null
	death_sound = 'sound/magic/Repulse.ogg'

/mob/living/simple_animal/hostile/megafauna/megadrone/New()
	shots_action.Grant(src)
	rain_action.Grant(src)
	homing_action.Grant(src)
	burst_action.Grant(src)
	..()

/mob/living/simple_animal/hostile/megafauna/megadrone/OpenFire()
	if(attack_type == null)
		attack_type = rand(1, 4)
	if(attack_type == 1)
		ranged_cooldown = world.time + 40
		homing_shots(20, src)
		sleep(40)
	else if(attack_type == 2)
		ranged_cooldown = world.time + 12
		laser_rain()
		sleep(12)
	else if(attack_type == 3)
		ranged_cooldown = world.time + 40
		homing_laser(20, src)
		sleep(40)
	else if(attack_type == 4)
		ranged_cooldown = world.time + 50
		smart_blast()
		sleep(50)
	if(client == null)
		attack_type = null

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/smart_blast()
	visible_message("<span class='boldwarning'>Drone releases wave of projectiles!</span>")
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	for(var/turf/turf in range(1,get_turf(src)))
		shoot_cross_projectile(turf)
		sleep(4)

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/homing_laser(var/timer, var/caster)
	visible_message("<span class='boldwarning'>Drone scans area!</span>")
	visible_message("<span class='boldwarning'>Laser rains from the sky!</span>")
	while(timer>0)
		for(var/turf/turf in range(12,get_turf(src)))
			for(var/mob/living/L in turf.contents - caster)
				if( L.stat == DEAD)
					continue
				PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon, list(turf, src))
			if(prob(1))
				PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon, list(turf, src))
		sleep(2)
		timer--




/mob/living/simple_animal/hostile/megafauna/megadrone/proc/homing_shots(var/timer, var/caster)
	visible_message("<span class='boldwarning'>Drone scans area!</span>")
	visible_message("<span class='boldwarning'>Drone starts shooting!</span>")
	while(timer>0)
		for(var/turf/turf in range(12,get_turf(src)))
			for(var/mob/living/L in turf.contents - caster)
				if( L.stat == DEAD)
					continue
				shoot_projectile(turf)
			if(prob(1/10))
				shoot_projectile(turf)
		sleep(2)
		timer--

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/laser_rain()
	visible_message("<span class='boldwarning'>Laser rains from the sky!</span>")
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(50))
			PoolOrNew(/obj/effect/overlay/temp/drone/laser_beacon, list(turf, src))

/mob/living/simple_animal/hostile/megafauna/megadrone/proc/shoot_projectile(turf/marker)
	if(!marker || marker == loc)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/energy/drone_laser(startloc)
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
	var/obj/item/projectile/P = new /obj/item/projectile/energy/white_only/cross_laser(startloc)
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

/obj/item/projectile/energy/drone_laser
	name ="drone laser"
	icon = 'icons/mob/lavaland/related_to_drone.dmi'
	icon_state= "drone_laser"
	damage = 20
	armour_penetration = 100
	speed = 2
	eyeblur = 1
	damage_type = BURN
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

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
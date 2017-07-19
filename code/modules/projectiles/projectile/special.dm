/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion


/obj/item/projectile/ion/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, 1, 1)
	return 1


/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = FALSE)
	..()
	empulse(target, 0, 0)
	return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2)
	return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 2, 1, 0, flame_range = 3)
	return 1

/obj/item/projectile/bullet/a84mm
	name ="anti-armour rocket"
	desc = "USE A WEEL GUN"
	icon_state= "atrocket"
	damage = 80
	var/anti_armour_damage = 200
	armour_penetration = 100
	dismemberment = 100

/obj/item/projectile/bullet/a84mm/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 1, 3, 1, 0, flame_range = 4)

	if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_overall_damage(anti_armour_damage*0.75, anti_armour_damage*0.25)
	return 1

/obj/item/projectile/bullet/srmrocket
	name ="SRM-8 Rocket"
	desc = "Boom"
	icon_state = "missile"
	damage = 30
	ricochets_max = 0 //it's a MISSILE

/obj/item/projectile/bullet/srmrocket/on_hit(atom/target, blocked=0)
	..()
	if(!isliving(target)) //if the target isn't alive, so is a wall or something
		explosion(target, 0, 1, 2, 4)
	else
		explosion(target, 0, 0, 2, 4)
	return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 100


/obj/item/projectile/temp/on_hit(atom/target, blocked = FALSE)//These two could likely check temp protection on the mob
	..()
	if(isliving(target))
		var/mob/M = target
		M.bodytemperature = temperature
	return 1

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/meteor/Collide(atom/A)
	if(A == firer)
		loc = A.loc
		return
	A.ex_act(EXPLODE_HEAVY)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
	for(var/mob/M in urange(10, src))
		if(!M.stat)
			shake_camera(M, 3, 1)
	qdel(src)

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/energy/floramut/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.dna.species.id == "pod")
			C.randmuti()
			C.randmut()
			C.updateappearance()
			C.domutcheck()

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20

/obj/item/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = "sparks"
	damage = 3
	var/obj/item/weapon/gun/energy/wormhole_projector/gun
	color = "#33CCFF"

/obj/item/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"

/obj/item/projectile/beam/wormhole/New(var/obj/item/ammo_casing/energy/wormhole/casing)
	if(casing)
		gun = casing.gun

/obj/item/ammo_casing/energy/wormhole/New(var/obj/item/weapon/gun/energy/wormhole_projector/wh)
	gun = wh

/obj/item/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		var/turf/portal_destination = pick(orange(6, src))
		do_teleport(target, portal_destination)
		return ..()
	if(!gun)
		qdel(src)
	gun.create_portal(src, get_turf(src))

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	knockdown = 50

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 1)
	return 1

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 20
	range = 4
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/pressure_decrease_active = FALSE
	var/pressure_decrease = 0.25
	var/mine_range = 3 //mines this many additional tiles of rock

/obj/item/projectile/plasma/Initialize()
	. = ..()
	if(!lavaland_equipment_pressure_check(get_turf(src)))
		name = "weakened [name]"
		damage = damage * pressure_decrease
		pressure_decrease_active = TRUE

/obj/item/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return -1

/obj/item/projectile/plasma/adv
	damage = 28
	range = 5
	mine_range = 5

/obj/item/projectile/plasma/adv/mech
	damage = 40
	range = 9
	mine_range = 3

/obj/item/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 24
	range = 7
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE


/obj/item/projectile/gravityrepulse
	name = "repulsion bolt"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	hitsound = 'sound/weapons/wave.ogg'
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	color = "#33CCFF"
	var/turf/T
	var/power = 4
	var/list/thrown_items = list()

/obj/item/projectile/gravityrepulse/Initialize()
	. = ..()
	var/obj/item/ammo_casing/energy/gravityrepulse/C = loc
	if(istype(C)) //Hard-coded maximum power so servers can't be crashed by trying to throw the entire Z level's items
		power = min(C.gun.power, 15)

/obj/item/projectile/gravityrepulse/on_hit()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, power))
		if(A == src || (firer && A == src.firer) || A.anchored || thrown_items[A])
			continue
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(A, src)))
		A.throw_at(throwtarget,power+1,1)
		thrown_items[A] = A
	for(var/turf/F in range(T,power))
		new /obj/effect/temp_visual/gravpush(F)

/obj/item/projectile/gravityattract
	name = "attraction bolt"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	hitsound = 'sound/weapons/wave.ogg'
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	color = "#FF6600"
	var/turf/T
	var/power = 4
	var/list/thrown_items = list()

/obj/item/projectile/gravityattract/Initialize()
	. = ..()
	var/obj/item/ammo_casing/energy/gravityattract/C = loc
	if(istype(C)) //Hard-coded maximum power so servers can't be crashed by trying to throw the entire Z level's items
		power = min(C.gun.power, 15)

/obj/item/projectile/gravityattract/on_hit()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, power))
		if(A == src || (firer && A == src.firer) || A.anchored || thrown_items[A])
			continue
		A.throw_at(T, power+1, 1)
		thrown_items[A] = A
	for(var/turf/F in range(T,power))
		new /obj/effect/temp_visual/gravpush(F)

/obj/item/projectile/gravitychaos
	name = "gravitational blast"
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	hitsound = 'sound/weapons/wave.ogg'
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	color = "#101010"
	var/turf/T
	var/power = 4
	var/list/thrown_items = list()

/obj/item/projectile/gravitychaos/Initialize()
	. = ..()
	var/obj/item/ammo_casing/energy/gravitychaos/C = loc
	if(istype(C)) //Hard-coded maximum power so servers can't be crashed by trying to throw the entire Z level's items
		power = min(C.gun.power, 15)

/obj/item/projectile/gravitychaos/on_hit()
	. = ..()
	T = get_turf(src)
	for(var/atom/movable/A in range(T, power))
		if(A == src|| (firer && A == src.firer) || A.anchored || thrown_items[A])
			continue
		A.throw_at(get_edge_target_turf(A, pick(GLOB.cardinals)), power+1, 1)
		thrown_items[A] = A
	for(var/turf/Z in range(T,power))
		new /obj/effect/temp_visual/gravpush(Z)

/obj/effect/ebeam/curse_arm
	name = "curse arm"
	layer = LARGE_MOB_LAYER

/obj/item/projectile/curse_hand
	name = "curse hand"
	icon_state = "cursehand"
	hitsound = 'sound/effects/curse4.ogg'
	layer = LARGE_MOB_LAYER
	damage_type = BURN
	damage = 10
	knockdown = 20
	speed = 2
	range = 16
	forcedodge = TRUE
	var/datum/beam/arm
	var/handedness = 0

/obj/item/projectile/curse_hand/Initialize(mapload)
	. = ..()
	handedness = prob(50)
	update_icon()

/obj/item/projectile/curse_hand/update_icon()
	icon_state = "[icon_state][handedness]"

/obj/item/projectile/curse_hand/fire(setAngle)
	if(starting)
		arm = starting.Beam(src, icon_state = "curse[handedness]", time = INFINITY, maxdistance = INFINITY, beam_type=/obj/effect/ebeam/curse_arm)
	..()

/obj/item/projectile/curse_hand/prehit(atom/target)
	if(target == original)
		forcedodge = FALSE
	else if(!isturf(target))
		return FALSE
	return ..()

/obj/item/projectile/curse_hand/Destroy()
	if(arm)
		arm.End()
		arm = null
	if(forcedodge)
		playsound(src, 'sound/effects/curse3.ogg', 25, 1, -1)
	var/turf/T = get_step(src, dir)
	new/obj/effect/temp_visual/dir_setting/curse/hand(T, dir, handedness)
	for(var/obj/effect/temp_visual/dir_setting/curse/grasp_portal/G in starting)
		qdel(G)
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading(starting, dir)
	var/datum/beam/D = starting.Beam(T, icon_state = "curse[handedness]", time = 32, maxdistance = INFINITY, beam_type=/obj/effect/ebeam/curse_arm, beam_sleep_time = 1)
	for(var/b in D.elements)
		var/obj/effect/ebeam/B = b
		animate(B, alpha = 0, time = 32)
	return ..()

/obj/item/projectile/hallucination
	name = "bullet"
	icon = null
	icon_state = null
	hitsound = ""
	suppressed = TRUE
	ricochets_max = 0
	ricochet_chance = 0
	damage = 0
	nodamage = TRUE
	projectile_type = /obj/item/projectile/hallucination
	log_override = TRUE
	var/hal_icon_state
	var/image/fake_icon
	var/mob/living/carbon/hal_target
	var/hal_fire_sound
	var/hal_hitsound
	var/hal_hitsound_wall
	var/hal_impact_effect
	var/hal_impact_effect_wall
	var/hit_duration
	var/hit_duration_wall

/obj/item/projectile/hallucination/fire()
	..()
	fake_icon = image('icons/obj/projectiles.dmi', src, hal_icon_state, ABOVE_MOB_LAYER)
	if(hal_target.client)
		hal_target.client.images += fake_icon

/obj/item/projectile/hallucination/Destroy()
	if(hal_target.client)
		hal_target.client.images -= fake_icon
	QDEL_NULL(fake_icon)
	return ..()

/obj/item/projectile/hallucination/Collide(atom/A)
	if(!ismob(A))
		if(hal_hitsound_wall)
			hal_target.playsound_local(loc, hal_hitsound_wall, 40, 1)
		if(hal_impact_effect_wall)
			spawn_hit(A, TRUE)
	else if(A == hal_target)
		if(hal_hitsound)
			hal_target.playsound_local(A, hal_hitsound, 100, 1)
		target_on_hit(A)
	qdel(src)
	return TRUE

/obj/item/projectile/hallucination/proc/target_on_hit(mob/M)
	if(M == hal_target)
		to_chat(hal_target, "<span class='userdanger'>[M] is hit by \a [src] in the chest!</span>")
		hal_apply_effect()
	else if(M in view(hal_target))
		to_chat(hal_target, "<span class='danger'>[M] is hit by \a [src] in the chest!!</span>")
	if(damage_type == BRUTE)
		var/splatter_dir = dir
		if(starting)
			splatter_dir = get_dir(starting, get_turf(M))
		spawn_blood(M, splatter_dir)
	else if(hal_impact_effect)
		spawn_hit(M, FALSE)

/obj/item/projectile/hallucination/proc/spawn_blood(mob/M, set_dir)
	set waitfor = 0
	if(!hal_target.client)
		return

	var/splatter_icon_state
	if(set_dir in GLOB.diagonals)
		splatter_icon_state = "splatter[pick(1, 2, 6)]"
	else
		splatter_icon_state = "splatter[pick(3, 4, 5)]"

	var/image/blood = image('icons/effects/blood.dmi', M, splatter_icon_state, ABOVE_MOB_LAYER)
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	hal_target.client.images += blood
	animate(blood, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = 5)
	sleep(5)
	hal_target.client.images -= blood
	qdel(blood)

/obj/item/projectile/hallucination/proc/spawn_hit(atom/A, is_wall)
	set waitfor = 0
	if(!hal_target.client)
		return

	var/image/hit_effect = image('icons/effects/blood.dmi', A, is_wall ? hal_impact_effect_wall : hal_impact_effect, ABOVE_MOB_LAYER)
	hit_effect.pixel_x = A.pixel_x + rand(-4,4)
	hit_effect.pixel_y = A.pixel_y + rand(-4,4)
	hal_target.client.images += hit_effect
	sleep(is_wall ? hit_duration_wall : hit_duration)
	hal_target.client.images -= hit_effect
	qdel(hit_effect)


/obj/item/projectile/hallucination/proc/hal_apply_effect()
	return

/obj/item/projectile/hallucination/bullet
	name = "bullet"
	hal_icon_state = "bullet"
	hal_fire_sound = "gunshot"
	hal_hitsound = 'sound/weapons/pierce.ogg'
	hal_hitsound_wall = "ricochet"
	hal_impact_effect = "impact_bullet"
	hal_impact_effect_wall = "impact_bullet"
	hit_duration = 5
	hit_duration_wall = 5

/obj/item/projectile/hallucination/bullet/hal_apply_effect()
	hal_target.adjustStaminaLoss(60)

/obj/item/projectile/hallucination/laser
	name = "laser"
	damage_type = BURN
	hal_icon_state = "laser"
	hal_fire_sound = 'sound/weapons/laser.ogg'
	hal_hitsound = 'sound/weapons/sear.ogg'
	hal_hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	hal_impact_effect = "impact_laser"
	hal_impact_effect_wall = "impact_laser_wall"
	hit_duration = 4
	hit_duration_wall = 10
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/hallucination/laser/hal_apply_effect()
	hal_target.adjustStaminaLoss(20)
	hal_target.blur_eyes(2)

/obj/item/projectile/hallucination/taser
	name = "electrode"
	damage_type = BURN
	hal_icon_state = "spark"
	color = "#FFFF00"
	hal_fire_sound = 'sound/weapons/taser.ogg'
	hal_hitsound = 'sound/weapons/taserhit.ogg'
	hal_hitsound_wall = null
	hal_impact_effect = null
	hal_impact_effect_wall = null

/obj/item/projectile/hallucination/taser/hal_apply_effect()
	hal_target.Knockdown(100)
	hal_target.stuttering += 20
	if(hal_target.dna && hal_target.dna.check_mutation(HULK))
		hal_target.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
	else if(hal_target.status_flags & CANKNOCKDOWN)
		addtimer(CALLBACK(hal_target, /mob/living/carbon.proc/do_jitter_animation, 20), 5)

/obj/item/projectile/hallucination/disabler
	name = "disabler beam"
	damage_type = STAMINA
	hal_icon_state = "omnilaser"
	hal_fire_sound = 'sound/weapons/taser2.ogg'
	hal_hitsound = 'sound/weapons/tap.ogg'
	hal_hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	hal_impact_effect = "impact_laser_blue"
	hal_impact_effect_wall = null
	hit_duration = 4
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/hallucination/disabler/hal_apply_effect()
	hal_target.adjustStaminaLoss(25)

/obj/item/projectile/hallucination/ebow
	name = "bolt"
	damage_type = TOX
	hal_icon_state = "cbbolt"
	hal_fire_sound = 'sound/weapons/genhit.ogg'
	hal_hitsound = null
	hal_hitsound_wall = null
	hal_impact_effect = null
	hal_impact_effect_wall = null

/obj/item/projectile/hallucination/ebow/hal_apply_effect()
	hal_target.Knockdown(100)
	hal_target.stuttering += 5
	hal_target.adjustStaminaLoss(8)

/obj/item/projectile/hallucination/change
	name = "bolt of change"
	damage_type = BURN
	hal_icon_state = "ice_1"
	hal_fire_sound = 'sound/magic/staff_change.ogg'
	hal_hitsound = null
	hal_hitsound_wall = null
	hal_impact_effect = null
	hal_impact_effect_wall = null

/obj/item/projectile/hallucination/change/hal_apply_effect()
	new /datum/hallucination/self_delusion(hal_target, TRUE, wabbajack = FALSE)

/obj/item/projectile/hallucination/death
	name = "bolt of death"
	damage_type = BURN
	hal_icon_state = "pulse1_bl"
	hal_fire_sound = 'sound/magic/wandodeath.ogg'
	hal_hitsound = null
	hal_hitsound_wall = null
	hal_impact_effect = null
	hal_impact_effect_wall = null

/obj/item/projectile/hallucination/death/hal_apply_effect()
	new /datum/hallucination/death(hal_target, TRUE)

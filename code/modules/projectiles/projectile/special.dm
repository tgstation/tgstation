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

/obj/item/projectile/meteor/Bump(atom/A, yes)
	if(!yes) //prevents multi bumps.
		return
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

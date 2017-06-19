/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ion


/obj/item/projectile/ion/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 1, 1)
	return 1


/obj/item/projectile/ion/weak

/obj/item/projectile/ion/weak/on_hit(atom/target, blocked = 0)
	..()
	empulse(target, 0, 0)
	return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 2)
	return 1

/obj/item/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon_state= "bolter"
	damage = 60

/obj/item/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0)
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

/obj/item/projectile/bullet/a84mm/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 1, 3, 1, 0, flame_range = 4)

	if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(anti_armour_damage)
	if(istype(target, /mob/living/silicon))
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


/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
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
	A.ex_act(2)
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

/obj/item/projectile/energy/floramut/on_hit(atom/target, blocked = 0)
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

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0)
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
	gun.create_portal(src)

/obj/item/projectile/bullet/frag12
	name ="explosive slug"
	damage = 25
	knockdown = 50

/obj/item/projectile/bullet/frag12/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, -1, 0, 1)
	return 1

/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 5
	range = 4
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/mine_range = 3 //mines this many additional tiles

/obj/item/projectile/plasma/Initialize()
	. = ..()
	var/turf/proj_turf = get_turf(src)
	if(!isturf(proj_turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure < 60)
			name = "full strength [name]"
			damage *= 4

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
	damage = 7
	range = 5
	mine_range = 5

/obj/item/projectile/plasma/adv/mech
	damage = 10
	range = 9
	mine_range = 3

/obj/item/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 6
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
		A.throw_at(get_edge_target_turf(A, pick(GLOB.cardinal)), power+1, 1)
		thrown_items[A] = A
	for(var/turf/Z in range(T,power))
		new /obj/effect/temp_visual/gravpush(Z)


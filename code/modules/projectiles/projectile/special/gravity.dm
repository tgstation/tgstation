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
	var/obj/item/ammo_casing/energy/gravity/repulse/C = loc
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
	var/obj/item/ammo_casing/energy/gravity/attract/C = loc
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
	var/obj/item/ammo_casing/energy/gravity/chaos/C = loc
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

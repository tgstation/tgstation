/*
	Beam turrets that lock on with hitscan projectiles and deal constant damage to their target
*/

/obj/structure/infection/turret/beam
	name = "infection beam turret"
	desc = "A solid wall with a radiating material on the inside."
	icon = 'icons/mob/infection/crystaline_infection_medium.dmi'
	icon_state = "crystalhitscan-layer"
	pixel_x = -16
	pixel_y = -4
	max_integrity = 150
	point_return = 10
	upgrade_subtype = /datum/infection_upgrade/beamturret
	scan_range = 4 // range to search for targets
	projectile_type = /obj/item/projectile/bullet/infection/beam // the bullet fired for this turret
	projectile_sound = null
	hit_sound = 'sound/effects/hitscan_zap.ogg'
	// the actual beam of the turret, deleted when not firing
	var/datum/beam/B

/obj/structure/infection/turret/beam/Destroy()
	qdel(B)
	return ..()

/obj/structure/infection/turret/beam/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/turret_base = mutable_appearance('icons/mob/infection/crystaline_infection_medium.dmi', "crystalhitscan-base")
	var/mutable_appearance/infection_base = mutable_appearance('icons/mob/infection/infection.dmi', "normal")
	turret_base.dir = dir
	infection_base.pixel_x = -pixel_x
	infection_base.pixel_y = -pixel_y
	underlays += turret_base
	underlays += infection_base

/obj/structure/infection/turret/beam/Life()
	qdel(B)
	. = ..()

/obj/structure/infection/turret/beam/shootAt(atom/movable/target)
	. = ..()
	var/turf/T = get_turf(src)
	if(T)
		B = T.Beam(target, icon_state="lightning-hitscan", icon='icons/mob/infection/crystal_effect.dmi', time=INFINITY, maxdistance=scan_range+1, beam_type=/obj/effect/ebeam/infection_beam, beam_sleep_time=1)

/obj/item/projectile/bullet/infection/beam
	name = "lightning beam"
	damage = 10
	damage_type = BURN
	pass_flags = PASSTABLE | PASSBLOB | PASSGLASS | PASSGRILLE | PASSMOB | PASSCLOSEDTURF
	hitscan = TRUE
	flag = "laser"
	impact_effect_type = null

/obj/effect/ebeam/infection_beam
	name = "lightning beam"
	desc = "An extremely painful arc of lightning that seems to stick to anything it touches."
	mouse_opacity = MOUSE_OPACITY_ICON
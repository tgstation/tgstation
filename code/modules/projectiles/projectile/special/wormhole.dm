/obj/item/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = "sparks"
	damage = 3
	var/obj/item/gun/energy/wormhole_projector/gun
	color = "#33CCFF"

/obj/item/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"

/obj/item/projectile/beam/wormhole/Initialize(mapload, obj/item/ammo_casing/energy/wormhole/casing)
	. = ..()
	if(casing)
		gun = casing.gun

/obj/item/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		var/turf/portal_destination = pick(orange(6, src))
		do_teleport(target, portal_destination)
		return ..()
	if(!gun)
		qdel(src)
	gun.create_portal(src, get_turf(src))

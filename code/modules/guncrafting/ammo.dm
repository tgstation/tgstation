/obj/item/ammo_casing/energy/prototype
	name = "prototype energy lens"
	projectile_type = /obj/item/projectile/energy/prototype
	e_cost = 0
	var/datum/gun/GCdatum

/obj/item/ammo_casing/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread)
	GCdatum.projectiles += BB
	BB.GCdatum = GCdatum
	if(!GC.on_fire(target, user, params, distro, quiet, zone_override, spread))
		return FALSE
	. = ..(target, user, params, distro, quiet, zone_override, spread)

/obj/item/projectile/energy/prototype
	name = "prototype energy beam"
	desc = "What the fuck does this even do?"
	damage = 0
	nodamage = FALSE
	icon = 'icons/obj/guncrafting/energy/projectile.dm'
	var/datum/gun/GCdatum

/obj/item/projectile/energy/prototype/Range()
	if(!GCdatum.on_range(get_turf(src)))
		. = ..()

/obj/item/projectile/energy/prototype/on_hit(atom/target, blocked = 0)
	if(GCdatum.on_hit(atom/target, blocked = 0))
		. = ..(atom/target, blocked = 0)

/obj/item/projectile/energy/prototype/vol_by_damage()
	return GCdatum.volume()

/obj/item/projectile/energy/prototype/Destroy()
	GCdatum.projectiles -= src
	. = ..()

/obj/item/projectile/energy/prototype/preparePixelProjectile(atom/target, var/turf/targloc, mob/living/user, params, spread)
	. = ..(target, targloc, user, params, GCdatum.spread())

/obj/item/projectile/energy/tesla
	name = "tesla bolt"
	icon_state = "tesla_projectile"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	var/chain

/obj/item/projectile/energy/tesla/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "lightning[rand(1, 12)]", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/item/projectile/energy/tesla/Destroy()
	qdel(chain)
	return ..()

/obj/item/projectile/energy/tesla/revolver
	name = "energy orb"

/obj/item/projectile/energy/tesla/revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(target, 3, 10000)
	qdel(src)

/obj/item/projectile/energy/tesla/cannon
	name = "tesla orb"

/obj/item/projectile/energy/tesla/cannon/on_hit(atom/target)
	. = ..()
	tesla_zap(target, 3, 10000, explosive = FALSE, stun_mobs = FALSE)
	qdel(src)

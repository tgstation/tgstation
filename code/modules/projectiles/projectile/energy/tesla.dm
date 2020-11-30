/obj/projectile/energy/tesla
	name = "tesla bolt"
	icon_state = "tesla_projectile"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 3
	var/power = 10000

/obj/projectile/energy/tesla/on_hit(atom/target)
	. = ..()
	tesla_zap(src, zap_range, power, zap_flags)
	qdel(src)

/obj/projectile/energy/tesla/process()
	. = ..()
	//Many coders have given their blood for this speed
	tesla_zap(src, zap_range, power, zap_flags)

/obj/projectile/energy/tesla/revolver
	name = "energy orb"

/obj/projectile/energy/tesla/cannon
	name = "tesla orb"
	power = 20000
	damage = 15 //Mech man big

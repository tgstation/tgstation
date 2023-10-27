/obj/projectile/energy/tesla
	name = "tesla bolt"
	icon_state = "tesla_projectile"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN
	var/zap_range = 3
	var/power = 4e6

/obj/projectile/energy/tesla/on_hit(atom/target, blocked = 0, pierce_hit)
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
	power = 8e6
	damage = 15 //Mech man big

/obj/projectile/energy/tesla_cannon
	name = "tesla orb"
	icon_state = "ice_1"
	damage = 0
	speed = 1.5
	var/shock_damage = 5

/obj/projectile/energy/tesla_cannon/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		victim.electrocute_act(shock_damage, src, siemens_coeff = 1, flags = SHOCK_NOSTUN|SHOCK_TESLA)

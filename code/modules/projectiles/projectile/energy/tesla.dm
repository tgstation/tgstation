/obj/projectile/energy/tesla
	name = "tesla bolt"
	icon_state = "tesla_projectile"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN
	var/zap_range = 3
	var/power = 1e4

/obj/projectile/energy/tesla/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	tesla_zap(source = src, zap_range = zap_range, power = power, cutoff = 1e3, zap_flags = zap_flags)
	qdel(src)

/obj/projectile/energy/tesla/process()
	. = ..()
	//Many coders have given their blood for this speed
	tesla_zap(source = src, zap_range = zap_range, power = power, cutoff = 1e3, zap_flags = zap_flags)

/obj/projectile/energy/tesla/revolver
	name = "energy orb"

/obj/projectile/energy/tesla/cannon
	name = "tesla orb"
	power = 2e4
	damage = 15 //Mech man big

/obj/projectile/energy/tesla_cannon
	name = "tesla bolt"
	icon_state = null
	hitscan = TRUE
	damage = 5
	var/shock_damage = 10
	var/datum/beam/chain

/obj/projectile/energy/tesla_cannon/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "lightning[rand(1, 12)]", time = 0.5 SECONDS)
	return ..()

/obj/projectile/energy/tesla_cannon/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		victim.electrocute_act(shock_damage, src, siemens_coeff = 1, flags = SHOCK_NOSTUN|SHOCK_TESLA)

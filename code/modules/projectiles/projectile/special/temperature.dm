/obj/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = FALSE
	flag = "energy"
	var/temperature = -50 // reduce the body temperature by 50 points

/obj/projectile/temp/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/hit_mob = target
		var/thermal_protection = 1 // The inverse of the amount of protection

		if(temperature > 0) // The projectile is hot
			thermal_protection -= hit_mob.get_heat_protection(hit_mob.bodytemperature + temperature)
		else // The projectile was cold
			thermal_protection -= hit_mob.get_cold_protection(hit_mob.bodytemperature + temperature)

		// The new body temperature is adjusted by 100-blocked % of the bullet's effect temperature
		// Reduce the amount of the effect temperature change based on the amount of insulation the mob is wearing
		hit_mob.adjust_bodytemperature(((100 - blocked) / 100) * (thermal_protection * temperature))

	else if(isliving(target))
		var/mob/living/L = target
		// the new body temperature is adjusted by 100-blocked % of the bullet's effect temperature
		L.adjust_bodytemperature(((100 - blocked) / 100) * temperature)

/obj/projectile/temp/hot
	name = "heat beam"
	temperature = 100 // Raise the body temp by 100 points

/obj/projectile/temp/cryo
	name = "cryo beam"
	range = 3
	temperature = -240 // Single slow shot reduces temp greatly

/obj/projectile/temp/cryo/on_range()
	var/turf/T = get_turf(src)
	if(isopenturf(T))
		var/turf/open/O = T
		O.freon_gas_act()
	return ..()

/obj/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	armor_flag = ENERGY
	var/temperature = -30 // reduce the body temperature by 30 points

/obj/projectile/temp/is_hostile_projectile()
	return temperature != 0 // our damage is done by cooling or heating (casting to boolean here)

/obj/projectile/temp/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/hit_mob = target
		var/thermal_protection = 1 - hit_mob.get_insulation_protection(hit_mob.bodytemperature + temperature)

		// The new body temperature is adjusted by the bullet's effect temperature
		// Reduce the amount of the effect temperature change based on the amount of insulation the mob is wearing
		hit_mob.adjust_bodytemperature((thermal_protection * temperature) + temperature)
		hit_mob.apply_status_effect(/datum/status_effect/ineffective_thermoregulation)

	else if(isliving(target))
		var/mob/living/L = target
		// the new body temperature is adjusted by the bullet's effect temperature
		L.adjust_bodytemperature((1 - blocked) * temperature)

	if(isobj(target))
		var/obj/objectification = target

		if(objectification.reagents)
			var/datum/reagents/reagents = objectification.reagents
			reagents?.expose_temperature(temperature)

/obj/projectile/temp/hot
	name = "heat beam"
	icon_state = "lava"
	temperature = 50 // Raise the body temp by 50 points

/obj/projectile/temp/hot/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()

	if(isliving(target))
		var/mob/living/living_target = target
		living_target.adjust_wet_stacks(-10)

/obj/projectile/temp/cryo
	name = "cryo beam"
	range = 9
	temperature = -350 // Single slow shot reduces temp greatly

/obj/projectile/temp/cryo/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()

	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/freezing_blast)

/obj/projectile/temp/cryo/on_range()
	var/turf/T = get_turf(src)
	if(isopenturf(T))
		var/turf/open/O = T
		O.freeze_turf()
	return ..()

/obj/projectile/temp/pyro
	name = "hot beam"
	icon_state = "firebeam" // sets on fire, diff sprite!
	range = 9
	temperature = 350

/obj/projectile/temp/pyro/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!.)
		return

	if(isobj(target))
		var/obj/objectification = target

		if(objectification.resistance_flags & ON_FIRE) //Don't burn something already on fire
			return

		objectification.fire_act(temperature)

		return

	if(isliving(target))
		var/mob/living/living_target = target
		living_target.adjust_fire_stacks(2)
		living_target.ignite_mob()

/obj/projectile/temp/pyro/on_range()
	var/turf/location = get_turf(src)
	new /obj/effect/hotspot(location)
	location.hotspot_expose(700, 50, 1)
	return ..()

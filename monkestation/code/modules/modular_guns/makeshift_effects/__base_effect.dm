/datum/makeshift_effect
	var/effect_name = "Generic Makeshift Mishap"
	var/effect_desc = "Causes a puff of smoke at the guns location."

	var/trigger_chance = 25

/datum/makeshift_effect/proc/attempt_trigger(atom/target)
	if(prob(trigger_chance))
		do_smoke(range = 1, holder = target, location = get_turf(target), smoke_type = /obj/effect/particle_effect/fluid/smoke/quick)
		return TRUE
	return FALSE

/obj/effect/particle_effect/fluid/smoke/quick
	lifetime = 1.5 SECONDS

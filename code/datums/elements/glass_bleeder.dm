/// Drop glass shards when taking damage
/datum/element/glass_bleeder
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/glass_bleeder/Attach(atom/movable/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, PROC_REF(on_adjust_brute_damage))

/datum/element/glass_bleeder/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/element/glass_bleeder/proc/on_adjust_brute_damage(mob/living/liver, damage_type, amount)
	SIGNAL_HANDLER

	if(amount > 20)
		new /obj/effect/spawner/random/glass_shards ((get_turf(liver)))
		playsound(liver, SFX_SHATTER, 60)
	else
		new /obj/effect/spawner/random/glass_debris (get_turf(liver))

/// Drop glass shards when taking damage
/datum/element/glass_bleeder
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	/// Grumble... we need to track this...
	var/last_health

/datum/element/glass_bleeder/Attach(atom/movable/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	var/mob/living/liver = target
	last_health = liver.health

	RegisterSignal(target, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

/datum/element/glass_bleeder/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/element/glass_bleeder/proc/on_health_update(mob/living/liver)
	SIGNAL_HANDLER

	var/amount = last_health - liver.health

	if(amount <= 0)
		return

	if(amount > 20)
		new /obj/effect/spawner/random/glass_shards ((get_turf(liver)))
		playsound(liver, SFX_SHATTER, 60)
	else
		new /obj/effect/spawner/random/glass_debris (get_turf(liver))

	last_health = liver.health

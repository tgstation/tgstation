/// Drop glass shards when taking damage
/datum/element/glass_bleeder
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/glass_bleeder/Attach(atom/movable/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_apply_damage))

/datum/element/glass_bleeder/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_MOB_APPLY_DAMAGE )
	return ..()

/datum/element/glass_bleeder/proc/on_apply_damage(mob/living/liver, amount, damage_type)
	SIGNAL_HANDLER

	if(damage_type != BRUTE)
		return

	if(amount > 20)
		new /obj/effect/spawner/random/glass_shards ((get_turf(liver)))
		playsound(liver, SFX_SHATTER, 60)
	else
		new /obj/effect/spawner/random/glass_debris (get_turf(liver))

/datum/gizmo_effect/bone_breaker/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	var/list/victims = list()
	for(var/mob/living/loser in orange(1, holder))
		victims += loser

	if(!victims.len)
		return

	var/mob/living/victim = pick(victims)
	holder.forceMove(get_turf(victim))
	playsound(victim, 'sound/effects/wounds/crack2.ogg', 70, TRUE)

	victim.apply_damage(60, BRUTE, wound_bonus = 100, sharpness = NONE)
	victim.Stun(2 SECONDS)
	victim.Knockdown(5 SECONDS)

	victim.emote("scream")

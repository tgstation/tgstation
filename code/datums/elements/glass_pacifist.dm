/// Prevents the living from attacking windows
/datum/element/glass_pacifist

/datum/element/glass_pacifist/Attach(datum/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_ATTACK_ATOM, PROC_REF(check_if_glass))

/datum/element/glass_pacifist/proc/check_if_glass(mob/living/owner, atom/hit)
	SIGNAL_HANDLER

	if(istype(hit, /obj/structure/window))
		owner.visible_message(span_notice("\The [owner] nuzzles \the [hit]!"))
		new /obj/effect/temp_visual/heart(hit.loc)
		return COMPONENT_CANCEL_ATTACK_CHAIN

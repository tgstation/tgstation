/// Prevents the living from attacking windows
/datum/component/glass_pacifist

/datum/component/glass_pacifist/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_LIVING_ATTACK_ATOM, PROC_REF(check_if_glass))

/datum/component/glass_pacifist/proc/check_if_glass(mob/living/parent, atom/hit)
	SIGNAL_HANDLER

	if(istype(hit, /obj/structure/window))
		parent.visible_message(span_notice("[parent.name] nuzzles the [hit.name]!"))
		new /obj/effect/temp_visual/heart(hit.loc)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/acme_wall
	var/overlay

/datum/component/acme_wall/Initialize(mutable_appearance/overlay)
	if(!istype(parent, /turf/closed/wall))
		return COMPONENT_INCOMPATIBLE
	var/turf/closed/wall/parent_wall = parent
	RegisterSignal(parent_wall, COMSIG_ATOM_BUMPED, PROC_REF(on_bump))
	RegisterSignal(parent_wall, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	src.overlay = overlay
	parent_wall.add_overlay(overlay)

/datum/component/acme_wall/Destroy()
	var/turf/closed/wall/wall = parent
	wall.cut_overlay(overlay)
	return ..()

/datum/component/acme_wall/proc/on_bump(datum/source, atom/bumped_atom)
	if(!istype(bumped_atom,/mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = bumped_atom
	H.Knockdown(5)
	playsound(H.loc, 'sound/effects/bodyfall1.ogg', 50, TRUE)
	H.visible_message(span_warning("[H] bumps into [source] and gets knocked down!"))

/datum/component/acme_wall/proc/on_clean(datum/source)
	qdel(src)

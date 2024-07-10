/// Component to make an item temporarily break glass
/datum/component/temporary_glass_shatterer/Initialize(...)
	. = ..()

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_tap))

/datum/component/temporary_glass_shatterer/proc/on_tap(obj/item/parent, mob/tapper, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/structure/window))
		var/obj/structure/grille/grille = locate(/obj/structure/grille) in get_turf(target)
		if(grille?.shock(tapper, 100))
			return

		var/obj/structure/window/window = target
		window.temporary_shatter()
	else if(istype(target, /obj/structure/grille))
		var/obj/structure/grille/grille = target
		if(grille.shock(tapper, 100))
			return

		grille.temporary_shatter()
	else
		return
	return COMPONENT_CANCEL_ATTACK_CHAIN

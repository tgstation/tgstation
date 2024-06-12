/*
 * A component to allow us to collect ore
 */
/datum/element/ore_collecting


/datum/element/ore_collecting/Attach(datum/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(collect_ore))

/datum/element/ore_collecting/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)

/datum/element/ore_collecting/proc/collect_ore(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/item/stack/ore))
		return

	var/atom/movable/movable_target = target
	movable_target.forceMove(source)
	return COMPONENT_HOSTILE_NO_ATTACK

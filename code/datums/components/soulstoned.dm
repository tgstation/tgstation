//adds godmode while in the container, prevents moving, and clears these effects up after leaving the stone
/datum/component/soulstoned
	var/atom/movable/container

/datum/component/soulstoned/Initialize(atom/movable/container)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/stoned = parent

	src.container = container

	stoned.forceMove(container)
	stoned.fully_heal()
	stoned.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)
	stoned.status_flags |= GODMODE

	RegisterSignal(stoned, COMSIG_MOVABLE_MOVED, PROC_REF(free_prisoner))

/datum/component/soulstoned/proc/free_prisoner()
	SIGNAL_HANDLER

	var/mob/living/stoned = parent
	if(stoned.loc != container)
		qdel(src)

/datum/component/soulstoned/UnregisterFromParent()
	var/mob/living/stoned = parent
	stoned.status_flags &= ~GODMODE
	stoned.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)

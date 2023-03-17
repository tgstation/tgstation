//adds godmode while in the container, prevents moving, and clears these effects up after leaving the stone
/datum/component/soulstoned
	var/atom/movable/container

/datum/component/soulstoned/Initialize(atom/movable/container)
	if(!isanimal(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/simple_animal/S = parent

	src.container = container

	S.forceMove(container)
	S.fully_heal()
	S.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)
	S.status_flags |= GODMODE

	RegisterSignal(S, COMSIG_MOVABLE_MOVED, PROC_REF(free_prisoner))

/datum/component/soulstoned/proc/free_prisoner()
	SIGNAL_HANDLER

	var/mob/living/simple_animal/S = parent
	if(S.loc != container)
		qdel(src)

/datum/component/soulstoned/UnregisterFromParent()
	var/mob/living/simple_animal/S = parent
	S.status_flags &= ~GODMODE
	S.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), SOULSTONE_TRAIT)

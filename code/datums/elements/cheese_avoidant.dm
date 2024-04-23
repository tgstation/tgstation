/**
 * ### cheese avoidant element!
 *
 * Non bespoke element (1 in existence) that makes tough mobs ignore cheap ways to die/get removed
 */
/datum/element/cheese_avoidant

/datum/element/cheese_avoidant/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
	RegisterSignal(target, COMSIG_LIVING_PRE_GIBBED, PROC_REF(on_pre_gib))
	RegisterSignal(target, COMSIG_LIVING_PRE_DUSTED, PROC_REF(on_pre_dust))

/datum/element/cheese_avoidant/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(
		COMSIG_MOVABLE_PRE_MOVE,
		COMSIG_LIVING_PRE_GIBBED,
		COMSIG_LIVING_PRE_DUSTED
	))

///Safety check to stay out of nullspace, nullspacing is... i mean, you can't brie serious
/datum/element/cheese_avoidant/proc/on_pre_move(mob/living/uncheesed, atom/destination)
	if(!destination)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

///Safety check to not get gibbed unless dead, gibbing is too gouda to be true
/datum/element/cheese_avoidant/proc/on_pre_gib(mob/living/uncheesed, drop_bitflags)
	if(uncheesed.health > 0)
		return COMPONENT_NO_GIB

///Safety check to not get dusted unless dead or firsted, dusting is a little havarti-handed for a single mob
/datum/element/cheese_avoidant/proc/on_pre_dust(mob/living/uncheesed, just_ash, drop_items, force)
	if(uncheesed.health > 0)
		return COMPONENT_NO_DUST

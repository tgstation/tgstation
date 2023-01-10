/**
 * # Trait Loc Element
 *
 * Adds a trait to the movable's loc, and handles relocating the trait if the movable itself moves.
 */
/datum/element/trait_loc
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY // handles if our movable is deleted
	argument_hash_start_idx = 2
	/// What trait to apply to the movable's loc.
	var/trait_to_give

/datum/element/trait_loc/Attach(atom/movable/target, trait_to_give)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.trait_to_give = trait_to_give

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_relocated))
	if(target.loc)
		ADD_TRAIT(target.loc, trait_to_give, REF(target))

/datum/element/trait_loc/Detach(atom/movable/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	if(source.loc)
		REMOVE_TRAIT(source.loc, trait_to_give, REF(source))

/datum/element/trait_loc/proc/on_movable_relocated(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER

	REMOVE_TRAIT(old_loc, trait_to_give, REF(source))
	if(source.loc)
		ADD_TRAIT(source.loc, trait_to_give, REF(source))

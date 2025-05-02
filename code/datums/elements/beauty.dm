/**
 * Beauty element. It makes the indoor area the parent is in prettier or uglier depending on the beauty var value.
 * Clean and well decorated areas lead to positive moodlets for passerbies;
 * Shabbier, dirtier ones lead to negative moodlets EXCLUSIVE to characters with the snob quirk.
 */
/datum/element/beauty
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	var/beauty = 0
	/**
	  * Assoc list of atoms as keys and number of time the same element instance has been attached to them as assoc value.
	  * So things don't get odd with same-valued yet dissimilar beauty modifiers being added to the same atom.
	  */
	var/beauty_counter = list()

/datum/element/beauty/Attach(datum/target, beauty)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	src.beauty = beauty

	var/area/current_area = get_area(target)
	var/beauty_active = TRUE
	if(ismovable(target))
		var/atom/movable/mov_target = target
		var/is_item = isitem(mov_target)
		beauty_active = !is_item || isturf(mov_target.loc)
		if(!beauty_counter[target])
			if(is_item)
				RegisterSignal(mov_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_item_moved))
			if(beauty_active)
				mov_target.become_area_sensitive(BEAUTY_ELEMENT_TRAIT)
				RegisterSignal(mov_target, COMSIG_ENTER_AREA, PROC_REF(enter_area))
				RegisterSignal(mov_target, COMSIG_EXIT_AREA, PROC_REF(exit_area))

	beauty_counter[target]++

	if(current_area && !current_area.outdoors && beauty_active)
		current_area.totalbeauty += beauty
		current_area.update_beauty()

/datum/element/beauty/proc/enter_area(datum/source, area/new_area)
	SIGNAL_HANDLER

	if(new_area.outdoors || HAS_TRAIT(source, TRAIT_BEAUTY_APPLIED))
		return
	new_area.totalbeauty += beauty * beauty_counter[source]
	new_area.update_beauty()
	ADD_TRAIT(source, TRAIT_BEAUTY_APPLIED, INNATE_TRAIT)

/datum/element/beauty/proc/exit_area(datum/source, area/old_area)
	SIGNAL_HANDLER

	if(old_area.outdoors || !HAS_TRAIT(source, TRAIT_BEAUTY_APPLIED))
		return
	old_area.totalbeauty -= beauty * beauty_counter[source]
	old_area.update_beauty()
	REMOVE_TRAIT(source, TRAIT_BEAUTY_APPLIED, INNATE_TRAIT)

///Items only contribute to beauty while not inside other objects or mobs (e.g on the floor, on a table etc.).
/datum/element/beauty/proc/on_item_moved(obj/item/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER

	var/is_old_turf = isturf(old_loc)
	if(!is_old_turf && isturf(source.loc))
		source.become_area_sensitive(BEAUTY_ELEMENT_TRAIT)
		RegisterSignal(source, COMSIG_ENTER_AREA, PROC_REF(enter_area), TRUE)
		RegisterSignal(source, COMSIG_EXIT_AREA, PROC_REF(exit_area), TRUE)
		enter_area(source, get_area(source.loc))
	else if(is_old_turf && !isturf(source.loc))
		source.lose_area_sensitivity(BEAUTY_ELEMENT_TRAIT)
		UnregisterSignal(source, list(COMSIG_ENTER_AREA, COMSIG_EXIT_AREA))
		exit_area(source, get_area(old_loc))

/datum/element/beauty/Detach(atom/source)
	if(!beauty_counter[source])
		return ..()

	var/area/current_area = (!isitem(source) || isturf(source.loc)) ? get_area(source) : null
	if(!QDELETED(source))//lower the 'counter' down by one, update the area, and call parent if it's reached zero.
		beauty_counter[source]--
		if(current_area && !current_area.outdoors)
			current_area.totalbeauty -= beauty
			current_area.update_beauty()
		if(beauty_counter[source])
			return
	else if(current_area)
		exit_area(source, current_area)

	UnregisterSignal(source, list(COMSIG_ENTER_AREA, COMSIG_EXIT_AREA, COMSIG_MOVABLE_MOVED))
	beauty_counter -= source
	var/atom/movable/movable_source = source
	if(istype(movable_source))
		movable_source.lose_area_sensitivity(BEAUTY_ELEMENT_TRAIT)

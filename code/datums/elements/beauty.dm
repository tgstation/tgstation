/**
 * Beauty element. It makes the indoor area the parent is in prettier or uglier depending on the beauty var value.
 * Clean and well decorated areas lead to positive moodlets for passerbies;
 * Shabbier, dirtier ones lead to negative moodlets EXCLUSIVE to characters with the snob quirk.
 */
/datum/element/beauty
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
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

	if(!beauty_counter[target] && ismovable(target))
		var/atom/movable/mov_target = target
		mov_target.become_area_sensitive(BEAUTY_ELEMENT_TRAIT)
		RegisterSignal(mov_target, COMSIG_ENTER_AREA, .proc/enter_area)
		RegisterSignal(mov_target, COMSIG_EXIT_AREA, .proc/exit_area)

	beauty_counter[target]++

	var/area/current_area = get_area(target)
	if(current_area && !current_area.outdoors)
		current_area.totalbeauty += beauty
		current_area.update_beauty()

/datum/element/beauty/proc/enter_area(datum/source, area/new_area)
	SIGNAL_HANDLER

	if(new_area.outdoors)
		return
	new_area.totalbeauty += beauty * beauty_counter[source]
	new_area.update_beauty()

/datum/element/beauty/proc/exit_area(datum/source, area/old_area)
	SIGNAL_HANDLER

	if(old_area.outdoors)
		return
	old_area.totalbeauty -= beauty * beauty_counter[source]
	old_area.update_beauty()

/datum/element/beauty/Detach(datum/source)
	if(!beauty_counter[source])
		return ..()
	var/area/current_area = get_area(source)
	if(QDELETED(source))
		. = ..()
		UnregisterSignal(source, list(COMSIG_ENTER_AREA, COMSIG_EXIT_AREA))
		if(current_area)
			exit_area(source, current_area)
		beauty_counter -= source
		REMOVE_TRAIT(source, TRAIT_AREA_SENSITIVE, BEAUTY_ELEMENT_TRAIT)
	else //lower the 'counter' down by one, update the area, and call parent if it's reached zero.
		beauty_counter[source]--
		if(current_area && !current_area.outdoors)
			current_area.totalbeauty -= beauty
			current_area.update_beauty()
		if(!beauty_counter[source])
			. = ..()
			UnregisterSignal(source, list(COMSIG_ENTER_AREA, COMSIG_EXIT_AREA))
			beauty_counter -= source
			REMOVE_TRAIT(source, TRAIT_AREA_SENSITIVE, BEAUTY_ELEMENT_TRAIT)

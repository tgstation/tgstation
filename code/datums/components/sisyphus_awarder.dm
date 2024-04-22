/**
 * This component awards the sisyphus achievement if you cart a boulder from lavaland to centcom
 * It's not really reusable but its a component just to encapsulate and destroy the behaviour neatly
 */
/datum/component/sisyphus_awarder
	/// What poor sap is hauling this rock?
	var/datum/weakref/sisyphus

/datum/component/sisyphus_awarder/Initialize()
	. = ..()
	if (!istype(parent, /obj/item/boulder))
		return COMPONENT_INCOMPATIBLE

/datum/component/sisyphus_awarder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(on_picked_up))

/datum/component/sisyphus_awarder/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))
	var/mob/living/struggler = sisyphus?.resolve()
	if (!isnull(struggler))
		UnregisterSignal(struggler, COMSIG_ENTER_AREA)

/// Called when we're picked up, check if we're in the right place to start our epic journey
/datum/component/sisyphus_awarder/proc/on_picked_up(atom/source, mob/living/the_taker)
	SIGNAL_HANDLER
	if (!istype(get_area(the_taker), /area/lavaland))
		qdel(src)
		return
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(the_taker, COMSIG_ENTER_AREA, PROC_REF(on_bearer_changed_area))
	sisyphus = WEAKREF(the_taker)

/// If you ever drop this shit you fail the challenge
/datum/component/sisyphus_awarder/proc/on_dropped()
	SIGNAL_HANDLER
	qdel(src) // Your quest ends here

/// If we changed area see if we arrived
/datum/component/sisyphus_awarder/proc/on_bearer_changed_area(mob/living/chosen_one, area/entered_area)
	SIGNAL_HANDLER
	var/atom/atom_parent = parent
	if (atom_parent.loc != chosen_one)
		qdel(src) // Hey! How did you do that?
		return
	if (entered_area.type != /area/centcom/central_command_areas/evacuation)
		return // Don't istype because taking pods doesn't count
	chosen_one.client?.give_award(/datum/award/achievement/misc/sisyphus, chosen_one)
	qdel(src)

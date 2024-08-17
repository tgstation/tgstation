/**
 * This component awards the sisyphus achievement if you cart a boulder from lavaland to centcom
 * It's not really reusable but its a component just to encapsulate and destroy the behaviour neatly
 */
/datum/component/sisyphus_awarder
	/// What poor sap is hauling this rock?
	var/mob/living/sisyphus
	/// Reference to a place where it all started.
	var/turf/bottom_of_the_hill

/datum/component/sisyphus_awarder/Initialize()
	if (!istype(parent, /obj/item/boulder))
		return COMPONENT_INCOMPATIBLE

/datum/component/sisyphus_awarder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_POST_EQUIPPED, PROC_REF(on_picked_up))

/datum/component/sisyphus_awarder/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_POST_EQUIPPED, COMSIG_MOVABLE_MOVED))
	if (!isnull(sisyphus))
		UnregisterSignal(sisyphus, list(COMSIG_ENTER_AREA, COMSIG_QDELETING))
	sisyphus = null

/// Called when we're picked up, check if we're in the right place to start our epic journey
/datum/component/sisyphus_awarder/proc/on_picked_up(atom/source, mob/living/the_taker)
	SIGNAL_HANDLER
	if (!istype(get_area(the_taker), /area/lavaland))
		qdel(src)
		return
	UnregisterSignal(parent, COMSIG_ITEM_POST_EQUIPPED)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_dropped))
	RegisterSignal(the_taker, COMSIG_ENTER_AREA, PROC_REF(on_bearer_changed_area))
	RegisterSignal(the_taker, COMSIG_QDELETING, PROC_REF(on_dropped))
	sisyphus = the_taker
	bottom_of_the_hill = get_turf(the_taker)

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
	play_reward_scene()

	qdel(src)

/// Sends the player back to the Lavaland and plays a funny sound
/datum/component/sisyphus_awarder/proc/play_reward_scene()
	if(isnull(bottom_of_the_hill))
		return // This probably shouldn't happen, but...

	podspawn(list(
		"path" = /obj/structure/closet/supplypod/centcompod/sisyphus,
		"target" = get_turf(sisyphus),
		"reverse_dropoff_coords" = list(bottom_of_the_hill.x, bottom_of_the_hill.y, bottom_of_the_hill.z),
	))

	SEND_SOUND(sisyphus, 'sound/ambience/music/sisyphus/sisyphus.ogg')

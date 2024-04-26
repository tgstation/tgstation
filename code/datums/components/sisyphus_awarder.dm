/**
 * This component awards the sisyphus achievement if you cart a boulder from lavaland to centcom
 * It's not really reusable but its a component just to encapsulate and destroy the behaviour neatly
 */
/datum/component/sisyphus_awarder
	/// What poor sap is hauling this rock?
	var/mob/living/sisyphus

/datum/component/sisyphus_awarder/Initialize()
	if (!istype(parent, /obj/item/boulder))
		return COMPONENT_INCOMPATIBLE

/datum/component/sisyphus_awarder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_POST_EQUIPPED, PROC_REF(on_picked_up))

/datum/component/sisyphus_awarder/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_POST_EQUIPPED, COMSIG_MOVABLE_MOVED))
	if (!isnull(sisyphus))
		UnregisterSignal(sisyphus, list(COMSIG_ENTER_AREA, COMSIG_QDELETING))

		sisyphus.client.set_eye(sisyphus.client.mob)
		sisyphus.client.perspective = MOB_PERSPECTIVE

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

	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(sisyphus, COMSIG_ENTER_AREA)

	chosen_one.client?.give_award(/datum/award/achievement/misc/sisyphus, chosen_one)
	start_reward_scene()

/datum/component/sisyphus_awarder/proc/start_reward_scene()
	var/list/turf/area_turfs = get_area_turfs(/area/lavaland/surface/outdoors)
	var/list/target_turf

	while (isnull(target_turf))
		var/turf/possible_pick = pick(area_turfs)

		if(possible_pick.density)
			continue

		target_turf = possible_pick

	var/obj/structure/closet/supplypod/our_pod = podspawn(list(
		"target" = target_turf,
		"path" = /obj/structure/closet/supplypod/centcompod,
	))

	sisyphus.client.set_eye(target_turf)
	sisyphus.client.perspective = EYE_PERSPECTIVE

	var/atom/movable/parent_atom = parent
	parent_atom.forceMove(our_pod)

	SEND_SOUND(sisyphus, 'sound/ambience/music/sisyphus/sisyphus.ogg')
	QDEL_IN(src, 11 SECONDS)

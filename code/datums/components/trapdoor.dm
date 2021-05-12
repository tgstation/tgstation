
///makes this file more legible
#define IS_OPEN(parent) isgroundlessturf(parent)

GLOBAL_LIST_EMPTY(unlinked_trapdoors)

/**
 * # trapdoor component!
 *
 * component attached to floors to turn them into trapdoors, a constructable trap that when signalled drops people to the level below.
 * assembly code at the bottom of this file
 */
/datum/component/trapdoor
	///assembly tied to this trapdoor
	var/obj/item/assembly/trapdoor/assembly
	///path of the turf this should change into when the assembly is pulsed. needed for openspace trapdoors knowing what to turn back into
	var/trapdoor_turf_path = /turf/open/openspace

/datum/component/trapdoor/Initialize(starts_open, trapdoor_turf_path, assembly)
	if(!isopenturf(parent))
		return COMPONENT_INCOMPATIBLE
	trapdoor_turf_path = parent.type
	if(starts_open)
		try_opening()
	src.assembly = assembly
	if(!src.assembly)
		GLOB.unlinked_trapdoors += src
	src.trapdoor_turf_path = trapdoor_turf_path

/datum/component/trapdoor/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_TURF_CHANGE, .proc/turf_changed_pre)

/datum/component/trapdoor/UnregisterFromParent()
	. = ..()
	UnregisterSignal(assembly, COMSIG_ASSEMBLY_PULSED)
	UnregisterSignal(parent, COMSIG_TURF_CHANGE)

///called by linking remotes to tie an assembly to the trapdoor
/datum/component/trapdoor/proc/link_with_assembly(obj/item/assembly/trapdoor/assembly)
	src.assembly = assembly
	GLOB.unlinked_trapdoors -= src
	assembly.linked = TRUE
	RegisterSignal(assembly, COMSIG_ASSEMBLY_PULSED, .proc/toggle_trapdoor)

///signal called by our assembly being pulsed
/datum/component/trapdoor/proc/toggle_trapdoor(datum/source)
	SIGNAL_HANDLER
	if(!IS_OPEN(parent))
		try_opening()
	else
		try_closing()

///signal called by turf changing
/datum/component/trapdoor/proc/turf_changed_pre(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER
	var/turf/open/dying_trapdoor = parent
	if(!IS_OPEN(dying_trapdoor) && !IS_OPEN(path)) //not a process of the trapdoor, so this trapdoor has been destroyed
		dying_trapdoor.visible_message("<span class='warning'>the trapdoor mechanism in [dying_trapdoor] is broken!</span>")
		assembly.forceMove(dying_trapdoor) //drops components that went into this
		return
	post_change_callbacks += CALLBACK(src, .proc/turf_changed_post, assembly, trapdoor_turf_path)

/**
 * # turf_changed_post
 *
 * wrapper that applies the trapdoor to the new turf (created by the last trapdoor)
 * change da turf my final callback. Goodbye
 */
/datum/component/trapdoor/proc/turf_changed_post(turf/new_turf, assembly, trapdoor_turf_path)
	new_turf.AddComponent(/datum/component/trapdoor, starts_open = TRUE, assembly, trapdoor_turf_path)

/**
 * # try_opening
 *
 * small proc for opening the turf into openspace
 * there are no checks for opening a trapdoor, but closed has some
 */
/datum/component/trapdoor/proc/try_opening()
	var/turf/open/trapdoor_turf = parent
	trapdoor_turf.visible_message("<span class='warning'>[trapdoor_turf] swings open!</span>")
	trapdoor_turf.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/**
 * # try_closing
 *
 * small proc for closing the turf back into what it should be
 * trapdoor can be blocked by building things on the openspace turf
 */
/datum/component/trapdoor/proc/try_closing()
	var/turf/open/trapdoor_turf = parent
	var/obj/structure/lattice/blocking = locate() in trapdoor_turf.contents
	if(blocking)
		trapdoor_turf.visible_message("<span class='warning'>The trapdoor mechanism in [trapdoor_turf] tries to shut, but is jammed by [blocking]!</span>")
		return
	trapdoor_turf.visible_message("<span class='warning'>The trapdoor mechanism in [trapdoor_turf] swings shut!</span>")
	trapdoor_turf.visible_message("<span class='warning'>[trapdoor_turf] swings open!</span>")
	trapdoor_turf.ChangeTurf(trapdoor_turf_path, flags = CHANGETURF_INHERIT_AIR)

#undef IS_OPEN

/obj/item/assembly/trapdoor
	name = "trapdoor controller"
	desc = "A sinister-looking controller for a trapdoor."
	var/linked = FALSE

#define TRAPDOOR_LINKING_SEARCH_RANGE 7

/obj/item/trapdoor_remote
	name = "trapdoor remote"
	desc = "A remote with internals that link to trapdoors and remotely activate them."
	icon = 'icons/obj/device.dmi'
	icon_state = "trapdoor_remote"
	COOLDOWN_DECLARE(search_cooldown)
	var/search_cooldown_time = 10 SECONDS
	COOLDOWN_DECLARE(trapdoor_cooldown)
	var/trapdoor_cooldown_time = 2 SECONDS
	var/obj/item/assembly/trapdoor/internals

/obj/item/trapdoor_remote/examine(mob/user)
	. = ..()
	if(!internals)
		. += "<span class='warning'>[src] has no internals! It needs a trapdoor controller to function.</span>"
		return
	if(!internals.linked)
		. += "<span class='warning'>[src] is not linked to a trapdoor.</span>"
		return
	. += "<span class='warning'>[src] is linked to a trapdoor.</span>"
	if(COOLDOWN_FINISHED(src, trapdoor_cooldown))
		. += "<span class='warning'>It is on a short cooldown.</span>"

/obj/item/trapdoor_remote/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!internals)
		to_chat(user, "<span class='warning'>[src] has no internals!</span>")
		return
	if(!internals.linked)
		attempt_link_up(user)
		return
	if(!COOLDOWN_FINISHED(src, trapdoor_cooldown))
		to_chat(user, "<span class='warning'>[src] is on a short cooldown.</span>")
		return
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	icon_state = "trapdoor_pressed"
	addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), trapdoor_cooldown_time)
	COOLDOWN_START(src, trapdoor_cooldown, trapdoor_cooldown_time)
	internals.pulsed()

/obj/item/trapdoor_remote/proc/attempt_link_up(mob/user)
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		var/timeleft = DisplayTimeText(COOLDOWN_TIMELEFT(src, search_cooldown))
		to_chat(user, "<span class='warning'>[src] is on cooldown! Please wait [timeleft].</span>")
		return
	///linking code
	var/found = FALSE
	for(var/datum/component/trapdoor/possible_trapdoor in GLOB.unlinked_trapdoors)
		var/turf/open/trapdoor_turf = possible_trapdoor.parent
		if(get_dist(src, trapdoor_turf) > TRAPDOOR_LINKING_SEARCH_RANGE)
			continue //out of range to link
		possible_trapdoor.link_with_assembly(internals)
		found = TRUE
		break
	if(found)
		to_chat(user, "<span class='notice'>[src] has linked up to a nearby trapdoor! \
		You may now use it to check where the trapdoor is... be careful!</span>")
	else
		to_chat(user, "<span class='warning'>[src] has failed to find a trapdoor nearby to link to.</span>")

#undef TRAPDOOR_LINKING_SEARCH_RANGE

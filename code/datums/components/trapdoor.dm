
///makes this file more legible
#define IS_OPEN(parent) isgroundlessturf(parent)
///distance a trapdoor will accept a link request.
#define TRAPDOOR_LINKING_SEARCH_RANGE 7

/**
 * ## trapdoor component!
 *
 * component attached to floors to turn them into trapdoors, a constructable trap that when signalled drops people to the level below.
 * assembly code at the bottom of this file
 */
/datum/component/trapdoor
	///assembly tied to this trapdoor
	var/obj/item/assembly/trapdoor/assembly
	///path of the turf this should change into when the assembly is pulsed. needed for openspace trapdoors knowing what to turn back into
	var/trapdoor_turf_path

/datum/component/trapdoor/Initialize(starts_open, trapdoor_turf_path, assembly)
	if(!isopenturf(parent))
		return COMPONENT_INCOMPATIBLE

	src.assembly = assembly
	if(IS_OPEN(parent))
		openspace_trapdoor_setup(trapdoor_turf_path, assembly)
	else
		tile_trapdoor_setup(trapdoor_turf_path, assembly)

	if(starts_open)
		try_opening()

///initializing as an opened trapdoor, we need to trust that we were given the data by a closed trapdoor
/datum/component/trapdoor/proc/openspace_trapdoor_setup(trapdoor_turf_path)
	src.trapdoor_turf_path = trapdoor_turf_path

///initializing as a closed trapdoor, we need to take data from the tile we're on to give it to the open state to store
/datum/component/trapdoor/proc/tile_trapdoor_setup(trapdoor_turf_path)
	src.trapdoor_turf_path = parent.type
	if(assembly && assembly.stored_decals.len)
		reapply_all_decals()

/datum/component/trapdoor/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_TURF_CHANGE, .proc/turf_changed_pre)
	if(!src.assembly)
		RegisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK, .proc/on_link_requested)
	else
		RegisterSignal(assembly, COMSIG_ASSEMBLY_PULSED, .proc/toggle_trapdoor)

/datum/component/trapdoor/UnregisterFromParent()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK)
	if(assembly)
		UnregisterSignal(assembly, COMSIG_ASSEMBLY_PULSED)
	UnregisterSignal(parent, COMSIG_TURF_CHANGE)

/datum/component/trapdoor/proc/decal_detached(datum/source, description, cleanable, directional, pic)
	SIGNAL_HANDLER
	///so it adds the list to the list, not appending it to the end. thank you byond, very cool.
	assembly.stored_decals += list(list(description, cleanable, directional, pic))

/**
 * ## reapply_all_decals
 *
 * changing turfs does not bring over decals, so we must perform a little bit of element reapplication.
 */
/datum/component/trapdoor/proc/reapply_all_decals()
	for(var/list/element_data as anything in assembly.stored_decals)
		apply_decal(element_data[1], element_data[2], element_data[3], element_data[4])
	assembly.stored_decals = list()

/// small proc that takes passed arguments and drops it into a new element
/datum/component/trapdoor/proc/apply_decal(description, cleanable, directional, pic)
	parent.AddElement(/datum/element/decal, _description = description, _cleanable = cleanable, _dir = directional, _pic = pic)

///called by linking remotes to tie an assembly to the trapdoor
/datum/component/trapdoor/proc/on_link_requested(datum/source, obj/item/assembly/trapdoor/assembly)
	SIGNAL_HANDLER
	if(get_dist(parent, assembly) > TRAPDOOR_LINKING_SEARCH_RANGE)
		return
	. = LINKED_UP
	src.assembly = assembly
	assembly.linked = TRUE
	UnregisterSignal(SSdcs, COMSIG_GLOB_TRAPDOOR_LINK)
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
	if((!IS_OPEN(dying_trapdoor) && !IS_OPEN(path)) || path == /turf/open/floor/plating) //not a process of the trapdoor, so this trapdoor has been destroyed
		dying_trapdoor.visible_message(span_warning("The trapdoor mechanism in [dying_trapdoor] is broken!"))
		if(assembly)
			assembly.linked = FALSE
			assembly.stored_decals.Cut()
			assembly = null
		return
	post_change_callbacks += CALLBACK(assembly, /obj/item/assembly/trapdoor.proc/carry_over_trapdoor, trapdoor_turf_path)

/**
 * ## carry_over_trapdoor
 *
 * applies the trapdoor to the new turf (created by the last trapdoor)
 * apparently callbacks with arguments on invoke and the callback itself have the callback args go first. interesting!
 */
/obj/item/assembly/trapdoor/proc/carry_over_trapdoor(trapdoor_turf_path, turf/new_turf)
	new_turf.AddComponent(/datum/component/trapdoor, FALSE, trapdoor_turf_path, src)

/**
 * ## try_opening
 *
 * small proc for opening the turf into openspace
 * there are no checks for opening a trapdoor, but closed has some
 */
/datum/component/trapdoor/proc/try_opening()
	var/turf/open/trapdoor_turf = parent
	///we want to save this turf's decals as they were right before deletion, so this is the point where we begin listening
	if(assembly)
		RegisterSignal(parent, COMSIG_TURF_DECAL_DETACHED, .proc/decal_detached)
	playsound(trapdoor_turf, 'sound/machines/trapdoor/trapdoor_open.ogg', 50)
	trapdoor_turf.visible_message(span_warning("[trapdoor_turf] swings open!"))
	trapdoor_turf.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/**
 * ## try_closing
 *
 * small proc for closing the turf back into what it should be
 * trapdoor can be blocked by building things on the openspace turf
 */
/datum/component/trapdoor/proc/try_closing()
	var/turf/open/trapdoor_turf = parent
	var/obj/structure/lattice/blocking = locate() in trapdoor_turf.contents
	if(blocking)
		trapdoor_turf.visible_message(span_warning("The trapdoor mechanism in [trapdoor_turf] tries to shut, but is jammed by [blocking]!"))
		return
	playsound(trapdoor_turf, 'sound/machines/trapdoor/trapdoor_shut.ogg', 50)
	trapdoor_turf.visible_message(span_warning("The trapdoor mechanism in [trapdoor_turf] swings shut!"))
	trapdoor_turf.ChangeTurf(trapdoor_turf_path, flags = CHANGETURF_INHERIT_AIR)

#undef IS_OPEN

/obj/item/assembly/trapdoor
	name = "trapdoor controller"
	desc = "A sinister-looking controller for a trapdoor."
	icon_state = "trapdoor"
	///if the trapdoor isn't linked it will try to link on pulse, this shouldn't be spammable
	COOLDOWN_DECLARE(search_cooldown)
	///trapdoor link cooldown time here!
	var/search_cooldown_time = 10 SECONDS
	///if true, a trapdoor in the world has a reference to this assembly and is listening for when it is pulsed.
	var/linked = FALSE
	/**
	* list of lists that are arguments for readding decals when the linked trapdoor comes back. pain.
	*
	* we are storing this data FOR the trapdoor component we are linked to. kinda like a multitool.
	* format: list(list(element's description, element's cleanable, element's directional, element's pic))
	* the list will be filled with all the data of the deleting elements (when ChangeTurf is called) only when the trapdoor begins to open.
	* so any other case the elements will be changed but not recorded.
	*/
	var/list/stored_decals = list()


/obj/item/assembly/trapdoor/pulsed(radio)
	. = ..()
	if(linked)
		return
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		visible_message(span_warning("[src] cannot attempt another trapdoor linkup so soon!"))
		return
	attempt_link_up()
	COOLDOWN_START(src, search_cooldown, search_cooldown_time)

/obj/item/assembly/trapdoor/proc/attempt_link_up()
	var/turf/assembly_turf = get_turf(src)
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		var/timeleft = DisplayTimeText(COOLDOWN_TIMELEFT(src, search_cooldown))
		assembly_turf.visible_message(span_warning("[src] is on cooldown! Please wait [timeleft]."), vision_distance = SAMETILE_MESSAGE_RANGE)
		return
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_TRAPDOOR_LINK, src) & LINKED_UP)
		playsound(assembly_turf, 'sound/machines/chime.ogg', 50, TRUE)
		assembly_turf.visible_message("<span class='notice'>[src] has linked up to a nearby trapdoor! \
		You may now use it to check where the trapdoor is... be careful!</span>", vision_distance = SAMETILE_MESSAGE_RANGE)
	else
		playsound(assembly_turf, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		assembly_turf.visible_message(span_warning("[src] has failed to find a trapdoor nearby to link to."), vision_distance = SAMETILE_MESSAGE_RANGE)

/**
 * ## trapdoor remotes!
 *
 * Item that accepts the assembly for the internals and helps link/activate it.
 * This base type is an empty shell that needs the assembly added to it first to work.
 */
/obj/item/trapdoor_remote
	name = "trapdoor remote"
	desc = "A small machine that interfaces with a trapdoor controller for easy use."
	icon = 'icons/obj/device.dmi'
	icon_state = "trapdoor_remote"
	COOLDOWN_DECLARE(trapdoor_cooldown)
	var/trapdoor_cooldown_time = 2 SECONDS
	var/obj/item/assembly/trapdoor/internals

/obj/item/trapdoor_remote/examine(mob/user)
	. = ..()
	if(!internals)
		. += span_warning("[src] has no internals! It needs a trapdoor controller to function.")
		return
	. += span_notice("The internals can be removed with a screwdriver.")
	if(!internals.linked)
		. += span_warning("[src] is not linked to a trapdoor.")
		return
	. += span_notice("[src] is linked to a trapdoor.")
	if(!COOLDOWN_FINISHED(src, trapdoor_cooldown))
		. += span_warning("It is on a short cooldown.")

/obj/item/trapdoor_remote/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!internals)
		to_chat(user, span_warning("[src] has no internals!"))
		return
	to_chat(user, span_notice("You pop [internals] out of [src]."))
	internals.forceMove(get_turf(src))
	internals = null

/obj/item/trapdoor_remote/attackby(obj/item/assembly/trapdoor/assembly, mob/living/user, params)
	. = ..()
	if(. || !istype(assembly))
		return
	if(internals)
		to_chat(user, span_warning("[src] already has internals!"))
		return
	to_chat(user, span_notice("You add [assembly] to [src]."))
	internals = assembly
	assembly.forceMove(src)

/obj/item/trapdoor_remote/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	if(!internals)
		to_chat(user, span_warning("[src] has no internals!"))
		return
	if(!internals.linked)
		to_chat(user, span_notice("You activate [src]."))
		internals.pulsed()
		return
	if(!COOLDOWN_FINISHED(src, trapdoor_cooldown))
		to_chat(user, span_warning("[src] is on a short cooldown."))
		return
	to_chat(user, span_notice("You activate [src]."))
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	icon_state = "trapdoor_pressed"
	addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), trapdoor_cooldown_time)
	COOLDOWN_START(src, trapdoor_cooldown, trapdoor_cooldown_time)
	internals.pulsed()

#undef TRAPDOOR_LINKING_SEARCH_RANGE

///subtype with internals already included. If you're giving a department a roundstart trapdoor, this is what you want
/obj/item/trapdoor_remote/preloaded

/obj/item/trapdoor_remote/preloaded/Initialize(mapload)
	. = ..()
	internals = new(src)

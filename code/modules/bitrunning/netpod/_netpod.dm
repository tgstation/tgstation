#define BASE_DISCONNECT_DAMAGE 40


/obj/machinery/netpod
	name = "netpod"

	base_icon_state = "netpod"
	circuit = /obj/item/circuitboard/machine/netpod
	desc = "A link to the netverse. It has an assortment of cables to connect yourself to a virtual domain."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "netpod"
	max_integrity = 300
	obj_flags = BLOCKS_CONSTRUCTION
	state_open = TRUE
	interaction_flags_mouse_drop = NEED_HANDS | NEED_DEXTERITY

	/// Whether we have an ongoing connection
	var/connected = FALSE
	/// A player selected outfit by clicking the netpod
	var/datum/outfit/netsuit = /datum/outfit/job/bitrunner
	/// Holds this to see if it needs to generate a new one
	var/datum/weakref/avatar_ref
	/// The linked quantum server
	var/datum/weakref/server_ref
	/// The amount of brain damage done from force disconnects
	var/disconnect_damage
	/// Static list of outfits to select from
	var/list/cached_outfits = list()


/obj/machinery/netpod/post_machine_initialize()
	. = ..()

	disconnect_damage = BASE_DISCONNECT_DAMAGE
	find_server()

	RegisterSignal(src, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(src, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_loss))
	RegisterSignals(src, list(COMSIG_QDELETING,	COMSIG_MACHINERY_BROKEN),PROC_REF(on_broken))

	register_context()
	update_appearance()


/obj/machinery/netpod/Destroy()
	. = ..()

	QDEL_LIST(cached_outfits)


/obj/machinery/netpod/examine(mob/user)
	. = ..()

	if(isnull(server_ref?.resolve()))
		. += span_infoplain("It's not connected to anything.")
		. += span_infoplain("Netpods must be built within 4 tiles of a server.")
		return

	if(!isobserver(user))
		. += span_infoplain("Drag yourself into the pod to engage the link.")
		. += span_infoplain("It has limited resuscitation capabilities. Remaining in the pod can heal some injuries.")
		. += span_infoplain("It has a security system that will alert the occupant if it is tampered with.")

	if(isnull(occupant))
		. += span_infoplain("It's currently unoccupied.")
		return

	. += span_infoplain("It's currently occupied by [occupant].")

	if(isobserver(user))
		. += span_notice("As an observer, you can click this netpod to jump to its avatar.")
		return

	. += span_notice("It can be pried open with a crowbar, but its safety mechanisms will alert the occupant.")


/obj/machinery/netpod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select Outfit"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/crowbar) && occupant)
		context[SCREENTIP_CONTEXT_LMB] = "Pry Open"
		return CONTEXTUAL_SCREENTIP_SET


/obj/machinery/netpod/update_icon_state()
	if(!is_operational)
		icon_state = base_icon_state
		return ..()

	if(state_open)
		icon_state = base_icon_state + "_open_active"
		return ..()

	if(panel_open)
		icon_state = base_icon_state + "_panel"
		return ..()

	icon_state = base_icon_state + "_closed"
	if(occupant)
		icon_state += "_active"

	return ..()


/obj/machinery/netpod/mouse_drop_receive(mob/target, mob/user, params)
	var/mob/living/carbon/player = user

	if(!iscarbon(player) || !is_operational || !state_open || player.buckled)
		return

	close_machine(target)


/obj/machinery/netpod/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!state_open && user == occupant)
		container_resist_act(user)


/obj/machinery/netpod/attack_ghost(mob/dead/observer/our_observer)
	var/our_target = avatar_ref?.resolve()
	if(isnull(our_target) || !our_observer.orbit(our_target))
		return ..()


/// When the server is upgraded, drops brain damage a little
/obj/machinery/netpod/proc/on_server_upgraded(obj/machinery/quantum_server/source)
	SIGNAL_HANDLER

	disconnect_damage = BASE_DISCONNECT_DAMAGE * (1 - source.servo_bonus)


#undef BASE_DISCONNECT_DAMAGE

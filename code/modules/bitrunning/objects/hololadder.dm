/obj/structure/hololadder
	name = "hololadder"

	anchored = TRUE
	desc = "Абстрактное представление средства отключения от виртуального пространства."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	obj_flags = BLOCK_Z_OUT_DOWN
	/// Time req to disconnect properly
	var/travel_time = 3 SECONDS
	/// Uses this to teleport observers back to the origin server
	var/datum/weakref/server_ref


/obj/structure/hololadder/Initialize(mapload, obj/machinery/quantum_server/origin)
	. = ..()

	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))
	server_ref = WEAKREF(origin)
	register_context()


/obj/structure/hololadder/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_LMB] = "отключить"


/obj/structure/hololadder/examine(mob/user)
	. = ..()

	if(isnull(server_ref.resolve()))
		. += span_infoplain("Ни к чему не подключено.")
		return

	if(isobserver(user))
		. += span_notice("Щелкните левой кнопкой мыши, чтобы просмотреть сервер, к которому подключена эта лестница.")
		return

	. += span_infoplain("Эта лестница подключена к серверу. Вы можете нажать на неё или пройти по ней, чтобы отключиться.")


/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	disconnect(user)


/obj/structure/hololadder/attack_ghost(mob/dead/observer/ghostie)
	var/our_server = server_ref?.resolve()
	if(isnull(our_server))
		return ..()

	ghostie.abstract_move(get_turf(our_server))


/// If there's a pilot ref- send the disconnect signal
/obj/structure/hololadder/proc/disconnect(mob/user)
	if(isnull(user.mind))
		return

	var/obj/machinery/quantum_server/our_server = server_ref.resolve()
	if(!our_server.domain_complete)
		for(var/datum/weakref/ghostrole_weakref as anything in our_server.spawned_threat_refs)
			var/mob/living/ghostrole = ghostrole_weakref.resolve()
			if(ghostrole?.stat == CONSCIOUS && ghostrole.client && ghostrole.mind.has_antag_datum(/datum/antagonist/bitrunning_glitch))
				to_chat(user, span_danger("A being in the simulation is preventing your retreat. You must either complete your mission or remove the obstacle before safe exit will be possible."))
				return

	if(!HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		balloon_alert(user, "соединение не обнаружено")
		return

	balloon_alert(user, "отключение...")
	if(do_after(user, travel_time, src))
		SEND_SIGNAL(user, COMSIG_BITRUNNER_LADDER_SEVER)


/// Helper for times when you dont have hands (gondola??)
/obj/structure/hololadder/proc/on_enter(datum/source, atom/movable/arrived, turf/old_loc)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	var/mob/living/user = arrived
	if(isnull(user.mind))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), user)

// A shuttle subtype for a "crashland on Lavaland" round
// Does a roundstart force-dock on lavaland

/obj/docking_port/mobile/crashland
	name = "crash shuttle"

// TODO: fix
/*
/obj/docking_port/mobile/crashland/dockRoundstart()
	var/port = SSshuttle.getDock(roundstart_move)
	if (port)
		initiate_docking(port, force=TRUE)
*/

// Spawn-point sleeper. Holds a phantom occupant until someone spawns in it,
// then becomes a regular usable sleeper.

/obj/machinery/sleeper/crashland
	name = "cryostasis sleeper"
	desc = "An enclosed machine used to stabilize and heal patients, with additional deep-freeze functionality."
	state_open = FALSE
	density = TRUE
	var/used_yet = FALSE

/obj/machinery/sleeper/crashland/Initialize(mapload)
	. = ..()
	GLOB.start_landmarks_list += src
	SSjob.latejoin_trackers += src

/obj/machinery/sleeper/crashland/Destroy()
	..()
	if (!used_yet)
		GLOB.start_landmarks_list -= src
		SSjob.latejoin_trackers -= src

/obj/machinery/sleeper/crashland/open_machine()
	if (used_yet)
		..()

/obj/machinery/sleeper/crashland/examine(mob/user)
	..()
	if (!used_yet)
		to_chat(user, "You can barely recognise a figure underneath the built up ice. The machine is attempting to wake up its occupant.")

/obj/machinery/sleeper/crashland/proc/WakeMeUpInside(mob/target)
	if (used_yet)
		return FALSE

	used_yet = TRUE
	open_machine()
	close_machine(target)
	updateUsrDialog()
	update_icon()
	GLOB.start_landmarks_list -= src
	SSjob.latejoin_trackers -= src
	return TRUE

/obj/machinery/sleeper/crashland/interact(mob/user, special_state)
	if (used_yet)
		..()
	else
		to_chat(user, "[src] is cold to the touch, and its controls are unresponsive.")

/datum/controller/subsystem/job/SendToAtom(mob/M, atom/A, buckle)
	var/obj/machinery/sleeper/crashland/CL = A
	if (!istype(CL) || !CL.WakeMeUpInside(M))
		..()

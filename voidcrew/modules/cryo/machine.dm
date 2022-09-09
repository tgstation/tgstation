//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'voidcrew/modules/cryo/icons/cryogenic.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF

	var/open_state = "cryopod-open"
	var/close_state = "cryopod"

	/// The last time the "no control computer" message was sent to admins.
	var/last_no_computer_message = 0
	/// The linked control computer.
	var/datum/weakref/control_computer

	var/obj/docking_port/mobile/voidcrew/linked_ship

/obj/machinery/cryopod/Initialize()
	. = ..()
	icon_state = open_state
	return INITIALIZE_HINT_LATELOAD //Gotta populate the cryopod computer GLOB first

/obj/machinery/cryopod/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	linked_ship = port
	linked_ship.spawn_points += src

/obj/machinery/cryopod/Destroy()
	if(linked_ship)
		linked_ship.spawn_points -= src
		linked_ship = null
	return ..()

/obj/machinery/cryopod/LateInitialize()
	. = ..()
	find_control_computer()

/obj/machinery/cryopod/proc/find_control_computer(urgent = FALSE)
	control_computer = null
	for(var/obj/machinery/computer/cryopod/C as anything in GLOB.cryopod_computers)
		if(get_area(C) == get_area(src))
			control_computer = WEAKREF(C)
			break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5 MINUTES < world.time)
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Cryopod in [get_area(src)] could not find control computer!")
		last_no_computer_message = world.time

/obj/machinery/cryopod/JoinPlayerHere(mob/M, buckle)
	. = ..()
	close_machine(M, TRUE)

/obj/machinery/cryopod/close_machine(mob/user, exiting = FALSE)
	if(!control_computer?.resolve())
		find_control_computer(TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		if(exiting && istype(user, /mob/living/carbon))
			var/mob/living/carbon/C = user
			C.SetSleeping(50)
			to_chat(occupant, "<span class='boldnotice'>You begin to wake from cryosleep...</span>")
			icon_state = close_state
			return
	icon_state = close_state

/obj/machinery/cryopod/open_machine()
	..()
	icon_state = open_state
	density = TRUE
	name = initial(name)

/obj/machinery/cryopod/container_resist_act(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist_act(user)

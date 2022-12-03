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

	///The icon state while the machine is closed.
	var/close_state = "cryopod"

	///The ship we're connected to.
	var/obj/docking_port/mobile/voidcrew/linked_ship

/obj/machinery/cryopod/connect_to_shuttle(mapload, obj/docking_port/mobile/voidcrew/port, obj/docking_port/stationary/dock)
	. = ..()
	linked_ship = port
	linked_ship.spawn_points += src

/obj/machinery/cryopod/Destroy()
	if(linked_ship)
		linked_ship.spawn_points -= src
		linked_ship = null
	return ..()

/obj/machinery/cryopod/JoinPlayerHere(mob/joining_mob, buckle)
	. = ..()
	close_machine(joining_mob)

/obj/machinery/cryopod/open_machine()
	. = ..()
	icon_state = initial(icon_state)
	set_density(TRUE)

/obj/machinery/cryopod/close_machine(mob/living/carbon/user)
	. = ..()
	to_chat(user, span_boldnotice("You begin to wake from cryosleep..."))
	icon_state = close_state
	user.SetStun(5 SECONDS)

/obj/machinery/cryopod/container_resist_act(mob/living/user)
	visible_message(
		span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"),
	)
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist_act(user)

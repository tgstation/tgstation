/obj/machinery/mechpad
	name = "mech orbital pad"
	desc = "A pad to drop mechs on. From space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bounty_trap_on"
	circuit = /obj/item/circuitboard/machine/mechpad
	///Name of the mechpad in a mechpad console
	var/display_name = "Orbital Pad"
	///The console the pad is linked to
	var/obj/machinery/computer/mechpad/connected_console

/obj/machinery/mechpad/Initialize()
	. = ..()
	display_name = "Orbital Pad - [get_area_name(src)]"

/obj/machinery/mechpad/Destroy()
	if(connected_console)
		connected_console.connected_mechpad = null
		connected_console = null
	return ..()

/obj/machinery/mechpad/attackby(obj/item/I, mob/user, params)
	if(panel_open)
		if(I.tool_behaviour == TOOL_MULTITOOL)
			if(!multitool_check_buffer(user, I))
				return
			var/obj/item/multitool/M = I
			M.buffer = src
			to_chat(user, "<span class='notice'>You save the data in the [I.name]'s buffer.</span>")
			return TRUE
	return ..()

/**
  * Spawns a special supply pod whitelisted to only accept mechs and have its drop off location be another mechpad
  * Arguments:
  * * where - where the supply pod will land after grabbing the mech
  */
/obj/machinery/mechpad/proc/launch(obj/machinery/mechpad/where)
	var/obj/structure/closet/supplypod/mechpod/pod = new()
	pod.reverse_dropoff_turf = get_turf(where)
	pod.whitelist = typecacheof(list(/obj/mecha))
	new /obj/effect/pod_landingzone(get_turf(src), pod)

/obj/structure/closet/supplypod/mechpod
	style = STYLE_SEETHROUGH
	explosionSize = list(0,0,0,0)
	reversing = TRUE
	landingDelay = 0
	openingDelay = 0
	departureDelay = 0
	effectOrgans = TRUE
	effectQuiet = TRUE
	leavingSound = 'sound/vehicles/rocketlaunch.ogg'
	close_sound = null
	firstSounds = FALSE

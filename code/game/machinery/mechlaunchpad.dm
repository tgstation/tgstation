/obj/machinery/mechpad
	name = "mech orbital pad"
	desc = "A pad to drop mechs on. From space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bounty_trap_on"

/obj/machinery/mechpad/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		M.buffer = src
		to_chat(user, "<span class='notice'>You save the data in the [I.name]'s buffer.</span>")
		return TRUE
	return ..()

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
	effectGib = TRUE
	effectQuiet = TRUE
	leavingSound = 'sound/vehicles/rocketlaunch.ogg'
	firstSounds = FALSE

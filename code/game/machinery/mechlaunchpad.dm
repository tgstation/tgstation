/obj/machinery/mechpad
	name = "orbital mech pad"
	desc = "A slab of heavy plating designed to withstand orbital-drop impacts. Through some sort of advanced bluespace tech, this one seems able to send and receive Mechs. Requires linking to a console to function."
	icon = 'icons/obj/machines/telepad.dmi'
	icon_state = "mechpad"
	circuit = /obj/item/circuitboard/machine/mechpad
	///ID of the console, used for linking up
	var/id = "roboticsmining"
	///Name of the mechpad in a mechpad console
	var/display_name = "Orbital Pad"
	///Can we carry mobs or just mechs?
	var/mech_only = FALSE

/obj/machinery/mechpad/Initialize(mapload)
	. = ..()
	display_name = "Orbital Pad - [get_area_name(src)]"

/obj/machinery/mechpad/examine(mob/user)
	. = ..()
	. += span_notice("Use a multitool with the panel open to save id to buffer.")
	. += span_notice("Use wirecutters with the panel open to [mech_only ? "cut" : "mend"] the lifeform restriction wire.")

/obj/machinery/mechpad/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "mechpad-open", "mechpad", tool)

/obj/machinery/mechpad/crowbar_act(mob/user, obj/item/tool)
	..()
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/mechpad/multitool_act(mob/living/user, obj/item/multitool/multitool)
	. = NONE
	if(!panel_open)
		return

	multitool.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/mechpad/wirecutter_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return
	mech_only = !mech_only
	to_chat(user, span_notice("You [mech_only ? "mend" : "cut"] the lifeform restriction wire."))
	return TRUE

/**
 * Spawns a special supply pod whitelisted to only accept mechs and have its drop off location be another mechpad
 * Arguments:
 * * where - where the supply pod will land after grabbing the mech
 */
/obj/machinery/mechpad/proc/launch(obj/machinery/mechpad/where)
	var/turf/reverse_turf = get_turf(where)
	podspawn(list(
		"target" = get_turf(src),
		"path" = /obj/structure/closet/supplypod/mechpod,
		"style" = /datum/pod_style/seethrough,
		"reverse_dropoff_coords" = list(reverse_turf.x, reverse_turf.y, reverse_turf.z)
	))
	use_energy(active_power_usage)

/obj/structure/closet/supplypod/mechpod
	style = /datum/pod_style/seethrough
	explosionSize = list(0,0,0,0)
	reversing = TRUE
	reverse_option_list = list("Mobs"=FALSE,"Objects"=FALSE,"Anchored"=FALSE,"Underfloor"=FALSE,"Wallmounted"=FALSE,"Floors"=FALSE,"Walls"=FALSE,"Mecha"=TRUE)
	delays = list(POD_TRANSIT = 0, POD_FALLING = 0, POD_OPENING = 0, POD_LEAVING = 0)
	reverse_delays = list(POD_TRANSIT = 30, POD_FALLING = 10, POD_OPENING = 0, POD_LEAVING = 0)
	custom_rev_delay = TRUE
	effectQuiet = TRUE
	effectStealth = TRUE
	leavingSound = 'sound/vehicles/rocketlaunch.ogg'
	close_sound = null
	pod_flags = FIRST_SOUNDS

/obj/structure/closet/supplypod/mechpod/handleReturnAfterDeparting(atom/movable/holder = src)
	effectGib = TRUE
	return ..()

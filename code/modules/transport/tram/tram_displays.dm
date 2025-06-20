/obj/machinery/transport/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/tram/tram_display.dmi'
	icon_state = "desto_blank"
	base_icon_state = "desto"
	use_power = NO_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	layer = SIGN_LAYER
	light_range = 0
	/// What sign face prefixes we have icons for
	var/static/list/available_faces = list()
	/// The sign face we're displaying
	var/sign_face
	var/sign_color = COLOR_DISPLAY_BLUE

/obj/machinery/transport/destination_sign/split/north
	pixel_x = -8

/obj/machinery/transport/destination_sign/split/south
	pixel_x = 8

/obj/machinery/transport/destination_sign/indicator
	icon = 'icons/obj/tram/tram_indicator.dmi'
	icon_state = "indi_blank"
	base_icon_state = "indi"
	use_power = IDLE_POWER_USE
	max_integrity = 50
	light_range = 2
	light_power = 0.7
	light_angle = 115
	flags_1 = NONE

/obj/item/wallframe/indicator_display
	name = "indicator display frame"
	desc = "Used to build tram indicator displays, just secure to the wall."
	icon_state = "indi_blank"
	icon = 'icons/obj/tram/tram_indicator.dmi'
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 4, /datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2)
	result_path = /obj/machinery/transport/destination_sign/indicator
	pixel_shift = 32

/obj/machinery/transport/destination_sign/Initialize(mapload)
	. = ..()
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(update_sign))
	SStransport.displays += src
	available_faces = list(
		TRAMSTATION_LINE_1,
	)
	set_light(l_dir = REVERSE_DIR(dir))

/obj/machinery/transport/destination_sign/Destroy()
	SStransport.displays -= src
	. = ..()

/obj/machinery/transport/destination_sign/indicator/setDir(newdir)
	. = ..()
	set_light(l_dir = REVERSE_DIR(dir))

/obj/machinery/transport/destination_sign/indicator/post_machine_initialize()
	. = ..()
	link_tram()

/obj/machinery/transport/destination_sign/indicator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "unanchor"
	if(held_item?.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "repair"

	return CONTEXTUAL_SCREENTIP_SET


/obj/machinery/transport/destination_sign/indicator/examine(mob/user)
	. = ..()

	if(panel_open)
		. += span_notice("It is secured to the tram wall with [EXAMINE_HINT("bolts.")]")

/obj/machinery/transport/destination_sign/on_deconstruction(disassembled)
	var/atom/drop = drop_location()
	if(disassembled)
		new /obj/item/wallframe/indicator_display(drop)
	else
		new /obj/item/stack/sheet/mineral/titanium(drop, 2)
		new /obj/item/stack/sheet/iron(drop)
		new /obj/item/shard(drop)
		new /obj/item/shard(drop)

/obj/machinery/transport/destination_sign/indicator/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "[anchored ? "un" : ""]securing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		balloon_alert(user, "[anchored ? "un" : ""]secured")
		deconstruct()
		return TRUE

/obj/machinery/transport/destination_sign/proc/update_sign(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform)
	SIGNAL_HANDLER

	if(machine_stat & (NOPOWER|BROKEN))
		sign_face = null
		update_appearance()
		return

	if(!controller || !controller.controller_operational || isnull(destination_platform))
		sign_face = "[base_icon_state]_NIS"
		sign_color = COLOR_DISPLAY_RED
		update_appearance()
		return

	if(controller.controller_status & EMERGENCY_STOP || controller.controller_status & SYSTEM_FAULT)
		sign_face = "[base_icon_state]_NIS"
		sign_color = COLOR_DISPLAY_RED
		update_appearance()
		return

	sign_face = ""
	sign_face += "[base_icon_state]_"
	if(!LAZYFIND(available_faces, controller.specific_transport_id))
		sign_face += "[TRAMSTATION_LINE_1]"
	else
		sign_face += "[controller.specific_transport_id]"

	sign_face += "[controller_active]"
	sign_face += "[destination_platform.platform_code]"
	sign_face += "[travel_direction]"
	sign_color = COLOR_DISPLAY_BLUE

	update_appearance()

/obj/machinery/transport/destination_sign/update_icon_state()
	. = ..()
	if(isnull(sign_face))
		icon_state = "[base_icon_state]_blank"
		return
	else
		icon_state = sign_face

/obj/machinery/transport/destination_sign/update_overlays()
	. = ..()

	if(isnull(sign_face))
		set_light(l_on = FALSE)
		return

	set_light(l_on = TRUE, l_color = sign_color)
	. += emissive_appearance(icon, "[sign_face]_e", src, alpha = src.alpha)

/obj/machinery/transport/destination_sign/indicator/power_change()
	..()
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	if(!tram)
		return

	update_sign(src, tram, tram.controller_active, tram.controller_status, tram.travel_direction, tram.destination_platform)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transport/destination_sign/indicator, 32)

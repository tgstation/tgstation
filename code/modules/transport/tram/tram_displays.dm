/obj/machinery/transport/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/tram/tram_display.dmi'
	icon_state = "desto_off"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	subsystem_type = /datum/controller/subsystem/processing/transport
	layer = SIGN_LAYER

	/// The ID of the tram we're indicating
	configured_transport_id = TRAMSTATION_LINE_1
	/// What sign face prefixes we have icons for
	var/static/list/available_faces = list()
	/// The light mask overlay we use
	var/light_mask

/obj/machinery/transport/destination_sign/indicator
	icon = 'icons/obj/tram/tram_indicator.dmi'
	icon_state = "indi_off"
	base_icon_state = "indi_"
	light_range = 1.5
	light_color = LIGHT_COLOR_DARK_BLUE

/obj/item/wallframe/icts/indicator_display
	name = "indicator display frame"
	desc = "Used to build tram indicator displays, just secure to the wall."
	icon_state = "indi_off"
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
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/transport/destination_sign/Destroy()
	SStransport.displays -= src
	. = ..()

/obj/machinery/transport/destination_sign/indicator/LateInitialize(mapload)
	. = ..()
	link_tram()

/obj/machinery/transport/destination_sign/proc/on_tram_travelling(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, datum/transport_controller/linear/tram/destination_platform)
	SIGNAL_HANDLER

	if(controller.specific_transport_id != configured_transport_id)
		return
	update_sign()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, process))

/obj/machinery/transport/destination_sign/indicator/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(disassembled)
		new /obj/item/wallframe/icts/indicator_display(drop_location())
	else
		new /obj/item/stack/sheet/mineral/titanium(drop_location(), 2)
		new /obj/item/stack/sheet/iron(drop_location(), 1)
		new /obj/item/shard(drop_location())
		new /obj/item/shard(drop_location())
	qdel(src)

/obj/machinery/transport/destination_sign/indicator/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "[anchored ? "un" : ""]securing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		balloon_alert(user, "[anchored ? "un" : ""]secured")
		deconstruct()
		return TRUE

/obj/machinery/transport/destination_sign/proc/update_operating()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/transport/destination_sign/proc/update_sign(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, obj/effect/landmark/icts/nav_beacon/tram/platform/destination_platform)
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "[base_icon_state]off"
		light_mask = null
		set_light(l_on = FALSE)
		update_appearance()
		return PROCESS_KILL

	if(!controller || !controller.controller_operational)
		icon_state = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]"
		light_mask = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]_e"
		update_appearance()
		return PROCESS_KILL

	use_power(active_power_usage)

	set_light(l_on = TRUE)
	var/sign_face = ""
	sign_face += "[base_icon_state]"
	if(!LAZYFIND(available_faces, controller.specific_transport_id))
		sign_face += "[TRAMSTATION_LINE_1]"
	else
		sign_face += "[controller.specific_transport_id]"
	sign_face += "[controller_active]"
	sign_face += "[destination_platform.platform_code]"
	sign_face += "[travel_direction]"
	icon_state = "[sign_face]"
	light_mask = "[sign_face]_e"

	update_appearance()
	return PROCESS_KILL

/obj/machinery/transport/destination_sign/update_overlays()
	. = ..()
	if(!light_mask)
		return

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)

/obj/machinery/transport/destination_sign/update_icon_state()
	. = ..()
	switch(dir)
		if(SOUTH, EAST)
			pixel_x = 8
		if(NORTH, WEST)
			pixel_x = -8

/obj/machinery/transport/destination_sign/indicator/update_icon_state()
	. = ..()
	pixel_x = 0

/obj/machinery/transport/destination_sign/indicator/power_change()
	..()
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	if(!tram)
		return

	update_sign(src, tram, tram.controller_active, tram.controller_status, tram.travel_direction, tram.destination_platform)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transport/destination_sign, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/transport/destination_sign/indicator, 32)

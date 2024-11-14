/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "light-nopower"
	base_icon_state = "light"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null
	///Range of the light emitted when powered, but off
	var/light_on_range = 1
	/// Should this lightswitch automatically rename itself to match the area it's in?
	var/autoname = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light_switch, 26)

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/redirect_attack_hand_from_turf)

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/light_switch,
	))
	if(istext(area))
		area = text2path(area)
	if(ispath(area))
		area = GLOB.areas_by_type[area]
	if(!area)
		area = get_area(src)
	if(autoname)
		name = "light switch ([area.name])"
	find_and_hang_on_wall(custom_drop_callback = CALLBACK(src, PROC_REF(deconstruct), TRUE))
	register_context()
	update_appearance()

/obj/machinery/light_switch/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = area.lightswitch ? "Flick off" : "Flick on"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/machinery/light_switch/update_appearance(updates=ALL)
	. = ..()
	luminosity = (machine_stat & NOPOWER) ? 0 : 1

/obj/machinery/light_switch/update_icon_state()
	set_light(area.lightswitch ? 0 : light_on_range)
	icon_state = "[base_icon_state]"
	if(machine_stat & NOPOWER)
		icon_state += "-nopower"
		return ..()
	icon_state += "[area.lightswitch ? "-on" : "-off"]"
	return ..()

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return ..()
	. += emissive_appearance(icon, "[base_icon_state]-emissive[area.lightswitch ? "-on" : "-off"]", src, alpha = src.alpha)

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [(machine_stat & NOPOWER) ? "unpowered" : (area.lightswitch ? "on" : "off")]."
	. += span_notice("It's <b>screwed</b> and secured to the wall.")

/obj/machinery/light_switch/interact(mob/user)
	. = ..()
	set_lights(!area.lightswitch)

/obj/machinery/light_switch/screwdriver_act(mob/living/user, obj/item/tool)
	user.visible_message(span_notice("[user] starts unscrewing [src]..."), span_notice("You start unscrewing [src]..."))
	if(!tool.use_tool(src, user, 40, volume = 50))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] unscrews [src]!"), span_notice("You detach [src] from the wall."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/light_switch/proc/set_lights(status)
	if(area.lightswitch == status)
		return
	area.lightswitch = status
	area.update_appearance()

	for(var/obj/machinery/light_switch/light_switch as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light_switch))
		if(light_switch.area != area)
			continue
		light_switch.update_appearance()
		SEND_SIGNAL(light_switch, COMSIG_LIGHT_SWITCH_SET, status)

	area.power_change()

/obj/machinery/light_switch/power_change()
	SHOULD_CALL_PARENT(FALSE)
	if(area == get_area(src))
		return ..()

/obj/machinery/light_switch/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		power_change()

/obj/machinery/light_switch/on_deconstruction(disassembled)
	new /obj/item/wallframe/light_switch(loc)

/obj/item/wallframe/light_switch
	name = "light switch"
	desc = "An unmounted light switch. Attach it to a wall to use."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "light-nopower"
	result_path = /obj/machinery/light_switch
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 26

/obj/item/circuit_component/light_switch
	display_name = "Light Switch"
	desc = "Allows to control the lights of an area."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///If the lights should be turned on or off when the trigger is triggered.
	var/datum/port/input/on_setting
	///Whether the lights are turned on
	var/datum/port/output/is_on

	var/obj/machinery/light_switch/attached_switch

/obj/item/circuit_component/light_switch/populate_ports()
	on_setting = add_input_port("On", PORT_TYPE_NUMBER)
	is_on = add_output_port("Is On", PORT_TYPE_NUMBER)

/obj/item/circuit_component/light_switch/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/light_switch))
		attached_switch = parent
		RegisterSignal(parent, COMSIG_LIGHT_SWITCH_SET, PROC_REF(on_light_switch_set))

/obj/item/circuit_component/light_switch/unregister_usb_parent(atom/movable/parent)
	attached_switch = null
	UnregisterSignal(parent, COMSIG_LIGHT_SWITCH_SET)
	return ..()

/obj/item/circuit_component/light_switch/proc/on_light_switch_set(datum/source, status)
	SIGNAL_HANDLER
	is_on.set_output(status)

/obj/item/circuit_component/light_switch/input_received(datum/port/input/port)
	attached_switch?.set_lights(on_setting.value ? TRUE : FALSE)

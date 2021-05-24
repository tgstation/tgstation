/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	base_icon_state = "light"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT
	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null

/obj/machinery/light_switch/directional/north
	dir = SOUTH
	pixel_y = 26

/obj/machinery/light_switch/directional/south
	dir = NORTH
	pixel_y = -26

/obj/machinery/light_switch/directional/east
	dir = WEST
	pixel_x = 26

/obj/machinery/light_switch/directional/west
	dir = EAST
	pixel_x = -26

/obj/machinery/light_switch/Initialize()
	. = ..()
	if(istext(area))
		area = text2path(area)
	if(ispath(area))
		area = GLOB.areas_by_type[area]
	if(!area)
		area = get_area(src)

	if(!name)
		name = "light switch ([area.name])"
	AddElement(/datum/element/wall_mount)

	update_appearance()

/obj/machinery/light_switch/update_appearance(updates=ALL)
	. = ..()
	luminosity = (machine_stat & NOPOWER) ? 0 : 1

/obj/machinery/light_switch/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]-p"
		return ..()
	icon_state = "[base_icon_state][area.lightswitch ? 1 : 0]"
	return ..()

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(!(machine_stat & NOPOWER))
		. += emissive_appearance(icon, "[base_icon_state]-glow", alpha = src.alpha)

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [area.lightswitch ? "on" : "off"]."

/obj/machinery/light_switch/interact(mob/user)
	. = ..()

	area.lightswitch = !area.lightswitch
	area.update_appearance()

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance()

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

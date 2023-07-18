//THIS TYPE IS WEIRD. THE BASE TYPE IS ACTUALLY AN EMPTY SHELL. USE /obj/machinery/light/floor/has_bulb FOR A PREBUILT
/obj/machinery/light/floor
	name = "floor light"
	icon = 'goon/icons/obj/lighting.dmi'
	base_state = "floor" // base description and icon_state
	icon_state = "floor"
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	light_type = /obj/item/light/bulb
	fitting = "bulb"

	overlay_icon = null

	status = LIGHT_EMPTY
	start_with_cell = FALSE

	bulb_inner_range = 0.5
	bulb_outer_range = 5
	// Floor lights use a steep falloff because they're pointing at the ceiling, they diffuse sharply as a result.
	bulb_falloff = LIGHTING_DEFAULT_FALLOFF_CURVE + 0.5

	nightshift_inner_range = 0.5
	nightshift_outer_range = 5
	nightshift_falloff = LIGHTING_DEFAULT_FALLOFF_CURVE + 1
	nightshift_light_power = 1
	nightshift_light_color = "#f2f9f7"

/obj/machinery/light/floor/has_bulb
	status = LIGHT_OK
	start_with_cell = TRUE

/obj/machinery/light/floor/update_icon_state()
	. = ..()
	if(status == LIGHT_OK)
		icon_state = on ? "floor" : "floor-off"

/obj/machinery/light/floor/deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & NODECONSTRUCT_1)
		qdel(src)
		return

	new /obj/item/stack/sheet/iron(loc, 2)

	qdel(src)

/obj/machinery/light/floor/attackby(obj/item/tool, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(istype(tool, /obj/item/stock_parts/cell))
		if(status != LIGHT_EMPTY)
			to_chat(user, span_warning("You must remove the lightbulb first!"))
			return
		if(!QDELETED(cell))
			to_chat(user, span_warning("There is already a cell inside of [src]!"))
			return

		src.cell = tool
		tool.forceMove(src)
		return TRUE

/obj/machinery/light/floor/wrench_act(mob/living/user, obj/item/tool)
	if(status != LIGHT_EMPTY)
		to_chat(user, span_warning("There is still a lightbulb inside of the fixture!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!QDELETED(cell))
		to_chat(user, span_warning("You must remove the cell first!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	visible_message(
		span_notice("[user] removes [src] from [loc]."),
		span_notice("You remove [src] from [loc]"),
		span_hear("You hear a soft metal clang."),
	)

	tool.play_tool_sound(src)
	deconstruct()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/light/floor/screwdriver_act(mob/living/user, obj/item/tool)
	if(status != LIGHT_EMPTY)
		to_chat(user, span_warning("There is still a lightbulb inside of [src]."))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(QDELETED(cell))
		to_chat(user, span_userdanger("You stick \the [tool] into the light socket!"))
		if(has_power() && (tool.flags_1 & CONDUCT_1))
			do_sparks(3, TRUE, src)
			if (prob(75))
				electrocute_mob(user, get_area(src), src, (rand(7,10) * 0.1), TRUE)
		return TOOL_ACT_TOOLTYPE_SUCCESS

	tool.play_tool_sound(loc)
	cell.forceMove(loc)
	cell = null
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/atmospherics/components/binary/thermomachine
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "thermo_base"

	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	hide = TRUE

	move_resist = MOVE_RESIST_DEFAULT
	vent_movement = NONE
	pipe_flags = PIPING_ONE_PER_TURF

	greyscale_config = /datum/greyscale_config/thermomachine
	greyscale_colors = COLOR_VIBRANT_LIME

	set_dir_on_move = FALSE

	var/min_temperature = T20C //actual temperature will be defined by RefreshParts() and by the cooling var
	var/max_temperature = T20C //actual temperature will be defined by RefreshParts() and by the cooling var
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.
	var/cooling = TRUE
	var/base_heating = 140
	var/base_cooling = 170
	var/use_enviroment_heat = FALSE
	var/skipping_work = FALSE
	var/safeties = TRUE
	var/lastwarning
	var/color_index = 1

	// Efficiency dictates how much we throttle the heat exchange process.
	var/efficiency = 1

/obj/machinery/atmospherics/components/binary/thermomachine/Initialize()
	. = ..()
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/on_construction(obj_color, set_layer)
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
		set_layer = piping_layer

	if(check_pipe_on_turf())
		deconstruct(TRUE)
		return
	return..()

/obj/machinery/atmospherics/components/binary/thermomachine/RefreshParts()
	var/calculated_bin_rating
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.rating
	heat_capacity = 7500 * ((calculated_bin_rating - 1) ** 2)
	min_temperature = T20C
	max_temperature = T20C
	var/calculated_laser_rating
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		calculated_laser_rating += laser.rating
	min_temperature = max(T0C - (base_cooling + calculated_laser_rating * 15), TCMB) //73.15K with T1 stock parts
	max_temperature = T20C + (base_heating * calculated_laser_rating) //573.15K with T1 stock parts

/obj/machinery/atmospherics/components/binary/thermomachine/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_notice("Something seems wrong with [src]'s thermal safeties.")
	. += span_notice("With the panel open:")
	. += span_notice("-use a wrench with left-click to rotate [src] and right-click to unanchor it.")
	. += span_notice("-use a multitool with left-click to change the piping layer and right-click to change the piping color.")
	. += span_notice("The thermostat is set to [target_temperature]K ([(T0C-target_temperature)*-1]C).")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("Heat capacity at <b>[heat_capacity] Joules per Kelvin</b>.")
		. += span_notice("Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C-min_temperature)*-1]C - [(T0C-max_temperature)*-1]C)</b>.")

/obj/machinery/atmospherics/components/binary/thermomachine/AltClick(mob/living/user)
	if(!can_interact(user))
		return
	target_temperature = T20C
	investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "temperature reset to [target_temperature] K")

/obj/machinery/atmospherics/components/binary/thermomachine/attackby(obj/item/item, mob/user, params)
	if(!on && item.tool_behaviour == TOOL_SCREWDRIVER)
		if(!anchored)
			to_chat(user, span_notice("Anchor [src] first!"))
			return
		if(default_deconstruction_screwdriver(user, "thermo-open", "thermo-0", item))
			change_pipe_connection(panel_open)
			return
	if(default_change_direction_wrench(user, item))
		return
	if(default_deconstruction_crowbar(item))
		return

	if(panel_open && item.tool_behaviour == TOOL_MULTITOOL)
		piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
		to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
		update_appearance()
		return
	return ..()

/obj/machinery/atmospherics/components/binary/thermomachine/attackby_secondary(obj/item/item, mob/user, params)
	. = ..()
	if(panel_open && item.tool_behaviour == TOOL_WRENCH && !check_pipe_on_turf())
		if(default_unfasten_wrench(user, item))
			return SECONDARY_ATTACK_CONTINUE_CHAIN
	if(panel_open && item.tool_behaviour == TOOL_MULTITOOL)
		color_index = (color_index >= GLOB.pipe_paint_colors.len) ? (color_index = 1) : (color_index = 1 + color_index)
		pipe_color = GLOB.pipe_paint_colors[GLOB.pipe_paint_colors[color_index]]
		visible_message("<span class='notice'>You set [src] pipe color to [GLOB.pipe_color_name[pipe_color]].")
		update_appearance()
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/machinery/atmospherics/components/binary/thermomachine/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(!istype(multitool))
		return
	if(panel_open && !anchored)
		piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
		to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
		update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/emag_act(mob/user)
	. = ..()
	if(!(obj_flags & EMAGGED))
		if(!do_after(user, 1 SECONDS, src))
			return
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 0, src)
		sparks.attach(src)
		sparks.start()
		obj_flags |= EMAGGED
		user.visible_message(span_warning("You emag [src], overwriting thermal safety restrictions."))
		log_game("[key_name(user)] emagged [src] at [AREACOORD(src)], overwriting thermal safety restrictions.")

/obj/machinery/atmospherics/components/binary/thermomachine/emp_act()
	. = ..()
	if(!(obj_flags & EMAGGED))
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 0, src)
		sparks.attach(src)
		sparks.start()
		obj_flags |= EMAGGED
		safeties = FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/CtrlClick(mob/living/user)
	if(!panel_open)
		if(!can_interact(user))
			return
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
		return
	. = ..()

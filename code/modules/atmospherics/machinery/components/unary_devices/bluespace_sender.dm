/obj/machinery/atmospherics/components/unary/bluespace_sender
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"

	var/datum/gas_mixture/bluespace_contents

/obj/machinery/atmospherics/components/unary/bluespace_sender/Initialize()
	. = ..()
	initialize_directions = dir
	bluespace_contents = new

/obj/machinery/atmospherics/components/unary/bluespace_sender/update_icon_state()
	if(panel_open)
		icon_state = icon_state_open
		return ..()
	if(on && is_operational)
		icon_state = icon_state_on
		return ..()
	icon_state = icon_state_off
	return ..()

/obj/machinery/atmospherics/components/unary/bluespace_sender/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/bluespace_sender/process_atmos()
	if(!is_operational || !on || !nodes[1])  //if it has no power or its switched off, dont process atmos
		return

	var/datum/gas_mixture/content = airs[1]
	var/datum/gas_mixture/remove = content.remove_ratio(0.5)
	bluespace_contents.merge(remove)

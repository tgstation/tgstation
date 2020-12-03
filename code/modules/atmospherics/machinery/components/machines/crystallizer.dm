/obj/machinery/atmospherics/components/unary/crystallizer
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"

	name = "crystallizer"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	pipe_flags = PIPING_ONE_PER_TURF

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"

/obj/machinery/atmospherics/components/unary/crystallizer/Initialize()
	. = ..()
	initialize_directions = dir

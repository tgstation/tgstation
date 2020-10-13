#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))
/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPING_ONE_PER_TURF

	var/volume = 10000 //in liters
	/// The typepath of the gas this tank should be filled with.
	var/gas_type = null

/obj/machinery/atmospherics/components/unary/tank/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = volume
	air_contents.temperature = T20C
	if(gas_type)
		air_contents.assert_gas(gas_type)
		air_contents.gases[gas_type][MOLES] = AIR_CONTENTS
		name = "[name] ([air_contents.gases[gas_type][GAS_META][META_GAS_NAME]])"
	setPipingLayer(piping_layer)


/obj/machinery/atmospherics/components/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/unary/tank/air/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = AIR_CONTENTS * 0.2
	air_contents.gases[/datum/gas/nitrogen][MOLES] = AIR_CONTENTS * 0.8

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/atmospherics/components/unary/tank/toxins
	icon_state = "orange"
	gas_type = /datum/gas/plasma

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "red"
	gas_type = /datum/gas/nitrogen

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "blue"
	gas_type = /datum/gas/oxygen

/obj/machinery/atmospherics/components/unary/tank/nitrous
	icon_state = "red_white"
	gas_type = /datum/gas/nitrous_oxide

/obj/machinery/atmospherics/components/unary/tank/bz
	gas_type = /datum/gas/bz

/obj/machinery/atmospherics/components/unary/tank/freon
	icon_state = "blue"
	gas_type = /datum/gas/freon

/obj/machinery/atmospherics/components/unary/tank/halon
	icon_state = "blue"
	gas_type = /datum/gas/halon

/obj/machinery/atmospherics/components/unary/tank/healium
	icon_state = "red"
	gas_type = /datum/gas/healium

/obj/machinery/atmospherics/components/unary/tank/hexane
	gas_type = /datum/gas/hexane

/obj/machinery/atmospherics/components/unary/tank/hydrogen
	icon_state = "grey"
	gas_type = /datum/gas/hydrogen

/obj/machinery/atmospherics/components/unary/tank/hypernoblium
	icon_state = "blue"
	gas_type = /datum/gas/hypernoblium

/obj/machinery/atmospherics/components/unary/tank/miasma
	gas_type = /datum/gas/miasma

/obj/machinery/atmospherics/components/unary/tank/nitryl
	gas_type = /datum/gas/nitryl

/obj/machinery/atmospherics/components/unary/tank/pluoxium
	icon_state = "blue"
	gas_type = /datum/gas/pluoxium

/obj/machinery/atmospherics/components/unary/tank/proto_nitrate
	icon_state = "red"
	gas_type = /datum/gas/proto_nitrate

/obj/machinery/atmospherics/components/unary/tank/stimulum
	icon_state = "red"
	gas_type = /datum/gas/stimulum

/obj/machinery/atmospherics/components/unary/tank/tritium
	gas_type = /datum/gas/tritium

/obj/machinery/atmospherics/components/unary/tank/water_vapor
	icon_state = "grey"
	gas_type = /datum/gas/water_vapor

/obj/machinery/atmospherics/components/unary/tank/zauker
	gas_type = /datum/gas/zauker

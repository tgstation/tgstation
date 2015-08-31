#define AIR_CONTENTS	(25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."
	var/volume = 10000 //in liters, 1 meters by 1 meters by 2 meters
	density = 1

/obj/machinery/atmospherics/components/unary/tank/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = volume
	air_contents.temperature = T20C

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	name = "pressure tank (Carbon Dioxide)"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.carbon_dioxide = AIR_CONTENTS

/obj/machinery/atmospherics/components/unary/tank/toxins
	icon_state = "orange"
	name = "pressure tank (Plasma)"

/obj/machinery/atmospherics/components/unary/tank/toxins/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.toxins = AIR_CONTENTS

/obj/machinery/atmospherics/components/unary/tank/oxygen_agent_b
	icon_state = "orange_2"
	name = "pressure tank (Oxygen + Plasma)"

/obj/machinery/atmospherics/components/unary/tank/oxygen_agent_b/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = AIR_CONTENTS
	air_contents.trace_gases += trace_gas

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "blue"
	name = "pressure tank (Oxygen)"

/obj/machinery/atmospherics/components/unary/tank/oxygen/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.oxygen = AIR_CONTENTS

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "red"
	name = "pressure tank (Nitrogen)"

/obj/machinery/atmospherics/components/unary/tank/nitrogen/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.nitrogen = AIR_CONTENTS

/obj/machinery/atmospherics/components/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/unary/tank/air/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.oxygen = AIR_CONTENTS
	air_contents.nitrogen = AIR_CONTENTS
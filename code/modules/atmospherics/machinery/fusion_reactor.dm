#define LOW_HEAT_THRESHOLD 1e10
#define HIGH_HEAT_THRESHOLD 1e14
#define MAX_POSSIBLE_HEAT 1e18
#define MOLES_THRESHOLD 2000
#define POWER_THRESHOLD 5000
#define LIGHT_SPEED 299792458
#define PLASMA_CONVERSION_FACTOR 1e-8
#define FUEL_CONVERSION_FACTOR 1e-9
#define PLANK_LIGHT_CONSTANT 2e-16
#define CALCULATED_H2RADIUS 120e-4
#define CALCULATED_TRITRADIUS 230e-3
#define HIGH_RADIATION_FACTOR 1e-6
#define VOID_CONDUCTION 1e-2
#define MAX_FUSION_RESEARCH 1000

/obj/machinery/atmospherics/fusion_reactor
	name = "Fusion Reactor Core"
	desc = "The core machine for a fusion reactor"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "heater-p"
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	critical_machine = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40


	var/gasefficency = 0.15
	var/gas_change_rate = 0.05
	var/active = FALSE
	var/combined_gas = 0
	var/Energy = 0
	var/InternalPower = 0
	var/Conduction = 0
	var/Radiation = 0
	var/deltaTemperature = 0
	var/Wavelenght = 0
	var/efficiency = 0
	var/PowerOutput = 0
	var/Core_temperature = 273
	var/gas_power = 0
	var/Instability = 0
	var/heat_factor = 1

	var/lasercomp = 1 //those need to be tied to the internal components
	var/upgrades = 1
	var/materialConduct = 0.005


	var/plasmacomp = 0
	var/tritiumcomp = 0
	var/h2comp = 0

/obj/machinery/atmospherics/fusion_reactor/Initialize()
	. = ..()
	SSair.atmos_machinery += src

/obj/machinery/atmospherics/fusion_reactor/Destroy()
	SSair.atmos_machinery -= src
	return ..()

/obj/machinery/atmospherics/fusion_reactor/process_atmos()
	var/turf/T = loc

	if(isnull(T))// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(T))//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(isclosedturf(T))
		var/turf/did_it_melt = T.Melt()
		if(!isclosedturf(did_it_melt)) //In case some joker finds way to place these on indestructible walls
			visible_message("<span class='warning'>[src] melts through [T]!</span>")
		return
	if (src.machine_stat != NONE) //NOPOWER etc
		return
	var/datum/gas_mixture/env = T.return_air()
	var/datum/gas_mixture/external
	if(Core_temperature < 1e6)
		active = FALSE
		icon_state = "heater-p"
		return
	if(active)
		icon_state = "heater1"
		//Remove gas from surrounding area
		external = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		external = new()
	if(!external || !external.total_moles() || isspaceturf(T)) //we're in space or there is no gas to process
		return
	else
		var/archived_heat = external.temperature
		external.assert_gases(/datum/gas/plasma, /datum/gas/tritium, /datum/gas/hydrogen)
		combined_gas = max(external.total_moles(), 0)
		plasmacomp += clamp(max(external.gases[/datum/gas/plasma][MOLES]/combined_gas, 0) - plasmacomp, -1, gas_change_rate)
		tritiumcomp += clamp(max(external.gases[/datum/gas/tritium][MOLES]/combined_gas, 0) - tritiumcomp, -1, gas_change_rate)
		h2comp += clamp(max(external.gases[/datum/gas/hydrogen][MOLES]/combined_gas, 0) - h2comp, -1, gas_change_rate)

		if(external.gases[/datum/gas/tritium][MOLES] < 5 || external.gases[/datum/gas/hydrogen][MOLES] < 5)
			active = FALSE
			env.merge(external)
			air_update_turf()
			return

		var/toroidal_size = (2 * PI) + TORADIANS(arctan((combined_gas * 10 - TOROID_VOLUME_BREAKEVEN) / TOROID_VOLUME_BREAKEVEN)) //The size of the phase space hypertorus
		gas_power = 0
		gas_power += external.gases[/datum/gas/tritium][MOLES] * 55
		gas_power += external.gases[/datum/gas/hydrogen][MOLES] * 45
		gas_power += external.gases[/datum/gas/plasma][MOLES] * -100 * upgrades
		Instability = 0
		Instability += MODULUS((gas_power * INSTABILITY_GAS_POWER_FACTOR)**2,toroidal_size)
		var/internal_instability = 0
		if(Instability < FUSION_INSTABILITY_ENDOTHERMALITY)
			internal_instability = 1
		else
			internal_instability = -1
		if(archived_heat > Core_temperature)
			internal_instability = 10

		Energy += internal_instability * ((external.gases[/datum/gas/hydrogen][MOLES] + external.gases[/datum/gas/tritium][MOLES] - external.gases[/datum/gas/plasma][MOLES]) * LIGHT_SPEED ** 2)
		InternalPower = heat_factor * (external.gases[/datum/gas/hydrogen][MOLES] / 4000 * upgrades) * (external.gases[/datum/gas/tritium][MOLES] / 4000 * upgrades) * (PI * (2 * (external.gases[/datum/gas/hydrogen][MOLES] / 100 * CALCULATED_H2RADIUS) * (external.gases[/datum/gas/tritium][MOLES] / 100 * CALCULATED_TRITRADIUS))**2) * Energy
		Core_temperature += InternalPower / (1000 * upgrades)
		Core_temperature = max(TCMB, Core_temperature)
		heat_factor = Core_temperature / 1e5
		deltaTemperature = archived_heat - Core_temperature
		Conduction = - materialConduct * deltaTemperature
		Radiation = max(- (PLANK_LIGHT_CONSTANT / ((0.0005/lasercomp) * 1e-14)) * deltaTemperature, 0)
		efficiency = VOID_CONDUCTION * upgrades
		PowerOutput = max(efficiency * (InternalPower - Conduction - Radiation), 0)

		external.temperature += Conduction
		external.temperature = clamp(external.temperature, MAX_POSSIBLE_HEAT, TCMB)

		if(InternalPower < 0)
			InternalPower = - InternalPower
		external.gases[/datum/gas/plasma][MOLES] += InternalPower * PLASMA_CONVERSION_FACTOR
		external.gases[/datum/gas/hydrogen][MOLES] -= InternalPower * FUEL_CONVERSION_FACTOR * 1.5
		external.gases[/datum/gas/tritium][MOLES] -= InternalPower * FUEL_CONVERSION_FACTOR * 1.8

		if(PowerOutput < 0)
			PowerOutput = - PowerOutput
		SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min(PowerOutput, MAX_FUSION_RESEARCH))

		idle_power_usage = Core_temperature / (1e4 * upgrades)

		radiation_pulse(src, Radiation * HIGH_RADIATION_FACTOR)
		if(prob(30))
			src.fire_nuclear_particle()
		env.merge(external)
		air_update_turf()

/obj/machinery/atmospherics/fusion_reactor/interact(mob/user)
	if(!active)
		active = TRUE
	else
		active = FALSE

/obj/machinery/atmospherics/fusion_reactor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		Core_temperature += 1000000



/*
Energy = (H2 + Trit − Plasma) * c**2 (comp) c = 299,792,458						(0.4+0.4-0.2)*299,792,458**2 = 8.9875518e+16
Power = densityH2 * densityTrit(Pi * (2 * rH2 * rTrit)**2) * Energy				(50/4000) * (500/4000) * (3.1415 * (2 * 0.9 * 120e-5 * 0.1 * 230e-2)**2)*8.9875518e+16
PowerOut = efficiency * (Power - Conduction - Radiation)
Conduction = materialConduct * deltaT
Radiation = 2*10**-16/wavelenght
Plasma generation = 1/16 * (H2 + Trit)
densityH2 = molesH2 / volume(upgradeable)
densityTrit = molesTrit / volume(upgradeable)
rH2 = constant
rTrit = constant
materialConduct = dependable on the material (upgradeable)
deltaT = dependable on the material (upgradeable)
wavelenght = radiation output
*/
//
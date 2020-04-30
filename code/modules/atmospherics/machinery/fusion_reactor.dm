#define LOW_HEAT_THRESHOLD 1e6
#define HIGH_HEAT_THRESHOLD 1e10
#define MOLES_THRESHOLD 2000
#define POWER_THRESHOLD 5000
#define MAX_POSSIBLE_HEAT 1e13

#define DAMAGE_HARDCAP 0.002

/obj/machinery/atmospherics/fusion_reactor
	name = "Fusion Reactor Core"
	desc = "The core machine for a fusion reactor"
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter"
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	critical_machine = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40

	var/explosion_point = 900

	var/gasefficency = 0.15
	var/core_integrity = 100
	var/core_integrity_archived = 100
	var/active = TRUE
	var/produces_heat = TRUE
	var/combined_gas = 0
	var/power = 0
	var/dynamic_heat_loss = 0
	var/dynamic_heat_power = 0
	var/dynamic_moles_power = 0
	var/mole_heat_penalty = 0
	var/calculated_power = 0

	var/gas_change_rate = 0.05

	var/n2comp = 0
	var/plasmacomp = 0
	var/o2comp = 0
	var/co2comp = 0
	var/n2ocomp = 0
	var/tritiumcomp = 0
	var/bzcomp = 0
	var/pluoxiumcomp = 0
	var/h2ocomp = 0
	var/freoncomp = 0
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
	var/datum/gas_mixture/core
	if(active)
		//Remove gas from surrounding area
		core = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		core = new()
	var/heat = core.temperature
	core_integrity_archived = core_integrity
	if(!core || !core.total_moles() || isspaceturf(T)) //we're in space or there is no gas to process
		return
	else
		if(produces_heat)
			core_integrity = min(core_integrity - max((clamp(core.total_moles() / 200, 0.5, 1) * (max(heat / HIGH_HEAT_THRESHOLD, 0) / 100) - T0C * dynamic_heat_loss), 0) * mole_heat_penalty / 150, core_integrity)
			core_integrity = min(core_integrity - max(power - POWER_THRESHOLD, 0) / 500, core_integrity)
			core_integrity = min(core_integrity - max(combined_gas - MOLES_THRESHOLD, 0) / 90, core_integrity)
			if(combined_gas < MOLES_THRESHOLD && power < POWER_THRESHOLD && heat < HIGH_HEAT_THRESHOLD)
				core_integrity = max(core_integrity + clamp((heat/LOW_HEAT_THRESHOLD) / 10, 0.5, 5), core_integrity)

			core_integrity = max(core_integrity_archived - (DAMAGE_HARDCAP * explosion_point), core_integrity)
		core.assert_gases(/datum/gas/oxygen, /datum/gas/water_vapor, /datum/gas/plasma, /datum/gas/carbon_dioxide, /datum/gas/nitrous_oxide, /datum/gas/nitrogen, /datum/gas/pluoxium, /datum/gas/tritium, /datum/gas/bz, /datum/gas/freon, /datum/gas/hydrogen)
		combined_gas = max(core.total_moles(), 0)
		plasmacomp += clamp(max(core.gases[/datum/gas/plasma][MOLES]/combined_gas, 0) - plasmacomp, -1, gas_change_rate)
		o2comp += clamp(max(core.gases[/datum/gas/oxygen][MOLES]/combined_gas, 0) - o2comp, -1, gas_change_rate)
		co2comp += clamp(max(core.gases[/datum/gas/carbon_dioxide][MOLES]/combined_gas, 0) - co2comp, -1, gas_change_rate)
		pluoxiumcomp += clamp(max(core.gases[/datum/gas/pluoxium][MOLES]/combined_gas, 0) - pluoxiumcomp, -1, gas_change_rate)
		tritiumcomp += clamp(max(core.gases[/datum/gas/tritium][MOLES]/combined_gas, 0) - tritiumcomp, -1, gas_change_rate)
		bzcomp += clamp(max(core.gases[/datum/gas/bz][MOLES]/combined_gas, 0) - bzcomp, -1, gas_change_rate)
		n2ocomp += clamp(max(core.gases[/datum/gas/nitrous_oxide][MOLES]/combined_gas, 0) - n2ocomp, -1, gas_change_rate)
		n2comp += clamp(max(core.gases[/datum/gas/nitrogen][MOLES]/combined_gas, 0) - n2comp, -1, gas_change_rate)
		h2ocomp += clamp(max(core.gases[/datum/gas/water_vapor][MOLES]/combined_gas, 0) - h2ocomp, -1, gas_change_rate)
		freoncomp += clamp(max(core.gases[/datum/gas/freon][MOLES]/combined_gas, 0) - freoncomp, -1, gas_change_rate)
		h2comp += clamp(max(core.gases[/datum/gas/hydrogen][MOLES]/combined_gas, 0) - h2comp, -1, gas_change_rate)

		dynamic_heat_loss = max(freoncomp + pluoxiumcomp + h2ocomp, 0)
		dynamic_heat_power = max(plasmacomp + co2comp + tritiumcomp + h2comp + bzcomp, 0)
		dynamic_moles_power = max(plasmacomp + o2comp + co2comp - pluoxiumcomp + tritiumcomp + bzcomp - n2ocomp - n2comp - h2ocomp + freoncomp + h2comp, 0)
		calculated_power = clamp(heat/LOW_HEAT_THRESHOLD + dynamic_heat_power * 150 + dynamic_moles_power * 100, -10, 10)

		var/list/cached_gases = core.gases

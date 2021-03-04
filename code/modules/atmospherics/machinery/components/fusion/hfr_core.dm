/**
 * This section contain the hfr core with all the variables and the Initialize() and Destroy() procs
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core
	name = "HFR core"
	desc = "This is the Hypertorus Fusion Reactor core, an advanced piece of technology to finely tune the reaction inside of the machine. It has I/O for cooling gases."
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core_off"
	circuit = /obj/item/circuitboard/machine/HFR_core
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	///Vars for the state of the icon of the object (open, off, active)
	icon_state_open = "core_open"
	icon_state_off = "core_off"
	icon_state_active = "core_active"

	/**
	 * Processing checks
	 */

	///Checks if the user has started the machine
	var/start_power = FALSE
	///Checks for the cooling to start
	var/start_cooling = FALSE
	///Checks for the fuel to be injected
	var/start_fuel = FALSE

	/**
	 * Hypertorus internal objects and gasmixes
	 */

	///Stores the informations of the interface machine
	var/obj/machinery/hypertorus/interface/linked_interface
	///Stores the information of the moderator input
	var/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input/linked_moderator
	///Stores the information of the fuel input
	var/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input/linked_input
	///Stores the information of the waste output
	var/obj/machinery/atmospherics/components/unary/hypertorus/waste_output/linked_output
	///Stores the information of the corners of the machine
	var/list/corners = list()
	///Stores the information of the fusion gasmix
	var/datum/gas_mixture/internal_fusion
	///Stores the information of the moderators gasmix
	var/datum/gas_mixture/moderator_internal
	///Set the filtering type of the waste remove
	var/filter_type = null

	/**
	 * Fusion vars
	 */

	///E=mc^2 with some addition to allow it gameplaywise
	var/energy = 0
	///Temperature of the center of the fusion reaction
	var/core_temperature = T20C
	/**Power emitted from the center of the fusion reaction: Internal power = densityH2 * densityTrit(Pi * (2 * rH2 * rTrit)**2) * Energy
	* density is calculated with moles/volume, rH2 and rTrit are values calculated with moles/(radius of the gas)
	both of the density can be varied by the power_modifier
	**/
	var/internal_power = 0
	/**The effective power transmission of the fusion reaction, power_output = efficiency * (internal_power - conduction - radiation)
	* Conduction is the heat value that is transmitted by the molecular interactions and it gets removed from the internal_power lowering the effective output
	* Radiation is the irradiation released by the fusion reaction, it comprehends all wavelenghts in the spectrum, it lowers the effective output of the reaction
	**/
	var/power_output = 0
	///Instability effects how chaotic the behavior of the reaction is
	var/instability = 0
	///Amount of radiation that the machine can output
	var/rad_power = 0
	///Difference between the gases temperature and the internal temperature of the reaction
	var/delta_temperature = 0
	///Energy from the reaction lost from the molecule colliding between themselves.
	var/conduction = 0
	///The remaining wavelength that actually can do damage to mobs.
	var/radiation = 0
	///Efficiency of the reaction, it increases with the amount of plasma
	var/efficiency = 0
	///Hotter air is easier to heat up and cool down
	var/heat_limiter_modifier = 0
	///The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	var/heat_output = 0

	///Stores the moles of the gases (the ones with m_ are of the moderator mix)
	var/tritium = 0
	var/hydrogen = 0
	var/helium = 0

	var/m_plasma = 0
	var/m_nitrogen = 0
	var/m_oxygen = 0
	var/m_co2 = 0
	var/m_h2o = 0
	var/m_n2o = 0
	var/m_no2 = 0
	var/m_freon = 0
	var/m_bz = 0
	var/m_proto_nitrate = 0
	var/m_healium = 0
	var/m_zauker = 0
	var/m_antinoblium = 0
	var/m_hypernoblium = 0

	///Check if the user want to remove the waste gases
	var/waste_remove = FALSE
	///User controlled variable to control the flow of the fusion by changing the contact of the material
	var/heating_conductor = 100
	///User controlled variable to control the flow of the fusion by changing the volume of the gasmix by controlling the power of the magnetic fields
	var/magnetic_constrictor  = 100
	///User controlled variable to control the flow of the fusion by changing the instability of the reaction
	var/current_damper = 0
	///Stores the current fusion mix power level
	var/power_level = 0
	///Stores the iron content produced by the fusion
	var/iron_content = 0
	///User controlled variable to control the flow of the fusion by changing the amount of fuel injected
	var/fuel_injection_rate = 250
	///User controlled variable to control the flow of the fusion by changing the amount of moderators injected
	var/moderator_injection_rate = 250

	///Integrity of the machine, if reaches 900 the machine will explode
	var/critical_threshold_proximity = 0
	///Store the integrity for calculations
	var/critical_threshold_proximity_archived = 0
	///Our "Shit is no longer fucked" message. We send it when critical_threshold_proximity is less then critical_threshold_proximity_archived
	var/safe_alert = "Main containment field returning to safe operating parameters."
	///The point at which we should start sending messeges about the critical_threshold_proximity to the engi channels.
	var/warning_point = 50
	///The alert we send when we've reached warning_point
	var/warning_alert = "Danger! Magnetic containment field faltering!"
	///The point at which we start sending messages to the common channel
	var/emergency_point = 700
	///The alert we send when we've reached emergency_point
	var/emergency_alert = "HYPERTORUS MELTDOWN IMMINENT."
	///The point at which we melt
	var/melting_point = 900
	///Boolean used for logging if we've passed the emergency point
	var/has_reached_emergency = FALSE
	///Time in 1/10th of seconds since the last sent warning
	var/lastwarning = 0

	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_eng
	///The engineering channel
	var/engineering_channel = "Engineering"
	///The common channel
	var/common_channel = null

	///Our soundloop
	var/datum/looping_sound/hypertorus/soundloop
	///cooldown tracker for accent sounds
	var/last_accent_sound = 0

	///These vars store the temperatures to be used in the GUI
	var/fusion_temperature = 0
	var/moderator_temperature = 0
	var/coolant_temperature = 0
	var/output_temperature = 0
	///Var used in the meltdown phase
	var/final_countdown = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/core/Initialize()
	. = ..()
	internal_fusion = new
	internal_fusion.assert_gases(/datum/gas/hydrogen, /datum/gas/tritium)
	moderator_internal = new

	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()
	investigate_log("has been created.", INVESTIGATE_HYPERTORUS)

/obj/machinery/atmospherics/components/unary/hypertorus/core/Destroy()
	unregister_signals(TRUE)
	if(internal_fusion)
		internal_fusion = null
	if(moderator_internal)
		moderator_internal = null
	if(linked_input)
		QDEL_NULL(linked_input)
	if(linked_output)
		QDEL_NULL(linked_output)
	if(linked_moderator)
		QDEL_NULL(linked_moderator)
	if(linked_interface)
		QDEL_NULL(linked_interface)
	for(var/obj/machinery/hypertorus/corner/corner in corners)
		QDEL_NULL(corner)
	QDEL_NULL(radio)
	QDEL_NULL(soundloop)
	return..()

///Max amount of radiation that can be emitted per reaction cycle
#define FUSION_RAD_MAX 5000
///Maximum instability before the reaction goes endothermic
#define FUSION_INSTABILITY_ENDOTHERMALITY   4
///Maximum reachable fusion temperature
#define FUSION_MAXIMUM_TEMPERATURE 1e8
///Speed of light, in m/s
#define LIGHT_SPEED 299792458
///Calculation between the plank constant and the lambda of the lightwave
#define PLANCK_LIGHT_CONSTANT 2e-16
///Radius of the h2 calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_H2RADIUS 120e-4
///Radius of the trit calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_TRITRADIUS 230e-3
///Power conduction in the void, used to calculate the efficiency of the reaction
#define VOID_CONDUCTION 1e-2
///Max reaction point per reaction cycle
#define MAX_FUSION_RESEARCH 1000
///Min amount of allowed heat change
#define MIN_HEAT_VARIATION -1e5
///Max amount of allowed heat change
#define MAX_HEAT_VARIATION 1e5
///Max mole consumption per reaction cycle
#define MAX_FUEL_USAGE 36
///Mole count required (tritium/hydrogen) to start a fusion reaction
#define FUSION_MOLE_THRESHOLD 25
///Used to reduce the gas_power to a more useful amount
#define INSTABILITY_GAS_POWER_FACTOR 0.003
///Used to calculate the toroidal_size for the instability
#define TOROID_VOLUME_BREAKEVEN 1000
///Constant used when calculating the chance of emitting a radioactive particle
#define PARTICLE_CHANCE_CONSTANT (-20000000)
///Conduction of heat inside the fusion reactor
#define METALLIC_VOID_CONDUCTIVITY 0.15
///Conduction of heat near the external cooling loop
#define HIGH_EFFICIENCY_CONDUCTIVITY 0.95
///Sets the range of the hallucinations
#define HALLUCINATION_RANGE(P) (min(7, round(abs(P) ** 0.25)))
///Sets the minimum amount of power the machine uses
#define MIN_POWER_USAGE 50000

#define DAMAGE_CAP_MULTIPLIER 0.005

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define HYPERTORUS_MELTING_PERCENT 5
#define HYPERTORUS_EMERGENCY_PERCENT 25
#define HYPERTORUS_DANGER_PERCENT 50
#define HYPERTORUS_WARNING_PERCENT 100

#define WARNING_TIME_DELAY 60
///to prevent accent sounds from layering
#define HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN 3 SECONDS

#define HYPERTORUS_COUNTDOWN_TIME 30 SECONDS

/obj/machinery/atmospherics/components/unary/hypertorus
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	layer = OBJ_LAYER
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/thermomachine
	///Vars for the state of the icon of the object (open, off, active)
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	///Check if the machine has been activated
	var/active = FALSE
	///Check if fusion has started
	var/fusion_started = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/Initialize()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/hypertorus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.</span>"

/obj/machinery/atmospherics/components/unary/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(.)
		SetInitDirections()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
			nullifyPipenet(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/unary/hypertorus/update_icon()
	. = ..()
	if(panel_open)
		icon_state = icon_state_open
	else if(active)
		icon_state = icon_state_active
	else
		icon_state = icon_state_off

/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	name = "HFR fuel input port"
	desc = "Input port for the Hypertorus Fusion Reactor, designed to take in only Hydrogen and Tritium in gas forms."
	icon_state = "fuel_input_off"
	icon_state_open = "fuel_input_open"
	icon_state_off = "fuel_input_off"
	icon_state_active = "fuel_input_active"
	circuit = /obj/item/circuitboard/machine/HFR_fuel_input

/obj/machinery/atmospherics/components/unary/hypertorus/waste_output
	name = "HFR waste output port"
	desc = "Waste port for the Hypertorus Fusion Reactor, designed to output the hot waste gases coming from the core of the machine."
	icon_state = "waste_output_off"
	icon_state_open = "waste_output_open"
	icon_state_off = "waste_output_off"
	icon_state_active = "waste_output_active"
	circuit = /obj/item/circuitboard/machine/HFR_waste_output

/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input
	name = "HFR moderator input port"
	desc = "Moderator port for the Hypertorus Fusion Reactor, designed to move gases inside the machine to cool and control the flow of the reaction."
	icon_state = "moderator_input_off"
	icon_state_open = "moderator_input_open"
	icon_state_off = "moderator_input_off"
	icon_state_active = "moderator_input_active"
	circuit = /obj/item/circuitboard/machine/HFR_moderator_input

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

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_part_connectivity()
	. = TRUE
	if(!anchored || panel_open)
		return FALSE

	for(var/obj/machinery/hypertorus/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(istype(object,/obj/machinery/hypertorus/corner))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				. =  FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != SOUTH)
						. = FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						. =  FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						. =  FALSE
				if(NORTHWEST)
					if(object.dir != NORTH)
						. =  FALSE
			corners |= object
			continue

		if(get_step(object,turn(object.dir,180)) != loc)
			. =  FALSE

		if(istype(object,/obj/machinery/hypertorus/interface))
			if(linked_interface && linked_interface != object)
				. =  FALSE
			linked_interface = object

	for(var/obj/machinery/atmospherics/components/unary/hypertorus/object in orange(1,src))
		if(. == FALSE)
			break

		if(object.panel_open)
			. = FALSE

		if(get_step(object,turn(object.dir,180)) != loc)
			. =  FALSE

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input))
			if(linked_input && linked_input != object)
				. =  FALSE
			linked_input = object

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/waste_output))
			if(linked_output && linked_output != object)
				. =  FALSE
			linked_output = object

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input))
			if(linked_moderator && linked_moderator != object)
				. =  FALSE
			linked_moderator = object

	if(!linked_interface || !linked_input || !linked_moderator || !linked_output || corners.len != 4)
		. = FALSE


/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/activate(mob/living/user)
	if(active)
		to_chat(user, "<span class='notice'>You already activated the machine.</span>")
		return
	to_chat(user, "<span class='notice'>You link all parts toghether.</span>")
	active = TRUE
	update_icon()
	linked_interface.active = TRUE
	linked_interface.update_icon()
	RegisterSignal(linked_interface, COMSIG_PARENT_QDELETING, .proc/unregister_signals)
	linked_input.active = TRUE
	linked_input.update_icon()
	RegisterSignal(linked_input, COMSIG_PARENT_QDELETING, .proc/unregister_signals)
	linked_output.active = TRUE
	linked_output.update_icon()
	RegisterSignal(linked_output, COMSIG_PARENT_QDELETING, .proc/unregister_signals)
	linked_moderator.active = TRUE
	linked_moderator.update_icon()
	RegisterSignal(linked_moderator, COMSIG_PARENT_QDELETING, .proc/unregister_signals)
	for(var/obj/machinery/hypertorus/corner/corner in corners)
		corner.active = TRUE
		corner.update_icon()
		RegisterSignal(corner, COMSIG_PARENT_QDELETING, .proc/unregister_signals)
	soundloop = new(list(src), TRUE)
	soundloop.volume = 5

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/unregister_signals(only_signals = FALSE)
	UnregisterSignal(linked_interface, COMSIG_PARENT_QDELETING)
	UnregisterSignal(linked_input, COMSIG_PARENT_QDELETING)
	UnregisterSignal(linked_output, COMSIG_PARENT_QDELETING)
	UnregisterSignal(linked_moderator, COMSIG_PARENT_QDELETING)
	for(var/obj/machinery/hypertorus/corner/corner in corners)
		UnregisterSignal(corner, COMSIG_PARENT_QDELETING)
	if(!only_signals)
		deactivate()

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/deactivate()
	if(!active)
		return
	active = FALSE
	update_icon()
	if(linked_interface)
		linked_interface.active = FALSE
		linked_interface.update_icon()
		linked_interface = null
	if(linked_input)
		linked_input.active = FALSE
		linked_input.update_icon()
		linked_input = null
	if(linked_output)
		linked_output.active = FALSE
		linked_output.update_icon()
		linked_output = null
	if(linked_moderator)
		linked_moderator.active = FALSE
		linked_moderator.update_icon()
		linked_moderator = null
	if(corners.len)
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.active = FALSE
			corner.update_icon()
		corners = list()
	QDEL_NULL(soundloop)

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_fuel()
	return (internal_fusion.gases[/datum/gas/tritium][MOLES] > FUSION_MOLE_THRESHOLD && internal_fusion.gases[/datum/gas/hydrogen][MOLES] > FUSION_MOLE_THRESHOLD)

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_power_use()
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	if(use_power == ACTIVE_POWER_USE)
		active_power_usage = ((power_level + 1) * MIN_POWER_USAGE) //Max around 350 KW
	return TRUE

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/get_status()
	var/integrity = get_integrity()
	if(integrity < HYPERTORUS_MELTING_PERCENT)
		return HYPERTORUS_MELTING

	if(integrity < HYPERTORUS_EMERGENCY_PERCENT)
		return HYPERTORUS_EMERGENCY

	if(integrity < HYPERTORUS_DANGER_PERCENT)
		return HYPERTORUS_DANGER

	if(integrity < HYPERTORUS_WARNING_PERCENT)
		return HYPERTORUS_WARNING

	if(power_level > 0)
		return HYPERTORUS_NOMINAL
	return HYPERTORUS_INACTIVE

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/alarm()
	switch(get_status())
		if(HYPERTORUS_MELTING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(HYPERTORUS_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(HYPERTORUS_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(HYPERTORUS_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/get_integrity()
	var/integrity = critical_threshold_proximity / melting_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/check_alert()
	if(critical_threshold_proximity < warning_point)
		return
	if((REALTIMEOFDAY - lastwarning) / 10 >= WARNING_TIME_DELAY)
		alarm()

		if(critical_threshold_proximity > emergency_point)
			radio.talk_into(src, "[emergency_alert] Integrity: [get_integrity()]%", common_channel)
			lastwarning = REALTIMEOFDAY
			if(!has_reached_emergency)
				investigate_log("has reached the emergency point for the first time.", INVESTIGATE_HYPERTORUS)
				message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
				has_reached_emergency = TRUE
		else if(critical_threshold_proximity >= critical_threshold_proximity_archived) // The damage is still going up
			radio.talk_into(src, "[warning_alert] Integrity: [get_integrity()]%", engineering_channel)
			lastwarning = REALTIMEOFDAY - (WARNING_TIME_DELAY * 5)

		else // Phew, we're safe
			radio.talk_into(src, "[safe_alert] Integrity: [get_integrity()]%", engineering_channel)
			lastwarning = REALTIMEOFDAY

	//Melt
	if(critical_threshold_proximity > melting_point)
		countdown()

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE

	var/speaking = "[emergency_alert] The Hypertorus fusion reactor has reached critical integrity failure. Emergency magnetic dampeners online."
	radio.talk_into(src, speaking, common_channel, language = get_selected_language())
	for(var/i in HYPERTORUS_COUNTDOWN_TIME to 0 step -10)
		if(critical_threshold_proximity < melting_point) // Cutting it a bit close there engineers
			radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			final_countdown = FALSE
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(10)
			continue
		else if(i > 50)
			speaking = "[DisplayTimeText(i, TRUE)] remain before total integrity failure."
		else
			speaking = "[i*0.1]..."
		radio.talk_into(src, speaking, common_channel)
		sleep(10)

	meltdown()

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/meltdown()
	explosion(loc, 0, 0, power_level * 5, power_level * 6, 1, 1)
	radiation_pulse(loc, power_level * 7000, (1 / (power_level + 5)), TRUE)
	empulse(loc, power_level * 5, power_level * 7)
	var/fusion_moles = internal_fusion.total_moles() ? internal_fusion.total_moles() : 0
	var/moderator_moles = moderator_internal.total_moles() ? moderator_internal.total_moles() : 0
	var/datum/gas_mixture/remove_fusion
	if(internal_fusion.total_moles() > 0)
		remove_fusion = internal_fusion.remove(fusion_moles)
		loc.assume_air(remove_fusion)
	var/datum/gas_mixture/remove_moderator
	if(moderator_internal.total_moles() > 0)
		remove_moderator = moderator_internal.remove(moderator_moles)
		loc.assume_air(remove_moderator)
	air_update_turf(FALSE, FALSE)
	qdel(src)

/obj/machinery/atmospherics/components/unary/hypertorus/core/process_atmos()
	/*
	 *Pre-checks
	 */
	//first check if the machine is active
	if(!active)
		return

	//then check if the other machines are still there
	if(!check_part_connectivity())
		deactivate()
		return

	//now check if the machine has been turned on by the user
	if(!start_power)
		return

	//We play delam/neutral sounds at a rate determined by power and critical_threshold_proximity
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((critical_threshold_proximity / 800) * ((power_level) / 5)), 1.0) * 100
		if(critical_threshold_proximity >= 300)
			playsound(src, "hypertorusmelting", max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
		else
			playsound(src, "hypertoruscalm", max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
		var/next_sound = round((100 - aggression) * 5) + 5
		last_accent_sound = world.time + max(HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	soundloop.volume = clamp((power_level + 1) * 8, 0, 50)

	/*
	 *Storing variables such as gas mixes, temperature, volume, moles
	 */

	critical_threshold_proximity_archived = critical_threshold_proximity
	if(power_level >= 5)
		critical_threshold_proximity = max(critical_threshold_proximity + max((round((internal_fusion.total_moles() * 1e5 + internal_fusion.temperature) / 1e5, 1) - 2500) / 200, 0), 0)

		critical_threshold_proximity = max(critical_threshold_proximity + max(log(10, internal_fusion.temperature) - 5, 0), 0)

	if(internal_fusion.total_moles() < 1200 || power_level <= 4)
		critical_threshold_proximity = max(critical_threshold_proximity + min((internal_fusion.total_moles() - 800) / 150, 0), 0)

	if(internal_fusion.total_moles() > 0 && internal_fusion.temperature < 5e5 && power_level <= 4)
		critical_threshold_proximity = max(critical_threshold_proximity + min(log(10, internal_fusion.temperature) - 5.5, 0), 0)

	critical_threshold_proximity += max(round(iron_content, 1) - 1, 0)

	critical_threshold_proximity = min(critical_threshold_proximity_archived + (DAMAGE_CAP_MULTIPLIER * melting_point), critical_threshold_proximity)

	check_alert()

	if(!check_power_use())
		return

	if(!start_cooling)
		return

	if(moderator_internal.total_moles() > 0 && internal_fusion.total_moles() > 0)
		//Modifies the moderator_internal temperature based on energy conduction and also the fusion by the same amount
		var/fusion_temperature_delta = internal_fusion.temperature - moderator_internal.temperature
		var/fusion_heat_amount = METALLIC_VOID_CONDUCTIVITY * fusion_temperature_delta * (internal_fusion.heat_capacity() * moderator_internal.heat_capacity() / (internal_fusion.heat_capacity() + moderator_internal.heat_capacity()))
		internal_fusion.temperature = max(internal_fusion.temperature - fusion_heat_amount / internal_fusion.heat_capacity(), TCMB)
		moderator_internal.temperature = max(moderator_internal.temperature + fusion_heat_amount / moderator_internal.heat_capacity(), TCMB)

	if(airs[1].total_moles() * 0.05 > MINIMUM_MOLE_COUNT)
		var/datum/gas_mixture/cooling_port = airs[1]
		var/datum/gas_mixture/cooling_remove = cooling_port.remove(0.05 * cooling_port.total_moles())
		//Cooling of the moderator gases with the cooling loop in and out the core
		if(moderator_internal.total_moles() > 0)
			var/coolant_temperature_delta = cooling_remove.temperature - moderator_internal.temperature
			var/cooling_heat_amount = HIGH_EFFICIENCY_CONDUCTIVITY * coolant_temperature_delta * (cooling_remove.heat_capacity() * moderator_internal.heat_capacity() / (cooling_remove.heat_capacity() + moderator_internal.heat_capacity()))
			cooling_remove.temperature = max(cooling_remove.temperature - cooling_heat_amount / cooling_remove.heat_capacity(), TCMB)
			moderator_internal.temperature = max(moderator_internal.temperature + cooling_heat_amount / moderator_internal.heat_capacity(), TCMB)

		else if(internal_fusion.total_moles() > 0)
			var/coolant_temperature_delta = cooling_remove.temperature - internal_fusion.temperature
			var/cooling_heat_amount = METALLIC_VOID_CONDUCTIVITY * coolant_temperature_delta * (cooling_remove.heat_capacity() * internal_fusion.heat_capacity() / (cooling_remove.heat_capacity() + internal_fusion.heat_capacity()))
			cooling_remove.temperature = max(cooling_remove.temperature - cooling_heat_amount / cooling_remove.heat_capacity(), TCMB)
			internal_fusion.temperature = max(internal_fusion.temperature + cooling_heat_amount / internal_fusion.heat_capacity(), TCMB)
		cooling_port.merge(cooling_remove)

	fusion_temperature = internal_fusion.temperature
	moderator_temperature = moderator_internal.temperature
	coolant_temperature = airs[1].temperature
	output_temperature = linked_output.airs[1].temperature

	//Set the power level of the fusion process
	switch(fusion_temperature)
		if(-INFINITY to 500)
			power_level = 0
		if(500 to 1e3)
			power_level = 1
		if(1e3 to 1e4)
			power_level = 2
		if(1e4 to 1e5)
			power_level = 3
		if(1e5 to 1e6)
			power_level = 4
		if(1e6 to 1e7)
			power_level = 5
		else
			power_level = 6

	//Update pipenets
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

	if(!start_fuel)
		return

	//Start by storing the gasmix of the inputs inside the internal_fusion and moderator_internal
	if(!linked_input.airs[1].total_moles())
		return
	var/datum/gas_mixture/buffer
	if(linked_input.airs[1].gases[/datum/gas/hydrogen][MOLES] > 0)
		buffer = linked_input.airs[1].remove_specific(/datum/gas/hydrogen, fuel_injection_rate * 0.1)
		internal_fusion.merge(buffer)
	if(linked_input.airs[1].gases[/datum/gas/tritium][MOLES] > 0)
		buffer = linked_input.airs[1].remove_specific(/datum/gas/tritium, fuel_injection_rate * 0.1)
		internal_fusion.merge(buffer)
	buffer = linked_moderator.airs[1].remove(moderator_injection_rate * 0.1)
	moderator_internal.merge(buffer)

/obj/machinery/atmospherics/components/unary/hypertorus/core/process(delta_time)
	fusion_process(delta_time)
	if(!active)
		return
	if(power_level > 0)
		fusion_started = TRUE
		linked_input.fusion_started = TRUE
		linked_output.fusion_started = TRUE
		linked_moderator.fusion_started = TRUE
		linked_interface.fusion_started = TRUE
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.fusion_started = TRUE
	else
		fusion_started = FALSE
		linked_input.fusion_started = FALSE
		linked_output.fusion_started = FALSE
		linked_moderator.fusion_started = FALSE
		linked_interface.fusion_started = FALSE
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.fusion_started = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/fusion_process(delta_time)
//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again! Again but with machine!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//7 reworks
	/*
	 *Pre-checks
	 */
	//first check if the machine is active
	if(!active)
		return

	//then check if the other machines are still there
	if(!check_part_connectivity())
		deactivate()
		return

	if(!check_fuel())
		return

	if(!check_power_use())
		magnetic_constrictor = 100
		heating_conductor = 500
		current_damper = 0
		fuel_injection_rate = 200
		moderator_injection_rate = 500
		waste_remove = FALSE
		iron_content += 0.1 * delta_time

	//Store the temperature of the gases after one cicle of the fusion reaction
	var/archived_heat = internal_fusion.temperature
	//Store the volume of the fusion reaction multiplied by the force of the magnets that controls how big it will be
	var/volume = internal_fusion.volume * (magnetic_constrictor * 0.01)

	//Assert the gases that will be used/created during the process
	internal_fusion.assert_gases(/datum/gas/helium, /datum/gas/antinoblium)
	moderator_internal.assert_gases(/datum/gas/plasma,
									/datum/gas/nitrogen,
									/datum/gas/oxygen,
									/datum/gas/carbon_dioxide,
									/datum/gas/water_vapor,
									/datum/gas/nitrous_oxide,
									/datum/gas/nitryl,
									/datum/gas/freon,
									/datum/gas/bz,
									/datum/gas/proto_nitrate,
									/datum/gas/healium,
									/datum/gas/zauker,
									/datum/gas/hypernoblium,
									/datum/gas/antinoblium
									)

	//Store the fuel gases and the product gas moles
	tritium = internal_fusion.gases[/datum/gas/tritium][MOLES]
	hydrogen = internal_fusion.gases[/datum/gas/hydrogen][MOLES]
	helium = internal_fusion.gases[/datum/gas/helium][MOLES]

	//Store the moderators gases moles
	m_plasma = moderator_internal.gases[/datum/gas/plasma][MOLES]
	m_nitrogen = moderator_internal.gases[/datum/gas/nitrogen][MOLES]
	m_oxygen = moderator_internal.gases[/datum/gas/oxygen][MOLES]
	m_co2 = moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES]
	m_h2o = moderator_internal.gases[/datum/gas/water_vapor][MOLES]
	m_n2o = moderator_internal.gases[/datum/gas/nitrous_oxide][MOLES]
	m_no2 = moderator_internal.gases[/datum/gas/nitryl][MOLES]
	m_freon = moderator_internal.gases[/datum/gas/freon][MOLES]
	m_bz = moderator_internal.gases[/datum/gas/bz][MOLES]
	m_proto_nitrate = moderator_internal.gases[/datum/gas/proto_nitrate][MOLES]
	m_healium = moderator_internal.gases[/datum/gas/healium][MOLES]
	m_zauker = moderator_internal.gases[/datum/gas/zauker][MOLES]
	m_antinoblium = moderator_internal.gases[/datum/gas/antinoblium][MOLES]
	m_hypernoblium = moderator_internal.gases[/datum/gas/hypernoblium][MOLES]

	//We scale it down by volume/2 because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/scale_factor = volume * 0.5

	//Scaled down moles of gases, no less than 0
	var/scaled_tritium = max((tritium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_hydrogen = max((hydrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_helium = max((helium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	var/scaled_m_plasma = max((m_plasma - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_nitrogen = max((m_nitrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_oxygen = max((m_oxygen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_co2 = max((m_co2 - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_h2o = max((m_h2o - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_n2o = max((m_n2o - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_no2 = max((m_no2 - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_freon = max((m_freon - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_bz = max((m_bz - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_proto_nitrate = max((m_proto_nitrate - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_healium = max((m_healium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_zauker = max((m_zauker - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_antinoblium = max((m_antinoblium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_hypernoblium = max((m_hypernoblium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	/*
	 *FUSION MAIN PROCESS
	 */
	//This section is used for the instability calculation for the fusion reaction
	//The size of the phase space hypertorus
	var/toroidal_size = (2 * PI) + TORADIANS(arctan((volume - TOROID_VOLUME_BREAKEVEN) / TOROID_VOLUME_BREAKEVEN))
	//Calculation of the gas power, only for theoretical instability calculations
	var/gas_power = 0
	for (var/gas_id in internal_fusion.gases)
		gas_power += (internal_fusion.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * internal_fusion.gases[gas_id][MOLES])
	for (var/gas_id in moderator_internal.gases)
		gas_power += (moderator_internal.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * moderator_internal.gases[gas_id][MOLES] * 0.75)

	instability = MODULUS((gas_power * INSTABILITY_GAS_POWER_FACTOR)**2, toroidal_size) + (current_damper * 0.01) - iron_content * 0.05
	//Effective reaction instability (determines if the energy is used/released)
	var/internal_instability = 0
	if(instability * 0.5 < FUSION_INSTABILITY_ENDOTHERMALITY)
		internal_instability = 1
	else
		internal_instability = -1

	/*
	 *Modifiers
	 */
	///Those are the scaled gases that gets consumed and releases energy or help increase that energy
	var/positive_modifiers = scaled_hydrogen + \
								scaled_tritium + \
								scaled_m_nitrogen * 0.35 + \
								scaled_m_co2 * 0.55 + \
								scaled_m_n2o * 0.95 + \
								scaled_m_zauker * 1.55 + \
								scaled_m_antinoblium * 10 - \
								scaled_m_hypernoblium * 10 //Hypernob decreases the amount of energy
	///Those are the scaled gases that gets produced and consumes energy or help decrease that energy
	var/negative_modifiers = scaled_helium + \
								scaled_m_h2o * 0.75 + \
								scaled_m_no2 * 0.15 + \
								scaled_m_healium * 0.45 + \
								scaled_m_freon * 1.15 - \
								scaled_m_antinoblium * 10
	///Between 0.25 and 100, this value is used to modify the behaviour of the internal energy and the core temperature based on the gases present in the mix
	var/power_modifier = clamp( scaled_tritium * 1.05 + \
								scaled_m_oxygen * 0.55 + \
								scaled_m_co2 * 0.95 + \
								scaled_m_no2 * 1.45 + \
								scaled_m_zauker * 5.55 + \
								scaled_m_plasma * 0.05 - \
								scaled_helium * 0.55 - \
								scaled_m_n2o * 0.05 - \
								scaled_m_freon * 0.75, \
								0.25, 100)
	///Minimum 0.25, this value is used to modify the behaviour of the energy emission based on the gases present in the mix
	var/heat_modifier = clamp( scaled_hydrogen * 1.15 + \
								scaled_helium * 1.05 + \
								scaled_m_plasma * 1.25 - \
								scaled_m_nitrogen * 0.75 - \
								scaled_m_n2o * 1.45 - \
								scaled_m_freon * 0.95, \
								0.25, 100)
	///Between 0.005 and 1000, this value modify the radiation emission of the reaction, higher values increase the emission
	var/radiation_modifier = clamp( scaled_helium * 0.55 - \
									scaled_m_freon * 1.15 - \
									scaled_m_nitrogen * 0.45 - \
									scaled_m_plasma * 0.95 + \
									scaled_m_bz * 1.9 + \
									scaled_m_proto_nitrate * 0.1 + \
									scaled_m_antinoblium * 10, \
									0.005, 1000)

	/*
	 *Main calculations (energy, internal power, core temperature, delta temperature,
	 *conduction, radiation, efficiency, power output, heat limiter modifier and heat output)
	 */
	//Can go either positive or negative depending on the instability and the negative_modifiers
	//E=mc^2 with some changes for gameplay purposes
	energy = ((positive_modifiers - negative_modifiers) * LIGHT_SPEED ** 2) * max(internal_fusion.temperature * heat_modifier / 100, 1)
	energy = clamp(energy, 0, 1e35) //ugly way to prevent NaN error
	//Power of the gas mixture
	internal_power = (scaled_hydrogen * power_modifier / 100) * (scaled_tritium * power_modifier / 100) * (PI * (2 * (scaled_hydrogen * CALCULATED_H2RADIUS) * (scaled_tritium * CALCULATED_TRITRADIUS))**2) * energy
	//Temperature inside the center of the gas mixture
	core_temperature = internal_power * power_modifier / 1000
	core_temperature = max(TCMB, core_temperature)
	//Difference between the gases temperature and the internal temperature of the reaction
	delta_temperature = archived_heat - core_temperature
	//Energy from the reaction lost from the molecule colliding between themselves.
	conduction = - delta_temperature * (magnetic_constrictor * 0.001)
	//The remaining wavelength that actually can do damage to mobs.
	radiation = max(-(PLANCK_LIGHT_CONSTANT / 5e-18) * radiation_modifier * delta_temperature, 0)
	//Efficiency of the reaction, it increases with the amount of helium
	efficiency = VOID_CONDUCTION * clamp(scaled_helium, 1, 100)
	power_output = efficiency * (internal_power - conduction - radiation)
	//Hotter air is easier to heat up and cool down
	heat_limiter_modifier = 10 * (10 ** power_level) * (heating_conductor / 100)
	//The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	heat_output = clamp(internal_instability * power_output * heat_modifier / 100, - heat_limiter_modifier * 0.01, heat_limiter_modifier)

	var/datum/gas_mixture/internal_output = new
	//gas consumption and production
	if(check_fuel())
		var/fuel_consumption_rate = clamp((fuel_injection_rate * 0.001) * 5 * power_level, 0.05, 30)
		var/fuel_consumption = fuel_consumption_rate * delta_time
		internal_fusion.gases[/datum/gas/tritium][MOLES] -= min(tritium, fuel_consumption * 0.85)
		internal_fusion.gases[/datum/gas/hydrogen][MOLES] -= min(hydrogen, fuel_consumption * 0.95)
		internal_fusion.gases[/datum/gas/helium][MOLES] += fuel_consumption * 0.5
		//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
		//Also dependant on what is the power level and what moderator gases are present
		if(power_output)
			switch(power_level)
				if(1)
					var/scaled_production = clamp(heat_output * 1e-2, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += scaled_production * 0.95
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production *0.75
					if(m_plasma > 100)
						moderator_internal.gases[/datum/gas/nitrous_oxide] += scaled_production * 0.5
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 0.85)
					if(m_bz > 150)
						internal_output.assert_gases(/datum/gas/healium, /datum/gas/halon, /datum/gas/proto_nitrate)
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production * 0.75
						internal_output.gases[/datum/gas/halon][MOLES] += scaled_production * 0.55
						internal_output.gases[/datum/gas/proto_nitrate][MOLES] += scaled_production * 0.25
						moderator_internal.gases[/datum/gas/bz][MOLES] -= min(moderator_internal.gases[/datum/gas/bz][MOLES], scaled_production * 0.95)
				if(2)
					var/scaled_production = clamp(heat_output * 1e-3, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += scaled_production * 1.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production
					if(m_plasma > 50)
						internal_output.assert_gases(/datum/gas/bz)
						internal_output.gases[/datum/gas/bz][MOLES] += scaled_production * 1.8
						moderator_internal.gases[/datum/gas/nitrous_oxide] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.75)
					if(m_proto_nitrate > 20)
						radiation *= 1.55
						heat_output *= 1.025
						internal_output.assert_gases(/datum/gas/stimulum)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.05
						moderator_internal.gases[/datum/gas/plasma][MOLES] += scaled_production * 1.65
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.35)
					if(m_n2o > 50)
						radiation *= 0.55
						heat_output *= 1.055
						moderator_internal.gases[/datum/gas/halon] += scaled_production * 1.35
						moderator_internal.gases[/datum/gas/nitrous_oxide][MOLES] -= min(moderator_internal.gases[/datum/gas/nitrous_oxide][MOLES], scaled_production * 1.5)
				if(3, 4)
					var/scaled_production = clamp(heat_output * 5e-4, 0, fuel_consumption_rate) * delta_time
					if(power_level == 3)
						moderator_internal.gases[/datum/gas/oxygen][MOLES] += scaled_production * 0.5
						moderator_internal.gases[/datum/gas/nitrogen][MOLES] += scaled_production * 0.45
					if(power_level == 4)
						moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += scaled_production * 1.65
						moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production * 1.25
					if(m_plasma > 10)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.1
						internal_output.assert_gases(/datum/gas/freon, /datum/gas/stimulum)
						internal_output.gases[/datum/gas/freon][MOLES] += scaled_production * 0.15
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.05
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 0.45)
					if(m_freon > 50)
						heat_output *= 0.9
						radiation *= 0.8
					if(m_proto_nitrate> 15)
						internal_output.assert_gases(/datum/gas/stimulum, /datum/gas/halon)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.25
						internal_output.gases[/datum/gas/halon][MOLES] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.55)
						radiation *= 1.95
						heat_output *= 1.25
					if(m_bz > 100)
						internal_output.assert_gases(/datum/gas/healium, /datum/gas/proto_nitrate)
						internal_output.gases[/datum/gas/proto_nitrate][MOLES] += scaled_production * 1.5
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production * 1.5
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_RANGE(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 50 * D * delta_time
								l.hallucination = clamp(l.hallucination, 0, 200)
				if(5)
					var/scaled_production = clamp(heat_output * 1e-6, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[/datum/gas/nitryl][MOLES] += scaled_production * 1.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production
					if(m_plasma > 15)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.35
						internal_output.assert_gases(/datum/gas/freon)
						internal_output.gases[/datum/gas/freon][MOLES] += scaled_production *0.25
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.45)
					if(m_freon > 500)
						heat_output *= 0.5
						radiation *= 0.2
					if(m_proto_nitrate > 50)
						internal_output.assert_gases(/datum/gas/stimulum, /datum/gas/pluoxium)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.95
						internal_output.gases[/datum/gas/pluoxium][MOLES] += scaled_production
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.35)
						radiation *= 1.95
						heat_output *= 1.25
					if(m_bz > 100)
						internal_output.assert_gases(/datum/gas/healium)
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_RANGE(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 100 * D
								l.hallucination = clamp(l.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] += scaled_production * 1.25
						moderator_internal.gases[/datum/gas/freon][MOLES] += scaled_production * 1.15
					if(m_healium > 100)
						if(critical_threshold_proximity > 400)
							critical_threshold_proximity = max(critical_threshold_proximity - (m_healium / 100 * delta_time ), 0)
							moderator_internal.gases[/datum/gas/healium][MOLES] -= min(moderator_internal.gases[/datum/gas/healium][MOLES], scaled_production * 20)
					if(moderator_internal.temperature < 1e7 || (m_plasma > 100 && m_bz > 50))
						internal_output.assert_gases(/datum/gas/antinoblium)
						internal_output.gases[/datum/gas/antinoblium][MOLES] += 0.1 * (scaled_helium / (fuel_injection_rate * 0.0065)) * delta_time
				if(6)
					var/scaled_production = clamp(heat_output * 1e-7, 0, fuel_consumption_rate) * delta_time
					if(m_plasma > 30)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.45)
					if(m_proto_nitrate)
						internal_output.assert_gases(/datum/gas/zauker, /datum/gas/stimulum)
						internal_output.gases[/datum/gas/zauker][MOLES] += scaled_production * 5.35
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 2.15
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 3.35)
						radiation *= 2
						heat_output *= 2.25
					if(m_bz)
						for(var/mob/living/carbon/human/human in view(src, HALLUCINATION_RANGE(heat_output)))
							//mesons won't protect you at fusion level 6
							var/distance_root = sqrt(1 / max(1, get_dist(human, src)))
							human.hallucination += power_level * 150 * distance_root
							human.hallucination = clamp(human.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/antinoblium][MOLES] += clamp((scaled_helium / (fuel_injection_rate * 0.0045)), 0, 10) * delta_time
					if(m_healium > 100)
						if(critical_threshold_proximity > 400)
							critical_threshold_proximity = max(critical_threshold_proximity - (m_healium / 100 * delta_time ), 0)
							moderator_internal.gases[/datum/gas/healium][MOLES] -= min(moderator_internal.gases[/datum/gas/healium][MOLES], scaled_production * 20)
					internal_fusion.gases[/datum/gas/antinoblium][MOLES] += 0.01 * (scaled_helium / (fuel_injection_rate * 0.0095)) * delta_time

	//Modifies the internal_fusion temperature with the amount of heat output
	if(internal_fusion.temperature <= FUSION_MAXIMUM_TEMPERATURE)
		internal_fusion.temperature = clamp(internal_fusion.temperature + heat_output,TCMB,FUSION_MAXIMUM_TEMPERATURE)
	else
		internal_fusion.temperature -= heat_limiter_modifier * 0.01 * delta_time

	//heat up and output what's in the internal_output into the linked_output port
	if(internal_output.total_moles() > 0)
		if(moderator_internal.total_moles() > 0)
			internal_output.temperature = moderator_internal.temperature * HIGH_EFFICIENCY_CONDUCTIVITY
		else
			internal_output.temperature = internal_fusion.temperature * METALLIC_VOID_CONDUCTIVITY
		linked_output.airs[1].merge(internal_output)

	//High power fusion might create other matter other than helium, iron is dangerous inside the machine, damage can be seen
	if(moderator_internal.total_moles() > 0)
		moderator_internal.remove(moderator_internal.total_moles() * (1 - (1 - 0.0005 * power_level) ** delta_time))
	if(power_level > 4 && prob(17 * power_level))//at power level 6 is 100%
		iron_content += 0.005 * delta_time
	if(iron_content > 0 && power_level <= 4 && prob(25 / (power_level + 1)))
		iron_content = max(iron_content - 0.01 * delta_time, 0)

	//Gases can be removed from the moderator internal by using the interface. Helium and antinoblium inside the fusion mix will get always removed at a fixed rate
	if(waste_remove && power_level <= 5)
		var/filtering = TRUE
		if(!ispath(filter_type))
			if(filter_type)
				filter_type = gas_id2path(filter_type)
			else
				filtering = FALSE
		if(filtering && moderator_internal.gases[filter_type])
			var/datum/gas_mixture/removed = moderator_internal.remove_specific(filter_type, 20 * delta_time)
			if(removed)
				linked_output.airs[1].merge(removed)

		var/datum/gas_mixture/internal_remove
		if(internal_fusion.gases[/datum/gas/helium][MOLES] > 0)
			internal_remove = internal_fusion.remove_specific(/datum/gas/helium, internal_fusion.gases[/datum/gas/helium][MOLES] * (1 - (1 - 0.5) ** delta_time))
			linked_output.airs[1].merge(internal_remove)
		if(internal_fusion.gases[/datum/gas/antinoblium][MOLES] > 0)
			internal_remove = internal_fusion.remove_specific(/datum/gas/antinoblium, internal_fusion.gases[/datum/gas/antinoblium][MOLES] * (1 - (1 - 0.05) ** delta_time))
			linked_output.airs[1].merge(internal_remove)
		internal_fusion.garbage_collect()
		moderator_internal.garbage_collect()


	//Update pipenets
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

	//better heat and rads emission
	//To do
	if(power_output)
		var/particle_chance = max(((PARTICLE_CHANCE_CONSTANT)/(power_output-PARTICLE_CHANCE_CONSTANT)) + 1, 0)//Asymptopically approaches 100% as the energy of the reaction goes up.
		if(prob(PERCENT(particle_chance)))
			var/obj/machinery/hypertorus/corner/picked_corner = pick(corners)
			picked_corner.loc.fire_nuclear_particle()
		rad_power = clamp((radiation / 1e5), 0, FUSION_RAD_MAX)
		radiation_pulse(loc, rad_power)

/*
* Interface and corners
*/
/obj/machinery/hypertorus
	name = "hypertorus_core"
	desc = "hypertorus_core"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"
	move_resist = INFINITY
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	power_channel = AREA_USAGE_ENVIRON
	var/active = FALSE
	var/icon_state_open
	var/icon_state_off
	var/icon_state_active
	var/fusion_started = FALSE

/obj/machinery/hypertorus/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] can be rotated by first opening the panel with a screwdriver and then using a wrench on it.</span>"

/obj/machinery/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!fusion_started)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/hypertorus/update_icon()
	if(panel_open)
		icon_state = icon_state_open
	else if(active)
		icon_state = icon_state_active
	else
		icon_state = icon_state_off

/obj/machinery/hypertorus/interface
	name = "HFR interface"
	desc = "Interface for the HFR to control the flow of the reaction."
	icon_state = "interface_off"
	circuit = /obj/item/circuitboard/machine/HFR_interface
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/connected_core
	icon_state_off = "interface_off"
	icon_state_open = "interface_open"
	icon_state_active = "interface_active"

/obj/machinery/hypertorus/interface/Destroy()
	if(connected_core)
		connected_core = null
	return..()

/obj/machinery/hypertorus/interface/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		to_chat(user, "<span class='notice'>Check all parts and then try again.</span>")
		return TRUE
	new/obj/item/paper/guides/jobs/atmos/hypertorus(loc)
	connected_core = centre

	connected_core.activate(user)
	return TRUE

/obj/machinery/hypertorus/interface/ui_interact(mob/user, datum/tgui/ui)
	if(active)
		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Hypertorus", name)
			ui.open()
	else
		to_chat(user, "<span class='notice'>Activate the machine first by using a multitool on the interface.</span>")

/obj/machinery/hypertorus/interface/ui_data()
	var/data = list()
	//Internal Fusion gases
	var/list/fusion_gasdata = list()
	if(connected_core.internal_fusion.total_moles())
		for(var/gasid in connected_core.internal_fusion.gases)
			fusion_gasdata.Add(list(list(
			"name"= connected_core.internal_fusion.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(connected_core.internal_fusion.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in connected_core.internal_fusion.gases)
			fusion_gasdata.Add(list(list(
				"name"= connected_core.internal_fusion.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0,
				)))
	//Moderator gases
	var/list/moderator_gasdata = list()
	if(connected_core.moderator_internal.total_moles())
		for(var/gasid in connected_core.moderator_internal.gases)
			moderator_gasdata.Add(list(list(
			"name"= connected_core.moderator_internal.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(connected_core.moderator_internal.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in connected_core.moderator_internal.gases)
			moderator_gasdata.Add(list(list(
				"name"= connected_core.moderator_internal.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0,
				)))

	data["fusion_gases"] = fusion_gasdata
	data["moderator_gases"] = moderator_gasdata

	data["energy_level"] = connected_core.energy
	data["heat_limiter_modifier"] = connected_core.heat_limiter_modifier
	data["heat_output"] = abs(connected_core.heat_output)
	data["heat_output_bool"] = connected_core.heat_output >= 0 ? "" : "-"

	data["heating_conductor"] = connected_core.heating_conductor
	data["magnetic_constrictor"] = connected_core.magnetic_constrictor
	data["fuel_injection_rate"] = connected_core.fuel_injection_rate
	data["moderator_injection_rate"] = connected_core.moderator_injection_rate
	data["current_damper"] = connected_core.current_damper

	data["power_level"] = connected_core.power_level
	data["iron_content"] = connected_core.iron_content
	data["integrity"] = connected_core.get_integrity()

	data["start_power"] = connected_core.start_power
	data["start_cooling"] = connected_core.start_cooling
	data["start_fuel"] = connected_core.start_fuel

	data["internal_fusion_temperature"] = connected_core.fusion_temperature
	data["moderator_internal_temperature"] = connected_core.moderator_temperature
	data["internal_output_temperature"] = connected_core.output_temperature
	data["internal_coolant_temperature"] = connected_core.coolant_temperature

	data["waste_remove"] = connected_core.waste_remove
	data["filter_types"] = list()
	data["filter_types"] += list(list("name" = "Nothing", "path" = "", "selected" = !connected_core.filter_type))
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filter_types"] += list(list("name" = gas[META_GAS_NAME], "id" = gas[META_GAS_ID], "selected" = (path == gas_id2path(connected_core.filter_type))))

	return data

/obj/machinery/hypertorus/interface/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("start_power")
			connected_core.start_power = !connected_core.start_power
			connected_core.use_power = connected_core.start_power ? ACTIVE_POWER_USE : IDLE_POWER_USE
			. = TRUE
		if("start_cooling")
			connected_core.start_cooling = !connected_core.start_cooling
			. = TRUE
		if("start_fuel")
			connected_core.start_fuel = !connected_core.start_fuel
			. = TRUE
		if("heating_conductor")
			var/heating_conductor = params["heating_conductor"]
			if(text2num(heating_conductor) != null)
				heating_conductor = text2num(heating_conductor)
				. = TRUE
			if(.)
				connected_core.heating_conductor = clamp(heating_conductor, 50, 500)
		if("magnetic_constrictor")
			var/magnetic_constrictor = params["magnetic_constrictor"]
			if(text2num(magnetic_constrictor) != null)
				magnetic_constrictor = text2num(magnetic_constrictor)
				. = TRUE
			if(.)
				connected_core.magnetic_constrictor = clamp(magnetic_constrictor, 50, 1000)
		if("fuel_injection_rate")
			var/fuel_injection_rate = params["fuel_injection_rate"]
			if(text2num(fuel_injection_rate) != null)
				fuel_injection_rate = text2num(fuel_injection_rate)
				. = TRUE
			if(.)
				connected_core.fuel_injection_rate = clamp(fuel_injection_rate, 5, 1500)
		if("moderator_injection_rate")
			var/moderator_injection_rate = params["moderator_injection_rate"]
			if(text2num(moderator_injection_rate) != null)
				moderator_injection_rate = text2num(moderator_injection_rate)
				. = TRUE
			if(.)
				connected_core.moderator_injection_rate = clamp(moderator_injection_rate, 5, 1500)
		if("current_damper")
			var/current_damper = params["current_damper"]
			if(text2num(current_damper) != null)
				current_damper = text2num(current_damper)
				. = TRUE
			if(.)
				connected_core.current_damper = clamp(current_damper, 0, 1000)
		if("waste_remove")
			connected_core.waste_remove = !connected_core.waste_remove
			. = TRUE
		if("filter")
			connected_core.filter_type = null
			var/filter_name = "nothing"
			var/gas = gas_id2path(params["mode"])
			if(gas in GLOB.meta_gas_info)
				connected_core.filter_type = gas
				filter_name = GLOB.meta_gas_info[gas][META_GAS_NAME]
			investigate_log("was set to filter [filter_name] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE

/obj/machinery/hypertorus/corner
	name = "HFR corner"
	desc = "Structural piece of the machine."
	icon_state = "corner_off"
	circuit = /obj/item/circuitboard/machine/HFR_corner
	icon_state_off = "corner_off"
	icon_state_open = "corner_open"
	icon_state_active = "corner_active"

/obj/item/paper/guides/jobs/atmos/hypertorus
	name = "paper- 'Quick guide to safe handling of the HFR'"
	info = "<B>How to safely(TM) operate the Hypertorus</B><BR>\
	-Build the machine as it’s shown in the main guide.<BR>\
	-Make a 50/50 gasmix of tritium and hydrogen totalling around 2000 moles.<BR>\
	-Start the machine, fill up the cooling loop with plasma/hypernoblium and use space or freezers to cool it.<BR>\
	-Connect the fuel mix into the fuel injector port, allow only 1000 moles into the machine to ease the kickstart of the reaction<BR>\
	-Set the Heat conductor to 500 when starting the reaction, reset it to 100 when power level is higher than 1<BR>\
	-In the event of a meltdown, set the heat conductor to max and set the current damper to max. Set the fuel injection to min. \
	If the heat output doesn’t go negative, try changing the magnetic costrictors untill heat output goes negative. \
	Make the cooling stronger, put high heat capacity gases inside the moderator (hypernoblium will help dealing with the problem)<BR><BR>\
	<B>Warnings:</B><BR>\
	-You cannot dismantle the machine if the power level is over 0<BR>\
	-You cannot power of the machine if the power level is over 0<BR>\
	-You cannot dispose of waste gases if power level is over 5<BR>\
	-You cannot remove gases from the fusion mix if they are not helium and antinoblium<BR>\
	-Hypernoblium will decrease the power of the mix by a lot<BR>\
	-Antinoblium will INCREASE the power of the mix by a lot more<BR>\
	-High heat capacity gases are harder to heat/cool<BR>\
	-Low heat capacity gases are easier to heat/cool<BR>\
	-The machine consumes 50 KW per power level, reaching 350 KW at power level 6 so prepare the SM accordingly<BR>\
	-In case of a power shortage, the fusion reaction will CONTINUE but the cooling will STOP<BR><BR>\
	The writer of the quick guide will not be held responsible for misuses and meltdown caused by the use of the guide, \
	use more advanced guides to understando how the various gases will act as moderators."

#undef FUSION_RAD_MAX
#undef FUSION_INSTABILITY_ENDOTHERMALITY
#undef FUSION_MAXIMUM_TEMPERATURE
#undef LIGHT_SPEED
#undef PLANCK_LIGHT_CONSTANT
#undef CALCULATED_H2RADIUS
#undef CALCULATED_TRITRADIUS
#undef VOID_CONDUCTION
#undef MAX_FUSION_RESEARCH
#undef MIN_HEAT_VARIATION
#undef MAX_HEAT_VARIATION
#undef MAX_FUEL_USAGE
#undef FUSION_MOLE_THRESHOLD
#undef INSTABILITY_GAS_POWER_FACTOR
#undef TOROID_VOLUME_BREAKEVEN
#undef PARTICLE_CHANCE_CONSTANT
#undef METALLIC_VOID_CONDUCTIVITY
#undef HIGH_EFFICIENCY_CONDUCTIVITY
#undef HALLUCINATION_RANGE
#undef DAMAGE_CAP_MULTIPLIER
#undef HYPERTORUS_MELTING_PERCENT
#undef HYPERTORUS_EMERGENCY_PERCENT
#undef HYPERTORUS_DANGER_PERCENT
#undef HYPERTORUS_WARNING_PERCENT
#undef WARNING_TIME_DELAY
#undef HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN
#undef HYPERTORUS_COUNTDOWN_TIME

#define SUPERMATTER_SURGE_DURATION_MIN 180 EVENT_SECONDS
#define SUPERMATTER_SURGE_DURATION_MAX 360 EVENT_SECONDS
#define SUPERMATTER_SURGE_SEVERITY_MIN 1
#define SUPERMATTER_SURGE_SEVERITY_MAX 4
/// The amount of bullet energy we add for the duration of the SM surge
#define SUPERMATTER_SURGE_BULLET_ENERGY_ADDITION 7
/// The amount of powerloss inhibition (energy retention) we add for the duration of the SM surge
#define SUPERMATTER_SURGE_POWERLOSS_INHIBITION 0.3125
/// The amount of heat resistance we reduce for the duration of the SM surge
#define SUPERMATTER_SURGE_HEAT_MODIFIER 0.5

/**
 * Supermatter Surge
 *
 * An engineering challenge event where the properties of the SM changes to be in a 'surge' of power.
 * For the duration of the event a powerloss inhibition is added to nitrogen, causing the crystal to retain more of its internal energy.
 * Heat modifier is lowered to generate some heat but not a high temp burn.
 * Bullet energy from emitters is raised slightly to raise meV while turned on.
 */

/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	category = EVENT_CATEGORY_ENGINEERING
	weight = 15
	max_occurrences = 1
	earliest_start = 20 MINUTES
	description = "The supermatter will increase in power and heat by a random amount, and announce it."
	admin_setup = list(
		/datum/event_admin_setup/input_number/surge_spiciness,
	)

/datum/round_event_control/supermatter_surge/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()

	if(SSjob.is_skeleton_engineering(crew_threshold = 2))
		return FALSE

/datum/round_event/supermatter_surge
	announce_when = 1
	end_when = SUPERMATTER_SURGE_DURATION_MIN
	/// How powerful is the supermatter surge going to be?
	var/surge_class = SUPERMATTER_SURGE_SEVERITY_MIN
	/// The default bullet energy of the crystal
	var/starting_bullet_energy = SUPERMATTER_DEFAULT_BULLET_ENERGY
	/// The default heat modifier of nitrogen
	var/starting_heat_modifier = -2.5
	/// The default powerloss inhibition of nitrogen
	var/starting_powerloss_inhibition = 0
	/// Typecasted reference to the supermatter chosen at event start
	var/obj/machinery/power/supermatter_crystal/engine
	/// Typecasted reference to the nitrogen properies in the SM chamber
	var/datum/sm_gas/nitrogen/sm_gas

/datum/event_admin_setup/input_number/surge_spiciness
	input_text = "Set surge intensity. (Higher is more severe.)"
	min_value = 1
	max_value = 4

/datum/event_admin_setup/input_number/surge_spiciness/prompt_admins()
	default_value = rand(1, 4)
	return ..()

/datum/event_admin_setup/input_number/surge_spiciness/apply_to_event(datum/round_event/supermatter_surge/event)
	event.surge_class = chosen_value

/datum/round_event/supermatter_surge/setup()
	engine = GLOB.main_supermatter_engine
	if(isnull(engine))
		stack_trace("SM surge event failed to find a supermatter engine!")
		return

	sm_gas = LAZYACCESS(GLOB.sm_gas_behavior, /datum/gas/nitrogen)
	if(isnull(sm_gas))
		stack_trace("SM surge event failed to find gas properties for the supermatter engine.")
		return

	starting_bullet_energy = engine.bullet_energy
	starting_heat_modifier = sm_gas.heat_modifier
	starting_powerloss_inhibition = sm_gas.powerloss_inhibition
	if(isnull(surge_class))
		surge_class = rand(SUPERMATTER_SURGE_SEVERITY_MIN, SUPERMATTER_SURGE_SEVERITY_MAX)

	end_when = rand(SUPERMATTER_SURGE_DURATION_MIN + (surge_class * 45 EVENT_SECONDS), SUPERMATTER_SURGE_DURATION_MAX)

/datum/round_event/supermatter_surge/announce()
	priority_announce("CIMS has detected unusual atmospheric properties in the supermatter chamber, energy output from the supermatter crystal has shown a significant and unanticipated increase. Engineering intervention is required to stabilize the crystal.", "Supermatter Surge Alert: Class [surge_class]", 'sound/machines/engine_alert3.ogg')

/datum/round_event/supermatter_surge/start()
	engine.bullet_energy = SUPERMATTER_SURGE_BULLET_ENERGY_ADDITION + surge_class
	sm_gas.heat_modifier += clamp(SUPERMATTER_SURGE_HEAT_MODIFIER * surge_class, 0.5, 2) // letting this get to 0 or higher will be a Bad Time
	sm_gas.powerloss_inhibition = SUPERMATTER_SURGE_POWERLOSS_INHIBITION * surge_class

/datum/round_event/supermatter_surge/end()
	engine.bullet_energy = starting_bullet_energy
	sm_gas.heat_modifier = starting_heat_modifier
	sm_gas.powerloss_inhibition = starting_powerloss_inhibition
	priority_announce("The supermatter surge has dissipated, crystal output readings have normalized.", "Anomaly Cleared")
	engine = null
	sm_gas = null

#undef SUPERMATTER_SURGE_DURATION_MIN
#undef SUPERMATTER_SURGE_DURATION_MAX
#undef SUPERMATTER_SURGE_SEVERITY_MIN
#undef SUPERMATTER_SURGE_SEVERITY_MAX
#undef SUPERMATTER_SURGE_BULLET_ENERGY_ADDITION
#undef SUPERMATTER_SURGE_POWERLOSS_INHIBITION
#undef SUPERMATTER_SURGE_HEAT_MODIFIER

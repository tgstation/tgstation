#define SURGE_DURATION_MIN 240 EVENT_SECONDS
#define SURGE_DURATION_MAX 270 EVENT_SECONDS
#define SURGE_SEVERITY_MIN 1
#define SURGE_SEVERITY_MAX 4
/// The amount of bullet energy we add for the duration of the SM surge
#define SURGE_BULLET_ENERGY_ADDITION 5
/// The amount of powerloss inhibition (energy retention) we add for the duration of the SM surge
#define SURGE_BASE_POWERLOSS_INHIBITION 0.55
/// The powerloss inhibition scaling based on surge severity
#define SURGE_POWERLOSS_INHIBITION_MODIFIER 0.175
/// The power generation scaling based on surge severity
#define SURGE_POWER_GENERATION_MODIFIER 0.075
/// The heat modifier scaling based on surge severity
#define SURGE_HEAT_MODIFIER 0.25

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
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7
	admin_setup = list(
		/datum/event_admin_setup/input_number/surge_spiciness,
	)

/datum/round_event_control/supermatter_surge/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()

	if(!SSjob.has_minimum_jobs(crew_threshold = 3, jobs = JOB_GROUP_ENGINEERS, head_jobs = list(JOB_CHIEF_ENGINEER)))
		return FALSE

/datum/round_event/supermatter_surge
	announce_when = 4
	end_when = SURGE_DURATION_MIN
	/// How powerful is the supermatter surge going to be?
	var/surge_class =  SURGE_SEVERITY_MIN
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

	sm_gas = LAZYACCESS(engine.current_gas_behavior, /datum/gas/nitrogen)
	if(isnull(sm_gas))
		stack_trace("SM surge event failed to find gas properties for [engine].")
		return

	if(isnull(surge_class))
		surge_class = rand(SURGE_SEVERITY_MIN, SURGE_SEVERITY_MAX)

	end_when = rand(SURGE_DURATION_MIN, SURGE_DURATION_MAX)

/datum/round_event/supermatter_surge/announce()
	priority_announce("The Crystal Integrity Monitoring System has detected unusual atmospheric properties in the supermatter chamber and energy output from the supermatter crystal has increased significantly. Engineering intervention is required to stabilize the engine.", "Class [surge_class] Supermatter Surge Alert", 'sound/machines/engine_alert3.ogg')

/datum/round_event/supermatter_surge/start()
	engine.bullet_energy = surge_class + SURGE_BULLET_ENERGY_ADDITION
	sm_gas.powerloss_inhibition = (surge_class * SURGE_POWERLOSS_INHIBITION_MODIFIER) + SURGE_BASE_POWERLOSS_INHIBITION
	sm_gas.heat_power_generation = (surge_class * SURGE_POWER_GENERATION_MODIFIER) - 1
	sm_gas.heat_modifier = (surge_class * SURGE_HEAT_MODIFIER) - 1


/datum/round_event/supermatter_surge/end()
	engine.bullet_energy = initial(engine.bullet_energy)
	sm_gas.powerloss_inhibition = initial(sm_gas.powerloss_inhibition)
	sm_gas.heat_power_generation = initial(sm_gas.heat_power_generation)
	sm_gas.heat_modifier = initial(sm_gas.heat_modifier)
	priority_announce("The supermatter surge has dissipated, crystal output readings have normalized.", "Anomaly Cleared")
	engine = null
	sm_gas = null

#undef SURGE_DURATION_MIN
#undef SURGE_DURATION_MAX
#undef SURGE_SEVERITY_MIN
#undef SURGE_SEVERITY_MAX
#undef SURGE_BULLET_ENERGY_ADDITION
#undef SURGE_BASE_POWERLOSS_INHIBITION
#undef SURGE_POWERLOSS_INHIBITION_MODIFIER
#undef SURGE_POWER_GENERATION_MODIFIER
#undef SURGE_HEAT_MODIFIER

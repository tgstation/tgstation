SUBSYSTEM_DEF(solar_power_bars)
	name = "Solar Power"
	dependencies = list(
		/datum/controller/subsystem/power_bars,
	)
	wait = 5 SECONDS

	var/datum/delayed_power_bar/solar_power_bars
	var/solars_needed = 80
	var/last_solar_sum = 0

/datum/controller/subsystem/solar_power_bars/Initialize()
	if (!SSpower_bars.enabled)
		can_fire = FALSE
		return SS_INIT_NO_NEED

	return SS_INIT_SUCCESS

/datum/controller/subsystem/solar_power_bars/fire(resumed)
	var/sum = 0

	// doesn't check powernet
	for (var/obj/machinery/power/solar_control/solar_control as anything in GLOB.solar_controls)
		sum += solar_control.last_solar_panels_tracked

	if (sum >= solars_needed)
		solar_power_bars ||= new("Solars", initial_delay = 15 SECONDS, lifetime = 25 SECONDS, recharge_delay = 15 SECONDS)
		solar_power_bars.poke()

	last_solar_sum = sum

/datum/controller/subsystem/solar_power_bars/stat_entry(msg)
	return ..("[last_solar_sum] seeing sun / [solar_power_bars ? solar_power_bars.display_text() : "Not setup"]")

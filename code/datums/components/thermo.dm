 // This is basicly a component that acts like a space heater
 // Like something thatt emits heat like a flare or absorbes heat like ice
 // You can set up ranges for when it starts smoking or when it catches fire or
 //  when it ices over and frezes over, but there is no implmention of sever cold yet
// Most of it is copyed over from the space_heater code
/datum/component/thermo
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/targetTemperature = T20C + 80
	var/heatingPower = 10000			// amount of raw heat added, side note, this is the default heat capacity a standard T1 frezzer can put out
	var/efficiency = 0.25				// amount of air taken from the turf
	var/temperatureTolerance = 1
	var/on = TRUE
	var/current_temp = -1

/datum/component/thermo/Initialize(_targetTemperature = T20C, _heatingPower = 10000, _efficiency = 0.25)
	targetTemperature = _targetTemperature
	heatingPower = _heatingPower
	efficiency = _efficiency
	START_PROCESSING(SSobj, src)

/datum/component/thermo/UnregisterFromParent()
	STOP_PROCESSING(SSobj, src)



/datum/component/thermo/proc/get_env_temp()
	// if we are on and ran though one tick
	if(on && current_temp >= 0)
		return current_temp
	else
		// otherwise we get the temp from the turf
		var/atom/A = parent
		var/turf/L = get_turf(A.loc)
		var/datum/gas_mixture/env
		if(istype(L))
			env = L.return_air()
		return env ? env.temperature : T20C			// env might be null at round start.  This stops runtimes

/datum/component/thermo/proc/enable()
	if(!on)
		on = TRUE
		current_temp = -1			// kelven can never be below 0, and this is updated after the first run of process
		START_PROCESSING(SSprocessing, src)

/datum/component/thermo/proc/disable()
	on = FALSE

/datum/component/thermo/Destroy()
	return ..()

/datum/component/thermo/process()
	if(!on)
		return PROCESS_KILL
	var/atom/A = parent
	var/turf/L = get_turf(A.loc)
	var/datum/gas_mixture/env
	if(istype(L))
		env = L.return_air()
		// This is from the RD server code.  It works well enough but I need to move over the
		// sspace heater code so we can caculate power used per tick as well and making this both
		// exothermic and an endothermic component
		if(env && env.temperature < targetTemperature)

			var/transfer_moles = efficiency * env.total_moles()

			var/datum/gas_mixture/removed = env.remove(transfer_moles)

			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = min((removed.temperature*heat_capacity + heatingPower)/heat_capacity, 1000)

			current_temp = removed.temperature
			env.merge(removed)
			A.air_update_turf()
		else
			current_temp = env ? env.temperature : -1

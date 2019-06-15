/datum/atmosphere
	var/gas_string
	var/id

	var/list/base_gases // A list of gases to always have
	var/list/normal_gases // A list of allowed gases:base_amount
	var/list/restricted_gases // A list of allowed gases like normal_gases but each can only be selected a maximum of one time
	var/restricted_chance = 10 // Chance per iteration to take from restricted gases

	var/minimum_pressure
	var/maximum_pressure

	var/minimum_temp
	var/maximum_temp

/datum/atmosphere/New()
	generate_gas_string()

/datum/atmosphere/proc/generate_gas_string()
	var/target_pressure = rand(minimum_pressure, maximum_pressure)
	var/pressure_scalar = target_pressure / maximum_pressure
	var/current_pressure = 0
	var/list/air_types = base_gases?.Copy() || list()
	for(var/i in air_types)
		current_pressure += air_types[i]
	while(current_pressure < target_pressure)
		var/datum/gas/gastype
		var/amount
		if(!prob(restricted_chance))
			gastype = pick(normal_gases)
			amount = normal_gases[gastype]
		else
			gastype = pick(restricted_gases)
			amount = restricted_gases[gastype]
			if(air_types[gastype])
				continue
		
		amount *= rand(50, 200) / 100	// Randomly modifes the amount from half to double the base for some variety
		amount *= pressure_scalar		// If we pick a really small target pressure we want roughly the same mix but less of it all
		amount = min(amount, target_pressure-current_pressure)
		amount = CEILING(amount, 0.1)
		
		air_types[gastype] += amount
		current_pressure += amount

	var/list/gas_string_builder = list()
	for(var/i in air_types)
		var/datum/gas/gastype = i
		var/id = initial(gastype.id)
		gas_string_builder += "[id]=[air_types[gastype]]"
	gas_string_builder += "TEMP=[rand(minimum_temp, maximum_temp)]"
	gas_string = gas_string_builder.Join(";")

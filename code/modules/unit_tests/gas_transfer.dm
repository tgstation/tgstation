/// Test to make sure the pressure pumping proc used by things like portable pumps, pressure pumps, etc actually work.
/datum/unit_test/atmospheric_gas_transfer

/datum/unit_test/atmospheric_gas_transfer/Run()
	for (var/tempNmoles in list(1e4, 1e6, 1e8, 1e10, 1e12))
		var/datum/gas_mixture/first_mix = allocate(/datum/gas_mixture)
		var/datum/gas_mixture/second_mix = allocate(/datum/gas_mixture)

		first_mix.volume = 200
		second_mix.volume = 200

		ASSERT_GAS(/datum/gas/hypernoblium, first_mix)
		ASSERT_GAS(/datum/gas/tritium, second_mix)
		first_mix.gases[/datum/gas/hypernoblium][MOLES] = tempNmoles
		second_mix.gases[/datum/gas/tritium][MOLES] = 200
		first_mix.temperature = tempNmoles
		second_mix.temperature = T20C

		var/initial_pressure = second_mix.return_pressure()
		// A constant value would be nicer but there will be cases when even MOLAR_ACCURACY amounts would far exceed the pressure so we need to scale it somewhat.
		var/additional_pressure = (tempNmoles / 1000) + 500
		
		/* ERROR MARGIN CALCULATION
		 * We calculate how much would the pressure change if MOLAR_ACCURACY amount of hothotgas is imparted on the cold mix.
		 * This number gets really big for very high temperatures so it's somewhat meaningless, but our main goal is to ensure the code doesn't break.
		 */ 
		var/error_margin = first_mix.gas_pressure_minimum_transfer(second_mix) - initial_pressure
		
		first_mix.pump_gas_to(second_mix, (initial_pressure + additional_pressure))
		var/margin = abs(second_mix.return_pressure() - (initial_pressure+additional_pressure))

		TEST_ASSERT(margin<=error_margin, "Gas pressure pumping test failed for [tempNmoles]. Expected pressure = [initial_pressure+additional_pressure] +/- [error_margin]. Got [second_mix.return_pressure()].")

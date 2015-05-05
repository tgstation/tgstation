/datum/artifact_effect/gas
	effecttype = "gas"
	var/max_pressure

	var/produced_gas = OXYGEN //the gas id

/datum/artifact_effect/gas/New()
	..()
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	max_pressure = rand(115,1000)
	effect_type = pick(6,7)
	//effecttype = "gas[produced_gas]" //generate the id


/datum/artifact_effect/gas/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			env.adjust_gas(produced_gas, rand(2,15), 1, 0)

/datum/artifact_effect/gas/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.total_moles() < max_pressure)
			env.adjust_gas(produced_gas, pick(0, 0, 0.1, rand()), 1, 0)

/datum/artifact_effect/gas/oxy
	effecttype = "gasoxy"
	produced_gas = OXYGEN

/datum/artifact_effect/gas/co2
	effecttype = "gasco2"
	produced_gas = CARBON_DIOXIDE

/datum/artifact_effect/gas/nitro
	effecttype = "gasnitro"
	produced_gas = NITROGEN

/datum/artifact_effect/gas/plasma
	effecttype = "gasplasma"
	produced_gas = PLASMA

/datum/artifact_effect/gas/sleeping
	effecttype = "gassleeping"
	produced_gas = NITROUS_OXIDE

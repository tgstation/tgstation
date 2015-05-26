
/datum/artifact_effect/gasplasma
	effecttype = "gasplasma"
	var/max_pressure
	var/target_percentage

/datum/artifact_effect/gasplasma/New()
	..()
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	max_pressure = rand(115,1000)
	effect_type = pick(6,7)

/datum/artifact_effect/gasplasma/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			env.toxins += rand(2,15)

/datum/artifact_effect/gasplasma/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.total_moles() < max_pressure)
			env.toxins += pick(0, 0, 0.1, rand())


/datum/artifact_effect/gasco2
	effecttype = "gasco2"
	var/max_pressure
	var/target_percentage

/datum/artifact_effect/heat/New()
	..()
	effect_type = pick(6,7)

/datum/artifact_effect/gasco2/New()
	..()
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	max_pressure = rand(115,1000)

/datum/artifact_effect/gasco2/DoEffectTouch(var/mob/user)
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env)
			env.carbon_dioxide += rand(2,15)

/datum/artifact_effect/gasco2/DoEffectAura()
	if(holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if(env && env.total_moles() < max_pressure)
			env.carbon_dioxide += pick(0, 0, 0.1, rand())

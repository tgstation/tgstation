
/datum/artifact_effect/robohurt
	effecttype = "robohurt"

/datum/artifact_effect/robohurt/New()
	..()
	effect_type = pick(3,4)

/datum/artifact_effect/robohurt/DoEffectTouch(var/mob/user)
	if(user)
		if (istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			R << "\red Your systems report severe damage has been inflicted!"
			R.adjustBruteLoss(rand(10,50))
			R.adjustFireLoss(rand(10,50))
			return 1

/datum/artifact_effect/robohurt/DoEffectAura()
	if(holder)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,holder))
			if(prob(10)) M << "\red SYSTEM ALERT: Harmful energy field detected!"
			M.adjustBruteLoss(1)
			M.adjustFireLoss(1)
			M.updatehealth()
		return 1

/datum/artifact_effect/robohurt/DoEffectPulse()
	if(holder)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,holder))
			M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
			M.adjustBruteLoss(10)
			M.adjustFireLoss(10)
			M.updatehealth()
		return 1


//todo
/datum/artifact_effect/sleepy
	effecttype = "sleepy"

/datum/artifact_effect/sleepy/New()
	..()
	effect_type = pick(5,2)

/datum/artifact_effect/sleepy/DoEffectTouch(var/mob/toucher)
	if(toucher)
		var/weakness = GetAnomalySusceptibility(toucher)
		if(ishuman(toucher) && prob(weakness * 100))
			var/mob/living/carbon/human/H = toucher
			H << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
			H.drowsyness = min(H.drowsyness + rand(5,25) * weakness, 50 * weakness)
			H.eye_blurry = min(H.eye_blurry + rand(1,3) * weakness, 50 * weakness)
			return 1
		else if(isrobot(toucher))
			toucher << "\red SYSTEM ALERT: CPU cycles slowing down."
			return 1

/datum/artifact_effect/sleepy/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/human/H in range(src.effectrange,holder))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				if(prob(10))
					H << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
				H.drowsyness = min(H.drowsyness + 1 * weakness, 25 * weakness)
				H.eye_blurry = min(H.eye_blurry + 1 * weakness, 25 * weakness)
		for (var/mob/living/silicon/robot/R in range(src.effectrange,holder))
			R << "\red SYSTEM ALERT: CPU cycles slowing down."
		return 1

/datum/artifact_effect/sleepy/DoEffectPulse()
	if(holder)
		for(var/mob/living/carbon/human/H in range(src.effectrange, holder))
			var/weakness = GetAnomalySusceptibility(H)
			if(prob(weakness * 100))
				H << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
				H.drowsyness = min(H.drowsyness + rand(5,15) * weakness, 50 * weakness)
				H.eye_blurry = min(H.eye_blurry + rand(5,15) * weakness, 50 * weakness)
		for (var/mob/living/silicon/robot/R in range(src.effectrange,holder))
			R << "\red SYSTEM ALERT: CPU cycles slowing down."
		return 1

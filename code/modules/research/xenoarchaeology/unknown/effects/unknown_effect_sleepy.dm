
//todo
/datum/artifact_effect/sleepy
	effecttype = "sleepy"

/datum/artifact_effect/sleepy/DoEffectTouch(var/mob/user)
	if(user)
		if(istype(user,/mob/living/carbon))
			var/mob/living/carbon/C = user
			C << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
			C.drowsyness = min(user.drowsyness + rand(5,25), 50)
			C.eye_blurry = min(user.eye_blurry + rand(1,3), 50)
			return 1
		else if(istype(user,/mob/living/silicon/robot))
			user << "\red SYSTEM ALERT: CPU cycles slowing down."
			return 1

/datum/artifact_effect/sleepy/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/M in range(src.effectrange,holder))
			if(prob(10))
				M << pick("\blue You feel like taking a nap.","\blue You feel a yawn coming on.","\blue You feel a little tired.")
			M.drowsyness = min(M.drowsyness + 1, 25)
			M.eye_blurry = min(M.eye_blurry + 1, 25)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,holder))
			M << "\red SYSTEM ALERT: CPU cycles slowing down."
		return 1

/datum/artifact_effect/sleepy/DoEffectPulse()
	if(holder)
		for(var/mob/living/H in range(src.effectrange, holder))
			H.drowsyness = min(H.drowsyness + rand(5,15), 50)
			H.eye_blurry = min(H.eye_blurry + rand(5,15), 50)
		for (var/mob/living/silicon/robot/M in range(src.effectrange,holder))
			M << "\red SYSTEM ALERT: CPU cycles slowing down."
		return 1

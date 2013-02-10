/datum/surgery
	var/name = "surgery"
	var/status = 1
	var/list/steps = list()
	var/location = "chest"


/datum/surgery/proc/next_step(mob/user, mob/living/carbon/target)
	var/procedure = steps[status]
	var/datum/surgery_step/S = new procedure
	if(S)
		if(S.try_op(user, target, user.zone_sel.selecting, user.get_active_hand(), src))
			return 1
	return 0


/datum/surgery/proc/complete(mob/living/carbon/human/target)
	target.surgeries.Cut(src)
	src = null
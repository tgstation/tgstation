/// These effects reapply their on_apply() effect when refreshed while stacks < max_stacks.
/datum/status_effect/limited_buff
	id = "limited_buff"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	///How many stacks we currently have
	var/stacks = 1
	///How many stacks we can have maximum
	var/max_stacks = 3

/datum/status_effect/limited_buff/refresh(effect)
	if(stacks < max_stacks)
		on_apply()
		stacks++
	else
		maxed_out()

/// Called whenever the buff is refreshed when there are more stacks than max_stacks.
/datum/status_effect/limited_buff/proc/maxed_out()
	return

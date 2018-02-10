/datum/component/relic
	var/cooldown = FALSE
	var/cooldown_time = 30
	var/charges
	var/max_charges = 30

/datum/component/relic/Initialize(var/maxcharges = 30,var/cooldowntime = 30)
	cooldown_time = cooldowntime
	max_charges = maxcharges
	charges = maxcharges

/datum/component/relic/proc/can_use()
	return !cooldown && charges >= 0

/datum/component/relic/proc/use_charge()
	if(charges > 0)
		charges--
	cooldown = TRUE
	addtimer(CALLBACK(src,.proc/reset_cooldown),cooldown_time)

/datum/component/relic/proc/recharge(amt)
	charges += amt

/datum/component/relic/proc/reset_cooldown()
	cooldown = FALSE
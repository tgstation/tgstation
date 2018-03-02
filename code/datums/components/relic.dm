/datum/component/relic
	var/cooldown = FALSE
	var/cooldown_time = 30
	var/charges
	var/max_charges = 30
	var/datum/relic_type/my_type

/datum/component/relic/Initialize(var/datum/relic_type/mytype,var/maxcharges = 30,var/cooldowntime = 30)
	cooldown_time = cooldowntime
	max_charges = maxcharges
	charges = maxcharges
	my_type = mytype

/datum/component/relic/proc/can_use()
	return !cooldown && charges >= 0

/datum/component/relic/proc/use_charge()
	if(charges > 0)
		charges--
	if(cooldown_time)
		cooldown = TRUE
		addtimer(CALLBACK(src,.proc/reset_cooldown),cooldown_time)

/datum/component/relic/proc/recharge(amt)
	charges = min(charges + amt,max_charges)

/datum/component/relic/proc/reset_cooldown()
	cooldown = FALSE
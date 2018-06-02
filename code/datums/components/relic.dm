/datum/component/relic
	var/cooldown = FALSE
	var/cooldown_time = 30
	var/charges
	var/max_charges = 30
	var/datum/relic_type/my_type
	var/list/process_callbacks = list()
	var/list/attackby_callbacks = list() //While it's not really reasonable to have multiple attackself or afterattack, this feels acceptable

/datum/component/relic/Initialize(datum/relic_type/mytype,maxcharges = 30,cooldowntime = 30)
	cooldown_time = cooldowntime
	max_charges = maxcharges
	charges = maxcharges
	my_type = mytype

/datum/component/relic/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/relic/proc/can_use(amt)
	return !cooldown && charges >= amt

/datum/component/relic/proc/use_charge(amt)
	if(charges >= amt)
		charges -= amt
	if(cooldown_time)
		cooldown = TRUE
		addtimer(CALLBACK(src,.proc/reset_cooldown),cooldown_time)

/datum/component/relic/proc/recharge(amt)
	charges = min(charges + amt,max_charges)

/datum/component/relic/proc/reset_cooldown()
	cooldown = FALSE

/datum/component/relic/process()
	for(var/datum/callback/cb in process_callbacks)
		cb.InvokeAsync()

	if(!LAZYLEN(process_callbacks))
		return PROCESS_KILL

/datum/component/relic/proc/attackby(obj/item/weapon, mob/living/user, params)
	for(var/datum/callback/cb in attackby_callbacks)
		if(cb.InvokeAsync(weapon,user,params))
			break

/datum/component/relic/proc/add_process(callback)
	if(!LAZYLEN(process_callbacks))
		START_PROCESSING(SSobj, src)
	process_callbacks += callback

/datum/component/relic/proc/add_attackby(callback)
	if(!LAZYLEN(attackby_callbacks))
		RegisterSignal(COMSIG_PARENT_ATTACKBY, CALLBACK(src, .proc/attackby, parent))
	attackby_callbacks += callback
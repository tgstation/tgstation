//Nanites, robotics' own chemistry lab and virology lite.
//Pattern nanites act as reagent effects, which draw upon idle nanites to fuel themselves.
//If someone wants to benefit from a nanite shot, they need to be full of idle nanites first!
/datum/reagent/nanites
	name = "Idle Nanites"
	id = "idle_nanites"
	metabolization_rate = 0
	synth_type = CHEM_SYNTH_NANITES
	color = "#777777"

/datum/reagent/nanites/proc/emp(severity)
	var/kill_amount = 0
	while(prob(66))
		kill_amount += 5
	convert("inert_nanites", kill_amount)

/datum/reagent/nanites/proc/shock()
	var/kill_amount = 0
	while(prob(80))
		kill_amount += 5
	convert("inert_nanites", kill_amount)

//Converts nanites into other reagents, preferably other nanites. Transfers programming if there's any.
//Use this when destroying/deactivating nanites, use remove_amount with force=TRUE if they're supposed to disappear completely.
/datum/reagent/nanites/proc/convert(result = "inert_nanites", amount)
	if(!amount)
		amount = volume
	remove_amount(amount, force = TRUE)
	holder.add_reagent(result, amount, data) //keeps programming settings and codes

/datum/reagent/nanites/dead
	name = "Inert Nanites"
	id = "inert_nanites"
	metabolization_rate = 0.4

/datum/reagent/nanites/programmed
	name = "Generic Programmed Nanites"
	description = "Warn a coder if you see this!"
	metabolization_rate = 0.75

	var/mob/living/host_mob
	var/can_trigger = FALSE		//If the nanites have a trigger function (used for the programming UI)
	var/trigger_cost = 0		//Amount of nanites required to trigger
	var/trigger_cooldown = 5	//Cycles required between each trigger activation
	var/next_trigger = 0		//Amount of current_cycle required for the next trigger activation
	var/nanite_flags = NONE
	var/passive_enabled = FALSE //If the nanites have an on/off-style effect, it's tracked by this var
	var/list/rogue_types = list("inert_nanites") //What these can turn into if emp'd

	data = list(
		"activated" = TRUE, 		//If FALSE, the nanites won't process, decay or trigger
		"activation_delay" = 0, 	//Cycles before the nanites self-activate.
		"timer" = 0, 				//Cycles before the timer effect activates. Starts AFTER the activation delay
		"timer_type" = NANITE_TIMER_DEACTIVATE, //What happens when the timer runs out

		//Signal codes, these handle remote input to the nanites. If set to 0 they'll ignore signals.
		"activation_code" = 0, 		//Code that activates nanite processing [1-9999]
		"deactivation_code" = 0, 	//Code that deactivates nanite processing [1-9999]
		"kill_code" = 0, 			//Code that permanently reverts nanite to idle [1-9999]
		"trigger_code" = 0 			//Code that activates nanite trigger effect [1-9999]
	)

/datum/reagent/nanites/programmed/on_merge(list/newdata, newvolume)
	if(!data["activated"] && newdata["activated"])
		activate()
	if(data["activated"] && !newdata["activated"])
		deactivate()
	current_cycle = 0
	if(data && newdata)
		data = newdata //completely override previous programming
	return TRUE

/datum/reagent/nanites/programmed/on_mob_add(mob/living/M)
	..()
	host_mob = M
	if(data["activated"]) //apply activation effects if it starts active
		activate()

/datum/reagent/nanites/programmed/on_mob_delete(mob/living/M)
	..()
	if(data["activated"])
		deactivate()

/datum/reagent/nanites/programmed/on_mob_life(mob/living/M)
	current_cycle++
	if(data["activation_delay"])
		if(data["activated"] && current_cycle < data["activation_delay"])
			deactivate()
		else if(!data["activated"] && current_cycle >= data["activation_delay"])
			activate()
	if(!data["activated"])
		return
	if(data["timer"] && current_cycle > (data["activation_delay"] + data["timer"]))
		if(data["timer_type"] == NANITE_TIMER_DEACTIVATE)
			deactivate()
		else if(data["timer_type"] == NANITE_TIMER_SELFDESTRUCT)
			convert("idle_nanites")
		else if(can_trigger && data["timer_type"] == NANITE_TIMER_TRIGGER)
			trigger()
			data["timer"] = data["activation_delay"] + data["timer"]
		else if(can_trigger && data["timer_type"] == NANITE_TIMER_RESET)
			current_cycle = 0 //restart the activation delay counter
	if(check_conditions(M))
		if(!passive_enabled)
			enable_passive_effect()
		nanite_life(M)
	else
		if(passive_enabled)
			disable_passive_effect()

//If false, nanites won't process their life procs
/datum/reagent/nanites/programmed/proc/check_conditions(mob/living/M)
	if(!decay())
		return FALSE
	return TRUE

//Nanite version of on_mob_life(), works the same without having to override the metabolism part every time
/datum/reagent/nanites/programmed/proc/nanite_life(mob/living/M)
	return

//Nanites try to consume idles before themselves, unless specifically forced otherwise
/datum/reagent/nanites/programmed/remove_amount(amount, force = FALSE)
	if(!force)
		consume(amount)
	else
		amount = CLAMP(amount, 0, volume)
		volume -= amount

//Nanites' version of metabolization rate; only applies if the nanites are activated.
/datum/reagent/nanites/programmed/proc/decay()
	if(!metabolization_rate)
		return TRUE
	return consume(metabolization_rate, TRUE)

//Tries to consume a given amount of idle nanites; if they run out, either consumes the programmed nanites or returns false altogether, depending on whether it's optional
/datum/reagent/nanites/programmed/proc/consume(amount, optional = FALSE)
	amount = consume_idles(amount)

	if(amount)
		if(optional)
			return FALSE
		else
			amount = consume_self(amount)

	return !amount

//Self-consumption aka regular chem removal
/datum/reagent/nanites/programmed/proc/consume_self(amount)
	var/removed_amount = CLAMP(amount, 0, volume)
	volume -= removed_amount
	amount -= removed_amount
	return amount

//Search for idle nanites and consume those instead, return the remaining amount to consume if the idles weren't enough
/datum/reagent/nanites/programmed/proc/consume_idles(amount)
	var/datum/reagent/nanites/idles
	idles = holder.has_reagent("idle_nanites")
	if(idles)
		var/removed_amount = CLAMP(amount, 0, idles.volume)
		holder.remove_reagent("idle_nanites", removed_amount)
		amount -= removed_amount
	return amount


/datum/reagent/nanites/programmed/emp()
	if(nanite_flags & NANITE_EMP_IMMUNE)
		return
	switch(rand(1,6))

		if(3)
			toggle() //enable/disable
		if(4)
			convert("idle_nanites") //kill switch
		if(5)
			convert("inert_nanites") //destroyed
		if(6)
			convert(pick(rogue_types)) //scrambled programming, now does the opposite effect

/datum/reagent/nanites/programmed/shock()
	if(prob(33) && !(nanite_flags & NANITE_SHOCK_IMMUNE))
		convert("inert_nanites")

/datum/reagent/nanites/programmed/proc/receive_signal(code)
	if(data["activation_code"] && code == data["activation_code"] && !data["activated"])
		activate()
	else if(data["deactivation_code"] && code == data["deactivation_code"] && data["activated"])
		deactivate()
	if(can_trigger && data["trigger_code"] && code == data["trigger_code"])
		trigger()
	if(data["kill_code"] && code == data["kill_code"])
		convert("idle_nanites")

/datum/reagent/nanites/programmed/proc/toggle()
	if(!data["activated"])
		activate()
	else
		deactivate()

/datum/reagent/nanites/programmed/proc/activate()
	data["activated"] = TRUE

/datum/reagent/nanites/programmed/proc/deactivate()
	if(passive_enabled)
		disable_passive_effect()
	data["activated"] = FALSE

/datum/reagent/nanites/programmed/proc/enable_passive_effect()
	return

/datum/reagent/nanites/programmed/proc/disable_passive_effect()
	return

/datum/reagent/nanites/programmed/proc/trigger()
	if(!data["activated"])
		return FALSE
	if(current_cycle < next_trigger)
		return FALSE
	if(!consume(trigger_cost, TRUE))
		return FALSE
	next_trigger = current_cycle + trigger_cooldown
	return TRUE
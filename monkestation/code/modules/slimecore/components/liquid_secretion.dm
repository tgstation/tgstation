/datum/component/liquid_secretion
	///the reagent we secrete
	var/reagent_id
	///the interval of secretion
	var/secretion_interval
	///amount of reagents to spawn
	var/amount
	///Callback interaction called when the turf has some liquids on it
	var/datum/callback/pre_secrete_callback
	var/next_secrete = 0



/datum/component/liquid_secretion/Initialize(reagent_id = /datum/reagent/water, amount = 10, secretion_interval = 1 SECONDS, pre_secrete_callback)
	. = ..()

	src.reagent_id = reagent_id
	src.secretion_interval = secretion_interval
	src.amount = amount
	src.pre_secrete_callback = CALLBACK(parent, pre_secrete_callback)

	START_PROCESSING(SSobj, src)

/datum/component/liquid_secretion/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SECRETION_UPDATE, PROC_REF(update_information)) //The only signal allowing item -> turf interaction

/datum/component/liquid_secretion/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_SECRETION_UPDATE)

/datum/component/liquid_secretion/proc/update_information(datum/source, reagent_id, amount, secretion_interval)
	if(reagent_id)
		src.reagent_id = reagent_id
	if(amount)
		src.amount = amount
	if(secretion_interval)
		src.secretion_interval = secretion_interval


/datum/component/liquid_secretion/process(seconds_per_tick)
	if(!parent || (next_secrete > world.time))
		return
	next_secrete = world.time + secretion_interval
	if(pre_secrete_callback && !pre_secrete_callback.Invoke(parent))
		return

	var/turf/parent_turf = get_turf(parent)
	var/list/reagent_list = list()
	reagent_list |= reagent_id
	reagent_list[reagent_id] = amount
	parent_turf.add_liquid_list(reagent_list, FALSE, T20C)

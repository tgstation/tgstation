/datum/corral_upgrade/autofeeder
	name = "Autofeeder Upgrade"
	desc = "Slowly feeds the baby slimes until they reach adulthood."
	cost = 8000

	var/datum/weakref/corral_data_weakref

/datum/corral_upgrade/autofeeder/on_add(datum/corral_data/parent)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	corral_data_weakref = WEAKREF(parent)

/datum/corral_upgrade/autofeeder/process(seconds_per_tick)
	var/datum/corral_data/corral_data = corral_data_weakref?.resolve()

	if(!corral_data)
		STOP_PROCESSING(SSprocessing, src)
		return

	for(var/mob/living/basic/slime/slime as anything in corral_data.managed_slimes)
		if(slime.hunger_precent >= slime.production_precent + 0.01) // small leeway
			continue
		SEND_SIGNAL(slime, COMSIG_MOB_ADJUST_HUNGER, 0.5 * seconds_per_tick)


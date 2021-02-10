/*!
This subsystem mostly exists to populate and manage the withdrawal singletons.
*/

SUBSYSTEM_DEF(withdrawal)
	name = "Withdrawal"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_WITHDRAWAL
	///Dictionary of withdrawal.type || withdrawal ref
	var/list/all_withdrawals = list()

/datum/controller/subsystem/withdrawal/Initialize(timeofday)
	InitializeSkills()
	return ..()

///Ran on initialize, populates the withdrawal dictionary
/datum/controller/subsystem/withdrawal/proc/InitializeSkills(timeofday)
	for(var/type in subtypesof(/datum/withdrawal))
		var/datum/withdrawal/ref = new type
		all_withdrawals[type] = ref

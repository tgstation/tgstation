SUBSYSTEM_DEF(economy)
	name = "Economy"
	flags = SS_NO_FIRE

	var/list/datum/credit/accounts = list()

	var/datum/credit/cargo

/datum/controller/subsystem/economy/Initialize(timeofday)
	. = ..()
	//create the cargo account
	cargo = new /datum/credit(SPECIAL_CARGO)
	cargo.balance = 5000

/datum/controller/subsystem/economy/proc/getaccount(account_number)
	for(var/datum/credit/C in accounts)
		if(C.acc_number == account_number)
			return C
	return ERROR_NONEXISTANT_ACC

/datum/controller/subsystem/economy/proc/getspecial(special)
	if(!special)
		return ERROR_NONEXISTANT_ACC
	for(var/datum/credit/C in accounts)
		if(C.special == special)
			return C
	//there's no special! panic!
	log_game("Special account [special] didn't exist!! YELL AT MRTY!!!")
	var/datum/credit/C = new /datum/credit(special)
	C.balance = 5000
	return C

/datum/controller/subsystem/economy/proc/add_money(account, amount)
	var/C = getaccount(account)
	if(!istype(C, /datum/credit))
		return C //return the error
	var/datum/credit/acc = C
	acc.balance += amount
	return SUCCESS

/datum/controller/subsystem/economy/proc/getbalance(acct)
	var/datum/credit/C = getaccount(acct)
	if(C)
		return C.balance
	return -1

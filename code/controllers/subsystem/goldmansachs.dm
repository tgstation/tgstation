SUBSYSTEM_DEF(goldmansachs)
	name = "Economy"
	flags = SS_NO_INIT
	var/paycheck_interval = 1 MINUTES
	var/roundstart_paychecks = 5
	var/budget_pool = 35000
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/generated_accounts = list()

/datum/controller/subsystem/goldmansachs/fire(resumed = 0)
	var/budget_to_hand_out = round(budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		var/datum/bank_account/department/D = new /datum/bank_account/department(src)
		D.department_id = A
		D.account_holder = department_accounts[A]
		D.account_balance = budget_to_hand_out
		generated_accounts += D
	addtimer(CALLBACK(src, .proc/its_payday_fellas), paycheck_interval)
	flags |= SS_NO_FIRE


/datum/controller/subsystem/goldmansachs/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D
/datum/controller/subsystem/goldmansachs/proc/its_payday_fellas()
	for(var/A in GLOB.bank_accounts)
		var/datum/bank_account/B = A
		B.i_need_my_payday_too(1)
	addtimer(CALLBACK(src, .proc/its_payday_fellas), paycheck_interval)

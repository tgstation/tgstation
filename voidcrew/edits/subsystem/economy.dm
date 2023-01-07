/datum/controller/subsystem/economy
	//remove all paychecks
	roundstart_paychecks = 0
	//remove all free money
	budget_pool = 0
	//we only keep cargo's budget for runtimes (sadly), this is filled with ship budgets.
	department_accounts = list(ACCOUNT_CAR = ACCOUNT_CAR_NAME)

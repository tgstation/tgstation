//Central bank datum.
var/datum/bank/bank = new()

/datum/bank
	name = "\improper Nanotrasen Central Bank"

	var/list/accounts = list() //Associative list containing all accounts. Key = account number; value = datum/bankaccount
	var/list/servers = list() //Contains all central bank servers on the station z.
	var/list/deptaccounts = list()

/datum/bank/New()
	var/list/depts = list(new datum/bankaccount/department/station, \
	new datum/bankaccount/department/security(), \
	new datum/bankaccount/department/service(), \
	new datum/bankaccount/department/medbay(), \
	new datum/bankaccount/department/research(), \
	new datum/bankaccount/department/cargo(), \
	new datum/bankaccount/department/engineering())

	for(var/acc in depts)
		addAccount(acc)
		deptaccounts[acc.name] = acc

/datum/bank/proc/isOperational() //If the bank system can be used.
	for(var/obj/machinery/bankserver/BS in servers)
		if(BS.can_use()) //the system works as long as one server is online.
			return 1
	return 0

/datum/bank/proc/transferAmount(datum/bankaccount/from, datum/bankaccount/to, amount, username, silent = 0, note, force = 0) //self-explanatory.
	if(!isOperational())
		return 0
	
	if(from.withdrawAmount(amount, username, 1, null, force))
		if(to.depositAmount(amount, username, 1, null))
			if(!silent)
				note = html_encode(note)
				from.addBankLog("[html_encode(username)] transferred [amount] [CURRENCY(amount)] to [html_encode(to.name)][to.owner ? " ([html_encode(to.owner)])" : ""][note ? " ([note])" : ""].")
				to.addBankLog("[html_encode(username)] transferred [amount] [CURRENCY(amount)] from [html_encode(from.name)][from.owner ? " ([html_encode(from.owner)])" : ""][note ? " ([note])" : ""].")
			return 1

		else
			from.depositAmount(amount, username, 1) //Make sure they get their money back.
			return 0


	return 0

/datum/bank/proc/addAccount(datum/bankaccount/account, username)
	accounts[account.name] = account
	account.addBankLog("Account #[account.name] created[username ? " by [username]" : ""].")

/datum/bank/proc/addToPayroll(datum/bankaccount/acc, paygrade, department)
	var/datum/bankaccount/department/deptacc = deptaccounts[department]
	deptacc.employees |= acc
	deptacc.payamount[acc.name] = paygrade

//Bank account datum.
/datum/bankaccount
	name = "0000000" //random number (department name for bankaccount/department subtype)

	var/balance = 0 //speaks for itself. can become negative.
	var/list/cards = list() //the ID cards that are linked to this bank account.
	var/frozen = 0 //if the bank account is frozen.
	var/owner = "" //String containing the name of the owner. You probably don't want to use this except for displaying it to people.
	var/list/logs = list() //Logs all actions related to this account.
	var/verified = 0 //If this is an "official" account (department or made at roundstart)

/datum/bankaccount/New(sbalance = 0)
	name = "[rand(0700000, 9999999)]" //TODO: improve this, this will become a maintainability issue once we regularily reach more than 9299999 players.
	while(bank.accounts[name]) //to ensure there are no colissions.
		name = "[rand(0700000, 9999999)]"

	balance = sbalance

	bank.addAccount(src)

/datum/bankaccount/proc/withdrawAmount(amount, username, silent = 0, note, force = 0) //force is for fines/etc and will allow negative balance. username is for logging.
	if(!force && balance - amount < 0)
		return 0

	if(!bank.isOperational() || frozen)
		return 0

	balance -= amount

	if(!silent)
		addBankLog("[html_encode(username)] withdrew [amount] [CURRENCY(amount)][note ? " ([html_encode(note)])" : ""].")

	return 1

/datum/bankaccount/proc/depositAmount(amount, username, silent = 0, note) //muh encapsulation
	if(!bank.isOperational() || frozen)
		return 0

	balance += amount

	if(!silent)
		addBankLog("[html_encode(username)] deposited [amount] [CURRENCY(amount)][note ? " ([html_encode(note)])" : ""].")

	return 1

/datum/bankaccount/proc/addBankLog(var/log)
	log = "<b>\[[gameTimestamp()]\]</b>: " + log
	logs += log
	bank.logs += log

/datum/bankaccount/department //departmental bank accounts, these are departmental budgets and will pay their employees from their balance.
	name = "Department"
	balance = 2000
	verified = 1

	var/list/employees = list() //list of datum/bankaccounts that will be paid to.
	var/list/payamount = list() //associative list that determines how much of the budget everybody gets. key = account number; value = number between 0 and 1. Sum of the values should never be greater than 1, unless you work at Wall Street.

/datum/bankaccount/department/station
	name = "Station"
	balance = 10000 //10k

/datum/bankaccount/department/cargo
	name = "Cargo"

/datum/bankaccount/department/security
	name = "Security"

/datum/bankaccount/department/service
	name = "Service"

/datum/bankaccount/department/medbay
	name = "Medbay"

/datum/bankaccount/department/research
	name = "Research"

/datum/bankaccount/department/engineering
	name = "Engineering"

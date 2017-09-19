/datum/credit
	var/original_owner_name = "None"
	var/pin = "0000"
	var/acc_number = "12345"
	var/balance = 0
	var/special = 0

/datum/credit/New(var/special = 0)
	. = ..()
	pin = "[rand(1000,9999)]"
	acc_number = "[rand(10000, 99999)]"
	if(SSeconomy.getspecial(special)) //don't allow multiple special accounts!
		qdel(src)
		return
	balance = rand(100, 250)
	if(!(src in SSeconomy.accounts))
		SSeconomy.accounts += src
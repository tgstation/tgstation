////////////////////////
// Ease-of-use
//
// Economy system is such a mess of spaghetti.  This should help.
////////////////////////

/proc/get_money_account(var/account_number, var/pin=0, var/security_level = 0, var/pin_needed=1, var/from_z=-1)
	for(var/obj/machinery/account_database/DB in machines)
		if(from_z != -1 && DB.z != from_z) continue
		var/datum/money_account/acct = DB.get_account(account_number,pin,security_level,pin_needed,from_z)
		if(!acct) continue
		return acct


/obj/proc/get_card_account(var/obj/item/weapon/card/I, var/terminal_name="", var/transaction_purpose="", var/require_pin=0)
	if(terminal_name=="")
		terminal_name=src.name
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		var/seclevel=0
		var/attempt_pin=0
		if(require_pin)
			attempt_pin = input("Enter pin code", "Transaction") as num
			seclevel=2
		var/datum/money_account/D = get_money_account(C.associated_account_number, pin=attempt_pin, security_level=seclevel)
		if(D)
			return D
		else
			usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"

/datum/money_account/proc/charge(var/transaction_amount,var/datum/money_account/dest,var/transaction_purpose, var/terminal_name="", var/terminal_id=0)
	if(transaction_amount <= money)
		//transfer the money
		money -= transaction_amount
		if(dest)
			dest.money += transaction_amount

		//create entries in the two account transaction logs
		var/datum/transaction/T
		if(dest)
			T = new()
			T.target_name = "[owner_name]"
			if(terminal_name!="")
				T.target_name += " (via [terminal_name])"
			T.purpose = transaction_purpose
			if(transaction_amount > 0)
				T.amount = "([transaction_amount])"
			else
				T.amount = "[transaction_amount]"
			if(terminal_id)
				T.source_terminal = terminal_id
			T.date = current_date_string
			T.time = worldtime2text()
			dest.transaction_log.Add(T)
		//
		T = new()
		T.target_name = dest.owner_name
		if(terminal_name!="")
			T.target_name += " (via [terminal_name])"
		T.purpose = transaction_purpose
		T.amount = "[transaction_amount]"
		if(terminal_id)
			T.source_terminal = terminal_id
		T.date = current_date_string
		T.time = worldtime2text()
		transaction_log.Add(T)
		return 1
	else
		usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
		return 0
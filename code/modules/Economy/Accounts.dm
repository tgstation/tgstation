var/global/current_date_string
var/global/num_financial_terminals = 1
var/global/datum/money_account/station_account
var/global/list/datum/money_account/department_accounts = list()
var/global/next_account_number = 0
var/global/obj/machinery/account_database/centcomm_account_db
var/global/datum/money_account/vendor_account
var/global/list/all_money_accounts = list()

/proc/create_station_account()
	if(!station_account)
		next_account_number = rand(111111, 999999)

		station_account = new()
		station_account.owner_name = "[station_name()] Station Account"
		station_account.account_number = rand(111111, 999999)
		station_account.remote_access_pin = rand(1111, 111111)
		station_account.money = 75000

		//create an entry in the account transaction log for when it was created
		var/datum/transaction/T = new()
		T.target_name = station_account.owner_name
		T.purpose = "Account creation"
		T.amount = 75000
		T.date = "2nd April, 2555"
		T.time = "11:24"
		T.source_terminal = "Biesel GalaxyNet Terminal #277"

		//add the account
		station_account.transaction_log.Add(T)
		all_money_accounts.Add(station_account)

/proc/create_department_account(department)
	next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(111111, 999999)
	department_account.remote_access_pin = rand(1111, 111111)
	department_account.money = 5000

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = department_account.owner_name
	T.purpose = "Account creation"
	T.amount = department_account.money
	T.date = "2nd April, 2555"
	T.time = "11:24"
	T.source_terminal = "Biesel GalaxyNet Terminal #277"

	//add the account
	department_account.transaction_log.Add(T)
	all_money_accounts.Add(department_account)

	department_accounts[department] = department_account

//the current ingame time (hh:mm) can be obtained by calling:
//worldtime2text()

/proc/create_account(var/new_owner_name = "Default user", var/starting_funds = 0, var/obj/machinery/account_database/source_db)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 111111)
	M.money = starting_funds

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds
	if(!source_db)
		//set a random date, time and location some time over the past few decades
		var/DD = text2num(time2text(world.timeofday, "DD"))											//For muh lore we'll pretend that Nanotrasen changed its account policy
		T.date = "[(DD == 1) ? "31" : "[DD-1]"] [time2text(world.timeofday, "Month")], [game_year]"	//shortly before the events of the round,
		T.time = "[rand(0,24)]:[rand(11,59)]"														//prompting everyone to get a new account one day prior.
		T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"								//The point being to partly to justify the transaction history being empty at the beginning of the round.

		M.account_number = rand(111111, 999999)
	else
		T.date = current_date_string
		T.time = worldtime2text()
		T.source_terminal = source_db.machine_id

		M.account_number = next_account_number
		next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(source_db.loc)

		var/obj/item/weapon/paper/R = new /obj/item/weapon/paper(P)
		P.wrapped = R
		R.name = "Account information: [M.owner_name]"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:94: R.info = "<b>Account details (confidential)</b><br><hr><br>"
		R.info = {"<b>Account details (confidential)</b><br><hr><br>
			<i>Account holder:</i> [M.owner_name]<br>
			<i>Account number:</i> [M.account_number]<br>
			<i>Account pin:</i> [M.remote_access_pin]<br>
			<i>Starting balance:</i> $[M.money]<br>
			<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>
			<i>Creation terminal ID:</i> [source_db.machine_id]<br>
			<i>Authorised NT officer overseeing creation:</i> [source_db.held_card.registered_name]<br>"}
		// END AUTOFIX
		//stamp the paper
		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		stampoverlay.icon_state = "paper_stamp-cent"
		if(!R.stamped)
			R.stamped = new
		R.stamped += /obj/item/weapon/stamp
		R.overlays += stampoverlay
		R.stamps += "<HR><i>This paper has been stamped by the Accounts Database.</i>"

	//add the account
	M.transaction_log.Add(T)
	all_money_accounts.Add(M)

	return M

/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/security_level = 1	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

/datum/money_account/New()
	..()
	security_level = pick (0,1) //Stealing is now slightly viable

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/obj/machinery/account_database
	name = "Accounts database"
	desc = "Holds transaction logs, account data and all kinds of other financial records."
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	density = 1
	req_one_access = list(access_hop, access_captain)
	var/receipt_num
	var/machine_id = ""
	var/obj/item/weapon/card/id/held_card
	var/access_level = 0
	var/datum/money_account/detailed_account_view
	var/creating_new_account = 0
	var/activated = 1

	ghost_read=0
	ghost_write=0

/obj/machinery/account_database/New()
	..()
	if(!station_account)
		create_station_account()

	if(department_accounts.len == 0)
		for(var/department in station_departments)
			create_department_account(department)
	if(!vendor_account)
		create_department_account("Vendor")
		vendor_account = department_accounts["Vendor"]

	if(!current_date_string)
		current_date_string = "[time2text(world.timeofday, "DD")] [time2text(world.timeofday, "Month")], [game_year]"

	machine_id = "[station_name()] Acc. DB #[num_financial_terminals++]"

	account_DBs += src

/obj/machinery/account_database/attack_hand(mob/user as mob)
	if(ishuman(user) && !user.stat && get_dist(src,user) <= 1)
		var/dat = "<b>Accounts Database</b><br>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:171: dat += "<i>[machine_id]</i><br>"
		dat += {"<i>[machine_id]</i><br>
			Confirm identity: <a href='?src=\ref[src];choice=insert_card'>[held_card ? held_card : "-----"]</a><br>"}
		// END AUTOFIX
		if(access_level > 0)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:175: dat += "<a href='?src=\ref[src];toggle_activated=1'>[activated ? "Disable" : "Enable"] remote access</a><br>"
			dat += {"<a href='?src=\ref[src];toggle_activated=1'>[activated ? "Disable" : "Enable"] remote access</a><br>
				You may not edit accounts at this terminal, only create and view them.<br>"}
			// END AUTOFIX
			if(creating_new_account)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:178: dat += "<br>"
				dat += {"<br>
					<a href='?src=\ref[src];choice=view_accounts_list;'>Return to accounts list</a>
					<form name='create_account' action='?src=\ref[src]' method='get'>
					<input type='hidden' name='src' value='\ref[src]'>
					<input type='hidden' name='choice' value='finalise_create_account'>
					<b>Holder name:</b> <input type='text' id='holder_name' name='holder_name' style='width:250px; background-color:white;'><br>
					<b>Initial funds:</b> <input type='text' id='starting_funds' name='starting_funds' style='width:250px; background-color:white;'> (subtracted from station account)<br>
					<i>New accounts are automatically assigned a secret number and pin, which are printed separately in a sealed package.</i><br>
					<input type='submit' value='Create'><br>
					</form>"}
				// END AUTOFIX
			else
				if(detailed_account_view)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:190: dat += "<br>"
					dat += {"<br>
						<a href='?src=\ref[src];choice=view_accounts_list;'>Return to accounts list</a><hr>
						<b>Account number:</b> #[detailed_account_view.account_number]<br>
						<b>Account holder:</b> [detailed_account_view.owner_name]<br>
						<b>Account balance:</b> $[detailed_account_view.money]<br>
						<table border=1 style='width:100%'>
						<tr>
						<td><b>Date</b></td>
						<td><b>Time</b></td>
						<td><b>Target</b></td>
						<td><b>Purpose</b></td>
						<td><b>Value</b></td>
						<td><b>Source terminal ID</b></td>
						</tr>"}
					// END AUTOFIX
					for(var/datum/transaction/T in detailed_account_view.transaction_log)

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:205: dat += "<tr>"
						dat += {"<tr>
							<td>[T.date]</td>
							<td>[T.time]</td>
							<td>[T.target_name]</td>
							<td>[T.purpose]</td>
							<td>$[T.amount]</td>
							<td>[T.source_terminal]</td>
							</tr>"}
						// END AUTOFIX
					dat += "</table>"
				else

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:215: dat += "<a href='?src=\ref[src];choice=create_account;'>Create new account</a><br><br>"
					dat += {"<a href='?src=\ref[src];choice=create_account;'>Create new account</a><br><br>
						<table border=1 style='width:100%'>"}
					// END AUTOFIX
					for(var/i=1, i<=all_money_accounts.len, i++)
						var/datum/money_account/D = all_money_accounts[i]

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\Accounts.dm:219: dat += "<tr>"
						dat += {"<tr>
							<td>#[D.account_number]</td>
							<td>[D.owner_name]</td>
							<td><a href='?src=\ref[src];choice=view_account_detail;account_index=[i]'>View in detail</a></td>
							</tr>"}
						// END AUTOFIX
					dat += "</table>"

		user << browse(dat,"window=account_db;size=700x650")
	else
		user << browse(null,"window=account_db")

/obj/machinery/account_database/attackby(O as obj, user as mob)//TODO:SANITY
	if(istype(O, /obj/item/weapon/card))
		var/obj/item/weapon/card/id/idcard = O
		if(!held_card)
			usr.drop_item()
			idcard.loc = src
			held_card = idcard

			if(access_cent_captain in idcard.access)
				access_level = 2
			else if(access_hop in idcard.access || access_captain in idcard.access)
				access_level = 1
	else
		..()

/obj/machinery/account_database/Topic(var/href, var/href_list)
	..()
	if(href_list["toggle_activated"])
		activated = !activated

	if(href_list["choice"])
		switch(href_list["choice"])
			if("create_account")
				creating_new_account = 1
			if("finalise_create_account")
				var/account_name = href_list["holder_name"]
				var/starting_funds = max(text2num(href_list["starting_funds"]), 0)
				create_account(account_name, starting_funds, src)
				if(starting_funds > 0)
					//subtract the money
					station_account.money -= starting_funds

					//create a transaction log entry
					var/datum/transaction/T = new()
					T.target_name = account_name
					T.purpose = "New account funds initialisation"
					T.amount = "([starting_funds])"
					T.date = current_date_string
					T.time = worldtime2text()
					T.source_terminal = machine_id
					station_account.transaction_log.Add(T)

				creating_new_account = 0
			if("insert_card")
				if(held_card)
					held_card.loc = src.loc

					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(held_card)
					held_card = null
					access_level = 0

				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card/id))
						var/obj/item/weapon/card/id/C = I
						usr.drop_item()
						C.loc = src
						held_card = C

						if(access_cent_captain in C.access)
							access_level = 2
						else if(access_hop in C.access || access_captain in C.access)
							access_level = 1
			if("view_account_detail")
				var/index = text2num(href_list["account_index"])
				if(index && index <= all_money_accounts.len)
					detailed_account_view = all_money_accounts[index]
			if("view_accounts_list")
				detailed_account_view = null
				creating_new_account = 0

	src.attack_hand(usr)

/obj/machinery/account_database/proc/charge_to_account(var/attempt_account_number, var/source_name, var/purpose, var/terminal_id, var/amount)
	if(!activated)
		return 0
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			D.money += amount

			//create a transaction log entry
			var/datum/transaction/T = new()
			T.target_name = source_name
			T.purpose = purpose
			if(amount < 0)
				T.amount = "([amount])"
			else
				T.amount = "[amount]"
			T.date = current_date_string
			T.time = worldtime2text()
			T.source_terminal = terminal_id
			D.transaction_log.Add(T)

			return 1

	return 0

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/obj/machinery/account_database/proc/attempt_account_access(var/attempt_account_number, var/attempt_pin_number, var/security_level_passed = 0,var/pin_needed=1)
	if(!activated)
		return 0
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number || !pin_needed) )
				return D

/obj/machinery/account_database/proc/get_account(var/account_number)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D
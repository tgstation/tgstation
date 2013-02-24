/*

TODO:
give money an actual use (QM stuff, vending machines)
send money to people (might be worth attaching money to custom database thing for this, instead of being in the ID)
log transactions

*/

#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3

/obj/item/weapon/card/id/var/money = 2000

/obj/machinery/atm
	name = "NanoTrasen Automatic Teller Machine"
	desc = "For all your monetary needs!"
	icon = 'terminals.dmi'
	icon_state = "atm"
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	var/obj/machinery/account_database/linked_db
	var/datum/money_account/authenticated_account
	var/number_incorrect_tries = 0
	var/previous_account_number = 0
	var/max_pin_attempts = 3
	var/ticks_left_locked_down = 0
	var/ticks_left_timeout = 0
	var/machine_id = ""
	var/obj/item/weapon/card/held_card
	var/editing_security_level = 0
	var/view_screen = NO_SCREEN

/obj/machinery/atm/New()
	..()
	reconnect_database()
	machine_id = "[station_name()] RT #[num_financial_terminals++]"

/obj/machinery/atm/process()
	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--

	for(var/obj/item/weapon/spacecash/S in src)
		S.loc = src.loc
		if(prob(50))
			playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
		else
			playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		break

/obj/machinery/atm/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in world)
		if(DB.z == src.z)
			linked_db = DB
			break

/obj/machinery/atm/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/card))
		var/obj/item/weapon/card/id/idcard = I
		if(!held_card)
			usr.drop_item()
			idcard.loc = src
			held_card = idcard
			authenticated_account = null
	else if(authenticated_account)
		if(istype(I,/obj/item/weapon/spacecash))
			//consume the money
			authenticated_account.money += I:worth
			if(prob(50))
				playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
			else
				playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)

			//create a transaction log entry
			var/datum/transaction/T = new()
			T.target_name = authenticated_account.owner_name
			T.purpose = "Credit deposit"
			T.amount = I:worth
			T.source_terminal = machine_id
			T.date = current_date_string
			T.time = worldtime2text()
			authenticated_account.transaction_log.Add(T)

			user << "<span class='info'>You insert [I] into [src].</span>"
			src.attack_hand(user)
			del I
	else
		..()

/obj/machinery/atm/attack_hand(mob/user as mob)
	if(istype(user, /mob/living/silicon))
		user << "\red Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per NanoTrasen regulation #1005."
		return
	if(get_dist(src,user) <= 1)
		//check to see if the user has low security enabled
		scan_user(user)

		//js replicated from obj/machinery/computer/card
		var/dat = "<h1>NanoTrasen Automatic Teller Machine</h1>"
		dat += "For all your monetary needs!<br>"
		dat += "<i>This terminal is</i> [machine_id]. <i>Report this code when contacting NanoTrasen IT Support</i><br/>"
		dat += "Card: <a href='?src=\ref[src];choice=insert_card'>[held_card ? held_card.name : "------"]</a><br><br>"

		if(ticks_left_locked_down > 0)
			dat += "<span class='alert'>Maximum number of pin attempts exceeded! Access to this ATM has been temporarily disabled.</span>"
		else if(authenticated_account)
			switch(view_screen)
				if(CHANGE_SECURITY_LEVEL)
					dat += "Select a new security level for this account:<br><hr>"
					var/text = "Zero - Either the account number or card is required to access this account. EFTPOS transactions will require a card and ask for a pin, but not verify the pin is correct."
					if(authenticated_account.security_level != 0)
						text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=0'>[text]</a>"
					dat += "[text]<hr>"
					text = "One - An account number and pin must be manually entered to access this account and process transactions."
					if(authenticated_account.security_level != 1)
						text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=1'>[text]</a>"
					dat += "[text]<hr>"
					text = "Two - In addition to account number and pin, a card is required to access this account and process transactions."
					if(authenticated_account.security_level != 2)
						text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=2'>[text]</a>"
					dat += "[text]<hr><br>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>"
				if(VIEW_TRANSACTION_LOGS)
					dat += "<b>Transaction logs</b><br>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>"
					dat += "<table border=1 style='width:100%'>"
					dat += "<tr>"
					dat += "<td><b>Date</b></td>"
					dat += "<td><b>Time</b></td>"
					dat += "<td><b>Target</b></td>"
					dat += "<td><b>Purpose</b></td>"
					dat += "<td><b>Value</b></td>"
					dat += "<td><b>Source terminal ID</b></td>"
					dat += "</tr>"
					for(var/datum/transaction/T in authenticated_account.transaction_log)
						dat += "<tr>"
						dat += "<td>[T.date]</td>"
						dat += "<td>[T.time]</td>"
						dat += "<td>[T.target_name]</td>"
						dat += "<td>[T.purpose]</td>"
						dat += "<td>$[T.amount]</td>"
						dat += "<td>[T.source_terminal]</td>"
						dat += "</tr>"
					dat += "</table>"
				if(TRANSFER_FUNDS)
					dat += "<b>Account balance:</b> $[authenticated_account.money]<br>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a><br><br>"
					dat += "<form name='transfer' action='?src=\ref[src]' method='get'>"
					dat += "<input type='hidden' name='src' value='\ref[src]'>"
					dat += "<input type='hidden' name='choice' value='transfer'>"
					dat += "Target account number: <input type='text' name='target_acc_number' value='' style='width:200px; background-color:white;'><br>"
					dat += "Funds to transfer: <input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><br>"
					dat += "Transaction purpose: <input type='text' name='purpose' value='Funds transfer' style='width:200px; background-color:white;'><br>"
					dat += "<input type='submit' value='Transfer funds'><br>"
					dat += "</form>"
				else
					dat += "Welcome, <b>[authenticated_account.owner_name].</b><br/>"
					dat += "<b>Account balance:</b> $[authenticated_account.money]"
					dat += "<form name='withdrawal' action='?src=\ref[src]' method='get'>"
					dat += "<input type='hidden' name='src' value='\ref[src]'>"
					dat += "<input type='hidden' name='choice' value='withdrawal'>"
					dat += "<input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><input type='submit' value='Withdraw funds'><br>"
					dat += "</form>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=1'>Change account security level</a><br>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=2'>Make transfer</a><br>"
					dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=3'>View transaction log</a><br>"
					dat += "<A href='?src=\ref[src];choice=balance_statement'>Print balance statement</a><br>"
					dat += "<A href='?src=\ref[src];choice=logout'>Logout</a><br>"
		else if(linked_db)
			dat += "<form name='atm_auth' action='?src=\ref[src]' method='get'>"
			dat += "<input type='hidden' name='src' value='\ref[src]'>"
			dat += "<input type='hidden' name='choice' value='attempt_auth'>"
			dat += "<b>Account:</b> <input type='text' id='account_num' name='account_num' style='width:250px; background-color:white;'><br>"
			dat += "<b>PIN:</b> <input type='text' id='account_pin' name='account_pin' style='width:250px; background-color:white;'><br>"
			dat += "<input type='submit' value='Submit'><br>"
			dat += "</form>"
		else
			dat += "<span class='warning'>Unable to connect to accounts database, please retry and if the issue persists contact NanoTrasen IT support.</span>"
			reconnect_database()

		user << browse(dat,"window=atm;size=550x650")
	else
		user << browse(null,"window=atm")

/obj/machinery/atm/Topic(var/href, var/href_list)
	if(href_list["choice"])
		switch(href_list["choice"])
			if("transfer")
				if(authenticated_account && linked_db)
					var/target_account_number = text2num(href_list["target_acc_number"])
					var/transfer_amount = text2num(href_list["funds_amount"])
					var/transfer_purpose = href_list["purpose"]
					if(transfer_amount <= authenticated_account.money)
						if(linked_db.charge_to_account(target_account_number, authenticated_account.owner_name, transfer_purpose, machine_id, transfer_amount))
							usr << "\icon[src]<span class='info'>Funds transfer successful.</span>"
							authenticated_account.money -= transfer_amount

							//create an entry in the account transaction log
							var/datum/transaction/T = new()
							T.target_name = "Account #[target_account_number]"
							T.purpose = transfer_purpose
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							T.amount = "([transfer_amount])"
							authenticated_account.transaction_log.Add(T)
						else
							usr << "\icon[src]<span class='warning'>Funds transfer failed.</span>"

					else
						usr << "\icon[src]<span class='warning'>You don't have enough funds to do that!</span>"
			if("view_screen")
				view_screen = text2num(href_list["view_screen"])
			if("change_security_level")
				if(authenticated_account)
					var/new_sec_level = max( min(text2num(href_list["new_security_level"]), 2), 0)
					authenticated_account.security_level = new_sec_level
			if("attempt_auth")
				if(linked_db)
					var/tried_account_num = text2num(href_list["account_num"])
					if(!tried_account_num)
						tried_account_num = held_card.associated_account_number
					var/tried_pin = text2num(href_list["account_pin"])

					authenticated_account = linked_db.attempt_account_access(tried_account_num, tried_pin, held_card && held_card.associated_account_number == tried_account_num ? 2 : 1)
					if(!authenticated_account)
						if(previous_account_number == tried_account_num)
							if(++number_incorrect_tries > max_pin_attempts)
								//lock down the atm
								number_incorrect_tries = 0
								ticks_left_locked_down = 10
								playsound(src, 'buzz-two.ogg', 50, 1)

								//create an entry in the account transaction log
								var/datum/transaction/T = new()
								T.target_name = authenticated_account.owner_name
								T.purpose = "Unauthorised login attempt"
								T.source_terminal = machine_id
								T.date = current_date_string
								T.time = worldtime2text()
								authenticated_account.transaction_log.Add(T)
							else
								previous_account_number = tried_account_num
								number_incorrect_tries = 1
								playsound(src, 'buzz-sigh.ogg', 50, 1)
					else
						playsound(src, 'twobeep.ogg', 50, 1)
						ticks_left_timeout = 120
						view_screen = NO_SCREEN

						//create a transaction log entry
						var/datum/transaction/T = new()
						T.target_name = authenticated_account.owner_name
						T.purpose = "Remote terminal access"
						T.source_terminal = machine_id
						T.date = current_date_string
						T.time = worldtime2text()
						authenticated_account.transaction_log.Add(T)
			if("withdrawal")
				var/amount = max(text2num(href_list["funds_amount"]),0)
				if(authenticated_account && amount > 0)
					if(amount <= authenticated_account.money)
						playsound(src, 'chime.ogg', 50, 1)

						//remove the money
						authenticated_account.money -= amount
						withdraw_arbitrary_sum(amount)

						//create an entry in the account transaction log
						var/datum/transaction/T = new()
						T.target_name = authenticated_account.owner_name
						T.purpose = "Credit withdrawal"
						T.amount = "([amount])"
						T.source_terminal = machine_id
						T.date = current_date_string
						T.time = worldtime2text()
						authenticated_account.transaction_log.Add(T)
					else
						usr << "\icon[src]<span class='warning'>You don't have enough funds to do that!</span>"
			if("balance_statement")
				if(authenticated_account)
					var/obj/item/weapon/paper/R = new(src.loc)
					R.name = "Account balance: [authenticated_account.owner_name]"
					R.info = "<b>NT Automated Teller Account Statement</b><br><br>"
					R.info += "<i>Account holder:</i> [authenticated_account.owner_name]<br>"
					R.info += "<i>Account number:</i> [authenticated_account.account_number]<br>"
					R.info += "<i>Balance:</i> $[authenticated_account.money]<br>"
					R.info += "<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>"
					R.info += "<i>Service terminal ID:</i> [machine_id]<br>"

					//stamp the paper
					var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
					stampoverlay.icon_state = "paper_stamp-cent"
					if(!R.stamped)
						R.stamped = new
					R.stamped += /obj/item/weapon/stamp
					R.overlays += stampoverlay
					R.stamps += "<HR><i>This paper has been stamped by the Automatic Teller Machine.</i>"

				if(prob(50))
					playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
				else
					playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
			if("insert_card")
				if(held_card)
					held_card.loc = src.loc
					authenticated_account = null

					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(held_card)
					held_card = null

				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						held_card = I
			if("logout")
				authenticated_account = null
				usr << browse(null,"window=atm")
				return
	src.attack_hand(usr)

//create the most effective combination of notes to make up the requested amount
/obj/machinery/atm/proc/withdraw_arbitrary_sum(var/arbitrary_sum)
	while(arbitrary_sum >= 1000)
		arbitrary_sum -= 1000
		new /obj/item/weapon/spacecash/c1000(src)
	while(arbitrary_sum >= 500)
		arbitrary_sum -= 500
		new /obj/item/weapon/spacecash/c500(src)
	while(arbitrary_sum >= 200)
		arbitrary_sum -= 200
		new /obj/item/weapon/spacecash/c200(src)
	while(arbitrary_sum >= 100)
		arbitrary_sum -= 100
		new /obj/item/weapon/spacecash/c100(src)
	while(arbitrary_sum >= 50)
		arbitrary_sum -= 50
		new /obj/item/weapon/spacecash/c50(src)
	while(arbitrary_sum >= 20)
		arbitrary_sum -= 20
		new /obj/item/weapon/spacecash/c20(src)
	while(arbitrary_sum >= 10)
		arbitrary_sum -= 10
		new /obj/item/weapon/spacecash/c10(src)
	while(arbitrary_sum >= 1)
		arbitrary_sum -= 1
		new /obj/item/weapon/spacecash(src)

//stolen wholesale and then edited a bit from newscasters, which are awesome and by Agouri
/obj/machinery/atm/proc/scan_user(mob/living/carbon/human/human_user as mob)
	if(!authenticated_account && linked_db)
		if(human_user.wear_id)
			var/obj/item/weapon/card/id/I
			if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				I = human_user.wear_id
			else if(istype(human_user.wear_id, /obj/item/device/pda) )
				var/obj/item/device/pda/P = human_user.wear_id
				I = P.id
			if(I)
				authenticated_account = linked_db.attempt_account_access(I.associated_account_number)

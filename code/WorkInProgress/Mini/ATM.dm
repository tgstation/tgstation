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
#define PRINT_DELAY 100

/obj/item/weapon/card/id/var/money = 2000

/obj/machinery/atm
	name = "NanoTrasen Automatic Teller Machine"
	desc = "For all your monetary needs!"
	icon = 'icons/obj/terminals.dmi'
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
	var/lastprint = 0 // Printer needs time to cooldown

/obj/machinery/atm/New()
	..()
	machine_id = "[station_name()] RT #[num_financial_terminals++]"

/obj/machinery/atm/initialize()
	..()
	reconnect_database()

/obj/machinery/atm/process()
	if(stat & NOPOWER)
		return

	if(linked_db && ( (linked_db.stat & NOPOWER) || !linked_db.activated ) )
		linked_db = null
		authenticated_account = null
		src.visible_message("\red \icon[src] [src] buzzes rudely, \"Connection to remote database lost.\"")
		updateDialog()

	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--
		if(ticks_left_locked_down <= 0)
			number_incorrect_tries = 0

	if(authenticated_account)
		var/turf/T = get_turf(src)
		if(istype(T) && locate(/obj/item/weapon/spacecash) in T)
			var/list/cash_found = list()
			for(var/obj/item/weapon/spacecash/S in T)
				cash_found+=S
			if(cash_found.len>0)
				if(prob(50))
					playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
				else
					playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
				var/amount = count_cash(cash_found)
				for(var/obj/item/weapon/spacecash/S in cash_found)
					qdel(S)
				authenticated_account.charge(-amount,null,"Credit deposit",terminal_id=machine_id,dest_name = "Terminal")

/obj/machinery/atm/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((DB.z == src.z) || (DB.z == STATION_Z))
			if(!(DB.stat & NOPOWER) && DB.activated )//If the database if damaged or not powered, people won't be able to use the ATM anymore
				linked_db = DB
				break

/obj/machinery/atm/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/card))
		var/obj/item/weapon/card/id/idcard = I
		if(!held_card)
			usr.drop_item()
			idcard.loc = src
			held_card = idcard
			if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
				authenticated_account = null
	else if(authenticated_account)
		if(istype(I,/obj/item/weapon/spacecash))
			//consume the money
			authenticated_account.money += I:worth * I:amount
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
		var/dat = {"<h1>NanoTrasen Automatic Teller Machine</h1>
			For all your monetary needs!<br>
			<i>This terminal is</i> [machine_id]. <i>Report this code when contacting NanoTrasen IT Support</i><br/>
			Card: <a href='?src=\ref[src];choice=insert_card'>[held_card ? held_card.name : "------"]</a><br><br>"}

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
					dat += {"[text]<hr><br>
						<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>"}
				if(VIEW_TRANSACTION_LOGS)
					dat += {"<b>Transaction logs</b><br>
						<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>
						<table border=1 style='width:100%'>
						<tr>
						<td><b>Date</b></td>
						<td><b>Time</b></td>
						<td><b>Target</b></td>
						<td><b>Purpose</b></td>
						<td><b>Value</b></td>
						<td><b>Source terminal ID</b></td>
						</tr>"}
					for(var/datum/transaction/T in authenticated_account.transaction_log)
						dat += {"<tr>
							<td>[T.date]</td>
							<td>[T.time]</td>
							<td>[T.target_name]</td>
							<td>[T.purpose]</td>
							<td>$[T.amount]</td>
							<td>[T.source_terminal]</td>
							</tr>"}
					dat += "</table>"
				if(TRANSFER_FUNDS)
					dat += {"<b>Account balance:</b> $[authenticated_account.money]<br>
						<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a><br><br>
						<form name='transfer' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='choice' value='transfer'>
						Target account number: <input type='text' name='target_acc_number' value='' style='width:200px; background-color:white;'><br>
						Funds to transfer: <input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><br>
						Transaction purpose: <input type='text' name='purpose' value='Funds transfer' style='width:200px; background-color:white;'><br>
						<input type='submit' value='Transfer funds'><br>
						</form>"}
				else
					dat += {"Welcome, <b>[authenticated_account.owner_name].</b><br/>
						<b>Account balance:</b> $[authenticated_account.money]
						<form name='withdrawal' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='choice' value='withdrawal'>
						<input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><input type='submit' value='Withdraw funds'><br>
						</form>
						<A href='?src=\ref[src];choice=view_screen;view_screen=1'>Change account security level</a><br>
						<A href='?src=\ref[src];choice=view_screen;view_screen=2'>Make transfer</a><br>
						<A href='?src=\ref[src];choice=view_screen;view_screen=3'>View transaction log</a><br>
						<A href='?src=\ref[src];choice=balance_statement'>Print balance statement</a><br>
						<A href='?src=\ref[src];choice=logout'>Logout</a><br>"}
		else if(linked_db)
			dat += {"<form name='atm_auth' action='?src=\ref[src]' method='get'>
				<input type='hidden' name='src' value='\ref[src]'>
				<input type='hidden' name='choice' value='attempt_auth'>
				<b>Account:</b> <input type='text' id='account_num' name='account_num' style='width:250px; background-color:white;'><br>
				<b>PIN:</b> <input type='text' id='account_pin' name='account_pin' style='width:250px; background-color:white;'><br>
				<input type='submit' value='Submit'><br>
				</form>"}
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
					var/transfer_amount = text2num(href_list["funds_amount"])
					if(transfer_amount <= 0)
						alert("That is not a valid amount.")
					else if(transfer_amount <= authenticated_account.money)
						var/target_account_number = text2num(href_list["target_acc_number"])
						var/transfer_purpose = href_list["purpose"]
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
				if(linked_db && !ticks_left_locked_down)
					var/tried_account_num = text2num(href_list["account_num"])
					if(!tried_account_num)
						tried_account_num = held_card.associated_account_number
					var/tried_pin = text2num(href_list["account_pin"])

					authenticated_account = linked_db.attempt_account_access(tried_account_num, tried_pin, held_card && held_card.associated_account_number == tried_account_num ? 2 : 1)
					if(!authenticated_account)
						number_incorrect_tries++
						if(previous_account_number == tried_account_num)
							if(number_incorrect_tries > max_pin_attempts)
								//lock down the atm
								ticks_left_locked_down = 30
								playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)

								//create an entry in the account transaction log
								var/datum/money_account/failed_account = linked_db.get_account(tried_account_num)
								if(failed_account)
									var/datum/transaction/T = new()
									T.target_name = failed_account.owner_name
									T.purpose = "Unauthorised login attempt"
									T.source_terminal = machine_id
									T.date = current_date_string
									T.time = worldtime2text()
									failed_account.transaction_log.Add(T)
							else
								usr << "\red \icon[src] Incorrect pin/account combination entered, [max_pin_attempts - number_incorrect_tries] attempts remaining."
								previous_account_number = tried_account_num
								playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
						else
							usr << "\red \icon[src] incorrect pin/account combination entered."
							number_incorrect_tries = 0
					else
						playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
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

						usr << "\blue \icon[src] Access granted. Welcome user '[authenticated_account.owner_name].'"

					previous_account_number = tried_account_num
			if("withdrawal")
				var/amount = max(text2num(href_list["funds_amount"]),0)
				if(amount <= 0)
					alert("That is not a valid amount.")
				else if(authenticated_account && amount > 0)
					if(amount <= authenticated_account.money)
						playsound(src, 'sound/machines/chime.ogg', 50, 1)

						//remove the money
						if(amount > 10000) // prevent crashes
							usr << "\blue The ATM's screen flashes, 'Maximum single withdrawl limit reached, defaulting to 10,000.'"
							amount = 10000
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
					if(world.timeofday < lastprint + PRINT_DELAY)
						usr << "<span class='notice'>The [src.name] flashes an error on its display.</span>"
						return
					lastprint = world.timeofday
					var/obj/item/weapon/paper/R = new(src.loc)
					R.name = "Account balance: [authenticated_account.owner_name]"
					R.info = {"<b>NT Automated Teller Account Statement</b><br><br>
						<i>Account holder:</i> [authenticated_account.owner_name]<br>
						<i>Account number:</i> [authenticated_account.account_number]<br>
						<i>Balance:</i> $[authenticated_account.money]<br>
						<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>
						<i>Service terminal ID:</i> [machine_id]<br>"}

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
				//usr << browse(null,"window=atm")

	src.attack_hand(usr)

//create the most effective combination of notes to make up the requested amount
/obj/machinery/atm/proc/withdraw_arbitrary_sum(var/arbitrary_sum)
	dispense_cash(arbitrary_sum,get_step(get_turf(src),turn(dir,180))) // Spawn on the ATM.

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
				if(authenticated_account)
					human_user << "\blue \icon[src] Access granted. Welcome user '[authenticated_account.owner_name].'"

					//create a transaction log entry
					var/datum/transaction/T = new()
					T.target_name = authenticated_account.owner_name
					T.purpose = "Remote terminal access"
					T.source_terminal = machine_id
					T.date = current_date_string
					T.time = worldtime2text()
					authenticated_account.transaction_log.Add(T)

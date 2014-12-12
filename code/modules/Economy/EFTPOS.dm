/obj/item/device/eftpos
	name = "EFTPOS scanner"
	desc = "Swipe your ID card to make purchases electronically."
	icon = 'icons/obj/device.dmi'
	icon_state = "eftpos"
	var/machine_id = ""
	var/eftpos_name = "Default EFTPOS scanner"
	var/transaction_locked = 0
	var/transaction_paid = 0
	var/transaction_amount = 0
	var/transaction_purpose = "Default charge"
	var/access_code = 0
	var/obj/machinery/account_database/linked_db
	var/datum/money_account/linked_account

/obj/item/device/eftpos/New()
	..()
	machine_id = "[station_name()] EFTPOS #[num_financial_terminals++]"
	access_code = rand(1111,111111)
	reconnect_database()
	spawn(0)
		print_reference()

	//by default, connect to the station account
	//the user of the EFTPOS device can change the target account though, and no-one will be the wiser (except whoever's being charged)
	linked_account = station_account

/obj/item/device/eftpos/proc/print_reference()
	var/obj/item/weapon/paper/R = new(src.loc)
	R.name = "Reference: [eftpos_name]"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\EFTPOS.dm:31: R.info = "<b>[eftpos_name] reference</b><br><br>"
	R.info = {"<b>[eftpos_name] reference</b><br><br>
		Access code: [access_code]<br><br>
		<b>Do not lose or misplace this code.</b><br>"}
	// END AUTOFIX
	//stamp the paper
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!R.stamped)
		R.stamped = new
	R.stamped += /obj/item/weapon/stamp
	R.overlays += stampoverlay
	R.stamps += "<HR><i>This paper has been stamped by the EFTPOS device.</i>"
	var/obj/item/smallDelivery/D = new(R.loc)
	R.loc = D
	D.wrapped = R
	D.name = "small parcel - 'EFTPOS access code'"

/obj/item/device/eftpos/proc/reconnect_database()
	var/turf/location = get_turf(src)
	if(!location)
		return

	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((DB.z == src.z) || (DB.z == STATION_Z))
			if(!(DB.stat & NOPOWER) && DB.activated )//If the database if damaged or not powered, people won't be able to use the EFTPOS anymore
				linked_db = DB
				break

/obj/item/device/eftpos/attack_self(mob/user as mob)
	if(get_dist(src,user) <= 1)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\EFTPOS.dm:59: var/dat = "<b>[eftpos_name]</b><br>"
		var/dat = {"<b>[eftpos_name]</b><br>
<i>This terminal is</i> [machine_id]. <i>Report this code when contacting NanoTrasen IT Support</i><br>"}
		// END AUTOFIX
		if(transaction_locked)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\EFTPOS.dm:59: dat += "<a href='?src=\ref[src];choice=toggle_lock'>Reset[transaction_paid ? "" : " (authentication required)"]</a><br><br>"
			dat += {"<a href='?src=\ref[src];choice=toggle_lock'>Reset[transaction_paid ? "" : " (authentication required)"]</a><br><br>
				Transaction purpose: <b>[transaction_purpose]</b><br>
				Value: <b>$[transaction_amount]</b><br>
				Linked account: <b>[linked_account ? linked_account.owner_name : "None"]</b><hr>"}
			// END AUTOFIX
			if(transaction_paid)
				dat += "<i>This transaction has been processed successfully.</i><hr>"
			else

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\EFTPOS.dm:67: dat += "<i>Swipe your card below the line to finish this transaction.</i><hr>"
				dat += {"<i>Swipe your card below the line to finish this transaction.</i><hr>
					<a href='?src=\ref[src];choice=scan_card'>\[------\]</a>"}
				// END AUTOFIX
		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Economy\EFTPOS.dm:70: dat += "<a href='?src=\ref[src];choice=toggle_lock'>Lock in new transaction</a><br><br>"
			dat += {"<a href='?src=\ref[src];choice=toggle_lock'>Lock in new transaction</a><br><br>
				Transaction purpose: <a href='?src=\ref[src];choice=trans_purpose'>[transaction_purpose]</a><br>
				Value: <a href='?src=\ref[src];choice=trans_value'>$[transaction_amount]</a><br>
				Linked account: <a href='?src=\ref[src];choice=link_account'>[linked_account ? linked_account.owner_name : "None"]</a><hr>
				<a href='?src=\ref[src];choice=change_code'>Change access code</a><br>
				<a href='?src=\ref[src];choice=change_id'>Change EFTPOS ID</a><br>
				Scan card to reset access code <a href='?src=\ref[src];choice=reset'>\[------\]</a>"}
			// END AUTOFIX
		user << browse(dat,"window=eftpos")
	else
		user << browse(null,"window=eftpos")

/obj/item/device/eftpos/attackby(O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = O
				scan_card(I)
			else
				usr << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"
	else
		..()

/obj/item/device/eftpos/Topic(var/href, var/href_list)
	if(href_list["choice"])
		switch(href_list["choice"])
			if("change_code")
				var/attempt_code = input("Re-enter the current EFTPOS access code", "Confirm old EFTPOS code") as num
				if(attempt_code == access_code)
					var/trycode = input("Enter a new access code for this device (4-6 digits, numbers only)", "Enter new EFTPOS code") as num
					if(trycode >= 1000 && trycode <= 999999)
						access_code = trycode
					else
						alert("That is not a valid code!")
					print_reference()
				else
					usr << "\icon[src]<span class='warning'>Incorrect code entered.</span>"
			if("change_id")
				var/attempt_code = text2num(input("Re-enter the current EFTPOS access code", "Confirm EFTPOS code"))
				if(attempt_code == access_code)
					eftpos_name = input("Enter a new terminal ID for this device", "Enter new EFTPOS ID") + " EFTPOS scanner"
					print_reference()
				else
					usr << "\icon[src]<span class='warning'>Incorrect code entered.</span>"
			if("link_account")
				if(!linked_db)
					reconnect_database()
				if(linked_db)
					var/attempt_account_num = input("Enter account number to pay EFTPOS charges into", "New account number") as num
					var/attempt_pin = input("Enter pin code", "Account pin") as num
					linked_account = linked_db.attempt_account_access(attempt_account_num, attempt_pin, 1)
				else
					usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"
			if("trans_purpose")
				transaction_purpose = input("Enter reason for EFTPOS transaction", "Transaction purpose")
			if("trans_value")
				var/try_num = input("Enter amount for EFTPOS transaction", "Transaction amount") as num
				if(try_num < 0)
					alert("That is not a valid amount!")
				else
					transaction_amount = try_num
			if("toggle_lock")
				if(transaction_locked)
					var/attempt_code = input("Enter EFTPOS access code", "Reset Transaction") as num
					if(attempt_code == access_code)
						transaction_locked = 0
						transaction_paid = 0
				else if(linked_account)
					transaction_locked = 1
				else
					usr << "\icon[src] <span class='warning'>No account connected to send transactions to.</span>"
			if("scan_card")
				//attempt to connect to a new db, and if that doesn't work then fail
				if(!linked_db)
					reconnect_database()
				if(linked_db && linked_account)
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/weapon/card))
						scan_card(I)
				else
					usr << "\icon[src]<span class='warning'>Unable to link accounts.</span>"
			if("reset")
				//reset the access code - requires HoP/captain access
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card))
					var/obj/item/weapon/card/id/C = I
					if(access_cent_captain in C.access || access_hop in C.access || access_captain in C.access)
						access_code = 0
						usr << "\icon[src]<span class='info'>Access code reset to 0.</span>"
				else if (istype(I, /obj/item/weapon/card/emag))
					access_code = 0
					usr << "\icon[src]<span class='info'>Access code reset to 0.</span>"

	src.attack_self(usr)

/obj/item/device/eftpos/proc/scan_card(var/obj/item/weapon/card/I)
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(transaction_locked && !transaction_paid)
			if(linked_account)
				var/attempt_pin = input("Enter pin code", "EFTPOS transaction") as num
				var/datum/money_account/D = linked_db.attempt_account_access(C.associated_account_number, attempt_pin, 2)
				if(D)
					if(transaction_amount <= D.money)
						playsound(src, 'sound/machines/chime.ogg', 50, 1)
						src.visible_message("\icon[src] The [src] chimes.")
						transaction_paid = 1

						//transfer the money
						D.money -= transaction_amount
						linked_account.money += transaction_amount

						//create entries in the two account transaction logs
						var/datum/transaction/T = new()
						T.target_name = "[linked_account.owner_name] (via [eftpos_name])"
						T.purpose = transaction_purpose
						if(transaction_amount > 0)
							T.amount = "([transaction_amount])"
						else
							T.amount = "[transaction_amount]"
						T.source_terminal = machine_id
						T.date = current_date_string
						T.time = worldtime2text()
						D.transaction_log.Add(T)
						//
						T = new()
						T.target_name = D.owner_name
						T.purpose = transaction_purpose
						T.amount = "[transaction_amount]"
						T.source_terminal = machine_id
						T.date = current_date_string
						T.time = worldtime2text()
						linked_account.transaction_log.Add(T)
					else
						usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
				else
					usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"
			else
				usr << "\icon[src]<span class='warning'>EFTPOS is not connected to an account.</span>"
	else
		..()

	//emag?
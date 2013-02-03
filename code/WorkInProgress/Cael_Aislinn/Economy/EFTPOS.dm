/obj/item/weapon/eftpos
	name = "EFTPOS scanner"
	desc = "Swipe your ID card to pay electronically."
	icon = 'icons/obj/library.dmi'
	icon_state = "scanner"
	var/machine_id = ""
	var/eftpos_name = "Default EFTPOS scanner"
	var/transaction_locked = 0
	var/transaction_paid = 0
	var/transaction_amount = 0
	var/transaction_purpose = "Default charge"
	var/access_code = 0
	var/obj/machinery/account_database/linked_db
	var/datum/money_account/linked_account

/obj/item/weapon/eftpos/New()
	..()
	machine_id = "[station_name()] EFTPOS #[num_financial_terminals++]"
	access_code = rand(1111,111111)
	reconnect_database()
	print_reference()

	//by default, connect to the station account
	//the user of the EFTPOS device can change the target account though, and no-one will be the wiser (except whoever's being charged)
	linked_account = station_account

/obj/item/weapon/eftpos/proc/print_reference()
	var/obj/item/weapon/paper/R = new(get_turf(src))
	R.name = "Reference: [eftpos_name]"
	R.info = "<b>[eftpos_name] reference</b><br><br>"
	R.info += "Access code: [access_code]<br><br>"
	R.info += "<b>Do not lose this code, or the device will have to be replaced.</b><br>"

	//stamp the paper
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_stamp-cent"
	if(!R.stamped)
		R.stamped = new
	R.stamped += /obj/item/weapon/stamp
	R.overlays += stampoverlay
	R.stamps += "<HR><i>This paper has been stamped by the EFTPOS device.</i>"

/obj/item/weapon/eftpos/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in world)
		if(DB.z == src.z)
			linked_db = DB
			break

/obj/item/weapon/eftpos/attack_self(mob/user as mob)
	if(get_dist(src,user) <= 1)
		var/dat = "<b>[eftpos_name]</b><br>"
		dat += "<i>This terminal is</i> [machine_id]. <i>Report this code when contacting NanoTrasen IT Support</i><br>"
		if(transaction_locked)
			dat += "<a href='?src=\ref[src];choice=toggle_lock'>Reset[transaction_paid ? "" : " (authentication required)"]</a><br><br>"

			dat += "Transaction purpose: <b>[transaction_purpose]</b><br>"
			dat += "Value: <b>$[transaction_amount]</b><br>"
			dat += "Linked account: <b>[linked_account ? linked_account.owner_name : "None"]</b><hr>"
			if(transaction_paid)
				dat += "<i>This transaction has been processed successfully.</i><hr>"
			else
				dat += "<i>Swipe your card below the line to finish this transaction.</i><hr>"
				dat += "<a href='?src=\ref[src];choice=scan_card'>\[------\]</a>"
		else
			dat += "<a href='?src=\ref[src];choice=toggle_lock'>Lock in new transaction</a><br><br>"

			dat += "Transaction purpose: <a href='?src=\ref[src];choice=trans_purpose'>[transaction_purpose]</a><br>"
			dat += "Value: <a href='?src=\ref[src];choice=trans_value'>$[transaction_amount]</a><br>"
			dat += "Linked account: <a href='?src=\ref[src];choice=link_account'>[linked_account ? linked_account.owner_name : "None"]</a><hr>"
			dat += "<a href='?src=\ref[src];choice=change_code'>Change access code</a>"
		user << browse(dat,"window=eftpos")
	else
		user << browse(null,"window=eftpos")

/obj/item/weapon/eftpos/attackby(O as obj, user as mob)
	if(istype(O, /obj/item/weapon/card))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db && linked_account)
			var/obj/item/weapon/card/I = O
			scan_card(I)
		else
			usr << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"
	else
		..()

/obj/item/weapon/eftpos/Topic(var/href, var/href_list)
	if(href_list["choice"])
		switch(href_list["choice"])
			if("change_code")
				var/attempt_code = text2num(input("Re-enter the current EFTPOS access code", "Confirm old EFTPOS code"))
				if(attempt_code == access_code)
					access_code = text2num(input("Enter a new access code for this device", "Enter new EFTPOS code"))
					print_reference()
				else
					usr << "\icon[src]<span class='warning'>Incorrect code entered.</span>"
			if("link_account")
				if(linked_db)
					var/attempt_account_num = text2num(input("Enter account number to pay EFTPOS charges into", "New account number"))
					var/attempt_pin = text2num(input("Enter pin code", "Account pin"))
					linked_account = linked_db.attempt_account_access(attempt_account_num, attempt_pin, 1)
				else
					usr << "<span class='warning'>Unable to connect to accounts database.</span>"
			if("trans_purpose")
				transaction_purpose = input("Enter reason for EFTPOS transaction", "Transaction purpose")
			if("trans_value")
				transaction_amount = max(text2num(input("Enter amount for EFTPOS transaction", "Transaction amount")),0)
			if("toggle_lock")
				if(transaction_locked)
					var/attempt_code = text2num(input("Enter EFTPOS access code", "Reset Transaction"))
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

	src.attack_self(usr)

/obj/item/weapon/eftpos/proc/scan_card(var/obj/item/weapon/card/I)
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(transaction_locked && !transaction_paid)
			if(linked_account)
				var/attempt_pin = text2num(input("Enter pin code", "EFTPOS transaction"))
				var/datum/money_account/D = linked_db.attempt_account_access(C.associated_account_number, attempt_pin, 2)
				if(D)
					if(transaction_amount <= D.money)
						playsound(src, 'chime.ogg', 50, 1)
						src.visible_message("\icon[src] The [src] chimes.")
						transaction_paid = 1

						//transfer the money
						D.money -= transaction_amount
						linked_account.money += transaction_amount

						//create entries in the two account transaction logs
						var/datum/transaction/T = new()
						T.target_name = "[linked_account.owner_name] ([eftpos_name])"
						T.purpose = transaction_purpose
						T.amount = "([transaction_amount])"
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
						usr << "\icon[src]<span class='warning'>You don't have that much money!<span>"
				else
					usr << "\icon[src]<span class='warning'>EFTPOS is not connected to an account.<span>"
			else
				usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"
	else
		..()

	//emag?
/obj/machinery/atm
	name = "automated transfer machine"
	desc = "An ATM belonging to the Nanotrasen Central Bank. Can be used to withdraw or deposit cash and manage your finances."
	icon = 'icons/obj/economy.dmi'
	icon_state = "atm"

	idle_power_usage = 25
	power_channel = EQUIP

	var/mode = 1 	// what screen we're on.
					// 0 = failure
					// 1 = main menu
					// 2 = deposit cash
					// 3 = withdraw cash
					// 4 = transfer money
					// 5 = manage accounts
					// 6 = open a new account
					// 7 = account list
	var/prevmode = 0 //So you can go back to the last screen before an error message.
	var/failuremessage = "" //what message to display when something fails.
	
	var/datum/bankaccount/selectedaccount = null //The currently selected account (in the manage accounts screen)
	var/datum/bankaccount/selectedaccount2 = null //The account to transfer to.

	var/obj/item/weapon/card/id/card
	var/list/swallowed = list() //list of cards that the machine has swallowed. 
	var/list/coins = list() //list of currently deposited coins.
	var/list/cash = list() //list of space cash currently in the machine.

/obj/machinery/atm/update_icon()
	if(stat & NOPOWER)
		icon_state = "atm_off"
	else
		icon_state = "atm"

/obj/machinery/atm/attackby(obj/item/I, mob/user, params)
	if(istype(I, obj/item/weapon/card/id))
		if(user.unEquip(I))
			I.loc = src
			card = I
			user << "<span class='notice'>You put your card in [src].</span>"
			if(card.account.frozen)
				user << "<span class='userdanger'>The machine swallows your card!</span>"
				swallowed |= card
				card = null
				return
			selectedaccount = card.account
			updateDialog()

/obj/machinery/atm/Interact(mob/user)
	var/datum/browser/popup = new(user, "atm", "Automated Transfer Machine", 400, 500)
	var/dat = ""
	if(card)
		dat += "<b>ID:</b> <a href='?src=\ref[src];ejectid=1'>[card]</a>\n"
	else
		dat += "<center><b>No ID card inserted.</b></center>"
	if(card)
		dat += "<hr>\n\n"
		if(!bank.isOperational())
			dat += "<span class='danger'>The local banking system is currently inoperational. No transactions can be made at this time.</span>"
		else
			if(mode != 1)
				dat += "<center><a href='?src=\ref[src];changemode=1'>< Back to Main Menu</a></center>\n\n"

			switch(mode)
				if(0) //Failure screen
					dat += failuremessage
					dat += "\n<a href='?src=\ref[src];changemode=[prevmode]'>Back</a>"

				if(1) //Main menu
					selectedaccount = null
					selectedaccount2 = null
					dat += "Welcome, [card.registered_name]. Please select an operation.\n"
					dat += "<center><a href='?src=\ref[src];changemode=2'>Deposit Cash</a></center>\n"
					dat += "<center><a href='?src=\ref[src];changemode=3'>Withdraw Cash</a></center>\n"
					dat += "<center><a href='?src=\ref[src];changemode=4'>Transfer Money</a></center>\n"
					dat += "<center><a href='?src=\ref[src];changemode=5'>Manage Accounts</a></center>\n"
					dat += "<center><a href='?src=\ref[src];changemode=6'>Open a New Account</a></center>\n"
					dat += "<center><a href='?src=\ref[src];changemode=7'>Account List</a></center>\n"

				if(2) //Deposit cash.
					dat += "Please select an account, insert any cash you wish to deposit and then click \"Deposit\"\n"
					for(var/datum/bankaccount/acc in card.accountlist)
						var/selected = acc == selectedaccount
						dat += "[selected ? "<span class='linkOff'>" : "<a href='?src=\ref[src];selectaccount=[acc.name]'>"][acc.name][acc.owner ? " ([acc.owner])" : ""][acc.verified ? " <font color='green'>V</font>" : ""] [acc.balance] [CURRENCY(acc.balance)][selected ? "</span>" : "</a>"]\n"
					dat += "<a href='?src=\ref[src];depositcash=1'>Deposit</a>\n"

				if(3) //Withdraw cash
					dat += "Please select an account, enter an amount, and then click \"Withdraw\"\n"
					dat += 	"<form name='withdraw' action='?src=\ref[src]'>\
										<input type='hidden' name='src' value='\ref[src]'>\
										<input type='hidden' name='withdraw' value='amount'>\
										<input type='text' name='amount'>\
										<input type='submit' value='Withdraw'>\
										</form>\n\n"

					for(var/datum/bankaccount/acc in card.accountlist)
						var/selected = acc == selectedaccount
						dat += "[selected ? "<span class='linkOff'>" : "<a href='?src=\ref[src];selectaccount=[acc.name]'>"][acc.name][acc.owner ? " ([acc.owner])" : ""][acc.verified ? " <font color='green'>V</font>" : ""] [acc.balance] [CURRENCY(acc.balance)][selected ? "</span>" : "</a>"]\n"

				if(4) //Transfer money
					dat += "Please enter an amount, select two accounts, and then click \"Transfer\"\n"
					dat += 	"<form name='transfer' action='?src=\ref[src]'>\
										<input type='hidden' name='src' value='\ref[src]'>\
										<input type='hidden' name='transfer' value='amount'>\
										<input type='text' name='amount'>\
										<input type='submit' value='Transfer'>\
										</form>\n\n"

					for(var/datum/bankaccount/acc in card.accountlist)
						var/selected = acc == selectedaccount
						dat += "[selected ? "<span class='linkOff'>" : "<a href='?src=\ref[src];selectaccount=[acc.name]'>"][acc.name][acc.owner ? " ([acc.owner])" : ""][acc.verified ? " <font color='green'>V</font>" : ""] [acc.balance] [CURRENCY(acc.balance)][selected ? "</span>" : "</a>"]\n"

					dat += 	"<hr>"
					dat += 	"<form name='search' action='?src=\ref[src]'>\
										<input type='hidden' name='src' value='\ref[src]'>\
										<input type='hidden' name='search' value='tosearch'>\
										<input type='text' name='tosearch' value='[tosearch]'>\
										<input type='submit' value='Search'>\
										</form>\n\n"

					for(var/datum/bankaccount/acc in bank.accounts)
						var/pendingcontent = "[acc.name][acc.owner ? " ([acc.owner])" : ""]"
						if(tosearch && findtext(pendingcontent, tosearch))
							dat += "[selected ? "<span class='linkOff'>" : "<a href='?src=\ref[src];selectaccount2=[acc.name]'>"][pendingcontent][acc.verified ? " <font color='green'>V</font>" : ""] [acc.balance] [CURRENCY(acc.balance)][selected ? "</span>" : "</a>"]\n"

				if(5) //Manage accounts
					if(!selectedaccount)
						dat += "Please select an account to begin."
						
						for(var/datum/bankaccount/acc in card.accountlist)
							dat += "<a href='?src=\ref[src];selectaccount=[acc.name]'>[acc.name][acc.owner ? " ([acc.owner])" : ""][acc.verified ? " <font color='green'>V</font>" : ""] [acc.balance] [CURRENCY(acc.balance)]</a>\n"

					else if(selectedaccount in card.accountlist) //cant have people looking at other people's account details!
						dat += "<a href='?src=\ref[src];selectaccount=0'>Back</a>\n"
						dat += "<hr>"
						dat += ""
						dat += "Account number:\t[selectedaccount.name]\n"
						dat += "Account owner:\t[selectedaccount.verified ? "<span class='LinkOff'>" : "<a href='?src=\ref[src];changename=1'>"][selectedaccount.owner][selectaccount.verified ? "</span>" : "</a>"]\n"
						dat += "Balance:\t[selectedaccount.balance]\n"
						dat += "Verified: \t[selectedaccount.verified ? "Yes" : "No"]\n"
						dat += "Linked Cards: t[selectedaccount.cards.len]\n"
						
						dat += "<hr>"
						dat += "<b>Logs</b>\n"
						for(var/log in selectaccount.logs)
							dat += log
							dat += "\n"

				if(6 to INFINITY) //holy shit i hate making uis
					dat += "ayy lmao"

	popup.set_content(dat)
	popup.open()

/obj/machinery/atm/Topic(href, href_list)
	if(..() || !bank.isOperational())
		return

	if(href_list["changemode"])
		mode = href_list["changemode"]
		updateDialog()
		return

	if(href_list["selectaccount"])
		selectedaccount = bank.accounts[href_list["selectedaccount"]]
		updateDialog()
		return
	
	if(href_list["selectaccount2"])
		selectedaccount2 = bank.accounts[href_list["selectedaccount2"]]
		updateDialog()
		return
	
	if(href_list["search"])
		var/tosearch = href_list["tosearch"]
		updateDialog()
		return

	if(href_list["depositcash"])
		var/value = 0
		for(var/obj/item/weapon/coin/C in coins)
			value += C.value
		for(var/obj/item/stack/spacecash/S in cash)
			value += amount
		if(selectedaccount.depositAmount(amount, card.registered_name, 0))
			for(var/obj/item/stack/spacecash/S in cash)
				qdel(S) //holocash!
			for(var/obj/item/weapon/coin/C in coins)
				move_to_vault(C) //bluespace ATMs
		else
			fail("Deposit failed. Please try again later.")
			return
		updateDialog()
		return

	if(href_list["withdraw"])
		var/value = text2num(href_list["amount"])
		if(!isnum(value) || value <= 0)
			fail("Please enter a valid amount to withdraw.")
			return
		else if(selectedaccount.withdrawAmount(value, card.registered_name, 0))
			eject_cash(value)
		else
			fail("Withdrawal failed, the account balance is insufficient for the requested amount.") //if the account is frozen or the bank is inoperational, you wouldnt reach this message.
			return
		updateDialog()
		return
	
	if(href_list["transfer"])
		var/value = text2num(href_list["amount"])
		if(!isnum(value) || value <= 0)
			fail("Please enter a valid amount to transfer.")
			return
		else if(!bank.transferAmount(selectedaccount, selectedaccount2, value, card.registered_name))
			fail("Transfer failed. Please ensure that your account has sufficient balance and that the target account is not frozen.")
			return
		updateDialog()
		return

/obj/machinery/atm/proc/fail(message)
	failuremessage = message
	prevmode = mode
	mode = 0
	updateDialog()

/obj/machinery/atm/proc/eject_cash(value)
	var/obj/item/stack/spacecash/S = new(loc, value)
	S.update_icon()
	

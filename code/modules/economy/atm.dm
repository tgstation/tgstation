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
					// 5 = manage account (account list)
					// 6 = open a new account
					// 7 = account list
					// 8 = manage account (account info/menu)
	var/prevmode = 0 //So you can go back to the last screen before an error message.
	var/failuremessage = "" //what message to display when something fails.
	
	var/datum/bankaccount/selectedaccount = null //The currently selected account (in the manage accounts screen)

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

/obj/machinery/atm/Interact(mob/user)
	var/datum/browser/popup = newnew(user, "atm", "Automated Transfer Machine", 400, 500)
	if(card)
		popup.content += "<b>ID:</b> <a href='?src=\ref[src];ejectid=1'>[card]</a>\n"
	else
		popup.content += "<center><b>No ID card inserted.</b></center>"
	if(card)
		popup.content += "<hr>\n\n"
		if(!bank.isOperational())
			popup.content += "<span class='danger'>The local banking system is currently inoperational. No transactions can be made at this time.</span>"
		else
			if(mode != 1)
				popup.content += "<center><a href='?src=\ref[src];changemode=1'>< Back to Main Menu</a></center>\n\n"
			switch(mode)
				if(0) //Failure screen
					popup.content += "<a href='?src=\ref[src];changemode=[prevmode]'>Back</a>"
					popup.content += failuremessage
				if(1) //Main menu
					popup.content += "Welcome, [card.registered_name]. Please select an operation.\n"
					popup.content += "<center><a href='?src=\ref[src];changemode=2'>Deposit Cash</a></center>\n"
					popup.content += "<center><a href='?src=\ref[src];changemode=3'>Withdraw Cash</a></center>\n"
					popup.content += "<center><a href='?src=\ref[src];changemode=4'>Transfer Money</a></center>\n"
					popup.content += "<center><a href='?src=\ref[src];changemode=5'>Manage Accounts</a></center>\n"
					popup.content += "<center><a href='?src=\ref[src];changemode=6'>Open a New Account</a></center>\n"
					popup.content += "<center><a href='?src=\ref[src];changemode=7'>Account List</a></center>\n"
					
				if(2) //Deposit cash.
					popup.content += "Please select an account, insert any cash you wish to deposit and then click \"Deposit\"\n"
					for(var/datum/bankaccount/acc in card.accountlist)
						popup.contents += "<a href='?src=\ref[src];selectaccount=[acc.name]'>[acc.name][acc.owner ? " ([acc.owner])" : ""][acc.verified ? "<font color='green'>V</font>" : ""]</a>\n"
					popup.content += "<a href='?src=\ref[src];depositcash=1'>Deposit</a>\n"
				if(3) //Withdraw cash
					popup.content += "Please select an account and then click \"Withdraw\"\n"
					for(var/datum/bankaccount/acc in card.accountlist)
						var/selected = acc == selectedaccount
						popup.contents += "[selected ? "<span class='linkOff'>" : "<a href='?src=\ref[src];selectaccount=[acc.name]'>"][acc.name][acc.owner ? " ([acc.owner])" : ""][acc.verified ? "<font color='green'>V</font>" : ""][selected ? "</span>" : "</a>"]\n"
					popup.content += "<a href='?src=\ref[src];withdrawcash=1'>Withdraw</a>\n"
				if(4) //Transfer money
					popup.content += "not implemented because im lazy"
	
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

	if(href_list["depositcash"])
		var/value = 0
		for(var/obj/item/weapon/coin/C in coins)
			value += C.value
		for(var/obj/item/stack/spacecash/S in cash)
			value += amount
		selectedaccount.depositAmount(amount, card.registered_name, 0)
		return

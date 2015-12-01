/*****************************
 * /vg/station In-Game Store *
 *****************************

By Nexypoo

The idea is to give people who do their jobs a reward.

Ideally, these items should be cosmetic in nature to avoid fucking up round balance.
People joining the round get between $100 and $500.  Keep this in mind.

Money should not persist between rounds, although a "bank" system to voluntarily store
money between rounds might be cool.  It'd need to be a bit volatile:  perhaps completing
job objectives = good stock market, shitty job objective completion = shitty economy.

Goal for now is to get the store itself working, however.
*/

var/global/datum/store/centcomm_store=new

/datum/store
	var/list/datum/storeitem/items=list()
	var/list/datum/storeorder/orders=list()

	var/obj/machinery/account_database/linked_db

/datum/store/New()
	for(var/itempath in typesof(/datum/storeitem) - /datum/storeitem/)
		items += new itempath()

/datum/store/proc/charge(var/mob/user,var/amount,var/datum/storeitem/item,var/obj/machinery/computer/merch/merchcomp)
	if(!user)
		//testing("No initial_account")
		return 0
	var/obj/item/weapon/card/id/card = user.get_id_card()
	if(!card)
		return 0

	reconnect_database()
	if(!linked_db)
		return 0

	//we start by checking the ID card's virtual wallet
	var/datum/money_account/D = card.virtual_wallet
	var/using_account = "Virtual Wallet"

	//if there isn't one for some reason we create it, that should never happen but oh well.
	if(!D)
		card.update_virtual_wallet()
		D = card.virtual_wallet

	//if there isn't enough money in the virtual wallet, then we check the bank account connected to the ID
	if(D.money < amount)
		D = linked_db.attempt_account_access(card.associated_account_number, 0, 2, 0)
		using_account = "Bank Account"
		if(!D)								//first we check if there IS a bank account in the first place
			to_chat(usr, "\icon[src]<span class='warning'>You don't have that much money on your virtual wallet!</span>")
			to_chat(usr, "\icon[src]<span class='warning'>Unable to access your bank account.</span>")
			return 0
		else if(D.security_level > 0)		//next we check if the security is low enough to pay directly from it
			to_chat(usr, "\icon[src]<span class='warning'>You don't have that much money on your virtual wallet!</span>")
			to_chat(usr, "\icon[src]<span class='warning'>Lower your bank account's security settings if you wish to pay directly from it.</span>")
			return 0
		else if(D.money < amount)			//and lastly we check if there's enough money on it, duh
			to_chat(user, "\icon[merchcomp]<span class='warning'>You don't have that much money on your bank account!</span>")
			return 0

	//transfer the money
	D.money -= amount

	to_chat(user, "\icon[merchcomp]<span class='notice'>Remaining balance ([using_account]): [D.money]$</span>")

	//create an entry on the buy's account's transaction log
	var/datum/transaction/T = new()
	T.target_name = D.owner_name
	T.purpose = "Purchase of [item.name]"
	T.amount = -amount
	T.date = current_date_string
	T.time = worldtime2text()
	T.source_terminal = merchcomp.machine_id
	D.transaction_log.Add(T)

	//and another entry on the vending machine's vendor account's transaction log
	if(vendor_account)
		T = new()
		T.target_name = "[command_name()] Merchandising"
		T.purpose = "Purchase of [item.name]"
		T.amount = amount
		T.date = current_date_string
		T.time = worldtime2text()
		T.source_terminal = merchcomp.machine_id
		vendor_account.transaction_log.Add(T)

	return 1

/datum/store/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if(DB.z == STATION_Z)
			if(!(DB.stat & NOPOWER) && DB.activated )//If the database if damaged or not powered, people won't be able to use the store anymore
				linked_db = DB
				break

/datum/store/proc/PlaceOrder(var/mob/living/usr, var/itemID, var/obj/machinery/computer/merch/merchcomp)
	// Get our item, first.

	var/datum/storeitem/item = new itemID()
	if(!item)
		return 0
	// Try to deduct funds.
	if(!charge(usr,item.cost,item,merchcomp))
		return 0
	// Give them the item.
	item.deliver(usr,merchcomp)
	return 1
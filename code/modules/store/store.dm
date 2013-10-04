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

/datum/store/proc/charge(var/datum/mind/mind,var/amount,var/datum/storeitem/item)
	if(!mind.initial_account)
		//testing("No initial_account")
		return 0
	if(mind.initial_account.money < amount)
		//testing("Not enough cash")
		return 0
	mind.initial_account.money -= amount
	var/datum/transaction/T = new()
	T.target_name = "[command_name()] Merchandising"
	T.purpose = "Purchase of [item.name]"
	T.amount = -amount
	T.date = current_date_string
	T.time = worldtime2text()
	T.source_terminal = "\[CLASSIFIED\] Terminal #[rand(111,333)]"
	mind.initial_account.transaction_log.Add(T)
	return 1

/datum/store/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in world)
		if(DB.z == 1)
			linked_db = DB
			break

/datum/store/proc/PlaceOrder(var/mob/living/usr, var/itemID)
	// Get our item, first.
	var/datum/storeitem/item = items[itemID]
	if(!item)
		return 0
	// Try to deduct funds.
	if(!charge(usr.mind,item.cost,item))
		return 0
	// Give them the item.
	item.deliver(usr)
	return 1
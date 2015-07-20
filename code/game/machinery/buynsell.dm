/obj/machinery
	var/obj/machinery/account_database/linked_db //normally the centcom database for accounts
	var/datum/money_account/linked_account //where we get our money from/put it to

/obj/machinery/proc/reconnect_database()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/proc/reconnect_database() called tick#: [world.time]")
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((DB.z == src.z) || (DB.z == STATION_Z))
			if((DB.stat == 0))//If the database if damaged or not powered, people won't be able to use the machines anymore.
				linked_db = DB
				break

//Normally where the transaction itself takes place - logs the transation datums for future reference
/obj/machinery/proc/scan_card(var/mob/user,var/obj/item/weapon/card/id/C)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/proc/scan_card() called tick#: [world.time]")
	return

/obj/machinery/proc/connect_account(var/mob/user, var/obj/item/W)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/proc/connect_account() called tick#: [world.time]")
	if(istype(W, /obj/item/weapon/card))
		//attempt to connect to a new db, and if that doesn't work then fail
		if(!linked_db)
			reconnect_database()
		if(linked_db)
			if(linked_account)
				var/obj/item/weapon/card/I = W
				scan_card(I)
			else
				user << "\icon[src]<span class='warning'>Unable to connect to linked account.</span>"
		else
			user << "\icon[src]<span class='warning'>Unable to connect to accounts database.</span>"
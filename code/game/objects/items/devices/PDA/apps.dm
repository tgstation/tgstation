///PDA apps by Deity Link///

//Menu values
var/global/list/pda_app_menus = list(
	101,//Ringer
	102,//Spam Filter
	103,//Balance Check
	)

/datum/pda_app
	var/name = "Template Application"
	var/desc = "Template Description"
	var/price = 10
	var/menu = 0	//keep it at 0 if your app doesn't need its own menu on the PDA
	var/obj/item/device/pda/pda_device = null

/datum/pda_app/proc/onInstall(var/obj/item/device/pda/device)
	if(istype(device))
		pda_device = device
		pda_device.applications += src

/////////////////////////////////////////////////

/datum/pda_app/ringer
	name = "Ringer"
	desc = "Set the frequency to that of a desk bell to be notified anytime someone presses it."
	price = 10
	menu = 101
	var/frequency = 1457	//	1200 < frequency < 1600 , always end with an odd number.
	var/state = 1			//	0=off 1=on


/datum/pda_app/light_upgrade
	name = "PDA Flashlight Enhancer"
	desc = "Slightly increases the luminosity of your PDA's flashlight."
	price = 60

/datum/pda_app/light_upgrade/onInstall()
	..()
	pda_device.f_lum = 3


/datum/pda_app/spam_filter
	name = "Spam Filter"
	desc = "Spam messages won't ring your PDA anymore. Enjoy the quiet."
	price = 30
	menu = 102
	var/function = 1	//0=do nothing 1=conceal the spam 2=block the spam


/datum/pda_app/balance_check
	name = "Balance Check"
	desc = "Connects to the Account Database to check the balance history the inserted ID card."
	price = 0
	menu = 103
	var/obj/machinery/account_database/linked_db

/datum/pda_app/balance_check/onInstall()
	..()
	reconnect_database()

/datum/pda_app/balance_check/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in world)
		// FIXME: If we're on asteroid z-level, use whatever's on the station. - N3X
		if(DB.z == pda_device.loc.z || (pda_device.loc.z == ASTEROID_Z && DB.z == STATION_Z))
			linked_db = DB
			break

SUBSYSTEM_DEF(bitcoin)
	name = "Space Bitcoin"
	wait = 120 SECONDS
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME
	var/minprice = 10 //in credits
	var/maxprice = 75
	var/currentprice = 33

/datum/controller/subsystem/bitcoin/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/bitcoin/fire(resumed)
	currentprice = rand(minprice, maxprice)

/datum/controller/subsystem/bitcoin/proc/get_price()
	return currentprice

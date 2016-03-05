var/datum/subsystem/stock_market/SSstockmarket

/datum/subsystem/stock_market
	name = "Stock Market"
	wait = 15
	priority = 16
	display = 6

	can_fire = 0 // This needs to fire before round start.

/datum/subsystem/stock_market/New()
	NEW_SS_GLOBAL(SSstockmarket)

/datum/subsystem/stock_market/fire()
	if(stockExchange)
		stockExchange.process()

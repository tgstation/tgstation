/datum/blackmarket_market
	/// Name for the market.
	var/name = "huh?"

	/// Available shipping methods and prices, just leave the shipping method out that you don't want to have.
	var/list/shipping	= list(SHIPPING_METHOD_LTSRBT	=100,
								SHIPPING_METHOD_LAUNCH	=20,
								SHIPPING_METHOD_DROPPOD	=200,
								SHIPPING_METHOD_TELEPORT=150)
	/// Item categories available from this market, only items which are in these categories can be gotten from this market.
	var/list/categories	= list()

	// Automatic vars, do not touch these.
	/// Items available from this market, popuplated by SSblackmarket on initialization.
	var/list/available_items = list()

/datum/blackmarket_market/blackmarket
	name = "Black Market"
	categories = list("Clothing", "Consumables", "Weapons", "Tools", "Miscellaneous")

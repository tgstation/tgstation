/datum/blackmarket_market
	/// Name for the market.
	var/name = "huh?"

	/// Available shipping methods and prices, just leave the shipping method out that you don't want to have.
	var/list/shipping

	/// Item categories available from this market, only items which are in these categories can be gotten from this market.
	var/list/categories	= list()

	// Automatic vars, do not touch these.
	/// Items available from this market, popuplated by SSblackmarket on initialization.
	var/list/available_items = list()

/datum/blackmarket_market/blackmarket
	name = "Black Market"
	shipping = list(SHIPPING_METHOD_LTSRBT	=50,
					SHIPPING_METHOD_LAUNCH	=10,
					SHIPPING_METHOD_DROPPOD	=100,
					SHIPPING_METHOD_TELEPORT=75)
	categories = list("Clothing", "Consumables", "Weapons", "Tools", "Miscellaneous")

///A special category for goods stolen by spies for their bounties.
/datum/market_item/stolen_good
	category = "Fenced Goods"
	abstract_path = /datum/market_item/stolen_good
	stock = 1
	availability_prob = 100

/datum/market_item/stolen_good/New(atom/movable/thing, thing_price)
	..()
	set_item(thing)
	name = "Stolen [thing.name]"
	desc = "A [thing.name], stolen from somewhere on the station. Whoever owned it probably wouldn't be happy to see it here."
	price = thing_price

/datum/map_template/ruin
	name = "A Chest of Doubloons"
	var/id = null // For blacklisting purposes, all ruins need an id
	var/description = "In the middle of a clearing in the rockface, there's a \
		chest filled with gold coins with Spanish engravings. How is there a \
		wooden container filled with 18th century coinage in the middle of a \
		lavawracked hellscape? It is clearly a mystery."

	var/cost = null

	var/prefix = null
	var/suffix = null

/datum/map_template/ruin/New()
	if(name == initial(name) && id)
		name = id

	mappath = prefix + suffix
	..(path = mappath)


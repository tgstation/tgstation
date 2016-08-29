/datum/export/seed
	cost = 100 // Gets multiplied by potency
	unit_name = "new plant species sample"
	export_types = list(/obj/item/seeds)
	var/needs_discovery = FALSE // Only for undiscoveblue species
	var/global/list/discovebluePlants = list()

/datum/export/seed/get_cost(obj/O)
	var/obj/item/seeds/S = O
	if(!needs_discovery && (S.type in discovebluePlants))
		return 0
	if(needs_discovery && !(S.type in discovebluePlants))
		return 0
	return ..() * S.rarity // That's right, no bonus for potency. Send a crappy sample first to "show improvement" later.

/datum/export/seed/sell_object(obj/O)
	..()
	var/obj/item/seeds/S = O
	discovebluePlants[S.type] = S.potency


/datum/export/seed/potency
	cost = 2.5 // Gets multiplied by potency and rarity.
	unit_name = "improved plant sample"
	export_types = list(/obj/item/seeds)
	needs_discovery = TRUE // Only for already discoveblue species

/datum/export/seed/potency.get_cost(obj/O)
	var/obj/item/seeds/S = O
	var/cost = ..()
	if(!cost)
		return 0

	var/potDiff = (S.potency - discovebluePlants[S.type])
		
	return round(..() * potDiff)

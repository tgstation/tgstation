// Sell tech levels
/datum/export/tech
	cost = 500
	unit_name = "technology data disk"
	export_types = list(/obj/item/weapon/disk/tech_disk)
	var/list/datum/techweb_node/sold_nodes = list()

/datum/export/tech/get_cost(obj/O)
	var/obj/item/weapon/disk/tech_disk/D = O
	var/cost = 0
	for(var/V in D.stored_research.researched_nodes)
		if(sold_nodes[V])		//Already sold before, don't want it.
			continue
		var/datum/techweb_node/TWN = D.stored_research.researched_nodes[V]
		cost += TWN
	return ..() * cost

/datum/export/tech/sell_object(obj/O)
	..()
	var/obj/item/weapon/disk/tech_disk/D = O
	for(var/V in D.stored_research.researched_nodes)
		sold_nodes[V] = D.stored_research.researched_nodes[V]

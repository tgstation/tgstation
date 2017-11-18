// Sell tech levels
/datum/export/tech
	cost = 500
	unit_name = "technology data disk"
	export_types = list(/obj/item/disk/tech_disk)
	var/list/techLevels = list()

/datum/export/tech/get_cost(obj/O)
	var/obj/item/disk/tech_disk/D = O
	var/cost = 0
	for(var/V in D.tech_stored)
		if(!V)
			continue
		var/datum/tech/tech = V
		cost += tech.getCost(techLevels[tech.id])
	return ..() * cost

/datum/export/tech/sell_object(obj/O)
	..()
	var/obj/item/disk/tech_disk/D = O
	for(var/V in D.tech_stored)
		if(!V)
			continue
		var/datum/tech/tech = V
		techLevels[tech.id] = max(techLevels[tech.id], tech.level)

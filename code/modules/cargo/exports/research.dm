// Sell tech levels
/datum/export/tech
	cost = 500
	unit_name = "technology data disk"
	export_types = list(/obj/item/weapon/disk/tech_disk)
	var/list/techLevels = list()

/datum/export/tech/get_cost(obj/O)
	var/obj/item/weapon/disk/tech_disk/D = O
	if(!D.stored)
		return 0
	var/datum/tech/tech = D.stored
	return ..() * tech.getCost(techLevels[tech.id])

/datum/export/tech/sell_object(obj/O)
	..()
	var/obj/item/weapon/disk/tech_disk/D = O
	var/datum/tech/tech = D.stored
	techLevels[tech.id] = tech.level

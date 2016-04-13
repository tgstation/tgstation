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



// Sell max reliablity designs
/datum/export/design
	cost = 2500
	unit_name = "design data disk"
	export_types = list(/obj/item/weapon/disk/design_disk)
	var/list/researchDesigns = list()

/datum/export/design/get_cost(obj/O)
	var/obj/item/weapon/disk/design_disk/disk = O
	if(!disk.blueprint)
		return 0
	var/datum/design/design = disk.blueprint
	if(design.id in researchDesigns)
		return 0
	if(initial(design.reliability) < 100 && design.reliability >= 100)
		return ..()
	return 0

/datum/export/design/sell_object(obj/O)
	..()
	var/obj/item/weapon/disk/design_disk/disk = O
	var/datum/design/design = disk.blueprint
	researchDesigns += design.id
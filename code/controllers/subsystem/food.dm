var/datum/subsystem/food/SSfood

/datum/subsystem/food
	name = "Food Health"
	priority = 25
	flags = SS_NO_INIT
	var/list/curFood = list()

/datum/subsystem/food/proc/insertFood(toInsert)
	if(istype(toInsert,/obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food/F = toInsert
		F.initialDesc = F.desc
		for(var/datum/reagent/R in F.reagents)
			F.bestReagents += R
		curFood[toInsert] = 1

/datum/subsystem/food/New()
	NEW_SS_GLOBAL(SSfood)

/datum/subsystem/food/stat_entry()
	..("Watched: [curFood.len]")


/datum/subsystem/food/fire()
	for(var/obj/item/weapon/reagent_containers/food/F in curFood)
		F.updateFood()
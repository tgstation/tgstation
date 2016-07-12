var/datum/subsystem/food/SSFood

/datum/subsystem/food
	name = "Food Health"
	priority = 25

	var/list/curFood = list()

/datum/subsystem/food/proc/insertFood(toInsert)
	if(istype(toInsert,/obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food/F = toInsert
		F.initialDesc = F.desc
		for(var/datum/reagent/R in F.reagents)
			F.bestReagents += R
		curFood |= toInsert

/datum/subsystem/food/New()
	NEW_SS_GLOBAL(SSFood)

/datum/subsystem/food/stat_entry()
	..("Watched: [curFood.len]")


/datum/subsystem/food/fire()
	for(var/obj/item/weapon/reagent_containers/food/F in curFood)
		F.updateFood()
var/datum/subsystem/food/SSfood

/datum/subsystem/food
	name = "Food Health"
	priority = 25
	flags = SS_NO_INIT
	var/list/curFood = list()
	var/list/insertProcess = list()
	var/list/currentrun = list()

/datum/subsystem/food/proc/insertFood(obj/item/weapon/reagent_containers/food/toInsert)
	if(!istype(toInsert))
		return
	insertProcess[toInsert] = 1

/datum/subsystem/food/New()
	NEW_SS_GLOBAL(SSfood)

/datum/subsystem/food/stat_entry()
	..("Watched: [curFood.len]")

/datum/subsystem/food/fire(resumed = 0)
	for(var/thing in insertProcess)
		var/obj/item/weapon/reagent_containers/food/F = thing
		F.initialDesc = F.desc
		for(var/datum/reagent/R in F.reagents)
			F.bestReagents += R
		curFood[F] = 1
	insertProcess.Cut()

	if(!resumed)
		src.currentrun = curFood.Copy()
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/item/weapon/reagent_containers/food/F = currentrun[currentrun.len]
		currentrun.len--
		if(F)
			F.updateFood()
		else
			curFood -= F
		if (MC_TICK_CHECK)
			return

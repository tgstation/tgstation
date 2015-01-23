var/datum/subsystem/foodstuffs/SSfood

/datum/subsystem/foodstuffs
	name = "Food"
	priority = 30
	var/list/watchedFood = list()

/datum/subsystem/foodstuffs/proc/insertFood(var/what)
	watchedFood |= what

/datum/subsystem/foodstuffs/New()
	NEW_SS_GLOBAL(SSfood)


/datum/subsystem/foodstuffs/stat_entry()
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%) [watchedFood.len]")


/datum/subsystem/foodstuffs/fire()
	for(var/obj/item/weapon/reagent_containers/food/F in watchedFood)
		F.updateFood()
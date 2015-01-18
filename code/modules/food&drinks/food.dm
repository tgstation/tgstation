////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = null
	volume = 50	//Sets the default container amount for all food items.
	//freshness
	var/freshMod = 0 //the amount the freshness is going to degrade by (or improve by) every time updateFood is called
	var/freshIndex = 0 //freshIndex counts how well preserved the food is, maxes at -1 and 1
	var/badIndex = 0 // how off the food is
	var/badThreshold = 10 // some foods can benefit from being mouldy and gross. 50 is the max threshold (never goes bad)
	var/coolFood = FALSE //if a food is marked as coolFood, index checks are reversed
	var/goesBad = TRUE
	var/tainted = FALSE //food tainted by an emagged kitchen machine
	var/cachedDesc // saved desc for updating the desc
	var/list/peakReagents = list() // reagent IDs and amounts of what the food should have at peak, strided as id, amount
	var/list/cachedReagents = list()

/obj/item/weapon/reagent_containers/food/proc/updateFood()
	if(freshMod < 0)
		freshIndex = max(tainted ? -100 : -1,freshIndex + freshMod)
	else
		freshIndex = min(tainted ? 100 : 1,freshIndex + freshMod)
	if(badIndex && freshMod)
		badIndex = max(0,goesBad - 0.01)
	cachedReagents.Cut()
	if(src.reagents)
		for(var/datum/reagent/r in src.reagents)
			if(!(r.id in peakReagents))
				cachedReagents += r.id
				cachedReagents += r.volume
	if(peakReagents.len)
		var/counter
		if(coolFood && freshIndex < 0 || !coolFood && freshIndex > 0)
			for(counter = 1; counter < peakReagents.len; counter = counter + 2)
				var/t_amount = peakReagents[counter+1]
				src.reagents.add_reagent(peakReagents[counter],min(t_amount,t_amount*freshIndex))
		else
			for(var/datum/reagent/r in src.reagents)
				if(!(r in cachedReagents))
					src.reagents.remove_reagent(r.id,r.volume*src.reagents.total_volume/100)

	if(freshIndex == 0 && goesBad) //food is not recieving any treatment.
		if(badIndex > badThreshold)
			if(!src.reagents.has_reagent("toxin"))
				src.reagents.add_reagent("toxin",badIndex-badThreshold)
			else
				var/difference = (badIndex - src.reagents.get_reagent_amount("toxin")) - badThreshold
				if(difference > 0)
					src.reagents.add_reagent("toxin",difference)
		badIndex = min(50,badIndex + 0.01)

	if(freshIndex > 0)
		freshIndex = freshIndex - 0.01
	else if(freshIndex < 0)
		freshIndex = freshIndex + 0.01
	if(freshMod > 0)
		freshMod = freshMod - 0.01
	else if(freshMod < 0)
		freshMod = freshMod + 0.01
	var/toxic = 0
	if(src.reagents)
		toxic = src.reagents.has_reagent("toxin")
	desc = "[cachedDesc] This food is <font color=[tempColor(freshIndex*10)]>[fluffTemp(freshIndex*10)]</font>. [toxic ? "It has a sickly smell about it." : ""]"

/obj/item/weapon/reagent_containers/food/attack(mob/M as mob, mob/user as mob, def_zone)
	if(freshIndex < -0.8 || freshIndex > 0.8)
		var/mob/living/L = M
		var/damage = freshIndex < 0 ? (-freshIndex)*20 : freshIndex*20
		L.apply_damage(damage,BURN,"head")

/obj/item/weapon/reagent_containers/food/New()
	..()
	pixel_x = rand(-5, 5)	//Randomizes postion slightly.
	pixel_y = rand(-5, 5)
	cachedDesc = desc
	SSfood.insertFood(src)
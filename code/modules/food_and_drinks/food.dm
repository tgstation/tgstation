////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////

var/list/whitelist_foodlocs = typecacheof(list(/obj/structure/closet/secure_closet/freezer,/obj/machinery/smartfridge,/obj/machinery/food_cart,/obj/machinery/vending))

/obj/item/weapon/reagent_containers/food
	possible_transfer_amounts = list()
	volume = 50	//Sets the default container amount for all food items.
	burn_state = FLAMMABLE

	// food degrading
	var/lifetime = 360 // our initial "life" in which we are freshest, and do not lose a lot of goodness
	var/temperature = 0 // current temperature
	var/reachTemp = 0 // temperature we want to reach, set through other external sources
	var/meltable = FALSE // is the food gooey and meltable, like cheese
	var/targetTemperature = 19 // our ideal temperature, in centigrade,by default it's just below "room" temp
	var/meltingPoint = 100 // the temperature we melt at, if any
	var/shouldBeHot = TRUE // are we a hot food?
	var/freshness = 100 // current freshness rating of the food, negative is worse, positive is better, in percentage of 100
	var/degradeSpeed = -0.5 // how far freshness changes per tick (something about twinkies), negative will gain freshness on incorrect temperatures, for gross wierd foods.
	var/mouldRating = -50 // at what freshness rating do we begin to mould and decay
	var/canRot = TRUE // can the food actually be affected by freshness (more twinkie jokes)
	var/list/bestReagents = list() // what we spawn with, and what a fresh piece will offer
	var/list/extraToxins = list() // extra stuff we can produce from being mouldy
	var/initialDesc = "" // we store our own copy of the initial desc just in case food changes on spawn
	var/ticksRotted = 0 // how much we've rotted, seperate from just checkign toxins for "poison" food, like carp
	var/visibleRot = FALSE // are we now visibly rotting


/obj/item/weapon/reagent_containers/food/New()
	..()
	pixel_x = rand(-5, 5)	//Randomizes postion slightly.
	pixel_y = rand(-5, 5)
	SSfood.insertFood(src)
	if(targetTemperature >= 50) // gotcha to make sure any missed flags dont break
		shouldBeHot = TRUE
	if(!src.reagents)
		canRot = FALSE // force off rotting for any non-reagent foods

/obj/item/weapon/reagent_containers/food/initialize()

// degrade handling
/obj/item/weapon/reagent_containers/food/proc/updateFood()
	if(src.loc) // less intensive but hackier way to make sure frozen food is fine
		if(is_type_in_typecache(src.loc, whitelist_foodlocs))
			reachTemp = -50
	if(canRot)
		if(!src.reagents)
			create_reagents(DEFAULT_REAGENT_SIZE)
			src.reagents.add_reagent("nutriment",1) // if we somehow got here with not having a reagent holder, make one and give us a tiny bit of nutriment to work with.
		if(lifetime > 0)
			--lifetime
		var/turf/T = get_turf(src)
		if(T)
			if(reachTemp < T.temperature)
				reachTemp += 0.1
			else if (reachTemp > T.temperature)
				reachTemp -= 0.1

			if(temperature < reachTemp)
				temperature += 1
			else if (temperature > reachTemp)
				temperature -= 1
		else
			reachTemp = targetTemperature // if we're in nullspace or just not able to get our pos, preserve our selves

		if((temperature < (targetTemperature - 1) && shouldBeHot) || (temperature > (targetTemperature + 1) && !shouldBeHot))
			freshness += (lifetime > 0 ? 0 : degradeSpeed) // we're rotting, panic!
		else if((temperature < (targetTemperature - 1) && !shouldBeHot) || (temperature > (targetTemperature + 1) && shouldBeHot))
			freshness -= (lifetime > 0 ? 0 : degradeSpeed) // we're getting a bit better.

		if(meltable && temperature > meltingPoint) // we jelly now
			var/obj/effect/decal/cleanable/molten_item/MI = new/obj/effect/decal/cleanable/molten_item(get_turf(src))
			if(src.reagents)
				src.reagents.trans_to(MI, src.reagents.total_volume, 1, 1, 1)
			qdel(src)

		freshness = Clamp(freshness,-100,100)

		if(freshness > 0)
			for(var/datum/reagent/R in src.reagents)
				for(var/datum/reagent/check in bestReagents)
					if(R.id == check.id && R.volume >= check.volume) // no magical creation of reagents, only adjust whats still in us and nothing else
						R.volume = check.volume * (freshness / 100)
		else if(freshness < 0) // we're beginning to rot
			if(freshness < mouldRating)
				ticksRotted++
				src.reagents.add_reagent("toxin",1)
				if(ticksRotted > 50 && !visibleRot)
					visibleRot = TRUE
					var/image/stank = image('icons/effects/effects.dmi', icon_state = "stinky")
					add_overlay(stank)

		//charcoooaaal
		if(temperature > targetTemperature * 3) // if we're much higher than our target, turn black and be charcoal
			var/canBurn = FALSE
			if(src.reagents)
				for(var/datum/reagent/R in src.reagents)
					if(R.id != "charcoal")
						canBurn = TRUE
				src.reagents.remove_any(1)
			if(canBurn)
				color = "#3c3c3c"
				src.reagents.add_reagent("charcoal",1)



		var/toxic = FALSE
		if(src.reagents)
			toxic = src.reagents.has_reagent("toxin")
			if(extraToxins.len)
				for(var/A in extraToxins)
					src.reagents.add_reagent("[A]",1)
		desc = "[initialDesc]. This food is <font color=[tempColor(temperature)]>[fluffTemp(temperature)]</font>. [toxic ? "It has a sickly smell about it." : ""]"

		if(toxic && ticksRotted > 0)
			color = rgb(255,min(ticksRotted,255),255)

/proc/fluffTemp(var/what)
	if(what <= -90)
		return "Frozen"
	if(what < -50 && what > -90)
		return "Freezing"
	if(what < -20 && what > -60)
		return "Chilled"
	if(what < 0 && what > -30)
		return "Cool"
	if(what > 0 && what < 30)
		return "Lukewarm"
	if(what > 20 && what < 60)
		return "Warm"
	if(what > 50 && what < 90)
		return "Hot"
	if(what >= 90)
		return "Boiling"
	return "Ambient"

/proc/tempColor(var/what)
	if(what <= -90)
		return "#3385FF"
	if(what < -50 && what > -90)
		return "#4D94FF"
	if(what < -20 && what > -60)
		return "#66A3FF"
	if(what < 0 && what > -30)
		return "#80B2FF"
	if(what > 0 && what < 30)
		return "#DB704D"
	if(what > 20 && what < 60)
		return "#D65C33"
	if(what > 50 && what < 90)
		return "#D14719"
	if(what >= 90)
		return "#CC3300"
	return "#000000"
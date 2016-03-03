// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				// Unknown plant seed - these shouldn't exist in-game.
	w_class = 1						// Pocketable.
	burn_state = FLAMMABLE
	var/plantname = "Plants"		// Name of plant when planted.
	var/product						// A type path. The thing that is created when the plant is harvested.
	var/species = ""				// Used to update icons. Should match the name in the sprites.
	var/lifespan = 25 				// How long before the plant begins to take damage from age.
	var/endurance = 15 				// Amount of health the plant has.
	var/maturation = 6 				// Used to determine which sprite to switch to when growing.
	var/production = 6 				// Changes the amount of time needed for a plant to become harvestable.
	var/yield = 3					// Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/oneharvest = 0				// If a plant is cleared from the tray after harvesting, e.g. a carrot.
	var/potency = 10				// The 'power' of a plant. Generally effects the amount of reagent in a plant, also used in other ways.
	var/growthstages = 6			// Amount of growth sprites the plant has.
	var/plant_type = 0				// 0 = 'normal plant'; 1 = weed; 2 = shroom
	var/rarity = 0					// How rare the plant is. Used for giving points to cargo when shipping off to Centcom.
	var/list/mutatelist = list()	// The type of plants that this plant can mutate into.

/obj/item/seeds/New(loc, parent)
	..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/seeds/proc/get_analyzer_text()  //in case seeds have something special to tell to the analyzer
	return

/obj/item/seeds/proc/on_chem_reaction(datum/reagents/S)  //in case seeds have some special interaction with special chems
	return

/obj/item/seeds/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		user << "*** <B>[plantname]</B> ***"
		user << "-Plant Endurance: <span class='notice'>[endurance]</span>"
		user << "-Plant Lifespan: <span class='notice'>[lifespan]</span>"
		user << "-Species Discovery Value: <span class='notice'>[rarity]</span>"
		if(yield != -1)
			user << "-Plant Yield: <span class='notice'>[yield]</span>"
		user << "-Plant Production: <span class='notice'>[production]</span>"
		if(potency != -1)
			user << "-Plant Potency: <span class='notice'>[potency]</span>"
		var/list/text_strings = get_analyzer_text()
		if(text_strings)
			for(var/string in text_strings)
				user << string
		return
	..() // Fallthrough to item/attackby() so that bags can pick seeds up
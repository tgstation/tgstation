/**
  *This is NOW the gradual affects that each chemical applies on every process() proc. Nutrients now use a more robust reagent holder in order to apply less insane
  * stat changes as opposed to 271 lines of individual statline effects. Shoutout to the original comments on chems, I just cleaned a few up.
  */

/obj/machinery/hydroponics/proc/applyChemicals(datum/reagents/S, mob/user)
	if(myseed)
		myseed.on_chem_reaction(S) //In case seeds have some special interactions with special chems, currently only used by vines

	// Plants need at least a half unit in order to gain mutagenic affects, and prevent powergaming with dilluting chems.
	if(S.has_reagent(/datum/reagent/toxin/mutagen, 0.5) || S.has_reagent(/datum/reagent/uranium/radium, 1) || S.has_reagent(/datum/reagent/uranium, 1))
		switch(rand(100))
			if(91 to 100)
				adjustHealth(-10)
				visible_message("<span class='warning'>[myseed.plantname] starts to wilt and burn!</span>")
			if(41 to 90)
				if(myseed && !self_sustaining) //Stability
					myseed.adjust_instability(5)
			if(21 to 40)
				visible_message("<span class='notice'>[myseed.plantname] appears unusually reactive...</span>")
			if(11 to 20)
				mutateweed()
			if(1 to 10)
				mutatepest(user)

	//Mutagenic chem side-effects.
	if(S.has_reagent(/datum/reagent/uranium, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/uranium) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/uranium) * 2))
	if(S.has_reagent(/datum/reagent/uranium/radium, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/uranium/radium) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/uranium/radium) * 3)) // Radium is harsher (OOC: also easier to produce)

	//Regular Nutrients
	if(S.has_reagent(/datum/reagent/plantnutriment/eznutriment, 1))
		if(myseed)
			myseed.adjust_instability(0.2)
			myseed.adjust_potency(round(S.get_reagent_amount(/datum/reagent/plantnutriment/eznutriment) * 0.05))
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/plantnutriment/eznutriment) * 0.1))

	if(S.has_reagent(/datum/reagent/plantnutriment/left4zednutriment, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/plantnutriment/left4zednutriment) * 0.01))
		if(myseed)
			myseed.adjust_instability(round(S.get_reagent_amount(/datum/reagent/plantnutriment/left4zednutriment) * 0.2))

	if(S.has_reagent(/datum/reagent/plantnutriment/robustharvestnutriment, 1))
		if(myseed)
			myseed.adjust_instability(-0.25)
			myseed.adjust_potency(round(S.get_reagent_amount(/datum/reagent/plantnutriment/robustharvestnutriment) * 0.5))
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/plantnutriment/robustharvestnutriment) * 0.1))

	// Antitoxin binds plants pretty well. So the tox goes significantly down
	if(S.has_reagent(/datum/reagent/medicine/C2/multiver, 1))
		adjustToxic(-round(S.get_reagent_amount(/datum/reagent/medicine/C2/multiver) * 2))

	// Are you a bad enough dude to poison your own plants?
	if(S.has_reagent(/datum/reagent/toxin, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin) * 2))

	// Milk is good for humans, but bad for plants. The sugars cannot be used by plants, and the milk fat harms growth. Not shrooms though. I can't deal with this now...
	if(S.has_reagent(/datum/reagent/consumable/milk, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/milk) * 0.3))
		if(myseed)
			myseed.adjust_potency(-S.get_reagent_amount(/datum/reagent/consumable/milk) * 0.5)

	// Beer is a chemical composition of alcohol and various other things. It's a garbage nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
	if(S.has_reagent(/datum/reagent/consumable/ethanol/beer, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.05))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/ethanol/beer) * 0.7))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent(/datum/reagent/fluorine, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/fluorine) * 2))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/fluorine) * 2.5))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/fluorine) * 0.5))
		adjustWeeds(-rand(1,4))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent(/datum/reagent/chlorine, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/chlorine) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/chlorine) * 1.5))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/chlorine) * 0.5))
		adjustWeeds(-rand(1,3))

	// White Phosphorous + water -> phosphoric acid. That's not a good thing really.
	// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
	if(S.has_reagent(/datum/reagent/phosphorus, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.75))
		adjustWater(-round(S.get_reagent_amount(/datum/reagent/phosphorus) * 0.5))
		adjustWeeds(-rand(1,2))

	// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
	if(S.has_reagent(/datum/reagent/consumable/sugar, 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))

	// On the other hand, honey has been known to carry pollen with it rarely. Can be used to take in a lot of plant qualities all at once, or harm the plant.
	if(S.has_reagent(/datum/reagent/consumable/honey, 1))
		if(myseed && prob(20))
			pollinate(rand(1,3))
		else
			adjustWeeds(rand(1,2))
			adjustPests(rand(1,2))

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits. Also ALSO increases stability.
	if(S.has_reagent(/datum/reagent/water/holywater, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 0.1))
		if(myseed)
			myseed.adjust_instability(round(S.get_reagent_amount(/datum/reagent/water/holywater) * 0.15))

	// A variety of nutrients are dissolved in club soda, without sugar.
	// These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
	if(S.has_reagent(/datum/reagent/consumable/sodawater, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/consumable/sodawater) * 0.1))

	// ...Why? I mean, clearly someone had to have done this and thought, well, acid doesn't hurt plants, but what brought us here, to this point?
	if(S.has_reagent(/datum/reagent/toxin/acid, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/acid) * 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/acid) * 1.5))
		adjustWeeds(-rand(1,2))

	// SERIOUSLY
	if(S.has_reagent(/datum/reagent/toxin/acid/fluacid, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/acid/fluacid) * 2))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/acid/fluacid) * 3))
		adjustWeeds(-rand(1,4))

	// Plant-B-Gone is just as bad
	if(S.has_reagent(/datum/reagent/toxin/plantbgone, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone) * 5))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone) * 6))
		adjustWeeds(-rand(4,8))

	// why, just why
	if(S.has_reagent(/datum/reagent/napalm, 1))
		if(!(myseed.resistance_flags & FIRE_PROOF))
			adjustHealth(-round(S.get_reagent_amount(/datum/reagent/napalm) * 6))
			adjustToxic(round(S.get_reagent_amount(/datum/reagent/napalm) * 7))
		adjustWeeds(-rand(5,9)) //At least give them a small reward if they bother.

	//Weed Spray
	if(S.has_reagent(/datum/reagent/toxin/plantbgone/weedkiller, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/plantbgone/weedkiller) * 0.5))
		adjustWeeds(-rand(1,2))

	//Pest Spray
	if(S.has_reagent(/datum/reagent/toxin/pestkiller, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/toxin/pestkiller) * 0.5))
		adjustPests(-rand(1,2))

	//Nicotine is used as a pesticide IRL.
	if(S.has_reagent(/datum/reagent/drug/nicotine, 1))
		adjustToxic(round(S.get_reagent_amount(/datum/reagent/drug/nicotine)))
		adjustPests(-rand(1,2))

	// Healing
	if(S.has_reagent(/datum/reagent/medicine/cryoxadone, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/medicine/cryoxadone) * 3))
		adjustToxic(-round(S.get_reagent_amount(/datum/reagent/medicine/cryoxadone) * 3))

	// Ammonia is bad ass.
	if(S.has_reagent(/datum/reagent/ammonia, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/ammonia) * 0.12))
		if(myseed && prob(10))
			myseed.adjust_yield(1)
			myseed.adjust_instability(1)

	// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
	if(S.has_reagent(/datum/reagent/saltpetre, 1))
		var/salt = S.get_reagent_amount(/datum/reagent/saltpetre)
		adjustHealth(round(salt * 0.18))
		if (myseed)
			myseed.adjust_production(-round(salt/10)-prob(salt%10))
			myseed.adjust_potency(round(salt*1))

	// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
	if(S.has_reagent(/datum/reagent/ash, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/ash) * 1))
		adjustWeeds(-1)

	// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant. The new trade off is it culls stability.
	if(S.has_reagent(/datum/reagent/diethylamine, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 1))
		if(myseed)
			myseed.adjust_yield(round(S.get_reagent_amount(/datum/reagent/diethylamine) * 1))
			myseed.adjust_instability(-round(S.get_reagent_amount(/datum/reagent/diethylamine) * 1))
		adjustPests(-rand(1,2))

	//It has stable IN THE NAME. IT WAS MADE FOR THIS MOMENT.
	if(S.has_reagent(/datum/reagent/stabilizing_agent, 1))
		if(myseed)
			myseed.adjust_instability(-1)

	// Compost, effectively
	if(S.has_reagent(/datum/reagent/consumable/nutriment, 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/consumable/nutriment) * 0.2))

	// Compost for EVERYTHING
	if(S.has_reagent(/datum/reagent/consumable/virus_food, 1))
		adjustHealth(-round(S.get_reagent_amount(/datum/reagent/consumable/virus_food) * 0.5))

	// FEED ME
	if(S.has_reagent(/datum/reagent/blood, 1))
		adjustPests(rand(2,3))

	// FEED ME SEYMOUR
	if(S.has_reagent(/datum/reagent/medicine/strange_reagent, 1))
		spawnplant()

	// The best stuff there is. For testing/debugging.
	if(S.has_reagent(/datum/reagent/medicine/adminordrazine, 1))
		adjustWater(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustHealth(round(S.get_reagent_amount(/datum/reagent/medicine/adminordrazine) * 1))
		adjustPests(-rand(1,5))
		adjustWeeds(-rand(1,5))
	if(S.has_reagent(/datum/reagent/medicine/adminordrazine, 3))
		switch(rand(100))
			if(66  to 100)
				mutatespecie()
			if(33	to 65)
				mutateweed()
			if(1   to 32)
				mutatepest(user)
			else if(prob(20))
				visible_message("<span class='warning'>Nothing happens...</span>")

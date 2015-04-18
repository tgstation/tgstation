/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray"
	density = 1
	anchored = 1			// anchored == 2 means the hoses are screwed in place
	var/waterlevel = 100	//The amount of water in the tray (max 100)
	var/maxwater = 100		//The maximum amount of water in the tray
	var/nutrilevel = 10		//The amount of nutrient in the tray (max 10)
	var/maxnutri = 10		//The maximum nutrient of water in the tray
	var/pestlevel = 0		//The amount of pests in the tray (max 10)
	var/weedlevel = 0		//The amount of weeds in the tray (max 10)
	var/yieldmod = 1		//Nutriment's effect on yield
	var/mutmod = 1			//Nutriment's effect on mutations
	var/toxic = 0			//Toxicity in the tray?
	var/age = 0				//Current age
	var/dead = 0			//Is it dead?
	var/health = 0			//Its health.
	var/lastproduce = 0		//Last time it was harvested
	var/lastcycle = 0		//Used for timing of cycles.
	var/cycledelay = 200	//About 10 seconds / cycle
	var/planted = 0			//Is it occupied?
	var/harvest = 0			//Ready to harvest?
	var/obj/item/seeds/myseed = null	//The currently planted seed
	var/unwrenchable = 1

	pixel_y=8

/obj/machinery/hydroponics/constructable
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray3"

/obj/machinery/hydroponics/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/hydroponics(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/hydroponics/constructable/RefreshParts()
	var tmp_capacity = 0
	for (var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		tmp_capacity += M.rating
	maxwater = tmp_capacity * 50 // Up to 300
	maxnutri = tmp_capacity * 5 // Up to 30
	waterlevel = maxwater
	nutrilevel = 3

/obj/machinery/hydroponics/constructable/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return

	if(istype(I, /obj/item/weapon/crowbar))
		if(anchored==2)
			user << "Unscrew the hoses first!"
			return
		default_deconstruction_crowbar(I, 1)
	..()

/obj/machinery/hydroponics/proc/FindConnected()

	var/list/connected = list()
	var/list/processing_atoms = list(src)

	while(processing_atoms.len)

		var/atom/a = processing_atoms[1]

		for(var/step_dir in cardinal)
			var/obj/machinery/hydroponics/h = locate() in get_step(a, step_dir)
			// Soil plots aren't dense.  anchored == 2 means the hoses are screwed in place
			if(h && h.anchored==2 && h.density && !(h in connected) && !(h in processing_atoms))
				processing_atoms += h

		processing_atoms -= a
		connected += a

	return connected


/obj/machinery/hydroponics/bullet_act(var/obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(!planted)
		..()
		return
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		mutate()
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		if(myseed.yield == 0)//Oh god don't divide by zero you'll doom us all.
			adjustSYield(1)
			//world << "Yield increased by 1, from 0, to a total of [myseed.yield]"
		else if(prob(1/(myseed.yield * myseed.yield) * 100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			adjustSYield(1)
			//world << "Yield increased by 1, to a total of [myseed.yield]"
	else
		..()
		return

obj/machinery/hydroponics/process()

	var/needs_update = 0 // Checks if the icon needs updating so we don't redraw empty trays every time

	if(myseed && (myseed.loc != src))
		myseed.loc = src

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(planted && !dead)
			// Advance age
			age++
			needs_update = 1

//Nutrients//////////////////////////////////////////////////////////////
			// Nutrients deplete slowly
			if(prob(50))
				adjustNutri(-1)

			// Lack of nutrients hurts non-weeds
			if(nutrilevel <= 0 && myseed.plant_type != 1)
				adjustHealth(-rand(1,3))

//Photosynthesis/////////////////////////////////////////////////////////
			// Lack of light hurts non-mushrooms
			if(isturf(loc))
				var/turf/currentTurf = loc
				var/lightAmt = currentTurf.lighting_lumcount
				if(myseed.plant_type == 2) // Mushroom
					if(lightAmt < 2)
						adjustHealth(-1)
				else // Non-mushroom
					if(lightAmt < 4)
						adjustHealth(-2)

//Water//////////////////////////////////////////////////////////////////
			// Drink random amount of water
			adjustWater(-rand(1,6))

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(waterlevel <= 10 && myseed.plant_type != 2)
				adjustHealth(-rand(0,1))
				if(waterlevel <= 0)
					adjustHealth(-rand(0,2))

			// Sufficient water level and nutrient level = plant healthy
			else if(waterlevel > 10 && nutrilevel > 0)
				adjustHealth(rand(1,2))
				if(prob(5))  //5 percent chance the weed population will increase
					adjustWeeds(1)

//Toxins/////////////////////////////////////////////////////////////////

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(toxic >= 40 && toxic < 80)
				adjustHealth(-1)
				adjustToxic(-rand(1,10))
			else if(toxic >= 80) // I don't think it ever gets here tbh unless above is commented out
				adjustHealth(-3)
				adjustToxic(-rand(1,10))

//Pests & Weeds//////////////////////////////////////////////////////////

			else if(pestlevel >= 5)
				adjustHealth(-1)

			// If it's a weed, it doesn't stunt the growth
			if(weedlevel >= 5 && myseed.plant_type != 1 )
				adjustHealth(-1)

//Health & Age///////////////////////////////////////////////////////////

			// Plant dies if health <= 0
			if(health <= 0)
				plantdies()
				adjustWeeds(1) // Weeds flourish

			// If the plant is too old, lose health fast
			if(age > myseed.lifespan)
				adjustHealth(-rand(1,5))

			// Harvest code
			if(age > myseed.production && (age - lastproduce) > myseed.production && (!harvest && !dead))
				nutrimentMutation()
				if(myseed && myseed.yield != -1) // Unharvestable shouldn't be harvested
					harvest = 1
				else
					lastproduce = age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				adjustPests(1)
		else
			if(waterlevel > 10 && nutrilevel > 0 && prob(10))  // If there's no plant, the percentage chance is 10%
				adjustWeeds(1)

		// Weeeeeeeeeeeeeeedddssss

		if(weedlevel >= 10 && prob(50)) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(planted)
				if(myseed.plant_type == 0) // If a normal plant
					weedinvasion()
			else
				weedinvasion() // Weed invasion into empty tray
			needs_update = 1
		if (needs_update)
			update_icon()
	return

obj/machinery/hydroponics/proc/nutrimentMutation()
	if (mutmod == 0)
		return
	if (mutmod == 1)
		if(prob(80))		//80%
			mutate()
		else if(prob(75))	//15%
			hardmutate()
		return
	if (mutmod == 2)
		if(prob(50))		//50%
			mutate()
		else if(prob(75))	//37.5%
			hardmutate()
		else if(prob(10))	//1/80
			mutatespecie()
		return
	return

obj/machinery/hydroponics/update_icon()

	//Refreshes the icon and sets the luminosity
	overlays.Cut()

	var/n = 0

	for(var/Dir in cardinal)

		var/obj/machinery/hydroponics/t = locate() in get_step(src,Dir)
		if(t && t.anchored == 2 && src.anchored == 2)
			n += Dir

	icon_state = "hoses-[n]"

	UpdateDescription()

	if(planted)
		var/image/I
		if(dead)
			I = image('icons/obj/hydroponics/growing.dmi', icon_state = "[myseed.species]-dead")
		else if(harvest)
			if(myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				I = image('icons/obj/hydroponics/growing.dmi', icon_state = "[myseed.species]-grow[myseed.growthstages]")
			else
				I = image('icons/obj/hydroponics/growing.dmi', icon_state = "[myseed.species]-harvest")
		else if(age < myseed.maturation)
			var/t_growthstate = ((age / myseed.maturation) * myseed.growthstages ) // Make sure it won't crap out due to HERPDERP 6 stages only
			I = image('icons/obj/hydroponics/growing.dmi', icon_state = "[myseed.species]-grow[round(t_growthstate)]")
			lastproduce = age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			I = image('icons/obj/hydroponics/growing.dmi', icon_state = "[myseed.species]-grow[myseed.growthstages]") // Same
		I.layer = MOB_LAYER + 0.1
		overlays += I

		if(waterlevel <= 10)
			overlays += image('icons/obj/hydroponics/equipment.dmi', icon_state = "over_lowwater3")
		if(nutrilevel <= 2)
			overlays += image('icons/obj/hydroponics/equipment.dmi', icon_state = "over_lownutri3")
		if(health <= (myseed.endurance / 2))
			overlays += image('icons/obj/hydroponics/equipment.dmi', icon_state = "over_lowhealth3")
		if(weedlevel >= 5 || pestlevel >= 5 || toxic >= 40)
			overlays += image('icons/obj/hydroponics/equipment.dmi', icon_state = "over_alert3")
		if(harvest)
			overlays += image('icons/obj/hydroponics/equipment.dmi', icon_state = "over_harvest3")

	if(istype(myseed,/obj/item/seeds/glowshroom))
		SetLuminosity(round(myseed.potency / 10))
	else
		SetLuminosity(0)

	return

obj/machinery/hydroponics/proc/UpdateDescription()
	desc = null
	if (planted)
		desc = "[src] has <span class='info'>[myseed.plantname]</span> planted."
		if (dead)
			desc += " It's dead."
		else if (harvest)
			desc += " It's ready to harvest."

obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	dead = 0
	var/oldPlantName
	if(myseed) // In case there's nothing in the tray beforehand
		oldPlantName = myseed.plantname
		qdel(myseed)
	else
		oldPlantName = "Empty tray"
	switch(rand(1,18))		// randomly pick predominative weed
		if(16 to 18)
			myseed = new /obj/item/seeds/reishimycelium
		if(14 to 15)
			myseed = new /obj/item/seeds/nettleseed
		if(12 to 13)
			myseed = new /obj/item/seeds/harebell
		if(10 to 11)
			myseed = new /obj/item/seeds/amanitamycelium
		if(8 to 9)
			myseed = new /obj/item/seeds/chantermycelium
		if(6 to 7)
			myseed = new /obj/item/seeds/towermycelium
		if(4 to 5)
			myseed = new /obj/item/seeds/plumpmycelium
		else
			myseed = new /obj/item/seeds/weeds
	planted = 1
	age = 0
	health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 // Reset
	pestlevel = 0 // Reset
	update_icon()
	visible_message("<span class='info'>[oldPlantName] overtaken by [myseed.plantname].</span>")


obj/machinery/hydroponics/proc/mutate(var/lifemut = 2, var/endmut = 5, var/productmut = 1, var/yieldmut = 2, var/potmut = 25) // Mutates the current seed
	if(!planted)
		return
	adjustSLife(rand(-lifemut,lifemut))
	adjustSEnd(rand(-endmut,endmut))
	adjustSProduct(rand(-productmut,productmut))
	adjustSYield(rand(-yieldmut,yieldmut))
	adjustSPot(rand(-potmut,potmut))


obj/machinery/hydroponics/proc/hardmutate()
	mutate(4, 10, 2, 4, 50)


obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!
	if(!planted || dead)
		return

	var/oldPlantName = myseed.plantname
	if(myseed.mutatelist.len > 0)
		var/mutantseed = pick(myseed.mutatelist)
		qdel(myseed)
		myseed = new mutantseed

	else
		return

	dead = 0
	hardmutate()
	planted = 1
	age = 0
	health = myseed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0 // Reset

	spawn(5) // Wait a while
	update_icon()
	visible_message("<span class='warning'>[oldPlantName] suddenly mutated into [myseed.plantname]!</span>")


obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if( weedlevel > 5 )
		if(myseed)
			qdel(myseed)
		var/newWeed = pick(/obj/item/seeds/libertymycelium, /obj/item/seeds/angelmycelium, /obj/item/seeds/deathnettleseed, /obj/item/seeds/kudzuseed)
		myseed = new newWeed
		dead = 0
		hardmutate()
		planted = 1
		age = 0
		health = myseed.endurance
		lastcycle = world.time
		harvest = 0
		weedlevel = 0 // Reset

		spawn(5) // Wait a while
		update_icon()
		visible_message("<span class='warning'>The mutated weeds in [src] spawned a [myseed.plantname]!</span>")
	else
		usr << "The few weeds in [src] seem to react, but only for a moment..."


obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	health = 0
	harvest = 0
	pestlevel = 0 // Pests die
	if(!dead)
		update_icon()
		dead = 1


obj/machinery/hydroponics/proc/mutatepest()
	if(pestlevel > 5)
		visible_message("The pests seem to behave oddly...")
		for(var/i=0, i<3, i++)
			var/obj/effect/spider/spiderling/S = new(src.loc)
			S.grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter
	else
		usr << "The pests seem to behave oddly, but quickly settle down..."

obj/machinery/hydroponics/proc/applyChemicals(var/datum/reagents/S)

	if(myseed)
		myseed.on_chem_reaction(S) //In case seeds have some special interactions with special chems, currently only used by vines

	// Requires 5 mutagen to possibly change species.// Poor man's mutagen.
	if(S.has_reagent("mutagen", 5) || S.has_reagent("radium", 10) || S.has_reagent("uranium", 10))
		switch(rand(100))
			if(91 to 100)	plantdies()
			if(81 to 90)	mutatespecie()
			if(66 to 80)	hardmutate()
			if(41 to 65)	mutate()
			if(21 to 41)	usr << "The plants don't seem to react..."
			if(11 to 20)	mutateweed()
			if(1 to 10)		mutatepest()
			else 			usr << "Nothing happens..."

	// 2 or 1 units is enough to change the yield and other stats.// Can change the yield and other stats, but requires more than mutagen
	else if(S.has_reagent("mutagen", 2) || S.has_reagent("radium", 5) || S.has_reagent("uranium", 5))
		hardmutate()
	else if(S.has_reagent("mutagen", 1) || S.has_reagent("radium", 2) || S.has_reagent("uranium", 2))
		mutate()

	// After handling the mutating, we now handle the damage from adding crude radioactives...
	if(S.has_reagent("uranium", 1))
		adjustHealth(-round(S.get_reagent_amount("uranium") * 1))
		adjustToxic(round(S.get_reagent_amount("uranium") * 2))
	if(S.has_reagent("radium", 1))
		adjustHealth(-round(S.get_reagent_amount("radium") * 1))
		adjustToxic(round(S.get_reagent_amount("radium") * 3)) // Radium is harsher (OOC: also easier to produce)

	// Nutriments
	if(S.has_reagent("eznutriment", 1))
		yieldmod = 1
		mutmod = 1
		adjustNutri(round(S.get_reagent_amount("eznutriment") * 1))

	if(S.has_reagent("left4zednutriment", 1))
		yieldmod = 0
		mutmod = 2
		adjustNutri(round(S.get_reagent_amount("left4zednutriment") * 1))

	if(S.has_reagent("robustharvestnutriment", 1))
		yieldmod = 2
		mutmod = 0
		adjustNutri(round(S.get_reagent_amount("robustharvestnutriment") *1 ))

	// Antitoxin binds shit pretty well. So the tox goes significantly down
	if(S.has_reagent("charcoal", 1))
		adjustToxic(-round(S.get_reagent_amount("charcoal") * 2))

	// NIGGA, YOU JUST WENT ON FULL RETARD.
	if(S.has_reagent("toxin", 1))
		adjustToxic(round(S.get_reagent_amount("toxin") * 2))

	// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
	if(S.has_reagent("milk", 1))
		adjustNutri(round(S.get_reagent_amount("milk") * 0.1))
		adjustWater(round(S.get_reagent_amount("milk") * 0.9))

	// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
	if(S.has_reagent("beer", 1))
		adjustHealth(-round(S.get_reagent_amount("beer") * 0.05))
		adjustNutri(round(S.get_reagent_amount("beer") * 0.25))
		adjustWater(round(S.get_reagent_amount("beer") * 0.7))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent("fluorine", 1))
		adjustHealth(-round(S.get_reagent_amount("fluorine") * 2))
		adjustToxic(round(S.get_reagent_amount("flourine") * 2.5))
		adjustWater(-round(S.get_reagent_amount("flourine") * 0.5))
		adjustWeeds(-rand(1,4))

	// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
	if(S.has_reagent("chlorine", 1))
		adjustHealth(-round(S.get_reagent_amount("chlorine") * 1))
		adjustToxic(round(S.get_reagent_amount("chlorine") * 1.5))
		adjustWater(-round(S.get_reagent_amount("chlorine") * 0.5))
		adjustWeeds(-rand(1,3))

	// White Phosphorous + water -> phosphoric acid. That's not a good thing really. Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
	if(S.has_reagent("phosphorus", 1))
		adjustHealth(-round(S.get_reagent_amount("phosphorus") * 0.75))
		adjustNutri(round(S.get_reagent_amount("phosphorus") * 0.1))
		adjustWater(-round(S.get_reagent_amount("phosphorus") * 0.5))
		adjustWeeds(-rand(1,2))

	// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
	if(S.has_reagent("sugar", 1))
		adjustWeeds(rand(1,2))
		adjustPests(rand(1,2))
		adjustNutri(round(S.get_reagent_amount("sugar") * 0.1))

	// It is water!
	if(S.has_reagent("water", 1))
		adjustWater(round(S.get_reagent_amount("water") * 1))

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
	if(S.has_reagent("holywater", 1))
		adjustWater(round(S.get_reagent_amount("holywater") * 1))
		adjustHealth(round(S.get_reagent_amount("holywater") * 0.1))

	// A variety of nutrients are dissolved in club soda, without sugar. These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
	if(S.has_reagent("sodawater", 1))
		adjustWater(round(S.get_reagent_amount("sodawater") * 1))
		adjustHealth(round(S.get_reagent_amount("sodawater") * 0.1))
		adjustNutri(round(S.get_reagent_amount("sodawater") * 0.1))

	// Man, you guys are retards
	if(S.has_reagent("sacid", 1))
		adjustHealth(-round(S.get_reagent_amount("sacid") * 1))
		adjustToxic(round(S.get_reagent_amount("sacid") * 1.5))
		adjustWeeds(-rand(1,2))

	// SERIOUSLY
	if(S.has_reagent("facid", 1))
		adjustHealth(-round(S.get_reagent_amount("facid") * 2))
		adjustToxic(round(S.get_reagent_amount("facid") * 3))
		adjustWeeds(-rand(1,4))

	// Plant-B-Gone is just as bad
	if(S.has_reagent("plantbgone", 1))
		adjustHealth(-round(S.get_reagent_amount("plantbgone") * 5))
		adjustToxic(-round(S.get_reagent_amount("plantbgone") * 6))
		adjustWeeds(-rand(4,8))

	//Weed Spray
	if(S.has_reagent("weedkiller", 1))
		adjustToxic(round(S.get_reagent_amount("weedkiller") * 0.5))
		//old toxicity was 4, each spray is default 10 (minimal of 5) so 5 and 2.5 are the new ammounts
		adjustWeeds(-rand(1,2))

	//Pest Spray
	if(S.has_reagent("pestkiller", 1))
		adjustToxic(round(S.get_reagent_amount("pestkiller") * 0.5))
		adjustPests(-rand(1,2))

	// Healing
	if(S.has_reagent("cryoxadone", 1))
		adjustHealth(round(S.get_reagent_amount("cryoxadone") * 3))
		adjustToxic(-round(S.get_reagent_amount("cryoxadone") * 3))

	// Ammonia is bad ass.
	if(S.has_reagent("ammonia", 1))
		adjustHealth(round(S.get_reagent_amount("ammonia") * 0.5))
		adjustNutri(round(S.get_reagent_amount("ammonia") * 1))
		adjustSYield(round(S.get_reagent_amount("ammonia") * 0.01))

	// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
	if(S.has_reagent("diethylamine", 1))
		adjustHealth(round(S.get_reagent_amount("diethylamine") * 1))
		adjustNutri(round(S.get_reagent_amount("diethylamine") * 2))
		adjustSYield(round(S.get_reagent_amount("diethylamine") * 0.02))
		adjustPests(-rand(1,2))

	// Compost, effectively
	if(S.has_reagent("nutriment", 1))
		adjustHealth(round(S.get_reagent_amount("nutriment") * 0.5))
		adjustNutri(round(S.get_reagent_amount("nutriment") * 1))

	// The best stuff there is. For testing/debugging.
	if(S.has_reagent("adminordrazine", 1))
		adjustWater(round(S.get_reagent_amount("adminordrazine") * 1))
		adjustHealth(round(S.get_reagent_amount("adminordrazine") * 1))
		adjustNutri(round(S.get_reagent_amount("adminordrazine") * 1))
		adjustPests(-rand(1,5))
		adjustWeeds(-rand(1,5))
	if(S.has_reagent("adminordrazine", 5))
		switch(rand(100))
			if(66  to 100)	mutatespecie()
			if(33	to 65)	mutateweed()
			if(1   to 32)	mutatepest()
			else 			usr << "Nothing happens..."

obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob, params)

	//Called when mob user "attacks" it with object O
	if(istype(O, /obj/item/weapon/reagent_containers) )  // Syringe stuff (and other reagent containers now too)
		var/obj/item/weapon/reagent_containers/reagent_source = O

		if(istype(reagent_source, /obj/item/weapon/reagent_containers/syringe))
			var/obj/item/weapon/reagent_containers/syringe/syr = reagent_source
			if(syr.mode != 1)
				user << "<span class='warning'>You can't get any extract out of this plant.</span>"		//That. Gives me an idea...
				return

		if(!reagent_source.reagents.total_volume)
			user << "<span class='notice'>[reagent_source] is empty.</span>"
			return 1

		var/list/trays = list(src)//makes the list just this in cases of syringes and compost etc
		var/target = myseed ? myseed.plantname : src
		var/visi_msg = ""
		var/irrigate = 0	//How am I supposed to irrigate pill contents?

		if(istype(reagent_source, /obj/item/weapon/reagent_containers/food/snacks) || istype(reagent_source, /obj/item/weapon/reagent_containers/pill))
			visi_msg="[user] composts [reagent_source], spreading it through [target]"
		else
			if(istype(reagent_source, /obj/item/weapon/reagent_containers/syringe/))
				var/obj/item/weapon/reagent_containers/syringe/syr = reagent_source
				visi_msg="[user] injects [target] with [syr]"
				if(syr.reagents.total_volume <= syr.amount_per_transfer_from_this)
					syr.mode = 0
			else if(istype(reagent_source, /obj/item/weapon/reagent_containers/spray/))
				visi_msg="[user] sprays [target] with [reagent_source]"
				playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
				irrigate = 1
			else if(reagent_source.amount_per_transfer_from_this) // Droppers, cans, beakers, what have you.
				visi_msg="[user] uses [reagent_source] on [target]"
				irrigate = 1
			// Beakers, bottles, buckets, etc.  Can't use is_open_container though.
			if(istype(reagent_source, /obj/item/weapon/reagent_containers/glass/))
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

		// anchored == 2 means the hoses are screwed in place
		if(irrigate && reagent_source.amount_per_transfer_from_this > 30 && reagent_source.reagents.total_volume >= 30 && anchored == 2)
			trays = FindConnected()
			if (trays.len > 1)
				visi_msg += ", setting off the irrigation system"

		if(visi_msg)
			visible_message("<span class='notice'>[visi_msg].</span>")

		var/split = round(reagent_source.amount_per_transfer_from_this/trays.len)

		for(var/obj/machinery/hydroponics/H in trays)
		//cause I don't want to feel like im juggling 15 tamagotchis and I can get to my real work of ripping flooring apart in hopes of validating my life choices of becoming a space-gardener

			var/datum/reagents/S = new /datum/reagents()
			S.my_atom = H

			reagent_source.reagents.trans_to(S,split)
			if(istype(reagent_source, /obj/item/weapon/reagent_containers/food/snacks) || istype(reagent_source, /obj/item/weapon/reagent_containers/pill))
				qdel(reagent_source)

			H.applyChemicals(S)

			S.clear_reagents()
			del(S)
			H.update_icon()
		if(reagent_source) // If the source wasn't composted and destroyed
			reagent_source.update_icon()
		return 1

	else if(istype(O, /obj/item/seeds/))
		if(!planted)
			user.unEquip(O)
			user << "You plant [O]."
			dead = 0
			myseed = O
			planted = 1
			age = 1
			health = myseed.endurance
			lastcycle = world.time
			O.loc = src
			if((user.client  && user.s_active != src))
				user.client.screen -= O
			O.dropped(user)
			update_icon()

		else
			user << "<span class='warning'>[src] already has seeds in it!</span>"

	else if(istype(O, /obj/item/device/analyzer/plant_analyzer))
		if(planted && myseed)
			user << "*** <B>[myseed.plantname]</B> ***" //Carn: now reports the plants growing, not the seeds.
			user << "-Plant Age: <span class='notice'> [age]</span>"
			user << "-Plant Endurance: <span class='notice'> [myseed.endurance]</span>"
			user << "-Plant Lifespan: <span class='notice'> [myseed.lifespan]</span>"
			if(myseed.yield != -1)
				user << "-Plant Yield: <span class='notice'> [myseed.yield]</span>"
			user << "-Plant Production: <span class='notice'> [myseed.production]</span>"
			if(myseed.potency != -1)
				user << "-Plant Potency: <span class='notice'> [myseed.potency]</span>"
			var/list/text_strings = myseed.get_analyzer_text()
			if(text_strings)
				for(var/string in text_strings)
					user << string
		else
			user << "<B>No plant found.</B>"
		user << "-Weed level: <span class='notice'> [weedlevel] / 10</span>"
		user << "-Pest level: <span class='notice'> [pestlevel] / 10</span>"
		user << "-Toxicity level: <span class='notice'> [toxic] / 100</span>"
		user << "-Water level: <span class='notice'> [waterlevel] / [maxwater]</span>"
		user << "-Nutrition level: <span class='notice'> [nutrilevel] / [maxnutri]</span>"
		user << ""

	else if(istype(O, /obj/item/weapon/minihoe))
		if(weedlevel > 0)
			user.visible_message("<span class='notice'>[user] uproots the weeds.</span>", "<span class='notice'>You remove the weeds from [src].</span>")
			weedlevel = 0
			update_icon()
		else
			user << "<span class='notice'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>"

	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		attack_hand(user)
		var/obj/item/weapon/storage/bag/plants/S = O
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if(istype(O, /obj/item/weapon/wrench) && unwrenchable)
		if(anchored == 2)
			user << "Unscrew the hoses first!"
			return

		if(!anchored && !isinspace())
			user.visible_message("<span class='notice'>[user] begins to wrench [src] into place.</span>", \
								"<span class='notice'>You begin to wrench [src] in place...</span>")
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if (do_after(user, 20))
				if(anchored)
					return
				anchored = 1
				user.visible_message("<span class='notice'>[user] wrenches [src] into place.</span>", \
									"<span class='notice'>You wrench [src] in place.</span>")
		else if(anchored)
			user.visible_message("<span class='notice'>[user] begins to unwrench [src].</span>", \
								"<span class='notice'>You begin to unwrench [src]...</span>")
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			if (do_after(user, 20))
				if(!anchored)
					return
				anchored = 0
				user.visible_message("<span class='notice'>[user] unwrenches [src].</span>", \
									"<span class='notice'>You unwrench [src].</span>")

	else if(istype(O, /obj/item/weapon/screwdriver) && unwrenchable) //THIS NEED TO BE DONE DIFFERENTLY, SOMEONE REFACTOR THE TRAY CODE ALREADY
		if(anchored)
			if(anchored == 2)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				anchored = 1
				user << "You unscrew \the [src]'s hoses."

			else if(anchored == 1)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				anchored = 2
				user << "You screw in \the [src]'s hoses."

			for(var/obj/machinery/hydroponics/h in range(1,src))
				spawn()
					h.update_icon()

	return

/obj/machinery/hydroponics/attack_hand(mob/user as mob)
	if(istype(user, /mob/living/silicon))		//How does AI know what plant is?
		return
	if(harvest)
		myseed.harvest()
	else if(dead)
		planted = 0
		dead = 0
		user << "You remove the dead plant from [src]."
		qdel(myseed)
		update_icon()
	else
		if(planted && !dead)
			user << "[src] has <span class='info'>[myseed.plantname]</span> planted."
			if(health <= (myseed.endurance / 2))
				user << "The plant looks unhealthy."
		else
			user << "[src] is empty."
		user << "Water: [waterlevel]/[maxwater]"
		user << "Nutrient: [nutrilevel]/[maxnutri]"
		if(weedlevel >= 5) // Visual aid for those blind
			user << "[src] is filled with weeds!"
		if(pestlevel >= 5) // Visual aid for those blind
			user << "[src] is filled with tiny worms!"
		user << "" // Empty line for readability.

/obj/item/seeds/proc/getYield()
	var/obj/machinery/hydroponics/parent = loc
	if (parent.yieldmod == 0)
		return min(yield, 1)//1 if above zero, 0 otherwise
	return (yield * parent.yieldmod)

/obj/item/seeds/proc/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0
	var/list/result = list()
	var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK

	while(t_amount < getYield())
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new product(output_loc, potency)
		result.Add(t_prod) // User gets a consumable
		if(!t_prod)	return
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.potency = potency
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

	return result


/obj/item/seeds/replicapod/harvest(mob/user = usr) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc
	var/make_podman = 0
	var/ckey_holder = null
	if(config.revival_pod_plants)
		if(ckey)
			for(var/mob/M in player_list)
				if(istype(M, /mob/dead/observer))
					var/mob/dead/observer/O = M
					if(O.ckey == ckey && O.can_reenter_corpse)
						make_podman = 1
						break
				else
					if(M.ckey == ckey && M.stat == 2 && !M.suiciding)
						make_podman = 1
						break
		else //If the player has ghosted from his corpse before blood was drawn, his ckey is no longer attached to the mob, so we need to match up the cloned player through the mind key
			for(var/mob/M in player_list)
				if(ckey(M.mind.key) == ckey(mind.key) && M.ckey && M.client && M.stat == 2 && !M.suiciding)
					if(istype(M, /mob/dead/observer))
						var/mob/dead/observer/O = M
						if(!O.can_reenter_corpse)
							break
					make_podman = 1
					ckey_holder = M.ckey
					break

	if(make_podman)	//all conditions met!
		var/mob/living/carbon/human/podman = new /mob/living/carbon/human(parent.loc)
		if(realName)
			podman.real_name = realName
		else
			podman.real_name = "Pod Person [rand(0,999)]"
		mind.transfer_to(podman)
		if(ckey)
			podman.ckey = ckey
		else
			podman.ckey = ckey_holder
		podman.gender = blood_gender
		podman.faction |= factions
		if(!mutant_color)
			mutant_color = "#59CE00"
		hardset_dna(podman,null,null,podman.real_name,blood_type,/datum/species/plant/pod,mutant_color)//Discard SE's and UI's, podman cloning is inaccurate, and always make them a podman
		podman.set_cloned_appearance()

	else //else, one packet of seeds. maybe two
		var/seed_count = 1
		if(prob(getYield() * 20))
			seed_count++
		for(var/i=0,i<seed_count,i++)
			var/obj/item/seeds/replicapod/harvestseeds = new /obj/item/seeds/replicapod(user.loc)
			harvestseeds.lifespan = lifespan
			harvestseeds.endurance = endurance
			harvestseeds.maturation = maturation
			harvestseeds.production = production
			harvestseeds.yield = yield
			harvestseeds.potency = potency

	parent.update_tray()

/obj/machinery/hydroponics/proc/update_tray(mob/user = usr)
	harvest = 0
	lastproduce = age
	if(istype(myseed,/obj/item/seeds/replicapod/))
		user << "<span class='notice'>You harvest from the [myseed.plantname].</span>"
	else if(myseed.getYield() <= 0)
		user << "<span class='warning'>You fail to harvest anything useful!</span>"
	else
		user << "<span class='notice'>You harvest [myseed.getYield()] items from the [myseed.plantname].</span>"
	if(myseed.oneharvest)
		qdel(myseed)
		planted = 0
		dead = 0
	update_icon()

/// Tray Setters - The following procs adjust the tray or plants variables, and make sure that the stat doesn't go out of bounds.///
/obj/machinery/hydroponics/proc/adjustNutri(var/adjustamt)
	nutrilevel += adjustamt
	nutrilevel = max(nutrilevel, 0)
	nutrilevel = min(nutrilevel, maxnutri)

/obj/machinery/hydroponics/proc/adjustWater(var/adjustamt)
	waterlevel += adjustamt
	waterlevel = max(waterlevel, 0)
	waterlevel = min(waterlevel, maxwater)
	if(adjustamt>0)
		adjustToxic(-round(adjustamt/4))//Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.

/obj/machinery/hydroponics/proc/adjustHealth(var/adjustamt)
	if(planted && !dead)
		health += adjustamt
		health = max(health, 0)
		health = min(health, myseed.endurance)

/obj/machinery/hydroponics/proc/adjustToxic(var/adjustamt)
	toxic += adjustamt
	toxic = max(toxic, 0)
	toxic = min(toxic, 100)

/obj/machinery/hydroponics/proc/adjustPests(var/adjustamt)
	pestlevel += adjustamt
	pestlevel = max(pestlevel, 0)
	pestlevel = min(pestlevel, 10)

/obj/machinery/hydroponics/proc/adjustWeeds(var/adjustamt)
	weedlevel += adjustamt
	weedlevel = max(weedlevel, 0)
	weedlevel = min(weedlevel, 10)

/// Seed Setters ///
/obj/machinery/hydroponics/proc/adjustSYield(var/adjustamt)//0,10
	if(myseed && myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		myseed.yield += adjustamt
		myseed.yield = max(myseed.yield, 0)
		myseed.yield = min(myseed.yield, 10)
		if(myseed.yield <= 0 && myseed.plant_type == 2)
			myseed.yield = 1 // Mushrooms always have a minimum yield of 1.

/obj/machinery/hydroponics/proc/adjustSLife(var/adjustamt)//10,100
	if(myseed)
		myseed.lifespan += adjustamt
		myseed.lifespan = max(myseed.lifespan, 10)
		myseed.lifespan = min(myseed.lifespan, 100)

/obj/machinery/hydroponics/proc/adjustSEnd(var/adjustamt)//10,100
	if(myseed)
		myseed.endurance += adjustamt
		myseed.endurance = max(myseed.endurance, 10)
		myseed.endurance = min(myseed.endurance, 100)

/obj/machinery/hydroponics/proc/adjustSProduct(var/adjustamt)//2,10
	if(myseed)
		myseed.production += adjustamt
		myseed.production = max(myseed.production, 2)
		myseed.production = min(myseed.production, 10)

/obj/machinery/hydroponics/proc/adjustSPot(var/adjustamt)//0,100
	if(myseed && myseed.potency != -1) //Not all plants have a potency
		myseed.potency += adjustamt
		myseed.potency = max(myseed.potency, 0)
		myseed.potency = min(myseed.potency, 100)

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0
	unwrenchable = 0

/obj/machinery/hydroponics/soil/update_icon() // Same as normal but with the overlays removed - Cheridan.
	overlays.Cut()

	UpdateDescription()

	if(planted)
		if(dead)
			overlays += image('icons/obj/hydroponics/growing.dmi', icon_state= "[myseed.species]-dead")
		else if(harvest)
			if(myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				overlays += image('icons/obj/hydroponics/growing.dmi', icon_state= "[myseed.species]-grow[myseed.growthstages]")
			else
				overlays += image('icons/obj/hydroponics/growing.dmi', icon_state= "[myseed.species]-harvest")
		else if(age < myseed.maturation)
			var/t_growthstate = ((age / myseed.maturation) * myseed.growthstages )
			overlays += image('icons/obj/hydroponics/growing.dmi', icon_state= "[myseed.species]-grow[round(t_growthstate)]")
			lastproduce = age
		else
			overlays += image('icons/obj/hydroponics/growing.dmi', icon_state= "[myseed.species]-grow[myseed.growthstages]")

	if(istype(myseed,/obj/item/seeds/glowshroom))
		SetLuminosity(round(myseed.potency/10))
	else
		SetLuminosity(0)
	return

/obj/machinery/hydroponics/soil/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	..()
	if(istype(O, /obj/item/weapon/shovel))
		user << "You clear up [src]!"
		qdel(src)

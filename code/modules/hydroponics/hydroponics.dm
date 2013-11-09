/obj/machinery/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	var/waterlevel = 100	//The amount of water in the tray (max 100)
	var/nutrilevel = 10		//The amount of nutrient in the tray (max 10)
	var/pestlevel = 0		//The amount of pests in the tray (max 10)
	var/weedlevel = 0		//The amount of weeds in the tray (max 10)
	var/yieldmod = 1		//Modifier to yield
	var/mutmod = 1			//Modifier to mutation chance
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
		else if(prob(1/(myseed.yield * myseed.yield) *100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			adjustSYield(1)
			//world << "Yield increased by 1, to a total of [myseed.yield]"
	else
		..()
		return

obj/machinery/hydroponics/process()

	if(myseed && (myseed.loc != src))
		myseed.loc = src

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(planted && !dead)
			// Advance age
			age++

//Nutrients//////////////////////////////////////////////////////////////
			// Nutrients deplete slowly
			if(prob(50))
				adjustNutri(-1)

			// Lack of nutrients hurts non-weeds
			if(nutrilevel <= 0 && myseed.plant_type != 1)
				adjustHealth(-rand(1,3))

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
				for(var/i = 0; i < mutmod; i++)
					if(prob(85))
						mutate()
					else if(prob(30))
						hardmutate()
					else if(prob(5))
						mutatespecie()

				if(yieldmod > 0 && myseed.yield != -1) // Unharvestable shouldn't be harvested
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
		update_icon()
	return



obj/machinery/hydroponics/update_icon()
	//Refreshes the icon and sets the luminosity
	overlays.Cut()
	if(planted)
		if(dead)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-dead")
		else if(harvest)
			if(myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]")
			else
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-harvest")
		else if(age < myseed.maturation)
			var/t_growthstate = ((age / myseed.maturation) * myseed.growthstages ) // Make sure it won't crap out due to HERPDERP 6 stages only
			overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[round(t_growthstate)]")
			lastproduce = age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]") // Same

		if(waterlevel <= 10)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_lowwater3")
		if(nutrilevel <= 2)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_lownutri3")
		if(health <= (myseed.endurance / 2))
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_lowhealth3")
		if(weedlevel >= 5 || pestlevel >= 5 || toxic >= 40)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_alert3")
		if(harvest)
			overlays += image('icons/obj/hydroponics.dmi', icon_state="over_harvest3")

	if(istype(myseed,/obj/item/seeds/glowshroom))
		SetLuminosity(round(myseed.potency / 10))
	else
		SetLuminosity(0)

	return


obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	dead = 0
	var/oldPlantName
	if(myseed) // In case there's nothing in the tray beforehand
		oldPlantName = myseed.plantname
		del(myseed)
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
	visible_message("\blue [oldPlantName] overtaken by [myseed.plantname].")



obj/machinery/hydroponics/proc/mutate(var/lifemut=2, var/endmut=5, var/productmut=1, var/yieldmut=2, var/potmut=25) // Mutates the current seed
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
		del(myseed)
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
	visible_message("\red[oldPlantName] suddenly mutated into \blue [myseed.plantname]!")



obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if( weedlevel > 5 )
		if(myseed)
			del(myseed)
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
		visible_message("\red The mutated weeds in [src] spawned a \blue [myseed.plantname]!")
	else
		usr << "The few weeds in [src] seem to react, but only for a moment..."



obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	health = 0
	harvest = 0
	pestlevel = 0 // Pests die
	if(!dead)
		update_icon()
		visible_message("\improper\red [myseed.plantname] are looking very unhealthy!")
		dead = 1



obj/machinery/hydroponics/proc/mutatepest()
	if(pestlevel > 5)
		visible_message("The pests seem to behave oddly...")
		for(var/i=0, i<3, i++)
			var/obj/effect/spider/spiderling/S = new(src.loc)
			S.grow_as = /mob/living/simple_animal/hostile/giant_spider/hunter
	else
		usr << "The pests seem to behave oddly, but quickly settle down..."



obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)

	//Called when mob user "attacks" it with object O
	if(istype(O, /obj/item/nutrient))
		var/obj/item/nutrient/myNut = O
		user.u_equip(O)
		adjustNutri(10)
		yieldmod = myNut.yieldmod
		mutmod = myNut.mutmod
		user << "You replace the nutrient solution in [src]."
		del(O)
		update_icon()

	else if(istype(O, /obj/item/weapon/reagent_containers) )  // Syringe stuff (and other reagent containers now too)
		var/obj/item/weapon/reagent_containers/reagent_source = O
		var/datum/reagents/S = new /datum/reagents()
		
		S.my_atom = src
		
		var/obj/target = myseed ? myseed.plantname : src

		if(istype(reagent_source, /obj/item/weapon/reagent_containers/syringe))
			var/obj/item/weapon/reagent_containers/syringe/syr = reagent_source
			if(syr.mode != 1)
				user << "You can't get any extract out of this plant."
				return
		if(!reagent_source.reagents.total_volume)
			user << "<span class='notice'>[reagent_source] is empty.</span>"
			return 1
		
		if(istype(reagent_source, /obj/item/weapon/reagent_containers/food/snacks) || istype(reagent_source, /obj/item/weapon/reagent_containers/pill))
			visible_message("<span class='notice'>[user] composts [reagent_source], spreading it through [target].</span>")
			reagent_source.reagents.trans_to(S,reagent_source.reagents.total_volume)
			del(reagent_source)
		else
			reagent_source.reagents.trans_to(S,reagent_source.amount_per_transfer_from_this)
			if(istype(reagent_source, /obj/item/weapon/reagent_containers/syringe/))
				var/obj/item/weapon/reagent_containers/syringe/syr = reagent_source
				visible_message("<span class='notice'>[user] injects [target] with [syr].</span>")
				if(syr.reagents.total_volume <= 0)
					syr.mode = 0
					syr.update_icon()
			else if(istype(reagent_source, /obj/item/weapon/reagent_containers/spray/))
				visible_message("<span class='notice'>[user] sprays [target] with [reagent_source].</span>")
				playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			else if(reagent_source.amount_per_transfer_from_this) // Droppers, cans, beakers, what have you.
				visible_message("<span class='notice'>[user] uses [reagent_source] on [target].</span>")
			
			// Beakers, bottles, buckets, etc.  Can't use is_open_container though.
			if(istype(reagent_source, /obj/item/weapon/reagent_containers/glass/))
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

		// There needs to be a good amount of mutagen to actually work
		if(S.has_reagent("mutagen", 5))
			switch(rand(100))
				if(91  to 100)	plantdies()
				if(81  to 90)  mutatespecie()
				if(66	to 80)	hardmutate()
				if(41  to 65)  mutate()
				if(21  to 41)  user << "The plants don't seem to react..."
				if(11	to 20)  mutateweed()
				if(1   to 10)  mutatepest()
				else 			user << "Nothing happens..."

		// Antitoxin binds shit pretty well. So the tox goes significantly down
		if(S.has_reagent("anti_toxin", 1))
			adjustToxic(-round(S.get_reagent_amount("anti_toxin")*2))

		// NIGGA, YOU JUST WENT ON FULL RETARD.
		if(S.has_reagent("toxin", 1))
			adjustToxic(round(S.get_reagent_amount("toxin")*2))

		// Milk is good for humans, but bad for plants. The sugars canot be used by plants, and the milk fat fucks up growth. Not shrooms though. I can't deal with this now...
		if(S.has_reagent("milk", 1))
			adjustNutri(round(S.get_reagent_amount("milk")*0.1))
			adjustWater(round(S.get_reagent_amount("milk")*0.9))

		// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
		if(S.has_reagent("beer", 1))
			adjustHealth(-round(S.get_reagent_amount("beer")*0.05))
			adjustNutri(round(S.get_reagent_amount("beer")*0.25))
			adjustWater(round(S.get_reagent_amount("beer")*0.7))

		// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
		if(S.has_reagent("fluorine", 1))
			adjustHealth(-round(S.get_reagent_amount("fluorine")*2))
			adjustToxic(round(S.get_reagent_amount("flourine")*2.5))
			adjustWater(-round(S.get_reagent_amount("flourine")*0.5))
			adjustWeeds(-rand(1,4))

		// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
		if(S.has_reagent("chlorine", 1))
			adjustHealth(-round(S.get_reagent_amount("chlorine")*1))
			adjustToxic(round(S.get_reagent_amount("chlorine")*1.5))
			adjustWater(-round(S.get_reagent_amount("chlorine")*0.5))
			adjustWeeds(-rand(1,3))

		// White Phosphorous + water -> phosphoric acid. That's not a good thing really. Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
		if(S.has_reagent("phosphorus", 1))
			adjustHealth(-round(S.get_reagent_amount("phosphorus")*0.75))
			adjustNutri(round(S.get_reagent_amount("phosphorus")*0.1))
			adjustWater(-round(S.get_reagent_amount("phosphorus")*0.5))
			adjustWeeds(-rand(1,2))

		// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...
		if(S.has_reagent("sugar", 1))
			adjustWeeds(rand(1,2))
			adjustPests(rand(1,2))
			adjustNutri(round(S.get_reagent_amount("sugar")*0.1))

		// It is water!
		if(S.has_reagent("water", 1))
			adjustWater(round(S.get_reagent_amount("water")*1))

		// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits~
		if(S.has_reagent("holywater", 1))
			adjustWater(round(S.get_reagent_amount("holywater")*1))
			adjustHealth(round(S.get_reagent_amount("holywater")*0.1))

		// A variety of nutrients are dissolved in club soda, without sugar. These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
		if(S.has_reagent("sodawater", 1))
			adjustWater(round(S.get_reagent_amount("sodawater")*1))
			adjustHealth(round(S.get_reagent_amount("sodawater")*0.1))
			adjustNutri(round(S.get_reagent_amount("sodawater")*0.1))

		// Man, you guys are retards
		if(S.has_reagent("sacid", 1))
			adjustHealth(-round(S.get_reagent_amount("sacid")*1))
			adjustToxic(round(S.get_reagent_amount("sacid")*1.5))
			adjustWeeds(-rand(1,2))

		// SERIOUSLY
		if(S.has_reagent("pacid", 1))
			adjustHealth(-round(S.get_reagent_amount("pacid")*2))
			adjustToxic(round(S.get_reagent_amount("pacid")*3))
			adjustWeeds(-rand(1,4))

		// Plant-B-Gone is just as bad
		if(S.has_reagent("plantbgone", 1))
			adjustHealth(-round(S.get_reagent_amount("plantbgone")*2))
			adjustToxic(-round(S.get_reagent_amount("plantbgone")*3))
			adjustWeeds(-rand(4,8))

		// Healing
		if(S.has_reagent("cryoxadone", 1))
			adjustHealth(round(S.get_reagent_amount("cryoxadone")*3))
			adjustToxic(-round(S.get_reagent_amount("cryoxadone")*3))

		// Ammonia is bad ass.
		if(S.has_reagent("ammonia", 1))
			adjustHealth(round(S.get_reagent_amount("ammonia")*0.5))
			adjustNutri(round(S.get_reagent_amount("ammonia")*1))

		// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant.
		if(S.has_reagent("diethylamine", 1))
			adjustHealth(round(S.get_reagent_amount("diethylamine")*1))
			adjustNutri(round(S.get_reagent_amount("diethylamine")*2))
			adjustPests(-rand(1,2))

		// Compost, effectively
		if(S.has_reagent("nutriment", 1))
			adjustHealth(round(S.get_reagent_amount("nutriment")*0.5))
			adjustNutri(round(S.get_reagent_amount("nutriment")*1))

		// Poor man's mutagen.
		if(S.has_reagent("radium", 1))
			adjustHealth(-round(S.get_reagent_amount("radium")*1.5))
			adjustToxic(round(S.get_reagent_amount("radium")*2))
		if(S.has_reagent("radium", 10))
			switch(rand(100))
				if(91  to 100)	plantdies()
				if(81  to 90)  mutatespecie()
				if(66	to 80)	hardmutate()
				if(41  to 65)  mutate()
				if(21  to 41)  user << "The plants don't seem to react..."
				if(11	to 20)  mutateweed()
				if(1   to 10)  mutatepest()
				else 			user << "Nothing happens..."

		// The best stuff there is. For testing/debugging.
		if(S.has_reagent("adminordrazine", 1))
			adjustWater(round(S.get_reagent_amount("adminordrazine")*1))
			adjustHealth(round(S.get_reagent_amount("adminordrazine")*1))
			adjustNutri(round(S.get_reagent_amount("adminordrazine")*1))
			adjustPests(-rand(1,5))
			adjustWeeds(-rand(1,5))
		if(S.has_reagent("adminordrazine", 5))
			switch(rand(100))
				if(66  to 100)  mutatespecie()
				if(33	to 65)  mutateweed()
				if(1   to 32)  mutatepest()
				else 			user << "Nothing happens..."

		S.clear_reagents()
		del(S)
		update_icon()
		return 1

	else if( istype(O, /obj/item/seeds/) )
		if(!planted)
			user.u_equip(O)
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
			user << "\red [src] already has seeds in it!"

	else if(istype(O, /obj/item/device/analyzer/plant_analyzer))
		if(planted && myseed)
			user << "*** <B>[myseed.plantname]</B> ***" //Carn: now reports the plants growing, not the seeds.
			user << "-Plant Age: \blue [age]"
			user << "-Plant Endurance: \blue [myseed.endurance]"
			user << "-Plant Lifespan: \blue [myseed.lifespan]"
			if(myseed.yield != -1)
				user << "-Plant Yield: \blue [myseed.yield]"
			user << "-Plant Production: \blue [myseed.production]"
			if(myseed.potency != -1)
				user << "-Plant Potency: \blue [myseed.potency]"
			user << "-Weed level: \blue [weedlevel]/10"
			user << "-Pest level: \blue [pestlevel]/10"
			user << "-Toxicity level: \blue [toxic]/100"
			user << "-Water level: \blue [waterlevel]/100"
			user << "-Nutrition level: \blue [nutrilevel]/10"
			user << ""
		else
			user << "<B>No plant found.</B>"
			user << "-Weed level: \blue [weedlevel]/10"
			user << "-Pest level: \blue [pestlevel]/10"
			user << "-Toxicity level: \blue [toxic]/100"
			user << "-Water level: \blue [waterlevel]/100"
			user << "-Nutrition level: \blue [nutrilevel]/10"
			user << ""
	
	else if(istype(O, /obj/item/weapon/minihoe))
		if(weedlevel > 0)
			user.visible_message("<span class='notice'>[user] uproots the weeds.</span>", "<span class='notice'>You remove the weeds from [src].</span>")
			weedlevel = 0
			update_icon()
		else
			user << "<span class='notice'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>"

	else if( istype(O, /obj/item/weapon/weedspray) )
		var/obj/item/weedkiller/myWKiller = O
		user.u_equip(O)
		adjustToxic(myWKiller.toxicity)
		adjustWeeds(-myWKiller.WeedKillStr)
		user << "You apply the weedkiller solution into [src]."
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		del(O)
		update_icon()

	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		attack_hand(user)
		var/obj/item/weapon/storage/bag/plants/S = O
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if( istype(O, /obj/item/weapon/pestspray) )
		var/obj/item/pestkiller/myPKiller = O
		user.u_equip(O)
		adjustToxic(myPKiller.toxicity)
		adjustPests(-myPKiller.PestKillStr)
		user << "You apply the pestkiller solution into [src]."
		playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
		del(O)
		update_icon()
	else if(istype(O, /obj/item/weapon/wrench))
		if(!anchored && !isinspace())
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
			user << "You wrench [src] in place."
		else if(anchored)
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
			user << "You unwrench [src]."
	else if(istype(O, /obj/item/weapon/shovel))
		if(istype(src, /obj/machinery/hydroponics/soil))
			user << "You clear up [src]!"
			del(src)
	return


/obj/machinery/hydroponics/attack_hand(mob/user as mob)
	if(istype(user, /mob/living/silicon))		//How does AI know what plant is?
		return
	if(harvest)
		if(!user in range(1,src))
			return
		myseed.harvest()
	else if(dead)
		planted = 0
		dead = 0
		user << "You remove the dead plant from [src]."
		del(myseed)
		update_icon()
	else
		if(planted && !dead)
			user << "[src] has \blue [myseed.plantname] \black planted."
			if(health <= (myseed.endurance / 2))
				user << "The plant looks unhealthy."
		else
			user << "[src] is empty."
		user << "Water: [waterlevel]/100"
		user << "Nutrient: [nutrilevel]/10"
		if(weedlevel >= 5) // Visual aid for those blind
			user << "[src] is filled with weeds!"
		if(pestlevel >= 5) // Visual aid for those blind
			user << "[src] is filled with tiny worms!"
		user << "" // Empty line for readability.

/obj/item/seeds/proc/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while(t_amount < (yield * parent.yieldmod))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new product(user.loc, potency) // User gets a consumable
		if(!t_prod)	return
		t_prod.seed = type
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.potency = potency
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()
/*
/obj/item/seeds/grassseed/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_yield = round(yield*parent.yieldmod)

	if(t_yield > 0)
		var/obj/item/stack/tile/grass/new_grass = new/obj/item/stack/tile/grass(user.loc)
		new_grass.amount = t_yield

	parent.update_tray()

/obj/item/seeds/gibtomato/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new product(user.loc, potency) // User gets a consumable

		t_prod.seed = type
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.potency = potency
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()
*/
/obj/item/seeds/nettleseed/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while(t_amount < (yield * parent.yieldmod))
		var/obj/item/weapon/grown/t_prod = new product(user.loc, potency) // User gets a consumable -QualityVan
		t_prod.seed = type
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.changePotency(potency) // -QualityVan
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

/obj/item/seeds/deathnettleseed/harvest(mob/user = usr) //isn't a nettle subclass yet, so
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while(t_amount < (yield * parent.yieldmod))
		var/obj/item/weapon/grown/t_prod = new product(user.loc, potency) // User gets a consumable -QualityVan
		t_prod.seed = type
		t_prod.species = species
		t_prod.lifespan = lifespan
		t_prod.endurance = endurance
		t_prod.maturation = maturation
		t_prod.production = production
		t_prod.yield = yield
		t_prod.changePotency(potency) // -QualityVan
		t_prod.plant_type = plant_type
		t_amount++

	parent.update_tray()

/obj/item/seeds/eggyseed/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while(t_amount < (yield * parent.yieldmod))
		new product(user.loc)
		t_amount++

	parent.update_tray()

/obj/item/seeds/replicapod/harvest(mob/user = usr) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc
	var/make_podman = 0
	var/mob/ghost
	if(ckey && config.revival_pod_plants)
		ghost = find_dead_player("[ckey]")
		if(ismob(ghost))
			if(istype(ghost,/mob/dead/observer))
				var/mob/dead/observer/O = ghost
				if(istype(mind,/datum/mind))
					if(O.can_reenter_corpse)
						make_podman = 1
			else
				make_podman = 1

	if(make_podman)	//all conditions met!
		var/mob/living/carbon/human/podman = new /mob/living/carbon/human(parent.loc)
		if(realName)
			podman.real_name = realName
		else
			podman.real_name = "Pod Person [rand(0,999)]"
		var/oldactive = mind.active
		mind.active = 1
		mind.transfer_to(podman)
		mind.active = oldactive
			// -- Mode/mind specific stuff goes here. TODO! Broken :( Should be merged into mob/living/Login
		switch(ticker.mode.name)
			if("revolution")
				if(podman.mind in ticker.mode:revolutionaries)
					ticker.mode:add_revolutionary(podman.mind)
					ticker.mode:update_all_rev_icons() //So the icon actually appears
				if(podman.mind in ticker.mode:head_revolutionaries)
					ticker.mode:update_all_rev_icons()
			if("nuclear emergency")
				if(podman.mind in ticker.mode:syndicates)
					ticker.mode:update_all_synd_icons()
			if("cult")
				if(podman.mind in ticker.mode:cult)
					ticker.mode:add_cultist(podman.mind)
					ticker.mode:update_all_cult_icons() //So the icon actually appears

			// -- End mode specific stuff

		podman.gender = ghost.gender

		//dna stuff
		hardset_dna(podman, ui, se, null, !prob(potency) ? "plant" : null)	//makes sure podman has dna and sets the dna's ui/se/mutantrace/real_name etc variables

	else //else, one packet of seeds. maybe two
		var/seed_count = 1
		if(prob(yield * parent.yieldmod * 20))
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

/obj/item/seeds/replicapod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers))
		if(ckey == null)
			user << "You inject the contents of the syringe into the seeds."

			for(var/datum/reagent/blood/bloodSample in W:reagents.reagent_list)
				var/mob/living/carbon/human/source = bloodSample.data["donor"] //hacky, since it gets the CURRENT condition of the mob, not how it was when the blood sample was taken
				if(!istype(source))
					continue
				//ui = bloodSample.data["blood_dna"] doesn't work for whatever reason
				ui = source.dna.uni_identity
				se = source.dna.struc_enzymes
				if(source.ckey)
					ckey = source.ckey
				else if(source.mind)
					ckey = ckey(source.mind.key)
				realName = source.real_name
				gender = source.gender

				if(!isnull(source.mind))
					mind = source.mind

			W:reagents.clear_reagents()
		else
			user << "There is already a genetic sample in these seeds."
	else
		return ..()

/obj/machinery/hydroponics/proc/update_tray(mob/user = usr)
	harvest = 0
	lastproduce = age
	if((yieldmod * myseed.yield) <= 0)
		user << "\red You fail to harvest anything useful."
	else
		user << "You harvest from the [myseed.plantname]."
	if(myseed.oneharvest)
		del(myseed)
		planted = 0
		dead = 0
	update_icon()

/// Tray Setters - The following procs adjust the tray or plants variables, and make sure that the stat doesn't go out of bounds.///
/obj/machinery/hydroponics/proc/adjustNutri(var/adjustamt)
	nutrilevel += adjustamt
	nutrilevel = max(nutrilevel, 0)
	nutrilevel = min(nutrilevel, 10)

/obj/machinery/hydroponics/proc/adjustWater(var/adjustamt)
	waterlevel += adjustamt
	waterlevel = max(waterlevel, 0)
	waterlevel = min(waterlevel, 100)
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
	pestlevel = min(pestlevel, 10)

/// Seed Setters ///
/obj/machinery/hydroponics/proc/adjustSYield(var/adjustamt)//0,10
	if(myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		myseed.yield += adjustamt
		myseed.yield = max(myseed.yield, 0)
		myseed.yield = min(myseed.yield, 10)
		if(myseed.yield <= 0 && myseed.plant_type == 2)
			myseed.yield = 1 // Mushrooms always have a minimum yield of 1.

/obj/machinery/hydroponics/proc/adjustSLife(var/adjustamt)//10,100
	myseed.lifespan += adjustamt
	myseed.lifespan = max(myseed.lifespan, 10)
	myseed.lifespan = min(myseed.lifespan, 100)

/obj/machinery/hydroponics/proc/adjustSEnd(var/adjustamt)//10,100
	myseed.endurance += adjustamt
	myseed.endurance = max(myseed.endurance, 10)
	myseed.endurance = min(myseed.endurance, 100)

/obj/machinery/hydroponics/proc/adjustSProduct(var/adjustamt)//2,10
	myseed.production += adjustamt
	myseed.production = max(myseed.endurance, 2)
	myseed.production = min(myseed.endurance, 10)

/obj/machinery/hydroponics/proc/adjustSPot(var/adjustamt)//0,100
	if(myseed.potency != -1) //Not all plants have a potency
		myseed.potency += adjustamt
		myseed.potency = max(myseed.potency, 0)
		myseed.potency = min(myseed.potency, 100)

///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0

	update_icon() // Same as normal but with the overlays removed - Cheridan.
		overlays.Cut()
		if(planted)
			if(dead)
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-dead")
			else if(harvest)
				if(myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
					overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]")
				else
					overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-harvest")
			else if(age < myseed.maturation)
				var/t_growthstate = ((age / myseed.maturation) * myseed.growthstages )
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[round(t_growthstate)]")
				lastproduce = age
			else
				overlays += image('icons/obj/hydroponics.dmi', icon_state="[myseed.species]-grow[myseed.growthstages]")

		if(!luminosity)
			if(istype(myseed,/obj/item/seeds/glowshroom))
				SetLuminosity(round(myseed.potency/10))
		else
			SetLuminosity(0)
		return
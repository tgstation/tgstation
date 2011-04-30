/obj/machinery/hydroponics
	name = "Hydroponics Tray"
	icon = 'hydroponics.dmi'
	icon_state = "hydrotraynew"
	density = 1
	anchored = 1
	var/waterlevel = 100 // The amount of water in the tray (max 100)
	var/nutrilevel = 10 // The amount of nutrient in the tray (max 10)
	var/pestlevel = 0 // The amount of pests in the tray (max 10)
	var/weedlevel = 0 // The amount of weeds in the tray (max 10)
	var/yieldmod = 1 //Modifier to yield
	var/mutmod = 1 //Modifier to mutation chance
	var/toxic = 0 // Toxicity in the tray?
	var/age = 0 // Current age
	var/dead = 0 // Is it dead?
	var/health = 0 // Its health.
	var/lastproduce = 0 // Last time it was harvested
	var/lastcycle = 0 //Used for timing of cycles.
	var/cycledelay = 200 // About 10 seconds / cycle
	var/planted = 0 // Is it occupied?
	var/harvest = 0 //Ready to harvest?
	var/obj/item/seeds/myseed = null // The currently planted seed



obj/machinery/hydroponics/process()

	if(world.time > (src.lastcycle + src.cycledelay))
		src.lastcycle = world.time
		if(src.planted && !src.dead)
			// Advance age
			src.age++

			// Drink random amount of water
			src.waterlevel -= rand(1,6)

			// Nutrients deplete slowly
			if(src.nutrilevel > 0)
				if(prob(50))
					src.nutrilevel -= 1

			// Lack of nutrients hurts non-weeds
			if(src.nutrilevel == 0 && src.myseed.plant_type != 1)
				src.health -= rand(1,3)

			// Adjust the water level so it can't go negative
			if(src.waterlevel < 0)
				src.waterlevel = 0

			// If the plant is dry, it loses health pretty fast, unless mushroom
			if(src.waterlevel <= 0 && src.myseed.plant_type != 2)
				src.health -= rand(1,3)
			else if(src.waterlevel <= 10 && src.myseed.plant_type != 2)
				src.health -= rand(0,1)

			// Too much toxins cause harm, but when the plant drinks the contaiminated water, the toxins disappear slowly
			if(src.toxic >= 40 && src.toxic < 80)
				src.health -= 1
				src.toxic -= rand(1,10)
			if(src.toxic >= 80) // I don't think it ever gets here tbh unless above is commented out
				src.health -= 3
				src.toxic -= rand(1,10)

			// Sufficient water level and nutrient level = plant healthy
			if(src.waterlevel > 10 && src.nutrilevel > 0)
				src.health += rand(1,2)

			// Too many pests cause the plant to be sick
			if(src.pestlevel >= 5)
				src.health -= 1

			// If it's a weed, it doesn't stunt the growth
			if(src.weedlevel >= 5 && src.myseed.plant_type != 1 )
				src.health -= 1

			// Don't go overboard with the health
			if(src.health > src.myseed.endurance)
				src.health = src.myseed.endurance

			// If the plant is too old, lose health fast
			if(src.age > src.myseed.lifespan)
				src.health -= rand(1,5)

			// Plant dies if health = 0
			if(src.health <= 0)
				src.dead = 1
				src.harvest = 0
				src.weedlevel += 1 // Weeds flourish
				//src.toxic = 0 // Water is still toxic
				src.pestlevel = 0 // Pests die

			// Harvest code
			if(src.age > src.myseed.production && (src.age - src.lastproduce) > src.myseed.production && (!src.harvest && !src.dead))
				var/m_count = 0
				while(m_count < src.mutmod)
					if(prob(90))
						src.mutate()
					else if(prob(30))
						src.hardmutate()
					m_count++;
				if(src.yieldmod > 0 && src.myseed.yield != -1) // Unharvestable shouldn't be harvested
					src.harvest = 1
				else
					src.lastproduce = src.age
			if(prob(5))  // On each tick, there's a 5 percent chance the pest population will increase
				src.pestlevel += 1
			if(prob(5) && src.waterlevel > 10 && src.nutrilevel > 0)  // On each tick, there's a 5 percent chance the weed
				src.weedlevel += 1					//population will increase, but there needs to be water/nuts for that!
		else
			if(prob(10) && src.waterlevel > 10 && src.nutrilevel > 0)  // If there's no plant, the percentage chance is 10%
				src.weedlevel += 1

		// These (v) wouldn't be necessary if additional checks were made earlier (^)

		if (src.weedlevel > 10) // Make sure it won't go overoboard
			src.weedlevel = 10
		if (src.toxic < 0) // Make sure it won't go overoboard
			src.toxic = 0
		if (src.pestlevel > 10 ) // Make sure it won't go overoboard
			src.pestlevel = 10

		// Weeeeeeeeeeeeeeedddssss

		if (prob(50) && src.weedlevel == 10) // At this point the plant is kind of fucked. Weeds can overtake the plant spot.
			if(src.planted)
				if(src.myseed.plant_type == 0) // If a normal plant
					src.weedinvasion()
			else
				src.weedinvasion() // Weed invasion into empty tray
		src.updateicon()
	return



obj/machinery/hydroponics/proc/updateicon()
	//Refreshes the icon
	overlays = null
	if(src.planted)
		if(dead)
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-dead")
		else if(src.harvest)
			if(src.myseed.plant_type == 2) // Shrooms don't have a -harvest graphic
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]")
			else
				overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-harvest")
		else if(src.age < src.myseed.maturation)
			var/t_growthstate = ((src.age / src.myseed.maturation) * src.myseed.growthstages ) // Make sure it won't crap out due to HERPDERP 6 stages only
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[round(t_growthstate)]")
			src.lastproduce = src.age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[src.myseed.growthstages]") // Same

		if(src.waterlevel <= 10)
			overlays += image('hydroponics.dmi', icon_state="over_lowwater")
		if(src.nutrilevel <= 2)
			overlays += image('hydroponics.dmi', icon_state="over_lownutri")
		if(src.health <= (src.myseed.endurance / 2))
			overlays += image('hydroponics.dmi', icon_state="over_lowhealth")
		if(src.weedlevel >= 5)
			overlays += image('hydroponics.dmi', icon_state="over_alert")
		if(src.pestlevel >= 5)
			overlays += image('hydroponics.dmi', icon_state="over_alert")
		if(src.toxic >= 40)
			overlays += image('hydroponics.dmi', icon_state="over_alert")
		if(src.harvest)
			overlays += image('hydroponics.dmi', icon_state="over_harvest")
	return



obj/machinery/hydroponics/proc/weedinvasion() // If a weed growth is sufficient, this happens.
	src.dead = 0
	if(src.myseed) // In case there's nothing in the tray beforehand
		del(src.myseed)
	switch(rand(1,15))		// randomly pick predominative weed
		if(14 to 15)
			src.myseed = new /obj/item/seeds/nettleseed
		if(12 to 13)
			src.myseed = new /obj/item/seeds/harebell
		if(10 to 11)
			src.myseed = new /obj/item/seeds/amanitamycelium
		if(6 to 9)
			src.myseed = new /obj/item/seeds/chantermycelium
		//if(6 to 7) implementation for tower caps still kinda missing
		//	src.myseed = new /obj/item/seeds/towermycelium
		if(4 to 5)
			src.myseed = new /obj/item/seeds/plumpmycelium
		else
			src.myseed = new /obj/item/seeds/weeds
	src.planted = 1
	src.age = 0
	src.health = src.myseed.endurance
	src.lastcycle = world.time
	src.harvest = 0
	src.weedlevel = 0 // Reset
	src.pestlevel = 0 // Reset
	spawn(5) // Wait a while
	src.updateicon()
	src.visible_message("\red[src] has been overtaken by \blue [src.myseed.plantname]!")

	return


obj/machinery/hydroponics/proc/mutate() // Mutates the current seed

	src.myseed.lifespan += rand(-2,2)
	if(src.myseed.lifespan < 10)
		src.myseed.lifespan = 10
	else if(src.myseed.lifespan > 30)
		src.myseed.lifespan = 30

	src.myseed.endurance += rand(-5,5)
	if(src.myseed.endurance < 10)
		src.myseed.endurance = 10
	else if(src.myseed.endurance > 100)
		src.myseed.endurance = 100

	src.myseed.production += rand(-1,1)
	if(src.myseed.production < 2)
		src.myseed.production = 2
	else if(src.myseed.production > 10)
		src.myseed.production = 10

	if(src.myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		src.myseed.yield += rand(-2,2)
		if(src.myseed.yield < 0)
			src.myseed.yield = 0
		else if(src.myseed.yield > 10)
			src.myseed.yield = 10
		if(src.myseed.yield == 0 && src.myseed.plant_type == 2)
			src.myseed.yield = 1 // Mushrooms always have a minimum yield of 1.

	if(src.myseed.potency != -1) //Not all plants have a potency
		src.myseed.potency += rand(-10,10)
		if(src.myseed.potency < 0)
			src.myseed.potency = 0
		else if(src.myseed.potency > 100)
			src.myseed.potency = 100
	return



obj/machinery/hydroponics/proc/hardmutate() // Strongly mutates the current seed.

	src.myseed.lifespan += rand(-4,4)
	if(src.myseed.lifespan < 10)
		src.myseed.lifespan = 10
	else if(src.myseed.lifespan > 30)
		src.myseed.lifespan = 30

	src.myseed.endurance += rand(-10,10)
	if(src.myseed.endurance < 10)
		src.myseed.endurance = 10
	else if(src.myseed.endurance > 100)
		src.myseed.endurance = 100

	src.myseed.production += rand(-2,2)
	if(src.myseed.production < 2)
		src.myseed.production = 2
	else if(src.myseed.production > 10)
		src.myseed.production = 10

	if(src.myseed.yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		src.myseed.yield += rand(-4,4)
		if(src.myseed.yield < 0)
			src.myseed.yield = 0
		else if(src.myseed.yield > 10)
			src.myseed.yield = 10
		if(src.myseed.yield == 0 && src.myseed.plant_type == 2)
			src.myseed.yield = 1 // Mushrooms always have a minimum yield of 1.

	if(src.myseed.potency != -1) //Not all plants have a potency
		src.myseed.potency += rand(-20,20)
		if(src.myseed.potency < 0)
			src.myseed.potency = 0
		else if(src.myseed.potency > 100)
			src.myseed.potency = 100
	return



obj/machinery/hydroponics/proc/mutatespecie() // Mutagent produced a new plant!

	if ( istype(src.myseed, /obj/item/seeds/nettleseed ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/deathnettleseed

	else if ( istype(src.myseed, /obj/item/seeds/amanitamycelium ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/angelmycelium

	else if ( istype(src.myseed, /obj/item/seeds/chiliseed ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/icepepperseed

	else if ( istype(src.myseed, /obj/item/seeds/eggplantseed ))
		del(src.myseed)
		src.myseed = new /obj/item/seeds/eggyseed

	else
		return

	src.dead = 0
	src.hardmutate()
	src.planted = 1
	src.age = 0
	src.health = src.myseed.endurance
	src.lastcycle = world.time
	src.harvest = 0
	src.weedlevel = 0 // Reset

	spawn(5) // Wait a while
	src.updateicon()
	src.visible_message("\red[src] has suddenly mutated into \blue [src.myseed.plantname]!")

	return



obj/machinery/hydroponics/proc/mutateweed() // If the weeds gets the mutagent instead. Mind you, this pretty much destroys the old plant
	if ( src.weedlevel > 5 )
		del(src.myseed)
		switch(rand(100))
			if(1 to 33)		src.myseed = new /obj/item/seeds/libertymycelium
			if(34 to 66)	src.myseed = new /obj/item/seeds/angelmycelium
			else			src.myseed = new /obj/item/seeds/deathnettleseed
		src.dead = 0
		src.hardmutate()
		src.planted = 1
		src.age = 0
		src.health = src.myseed.endurance
		src.lastcycle = world.time
		src.harvest = 0
		src.weedlevel = 0 // Reset

		spawn(5) // Wait a while
		src.updateicon()
		src.visible_message("\red The mutated weeds in [src] spawned a \blue [src.myseed.plantname]!")
	return



obj/machinery/hydroponics/proc/plantdies() // OH NOES!!!!! I put this all in one function to make things easier
	src.health = 0
	src.dead = 1
	src.harvest = 0
	src.updateicon()
	src.visible_message("\red[src] is looking very unhealthy!")
	return



obj/machinery/hydroponics/proc/mutatepest()  // Until someone makes a spaceworm, this is commented out
//	if ( src.pestlevel > 5 )
//  	user << "The worms seem to behave oddly..."
//		spawn(10)
//		new /obj/alien/spaceworm(src.loc)
//	else
	//user << "Nothing happens..."
	return



obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)

	//Called when mob user "attacks" it with object O
	if (istype(O, /obj/item/weapon/reagent_containers/glass/bucket))
		var/b_amount = O.reagents.get_reagent_amount("water")
		if(b_amount > 0 && src.waterlevel < 100)
			if(b_amount + src.waterlevel > 100)
				b_amount = 100 - src.waterlevel
			O.reagents.remove_reagent("water", b_amount)
			src.waterlevel += b_amount
			playsound(src.loc, 'slosh.ogg', 25, 1)
			user << "You fill the tray with [b_amount] units of water."

	//		Toxicity dilutation code. The more water you put in, the lesser the toxin concentration.
			src.toxic -= round(b_amount/4)
			if (src.toxic < 0 ) // Make sure it won't go overoboard
				src.toxic = 0

		else if(src.waterlevel >= 100)
			user << "\red The hydroponics tray is already full."
		else
			user << "\red The bucket is not filled with water."
		src.updateicon()

	else if ( istype(O, /obj/item/nutrient) )
		var/obj/item/nutrient/myNut = O
		user.u_equip(O)
		src.nutrilevel = 10
		src.yieldmod = myNut.yieldmod
		src.mutmod = myNut.mutmod
		user << "You replace the nutrient solution in the tray"
		del(O)
		src.updateicon()



	else if ( istype(O, /obj/item/weapon/reagent_containers/syringe))  // Syringe stuff
		var/obj/item/weapon/reagent_containers/syringe/S = O
		if (src.planted)
			if (S.mode == 1)
				user << "\red You inject the [src.myseed.plantname] with a chemical solution."

				// There needs to be a good amount of mutagen to actually work

				if(S.reagents.has_reagent("mutagen", 5))
					switch(rand(100))
						if (91  to 100)	src.plantdies()
						if (81  to 90)  src.mutatespecie()
						if (66	to 80)	src.hardmutate()
						if (41  to 65)  src.mutate()
						if (21  to 41)  user << "Nothing happens..."
						if (11	to 20)  src.mutateweed()
						if (1   to 10)  src.mutatepest()
						else 			user << "Nothing happens..."

				// Antitoxin binds shit pretty well. So the tox goes significantly down

				if(S.reagents.has_reagent("anti_toxin", 1))
					src.toxic -= round(S.reagents.get_reagent_amount("anti_toxin")*2)

				// NIGGA, YOU JUST WENT ON FULL RETARD.

				if(S.reagents.has_reagent("toxin", 1))
					src.toxic += round(S.reagents.get_reagent_amount("toxin")*2)

				// Milk is good for humans, but bad for plants. The sugars canot be used by ploants, and the milk fat fuck up growth. Not shrooms though. I can't deal with this now...
				if(S.reagents.has_reagent("milk", 1))
					src.nutrilevel += round(S.reagents.get_reagent_amount("milk")*0.1)
					src.waterlevel += round(S.reagents.get_reagent_amount("milk")*0.9)

				// Beer is a chemical composition of alcohol and various other things. It's a shitty nutrient but hey, it's still one. Also alcohol is bad, mmmkay?

				if(S.reagents.has_reagent("beer", 1))
					src.health -= round(S.reagents.get_reagent_amount("beer")*0.05)
					src.nutrilevel += round(S.reagents.get_reagent_amount("beer")*0.25)
					src.waterlevel += round(S.reagents.get_reagent_amount("beer")*0.7)

				// You're an idiot of thinking that one of the most corrosive and deadly gasses would be beneficial

				if(S.reagents.has_reagent("fluorine", 1))
					src.health -= round(S.reagents.get_reagent_amount("fluorine")*2)
					src.toxic += round(S.reagents.get_reagent_amount("flourine")*2.5)
					src.waterlevel -= round(S.reagents.get_reagent_amount("flourine")*0.5)
					src.weedlevel -= rand(1,4)

				// You're an idiot of thinking that one of the most corrosive and deadly gasses would be beneficial

				if(S.reagents.has_reagent("chlorine", 1))
					src.health -= round(S.reagents.get_reagent_amount("chlorine")*1)
					src.toxic += round(S.reagents.get_reagent_amount("chlorine")*1.5)
					src.waterlevel -= round(S.reagents.get_reagent_amount("chlorine")*0.5)
					src.weedlevel -= rand(1,3)

				// White Phosphorous + water -> phosphoric acid. That's not a good thing really. Phosphoric salts are beneficial though. And even if the plan suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.

				if(S.reagents.has_reagent("phosphorus", 1))
					src.health -= round(S.reagents.get_reagent_amount("phosphorus")*0.75)
					src.nutrilevel += round(S.reagents.get_reagent_amount("phosphorus")*0.1)
					src.waterlevel -= round(S.reagents.get_reagent_amount("phosphorus")*0.5)
					src.weedlevel -= rand(1,2)

				// Plants should not have sugar, they can't use it and it prevents them getting water/ nutients, it is good for mold though...

				if(S.reagents.has_reagent("sugar", 1))
					src.weedlevel += rand(1,2)
					src.pestlevel += rand(1,2)
					src.nutrilevel+= round(S.reagents.get_reagent_amount("sugar")*0.1)

				// It is water!
				if(S.reagents.has_reagent("water", 1))
					src.waterlevel += round(S.reagents.get_reagent_amount("water")*1)

				// A variety of nutrients are dissolved in club soda, without sugar. These nutrients include carbon, oxygen, hydrogen, phosphorous, potassium, sulfur and sodium, all of which are needed for healthy plant growth.
				if(S.reagents.has_reagent("sodawater", 1))
					src.waterlevel += round(S.reagents.get_reagent_amount("sodawater")*1)
					src.health += round(S.reagents.get_reagent_amount("sodawater")*0.1)
					src.nutrilevel += round(S.reagents.get_reagent_amount("sodawater")*0.1)

				// Man, you guys are retards

				if(S.reagents.has_reagent("acid", 1))
					src.health -= round(S.reagents.get_reagent_amount("acid")*1)
					src.toxic += round(S.reagents.get_reagent_amount("acid")*1.5)
					src.weedlevel -= rand(1,2)

				// SERIOUSLY

				if(S.reagents.has_reagent("pacid", 1))
					src.health -= round(S.reagents.get_reagent_amount("pacid")*2)
					src.toxic += round(S.reagents.get_reagent_amount("pacid")*3)
					src.weedlevel -= rand(1,4)

				// Plant-B-Gone is just as bad

				if(S.reagents.has_reagent("plantbgone", 1))
					src.health -= round(S.reagents.get_reagent_amount("plantbgone")*2)
					src.toxic -= round(S.reagents.get_reagent_amount("plantbgone")*3)
					src.weedlevel -= rand(4,8)

				// Healing

				if(S.reagents.has_reagent("cryoxadone", 1))
					src.health += round(S.reagents.get_reagent_amount("cryoxadone")*3)
					src.toxic -= round(S.reagents.get_reagent_amount("cryoxadone")*3)

				// FINALLY IMPLEMENTED, Ammonia is bad ass.

				if(S.reagents.has_reagent("ammonia", 1))
					src.health += round(S.reagents.get_reagent_amount("ammonia")*0.5)
					src.nutrilevel += round(S.reagents.get_reagent_amount("ammonia")*1)

				// FINALLY IMPLEMENTED, This is more bad ass, and pest get hurt by the crossive nature of it, not the plant

				if(S.reagents.has_reagent("diethylamine", 1))
					src.health += round(S.reagents.get_reagent_amount("diethylamine")*1)
					src.nutrilevel += round(S.reagents.get_reagent_amount("diethylamine")*2)
					src.pestlevel -= rand(1,2)

				// Compost, effectively

				if(S.reagents.has_reagent("nutriment", 1))
					src.health += round(S.reagents.get_reagent_amount("nutriment")*0.5)
					src.nutrilevel += round(S.reagents.get_reagent_amount("nutriment")*1)

				// Poor man's mutagen.

				if(S.reagents.has_reagent("radium", 1))
					src.health -= round(S.reagents.get_reagent_amount("radium")*1.5)
					src.toxic += round(S.reagents.get_reagent_amount("radium")*2)
				if(S.reagents.has_reagent("radium", 10))
					switch(rand(100))
						if (91  to 100)	src.plantdies()
						if (81  to 90)  src.mutatespecie()
						if (66	to 80)	src.hardmutate()
						if (41  to 65)  src.mutate()
						if (21  to 41)  user << "Nothing happens..."
						if (11	to 20)  src.mutateweed()
						if (1   to 10)  src.mutatepest()
						else 			user << "Nothing happens..."

				S.reagents.clear_reagents()
				if (src.weedlevel < 0 ) // Make sure it won't go overoboard
					src.weedlevel = 0
				if (src.health < 0 ) // Make sure it won't go overoboard
					src.health = 0
				if (src.waterlevel > 100 )	// Make sure it won't go overoboard
					src.waterlevel = 100
				if (src.waterlevel < 0 )	// Make sure it won't go overoboard
					src.waterlevel = 0
				if (src.toxic < 0 ) // Make sure it won't go overoboard
					src.toxic = 0
				if (src.toxic > 100 ) // Make sure it won't go overoboard
					src.toxic = 100
			else
				user << "You can't get any extract out of this plant."
		else
			user << "There's nothing to apply the solution into."

	else if ( istype(O, /obj/item/seeds/) )
		if(!src.planted)
			user.u_equip(O)
			user << "You plant the [O.name]"
			src.dead = 0
			src.myseed = O
			src.planted = 1
			src.age = 1
			src.health = src.myseed.endurance
			src.lastcycle = world.time
			O.loc = src
			if((user.client  && user.s_active != src))
				user.client.screen -= O
			O.dropped(user)
			src.updateicon()

		else
			user << "\red The tray already has a seed in it!"

	else if (istype(O, /obj/item/device/analyzer/plant_analyzer))
		if(src.planted && src.myseed)
			user << "*** <B>[src.myseed.name]</B> ***"
			user << "-Plant Age: \blue [src.age]"
			user << "-Plant Endurance: \blue [src.myseed.endurance]"
			user << "-Plant Lifespan: \blue [src.myseed.lifespan]"
			if(src.myseed.yield != -1)
				user << "-Plant Yield: \blue [src.myseed.yield]"
			user << "-Plant Production: \blue [src.myseed.production]"
			if(src.myseed.potency != -1)
				user << "-Plant Potency: \blue [src.myseed.potency]"
			user << "-Weed level: \blue [src.weedlevel]/10"
			user << "-Pest level: \blue [src.pestlevel]/10"
			user << "-Toxicity level: \blue [src.toxic]/100"
			user << "-Water level: \blue [src.waterlevel]/100"
			user << "-Nutrition level: \blue [src.nutrilevel]/100"
			user << ""
		else
			user << "<B>No plant found.</B>"
			user << "-Weed level: \blue [src.weedlevel]/10"
			user << "-Pest level: \blue [src.pestlevel]/10"
			user << "-Toxicity level: \blue [src.toxic]/100"
			user << "-Water level: \blue [src.waterlevel]/100"
			user << "-Nutrition level: \blue [src.nutrilevel]/100"
			user << ""

	else if (istype(O, /obj/item/weapon/plantbgone))
		if(src.planted && src.myseed)
			src.health -= rand(5,20)

			if(src.pestlevel > 0)
				src.pestlevel -= 2 // Kill kill kill
			else
				src.pestlevel = 0

			if(src.weedlevel > 0)
				src.weedlevel -= 3 // Kill kill kill
			else
				src.weedlevel = 0
			src.toxic += 4 // Oops
			src.visible_message("\red <B>\The [src] has been sprayed with \the [O][(user ? " by [user]." : ".")]")
			playsound(src.loc, 'spray3.ogg', 50, 1, -6)

	else if (istype(O, /obj/item/weapon/minihoe))  // The minihoe
		//var/deweeding
		if(src.weedlevel > 0)
			user.visible_message("\red [user] starts uprooting the weeds.", "\red You start removing some weeds from the tray.")
			sleep(10)
			if(src.weedlevel > 1)
				src.weedlevel -= rand(1,2) // Kill kill kill
			else
				src.weedlevel = 0
			user << "Success!"
		else
			user << "\red This plot is completely devoid of weeds. It doesn't need uprooting."

/*				Commented out due to being redundant -Darem
	else if ( istype(O, /obj/item/weapon/weedspray) )
		var/obj/item/weedkiller/myWKiller = O
		user.u_equip(O)
		src.toxic += myWKiller.toxicity
		src.weedlevel -= myWKiller.WeedKillStr
		if (src.weedlevel < 0 ) // Make sure it won't go overoboard
			src.weedlevel = 0
		if (src.toxic > 100 ) // Make sure it won't go overoboard
			src.toxic = 100
		user << "You apply the weedkiller solution into the tray"
		playsound(src.loc, 'spray3.ogg', 50, 1, -6)
		del(O)
		src.updateicon()

	else if ( istype(O, /obj/item/weapon/pestspray) )
		var/obj/item/pestkiller/myPKiller = O
		user.u_equip(O)
		src.toxic += myPKiller.toxicity
		src.pestlevel -= myPKiller.PestKillStr
		if (src.pestlevel < 0 ) // Make sure it won't go overoboard
			src.pestlevel = 0
		if (src.toxic > 100 ) // Make sure it won't go overoboard
			src.toxic = 100
		user << "You apply the pestkiller solution into the tray"
		playsound(src.loc, 'spray3.ogg', 50, 1, -6)
		del(O)
		src.updateicon()
	return
*/


/obj/machinery/hydroponics/attack_hand(mob/user as mob)
	if(istype(usr,/mob/living/silicon))		//How does AI know what plant is?
		return
	if(src.harvest)
		if(!user in range(1,src))
			return
		myseed.harvest()
	else if(src.dead)
		src.planted = 0
		src.dead = 0
		usr << text("You remove the dead plant from the tray")
		del(src.myseed)
		src.updateicon()
	else
		if(src.planted && !src.dead)
			usr << text("The hydroponics tray has \blue [src.myseed.plantname] \black planted")
			if(src.health <= (src.myseed.endurance / 2))
				usr << text("The plant looks unhealthy")
		else
			usr << text("The hydroponics tray is empty")
		usr << text("Water: [src.waterlevel]/100")
		usr << text("Nutrient: [src.nutrilevel]/10")
		if(src.weedlevel >= 5) // Visual aid for those blind
			usr << text("The tray is filled with weeds!")
		if(src.pestlevel >= 5) // Visual aid for those blind
			usr << text("The tray is filled with tiny worms!")
		usr << text ("") // Empty line for readability.

/obj/item/seeds/proc/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new produce(user.loc, potency) // User gets a consumable

		t_prod.seed = mypath
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

/obj/item/seeds/nettleseed/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new produce(user.loc, potency) // User gets a consumable
		t_prod.seed = mypath
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

/obj/item/seeds/deathnettleseed/harvest(mob/user = usr) //isn't a nettle subclass yet, so
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new produce(user.loc, potency) // User gets a consumable
		t_prod.seed = mypath
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

/obj/item/seeds/eggyseed/harvest(mob/user = usr)
	var/produce = text2path(productname)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0

	while ( t_amount < (yield * parent.yieldmod ))
		new produce(user.loc)
		t_amount++

	parent.update_tray()

/obj/item/seeds/replicapod/harvest(mob/user = usr) //now that one is fun -- Urist
	var/obj/machinery/hydroponics/parent = loc

	if(ckey) //if there's human data stored in it, make a human
		var/mob/ghost = find_dead_player("[ckey]")

		var/mob/living/carbon/human/podman = new /mob/living/carbon/human(parent.loc)
		if(ghost)
			ghost.client.mob = podman

		if (realName)
			podman.real_name = realName
		else
			podman.real_name = "pod person"  //No null names!!

		if(mind && istype(mind,/datum/mind)) //let's try that
			mind:transfer_to(podman)
			mind:original = podman
		else //welp
			podman.mind = new /datum/mind(  )
			podman.mind.key = podman.key
			podman.mind.current = podman
			podman.mind.original = podman
			podman.mind.transfer_to(podman)
			ticker.minds += podman.mind

			// -- Mode/mind specific stuff goes here
		switch(ticker.mode.name)
			if ("revolution")
				if (podman.mind in ticker.mode:revolutionaries)
					ticker.mode:add_revolutionary(podman.mind)
					ticker.mode:update_all_rev_icons() //So the icon actually appears
				if (podman.mind in ticker.mode:head_revolutionaries)
					ticker.mode:update_all_rev_icons()
			if ("cult")
				if (podman.mind in ticker.mode:cult)
					ticker.mode:add_cultist(podman.mind)
					ticker.mode:update_all_cult_icons() //So the icon actually appears
			if ("changeling")
				if (podman.mind in ticker.mode:changelings)
					podman.make_changeling()

			// -- End mode specific stuff

		if(ghost)
			if (istype(ghost, /mob/dead/observer))
				del(ghost) //Don't leave ghosts everywhere!!

		podman.gender = gender

		if (!podman.dna)
			podman.dna = new /datum/dna(  )
		if (ui)
			podman.dna.uni_identity = ui
			updateappearance(podman, ui)
		if (se)
			podman.dna.struc_enzymes = se
		podman:update_face()
		podman:update_body()

		if(!prob(potency)) //if it fails, plantman!
			podman.mutantrace = "plant"

	else //else, one packet of seeds. ONE.
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

		user << "You inject the contents of the syringe into the seeds."

		for(var/datum/reagent/blood/bloodSample in W:reagents.reagent_list)
			var/mob/living/carbon/human/source = bloodSample.data["donor"] //hacky, since it gets the CURRENT condition of the mob, not how it was when the blood sample was taken

			//ui = bloodSample.data["blood_dna"] doesn't work for whatever reason
			ui = source.dna.uni_identity
			se = source.dna.struc_enzymes
			ckey = source.ckey
			realName = source.real_name
			gender = source.gender

			if (!isnull(source.mind))
				mind = source.mind

		W:reagents.clear_reagents()
	else
		return ..()

/obj/machinery/hydroponics/proc/update_tray(mob/user = usr)
	harvest = 0
	lastproduce = src.age
	if((yieldmod * myseed.yield) <= 0)
		user << text("\red You fail to harvest anything useful")
	else
		user << text("You harvest from the [src.myseed.plantname]")
	if(myseed.oneharvest)
		planted = 0
		dead = 0
	updateicon()

/*
else if (href_list["clone"])
		var/datum/data/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		var/mob/selected = find_dead_player("[C.fields["ckey"]]")

//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
		if ((!selected) || (!src.pod1) || (src.pod1.occupant) || (src.pod1.mess))
			src.temp = "Unable to initiate cloning cycle." // most helpful error message in THE HISTORY OF THE WORLD
		else if (src.pod1.growclone(selected, C.fields["name"], C.fields["UI"], C.fields["SE"], C.fields["mind"], C.fields["mrace"]))
			src.temp = "Cloning cycle activated."
			src.records.Remove(C)
			del(C)
			src.menu = 1

----

subject.dna.check_integrity()

	var/datum/data/record/R = new /datum/data/record(  )
	R.fields["mrace"] = subject.mutantrace
	R.fields["ckey"] = subject.ckey
	R.fields["name"] = subject.real_name
	R.fields["id"] = copytext(md5(subject.real_name), 2, 6)
	R.fields["UI"] = subject.dna.uni_identity
	R.fields["SE"] = subject.dna.struc_enzymes

	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp =locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implanted = subject
		R.fields["imp"] = "\ref[imp]"
	//Update it if needed
	else
		R.fields["imp"] = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = "\ref[subject.mind]"

	src.records += R
	src.temp = "Subject successfully scanned."

----

/obj/machinery/clonepod/proc/growclone(mob/ghost as mob, var/clonename, var/ui, var/se, var/mindref, var/mrace)
	if (((!ghost) || (!ghost.client)) || src.mess || src.attempting)
		return 0

	src.attempting = 1 //One at a time!!
	src.locked = 1

	src.eject_wait = 1
	spawn(30)
		src.eject_wait = 0

	src.occupant = new /mob/living/carbon/human(src)
	ghost.client.mob = src.occupant

	src.icon_state = "pod_1"
	//Get the clone body ready
	src.occupant.rejuv = 10
	src.occupant.cloneloss += 190 //new damage var so you can't eject a clone early then stab them to abuse the current damage system --NeoFite
	src.occupant.brainloss += 90
	src.occupant.paralysis += 4

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	src.occupant.health = (src.occupant.bruteloss + src.occupant.toxloss + src.occupant.oxyloss + src.occupant.cloneloss)

	src.occupant << "\blue <b>Clone generation process initiated.</b>"
	src.occupant << "\blue This will take a moment, please hold."

	if (clonename)
		src.occupant.real_name = clonename
	else
		src.occupant.real_name = "clone"  //No null names!!


	var/datum/mind/clonemind = (locate(mindref) in ticker.minds)

	if ((clonemind) && (istype(clonemind))) //Move that mind over!!
		clonemind.transfer_to(src.occupant)
		clonemind.original = src.occupant
	else //welp
		src.occupant.mind = new /datum/mind(  )
		src.occupant.mind.key = src.occupant.key
		src.occupant.mind.current = src.occupant
		src.occupant.mind.original = src.occupant
		src.occupant.mind.transfer_to(src.occupant)
		ticker.minds += src.occupant.mind

	// -- Mode/mind specific stuff goes here
	switch(ticker.mode.name)
		if ("revolution")
			if (src.occupant.mind in ticker.mode:revolutionaries)
				ticker.mode:add_revolutionary(src.occupant.mind)
				ticker.mode:update_all_rev_icons() //So the icon actually appears
			if (src.occupant.mind in ticker.mode:head_revolutionaries)
				ticker.mode:update_all_rev_icons()
		if ("cult")
			if (src.occupant.mind in ticker.mode:cult)
				ticker.mode:add_cultist(src.occupant.mind)
				ticker.mode:update_all_cult_icons() //So the icon actually appears
		if ("changeling")
			if (src.occupant.mind in ticker.mode:changelings)
				src.occupant.make_changeling()

	// -- End mode specific stuff

	if (istype(ghost, /mob/dead/observer))
		del(ghost) //Don't leave ghosts everywhere!!

	if (!src.occupant.dna)
		src.occupant.dna = new /datum/dna(  )
	if (ui)
		src.occupant.dna.uni_identity = ui
		updateappearance(src.occupant, ui)
	if (se)
		src.occupant.dna.struc_enzymes = se
		randmutb(src.occupant) //Sometimes the clones come out wrong.
	src.occupant:update_face()
	src.occupant:update_body()
	src.occupant:mutantrace = mrace
	src.attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()

	if (stat & NOPOWER) //Autoeject if power is lost
		if (src.occupant)
			src.locked = 0
			src.go_out()
		return

	if ((src.occupant) && (src.occupant.loc == src))
		if((src.occupant.stat == 2) || (src.occupant.suiciding))  //Autoeject corpses and suiciding dudes.
			src.locked = 0
			src.go_out()
			src.connected_message("Clone Rejected: Deceased.")
			return

		else if(src.occupant.health < src.heal_level)
			src.occupant.paralysis = 4

			 //Slowly get that clone healed and finished.
			src.occupant.cloneloss = max(src.occupant.cloneloss-1, 0)

			//Premature clones may have brain damage.
			src.occupant.brainloss = max(src.occupant.brainloss-1, 0)

			//So clones don't die of oxyloss in a running pod.
			if (src.occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				src.occupant.reagents.add_reagent("inaprovaline", 60)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			src.occupant.oxyloss = max(src.occupant.oxyloss-2, 0)

			use_power(7500) //This might need tweaking.
			return

		else if((src.occupant.health >= src.heal_level) && (!src.eject_wait))
			src.connected_message("Cloning Process Complete.")
			src.locked = 0
			src.go_out()
			return

	else if ((!src.occupant) || (src.occupant.loc != src))
		src.occupant = null
		if (src.locked)
			src.locked = 0
		if (!src.mess)
			icon_state = "pod_0"
		use_power(200)
		return

	return

	-----

	Blood.data["donor"] = reference to human

	---

	else if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = W

		user << "You inject the solution into the power cell."

		if(S.reagents.has_reagent("plasma", 5))

			rigged = 1

		S.reagents.clear_reagents()
*/
/obj/machinery/hydroponics
	name = "Hydroponics Tray"
	icon = 'hydroponics.dmi'
	icon_state = "hydrotray"
	density = 1
	anchored = 1
	var/waterlevel = 100 // The amount of water in the tray (max 100)
	var/nutrilevel = 10 // The amount of nutrient in the tray (max 10)
	var/yieldmod = 1 //Modifier to yield
	var/mutmod = 1 //Modifier to mutation chance
	var/age = 0 // Current age
	var/dead = 0 // Is it dead?
	var/health = 0 // It's health.
	var/lastproduce = 0 // Last time it was harvested
	var/lastcycle = 0 //Used for timing of cycles.
	var/cycledelay = 200 // About 10 seconds / cycle
	var/planted = 0 // Is it occupied?
	var/harvest = 0; //Ready to harvest?
	var/obj/item/seeds/myseed = null // The currently planted seed

obj/machinery/hydroponics/process()

	if(world.time > (src.lastcycle + src.cycledelay))
		src.lastcycle = world.time
		if(src.planted & !src.dead)
			src.age++
			src.waterlevel -= rand(1,6)
			if(src.nutrilevel > 0)
				src.nutrilevel -= 1
			if(src.waterlevel < 0)
				src.waterlevel = 0
			if(src.waterlevel <= 0)
				src.health -= 3
			else if(src.waterlevel <= 5)
				src.health -= 1
			if(src.waterlevel > 10 & src.nutrilevel > 0)
				src.health += 1
			if(src.health > src.myseed.endurance)
				src.health = src.myseed.endurance
			if(src.age > src.myseed.lifespan)
				src.health -= 5
			if(src.health <= 0)
				src.dead = 1
				src.harvest = 0
			if(src.age > src.myseed.production && (src.age - src.lastproduce) > src.myseed.production && (!src.harvest && !src.dead))
				var/m_count = 0
				while(m_count < src.mutmod)
					src.mutate()
					m_count++;
				if(src.yieldmod > 0)
					src.harvest = 1
				else
					src.lastproduce = src.age
		src.updateicon()
	return

obj/machinery/hydroponics/proc/updateicon()
	//Refreshes the icon
	overlays = null
	if(src.planted)
		if(dead)
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-dead")
		else if(src.harvest)
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-harvest")
		else if(src.age < src.myseed.maturation)
			var/t_growthstate = ((src.age / src.myseed.maturation) * 6)
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow[round(t_growthstate)]")
			src.lastproduce = src.age //Cheating by putting this here, it means that it isn't instantly ready to harvest
		else
			overlays += image('hydroponics.dmi', icon_state="[src.myseed.species]-grow6")

		if(src.waterlevel <= 10)
			overlays += image('hydroponics.dmi', icon_state="over_lowwater")
		if(src.nutrilevel <= 2)
			overlays += image('hydroponics.dmi', icon_state="over_lownutri")
		if(src.health <= (src.myseed.endurance / 2))
			overlays += image('hydroponics.dmi', icon_state="over_lowhealth")
		if(src.harvest)
			overlays += image('hydroponics.dmi', icon_state="over_harvest")
	return

obj/machinery/hydroponics/proc/mutate() // Mutates the current seed

	src.myseed.lifespan += rand(-2,2)
	if(src.myseed.lifespan < 10)
		src.myseed.lifespan = 10
	if(src.myseed.lifespan > 30)
		src.myseed.lifespan = 30

	src.myseed.endurance += rand(-5,5)
	if(src.myseed.endurance < 10)
		src.myseed.endurance = 10
	if(src.myseed.endurance > 100)
		src.myseed.endurance = 100

	src.myseed.production += rand(-1,1)
	if(src.myseed.production < 2)
		src.myseed.production = 2
	if(src.myseed.production > 10)
		src.myseed.production = 10

	src.myseed.yield += rand(-2,2)
	if(src.myseed.yield < 0)
		src.myseed.yield = 0
	if(src.myseed.yield > 10)
		src.myseed.yield = 10

	if(src.myseed.potency != -1) //Not all plants have a potency
		src.myseed.potency += rand(-10,10)
		if(src.myseed.potency < 0)
			src.myseed.potency = 0
		if(src.myseed.potency > 100)
			src.myseed.potency = 100

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
		else if(src.waterlevel >= 100)
			user << "\red The hydroponics tray is already full."
		else
			user << "\red The bucket is not filled with water."
		src.updateicon()
	else if ( istype(O, /obj/item/nutrient/) )
		var/obj/item/nutrient/myNut = O
		user.u_equip(O)
		src.nutrilevel = 10
		src.yieldmod = myNut.yieldmod
		src.mutmod = myNut.mutmod
		user << "You replace the nutrient solution in the tray"
		del(O)
		src.updateicon()
	else if (istype(O, /obj/item/seeds/))
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
			user << "<B>[src.myseed.name]</B>"
			user << "-<B>Plant Age:</B> [src.age]"
			user << "--<B>Plant Endurance:</B> [src.myseed.endurance]"
			user << "--<B>Plant Lifespan:</B> [src.myseed.lifespan]"
			user << "--<B>Plant Yield:</B> [src.myseed.yield]"
			user << "--<B>Plant Production:</B> [src.myseed.production]"
			if(src.myseed.potency != -1)
				user << "--<B>Plant Potency:</B> [src.myseed.potency]"
		else
			user << "<B>No plant found.</B>"

	return

/obj/machinery/hydroponics/attack_hand(mob/user as mob)
	if(src.harvest)
		if(!user in range(1,src))
			return
		var/item = text2path(src.myseed.productname)
		var/t_amount = 0

		while ( t_amount < (src.myseed.yield * src.yieldmod ))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/t_prod = new item(user.loc)
			t_prod.seed = src.myseed.mypath
			t_prod.species = src.myseed.species
			t_prod.lifespan = src.myseed.lifespan
			t_prod.endurance = src.myseed.endurance
			t_prod.maturation = src.myseed.maturation
			t_prod.production = src.myseed.production
			t_prod.yield = src.myseed.yield
			t_prod.potency = src.myseed.potency
			t_amount++
		src.harvest = 0
		src.lastproduce = src.age
		if((src.yieldmod * src.myseed.yield) <= 0)
			usr << text("\red You fail to harvest anything useful")
		else
			usr << text("You harvest from the [src.myseed.plantname]")
			if(src.myseed.oneharvest)
				src.planted = 0
				src.dead = 0
		src.updateicon()
	else if(src.dead)
		src.planted = 0
		src.dead = 0
		usr << text("You remove the dead plant from the tray")
		del(src.myseed)
		src.updateicon()
	else
		if(src.planted && !src.dead)
			usr << text("The hydroponics tray has a [src.myseed.plantname] planted")
			if(src.health <= (src.myseed.endurance / 2))
				usr << text("The plant looks unhealthy")
		else
			usr << text("The hydroponics tray is empty")
		usr << text("Water: [src.waterlevel]/100")
		usr << text("Nutrient: [src.nutrilevel]/10")

/obj/item/device/analyzer/plant_analyzer
	name = "Plant Analyzer"
	icon_state = "hydro"

	attack_self(mob/user as mob)
		return 0

/datum/vinetracker
	var/list/vines = list()

	proc/process()
		set background = 1
		while(vines.len > 0)
			for(var/obj/plant/vine/V in vines)
				sleep(-1)
				switch(V.stage)
					if(1)
						for(var/turf/T in orange(1, V))
							var/plantfound = 0
							if(istype(T, /turf/space)) // Vines don't grow in space
								break
							for(var/obj/O in T)		   // Vines don't grow on other plants, either
								if(istype(O, /obj/plant))
									plantfound = 1
									break
							if(plantfound)
								continue
							var/chance = rand(1,100)
							if(chance < 50)
								spawn() new /obj/plant/vine(T)
								continue
						V.health += 5
						if(V.health >= 30)
							V.stage = 2
							V.icon_state = "spacevine2"
							V.density = 1
					else if(2)
						/*
						for(var/turf/T in orange(1, V))
							var/plantfound = 0
							if(istype(T, /turf/space))
								break
							for(var/obj/O in T)
								if(istype(O, /obj/plant))
									plantfound = 1
									break
							if(plantfound)
								continue
							if(prob(15))
								spawn() new /obj/plant/vine(T)
						*/
						V.health += 5
						if(V.health >= 40)
							V.stage = 3
							V.icon_state = "spacevine3"
					else if(3)
						V.health += 10
						if(V.health >= 60)
							V.stage = 4
							V.icon_state = "spacevine4"
					else if(4)
						V.health += 20
						spawn(3000) del(V)
			sleep(600)



obj/plant
	anchored = 1
	var
		stage = 1
		health = 10

obj/plant/vine
	name = "space vine"
	icon = 'hydroponics.dmi'
	icon_state = "spacevine1"
	anchored = 1
	health = 20
	var
		datum/vinetracker/tracker

	New()
		..()
		for(var/datum/vinetracker/V in world)
			if(V)
				tracker = V
				V.vines.Add(src)
				return
		var/datum/vinetracker/V = new /datum/vinetracker
		tracker = V
		V.vines.Add(src)
		spawn () V.process()

	attackby(var/obj/item/weapon/W, var/mob/user)
		if(health <= 0)
			del(src)
			return
		src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = W.force * 2

		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W

			if(WT.welding)
				damage = 15
				playsound(src.loc, 'Welder.ogg', 100, 1)

		src.health -= damage

/obj/plant/vine/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 350)
		health -= 15
		if(health <= 0)
			del(src)
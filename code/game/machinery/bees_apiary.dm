//http://www.youtube.com/watch?v=-1GadTfGFvU
//i could have done these as just an ordinary plant, but fuck it - there would have been too much snowflake code

/obj/machinery/apiary
	name = "apiary tray"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	var/nutrilevel = 0
	var/yieldmod = 1
	var/mut = 1
	var/toxic = 0
	var/dead = 0
	var/health = -1
	var/maxhealth = 100
	var/lastcycle = 0
	var/cycledelay = 100
	var/harvestable_honey = 0
	var/beezeez = 0
	var/swarming = 0

	var/bees_in_hive = 0
	var/list/owned_bee_swarms = list()
	var/hydrotray_type = /obj/machinery/hydroponics

//overwrite this after it's created if the apiary needs a custom machinery sprite
/obj/machinery/apiary/New()
	..()
	overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="apiary")

/obj/machinery/apiary/bullet_act(var/obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		mut++
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		if(!yieldmod)
			yieldmod += 1
			//world << "Yield increased by 1, from 0, to a total of [myseed.yield]"
		else if (prob(1/(yieldmod * yieldmod) *100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			yieldmod += 1
			//world << "Yield increased by 1, to a total of [myseed.yield]"
	else
		..()
		return

/obj/machinery/apiary/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/queen_bee))
		if(health > 0)
			user << "\red There is already a queen in there."
		else
			health = 10
			nutrilevel += 10
			user.drop_item()
			del(O)
			user << "\blue You carefully insert the queen into [src], she gets busy making a hive."
			bees_in_hive = 0
	else if(istype(O, /obj/item/beezeez))
		beezeez += 100
		nutrilevel += 10
		user.drop_item()
		if(health > 0)
			user << "\blue You insert [O] into [src]. A relaxed humming appears to pick up."
		else
			user << "\blue You insert [O] into [src]. Now it just needs some bees."
		del(O)
	else if(istype(O, /obj/item/weapon/minihoe))
		if(health > 0)
			user << "\red <b>You begin to dislodge the apiary from the tray, the bees don't like that.</b>"
			angry_swarm(user)
		else
			user << "\blue You begin to dislodge the dead apiary from the tray."
		if(do_after(user, 50))
			new hydrotray_type(src.loc)
			new /obj/item/apiary(src.loc)
			user << "\red You dislodge the apiary from the tray."
			del(src)
	else if(istype(O, /obj/item/weapon/bee_net))
		var/obj/item/weapon/bee_net/N = O
		if(N.caught_bees > 0)
			user << "\blue You empty the bees into the apiary."
			bees_in_hive += N.caught_bees
			N.caught_bees = 0
		else
			user << "\blue There are no more bees in the net."
	else if(istype(O, /obj/item/weapon/reagent_containers/glass))
		var/obj/item/weapon/reagent_containers/glass/G = O
		if(harvestable_honey > 0)
			if(health > 0)
				user << "\red You begin to harvest the honey. The bees don't seem to like it."
				angry_swarm(user)
			else
				user << "\blue You begin to harvest the honey."
			if(do_after(user,50))
				G.reagents.add_reagent("honey",harvestable_honey)
				harvestable_honey = 0
				user << "\blue You successfully harvest the honey."
		else
			user << "\blue There is no honey left to harvest."
	else
		angry_swarm(user)
		..()

/obj/machinery/apiary/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/apiary/process()

	if(swarming > 0)
		swarming -= 1
		if(swarming <= 0)
			for(var/mob/living/simple_animal/bee/B in src.loc)
				bees_in_hive += B.strength
				del(B)
	else if(bees_in_hive < 10)
		for(var/mob/living/simple_animal/bee/B in src.loc)
			bees_in_hive += B.strength
			del(B)

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(health < 0)
			return

		//magical bee formula
		if(beezeez > 0)
			beezeez -= 1

			nutrilevel += 2
			health += 1
			toxic = max(0, toxic - 1)

		//handle nutrients
		nutrilevel -= bees_in_hive / 10 + owned_bee_swarms.len / 5
		if(nutrilevel > 0)
			bees_in_hive += 1 * yieldmod
			if(health < maxhealth)
				health++
		else
			//nutrilevel is less than 1, so we're effectively subtracting here
			health += max(nutrilevel - 1, round(-health / 2))
			bees_in_hive += max(nutrilevel - 1, round(-bees_in_hive / 2))
			if(owned_bee_swarms.len)
				var/mob/living/simple_animal/bee/B = pick(owned_bee_swarms)
				B.target_turf = get_turf(src)

		//clear out some toxins
		if(toxic > 0)
			toxic -= 1
			health -= 1

		if(health <= 0)
			return

		//make a bit of honey
		if(harvestable_honey < 50)
			harvestable_honey += 0.5

		//make some new bees
		if(bees_in_hive >= 10 && prob(bees_in_hive * 10))
			var/mob/living/simple_animal/bee/B = new(get_turf(src), src)
			owned_bee_swarms.Add(B)
			B.mut = mut
			B.toxic = toxic
			bees_in_hive -= 1

		//find some plants, harvest
		for(var/obj/machinery/hydroponics/H in view(7, src))
			if(H.planted && !H.dead && H.myseed && prob(owned_bee_swarms.len * 10))
				src.nutrilevel++
				H.nutrilevel++
				if(mut < H.mutmod - 1)
					mut = H.mutmod - 1
				else if(mut > H.mutmod - 1)
					H.mutmod = mut

				//flowers give us pollen (nutrients)
/* - All plants should be giving nutrients to the hive.
				if(H.myseed.type == /obj/item/seeds/harebell || H.myseed.type == /obj/item/seeds/sunflowerseed)
					src.nutrilevel++
					H.nutrilevel++
*/
				//have a few beneficial effects on nearby plants
				if(prob(10))
					H.lastcycle -= 5
				if(prob(10))
					H.myseed.lifespan = max(initial(H.myseed.lifespan) * 1.5, H.myseed.lifespan + 1)
				if(prob(10))
					H.myseed.endurance = max(initial(H.myseed.endurance) * 1.5, H.myseed.endurance + 1)
				if(H.toxic && prob(10))
					H.toxic = min(0, H.toxic - 1)
					toxic++

/obj/machinery/apiary/proc/die()
	if(owned_bee_swarms.len)
		var/mob/living/simple_animal/bee/B = pick(owned_bee_swarms)
		B.target_turf = get_turf(src)
		B.strength -= 1
		if(B.strength <= 0)
			del(B)
		else if(B.strength <= 5)
			B.icon_state = "bees[B.strength]"
	bees_in_hive = 0
	health = 0

/obj/machinery/apiary/proc/angry_swarm(var/mob/M)
	for(var/mob/living/simple_animal/bee/B in owned_bee_swarms)
		B.feral = 25
		B.target_mob = M

	swarming = 25

	while(bees_in_hive > 0)
		var/spawn_strength = bees_in_hive
		if(bees_in_hive >= 5)
			spawn_strength = 6

		var/mob/living/simple_animal/bee/B = new(get_turf(src), src)
		B.target_mob = M
		B.strength = spawn_strength
		B.feral = 25
		B.mut = mut
		B.toxic = toxic
		bees_in_hive -= spawn_strength

/obj/machinery/apiary/verb/harvest_honeycomb()
	set src in oview(1)
	set name = "Harvest honeycomb"
	set category = "Object"

	while(health > 15)
		health -= 15
		var/obj/item/weapon/reagent_containers/food/snacks/honeycomb/H = new(src.loc)
		if(toxic > 0)
			H.reagents.add_reagent("toxin", toxic)

	usr << "\blue You harvest the honeycomb from the hive. There is a wild buzzing!"
	angry_swarm(usr)

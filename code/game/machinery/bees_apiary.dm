//http://www.youtube.com/watch?v=-1GadTfGFvU
//i could have done these as just an ordinary plant, but fuck it - there would have been too much snowflake code

#define HONEYCOMB_COST 15

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
	var/beezeez = 0
	var/swarming = 0
	var/honey_level = 0

	var/bees_in_hive = 0
	var/list/owned_bee_swarms = list()
	var/hydrotray_type = /obj/machinery/portable_atmospherics/hydroponics

	machine_flags = FIXED2WORK | WRENCHMOVE

//overwrite this after it's created if the apiary needs a custom machinery sprite
/obj/machinery/apiary/New()
	..()
	overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="apiary0")

/obj/machinery/apiary/examine(mob/user)
	..()
	if(health > 0)
		to_chat(user, "You can hear a loud buzzing coming from the inside.")
	else
		to_chat(user, "There doesn't seem to be any bees in it.")

	switch(honey_level)
		if(1)
			to_chat(user, "<span class='info'>Looks like there's a bit of honey in it.</span>")
		if(2)
			to_chat(user, "<span class='info'>There's a decent amount of honey dripping from it!</span>")
		if(3)
			to_chat(user, "<span class='info'>It's full of honey!</span>")

/obj/machinery/apiary/bullet_act(var/obj/item/projectile/Proj) //Works with the Somatoray to modify plant variables.
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		mut++
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		if(!yieldmod)
			yieldmod += 1
//			to_chat(world, "Yield increased by 1, from 0, to a total of [myseed.yield]")
		else if (prob(1/(yieldmod * yieldmod) *100))//This formula gives you diminishing returns based on yield. 100% with 1 yield, decreasing to 25%, 11%, 6, 4, 2...
			yieldmod += 1
//			to_chat(world, "Yield increased by 1, to a total of [myseed.yield]")
	else
		..()
		if(src)
			angry_swarm()
		return

/obj/machinery/apiary/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(..())
		return
	if(istype(O, /obj/item/queen_bee))
		if(health > 0)
			to_chat(user, "<span class='warning'>There is already a queen in there.</span>")
		else
			health = 10
			nutrilevel = min(10,nutrilevel+10)
			user.drop_item(O)
			qdel(O)
			to_chat(user, "<span class='notice'>You carefully insert the queen into [src], she gets busy making a hive.</span>")
			bees_in_hive = 0
	else if(istype(O, /obj/item/beezeez))
		beezeez += 100
		nutrilevel += 10
		user.drop_item(O)
		if(health > 0)
			to_chat(user, "<span class='notice'>You insert [O] into [src]. A relaxed humming appears to pick up.</span>")
		else
			to_chat(user, "<span class='notice'>You insert [O] into [src]. Now it just needs some bees.</span>")
		qdel(O)
	else if(istype(O, /obj/item/weapon/hatchet))
		if(health > 0)
			user.visible_message("<span class='danger'>\the [user] begins harvesting the honeycombs, the bees don't like that.</span>","<span class='danger'>You begin harvesting the honeycombs, the bees don't like that.</span>")
			angry_swarm(user)
		else
			to_chat(user, "<span class='notice'>You begin to dislodge the dead apiary from the tray.</span>")
		if(do_after(user, src, 50))
			var/obj/machinery/created_tray = new hydrotray_type(src.loc)
			created_tray.component_parts = list()
			for(var/obj/I in src.component_parts)
				created_tray.component_parts += I
				I.loc = created_tray
				component_parts -= I
			for(var/obj/I in src.contents)
				I.loc = created_tray
				contents -= I
			new /obj/item/apiary(src.loc)
			if(health > 0)
				while(health > HONEYCOMB_COST)
					health -= HONEYCOMB_COST
					var/obj/item/weapon/reagent_containers/food/snacks/honeycomb/H = new(src.loc)
					if(toxic > 0)
						H.reagents.add_reagent("toxin", toxic)
				if(honey_level >= 3)
					new/obj/item/queen_bee(src.loc)
				to_chat(user, "<span class='notice'>You successfully harvest the honeycombs. The empty apiary can be relocated.</span>")
			else
				to_chat(user, "<span class='notice'>You dislodge the apiary from the tray.</span>")
			qdel(src)
	else if(istype(O, /obj/item/weapon/bee_net))
		var/obj/item/weapon/bee_net/N = O
		if(N.caught_bees > 0)
			to_chat(user, "<span class='notice'>You empty the bees into the apiary.</span>")
			bees_in_hive += N.caught_bees
			N.caught_bees = 0
		else
			to_chat(user, "<span class='notice'>There are no more bees in the net.</span>")
	else
		user.visible_message("<span class='warning'>\the [user] hits \the [src] with \the [O]!</span>","<span class='warning'>You hit \the [src] with \the [O]!</span>")
		angry_swarm(user)

/obj/machinery/apiary/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
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
				returnToPool(B)
	else if(bees_in_hive < 10)
		for(var/mob/living/simple_animal/bee/B in src.loc)
			bees_in_hive += B.strength
			returnToPool(B)

	if(world.time > (lastcycle + cycledelay))
		lastcycle = world.time
		if(health < 0)
			return

		//magical bee formula
		if(beezeez > 0)
			beezeez -= 1

			nutrilevel += 2
			health = min(health+1,maxhealth)
			if(prob(10))
				toxic = max(0, toxic - 1)

		//handle nutrients
		nutrilevel -= bees_in_hive / 10 + owned_bee_swarms.len / 5
		if(nutrilevel > 0)
			bees_in_hive += 1 * yieldmod
			health = min(health+1,maxhealth)
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

		var/newlevel = 0
		if(health >= (HONEYCOMB_COST * 6))
			newlevel = 3
		else if(health >= (HONEYCOMB_COST * 3))
			newlevel = 2
		else if(health >= HONEYCOMB_COST)
			newlevel = 1
		else
			newlevel = 0

		if(newlevel != honey_level)
			overlays -= image('icons/obj/apiary_bees_etc.dmi', icon_state="apiary[honey_level]")
			overlays += image('icons/obj/apiary_bees_etc.dmi', icon_state="apiary[newlevel]")
			honey_level = newlevel

		if(health <= 0)
			return

		if(prob(2))
			playsound(get_turf(src), 'sound/effects/bees.ogg', min(20+(20*honey_level),100), 1)

		//make some new bees
		if(bees_in_hive >= 10 && prob(bees_in_hive * 10))
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/bee/B = getFromPool(/mob/living/simple_animal/bee, T, src)
			owned_bee_swarms.Add(B)
			B.mut = mut
			B.toxic = toxic
			bees_in_hive -= 1

		//find some plants, harvest
		for(var/obj/machinery/portable_atmospherics/hydroponics/H in view(7, src))
			if(H.seed && !H.dead && prob(owned_bee_swarms.len * 10))
				src.nutrilevel++
				if(H.nutrilevel < 10)
					H.nutrilevel++

				if(mut < H.mutation_mod - 1)
					mut = H.mutation_mod - 1
				else if(mut > H.mutation_mod - 1)
					H.mutation_mod = mut

				//flowers give us pollen (nutrients)
/* - All plants should be giving nutrients to the hive.
				if(H.myseed.type == /obj/item/seeds/harebell || H.myseed.type == /obj/item/seeds/sunflowerseed)
					src.nutrilevel++
					H.nutrilevel++
*/
				//have a few beneficial effects on nearby plants
/* - beneficial effects are now applied directly by bees themselves
				if(prob(10))
					H.lastcycle -= 5
				if(prob(10))
					if(!isnull(seed_types[H.seed.name]))
						H.seed = H.seed.diverge(-1)
					if(H.seed) H.seed.lifespan = max(initial(H.seed.lifespan) * 1.5, H.seed.lifespan + 1)
				if(prob(10))
					if(!isnull(seed_types[H.seed.name]))
						H.seed = H.seed.diverge(-1)
					if(H.seed) H.seed.endurance = max(initial(H.seed.endurance) * 1.5, H.seed.endurance + 1)
				if(H.toxins && prob(10))
					H.toxins = min(0, H.toxins - 1)
					toxic++
*/

/obj/machinery/apiary/proc/die()
	if(owned_bee_swarms.len)
		var/mob/living/simple_animal/bee/B = pick(owned_bee_swarms)
		B.target_turf = get_turf(src)
		B.strength -= 1
		if(B.strength <= 0)
			returnToPool(B)
		else if(B.strength <= 5)
			B.icon_state = "bees[B.strength]"
	bees_in_hive = 0
	health = 0

/obj/machinery/apiary/proc/angry_swarm(var/mob/M = null)
	for(var/mob/living/simple_animal/bee/B in owned_bee_swarms)
		B.feral = 25
		B.target = M

	swarming = 25

	while(bees_in_hive >= 1)
		var/spawn_strength = round(bees_in_hive)
		if(bees_in_hive >= 5)
			spawn_strength = 6
		var/turf/T = get_turf(src)
		var/mob/living/simple_animal/bee/B = getFromPool(/mob/living/simple_animal/bee, T, src)
		B.target = M
		B.strength = spawn_strength
		B.feral = 25
		B.mut = mut
		B.toxic = toxic
		bees_in_hive -= spawn_strength

#undef HONEYCOMB_COST

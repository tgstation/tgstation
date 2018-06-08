//separate dm since hydro is getting bloated already

/obj/structure/glowshroom
	name = "glowshroom"
	desc = "Mycena Bregprox, a species of mushroom that glows in the dark."
	anchored = TRUE
	opacity = 0
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroom" //replaced in New
	layer = ABOVE_NORMAL_TURF_LAYER
	max_integrity = 30
	var/delay = 1200
	var/floor = 0
	var/generation = 1
	var/spreadIntoAdjacentChance = 60
	var/obj/item/seeds/myseed = /obj/item/seeds/glowshroom
	var/static/list/blacklisted_glowshroom_turfs = typecacheof(list(
	/turf/open/lava,
	/turf/open/floor/plating/beach/water))

/obj/structure/glowshroom/glowcap
	name = "glowcap"
	desc = "Mycena Ruthenia, a species of mushroom that, while it does glow in the dark, is not actually bioluminescent."
	icon_state = "glowcap"
	myseed = /obj/item/seeds/glowshroom/glowcap

/obj/structure/glowshroom/shadowshroom
	name = "shadowshroom"
	desc = "Mycena Umbra, a species of mushroom that emits shadow instead of light."
	icon_state = "shadowshroom"
	myseed = /obj/item/seeds/glowshroom/shadowshroom

/obj/structure/glowshroom/single/Spread()
	return

/obj/structure/glowshroom/examine(mob/user)
	. = ..()
	to_chat(user, "This is a [generation]\th generation [name]!")

/obj/structure/glowshroom/Destroy()
	if(myseed)
		QDEL_NULL(myseed)
	return ..()

/obj/structure/glowshroom/New(loc, obj/item/seeds/newseed, mutate_stats)
	..()
	if(newseed)
		myseed = newseed.Copy()
		myseed.forceMove(src)
	else
		myseed = new myseed(src)
	if(mutate_stats) //baby mushrooms have different stats :3
		myseed.adjust_potency(rand(-3,6))
		myseed.adjust_yield(rand(-1,2))
		myseed.adjust_production(rand(-3,6))
		myseed.adjust_endurance(rand(-3,6))
	delay = delay - myseed.production * 100 //So the delay goes DOWN with better stats instead of up. :I
	obj_integrity = myseed.endurance
	max_integrity = myseed.endurance
	var/datum/plant_gene/trait/glow/G = myseed.get_gene(/datum/plant_gene/trait/glow)
	if(ispath(G)) // Seeds were ported to initialize so their genes are still typepaths here, luckily their initializer is smart enough to handle us doing this
		myseed.genes -= G
		G = new G
		myseed.genes += G
	set_light(G.glow_range(myseed), G.glow_power(myseed), G.glow_color)
	addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/proc/Spread()
	var/turf/ownturf = get_turf(src)
	var/shrooms_planted = 0
	for(var/i in 1 to myseed.yield)
		if(prob(1/(generation * generation) * 100))//This formula gives you diminishing returns based on generation. 100% with 1st gen, decreasing to 25%, 11%, 6, 4, 2...
			if(prob(spreadIntoAdjacentChance))
				var/list/possibleLocs = list()
				for(var/turf/T in ownturf.GetAtmosAdjacentTurfs())
					if(is_type_in_typecache(T, blacklisted_glowshroom_turfs))
						continue
					if(!locate(/obj/structure/glowshroom) in T)
						possibleLocs += earth
					CHECK_TICK

				if(!possibleLocs.len)
					break
				var/turf/newLoc = pick(possibleLocs)
				var/obj/structure/glowshroom/child = new type(newLoc, myseed, TRUE)
				child.generation = generation + 1
				shrooms_planted++
		CHECK_TICK
	if(shrooms_planted < myseed.yield) //if we didn't get all possible shrooms planted, try again later
		myseed.yield -= shrooms_planted
		addtimer(CALLBACK(src, .proc/Spread), delay)

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/glowshroom/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/glowshroom/acid_act(acidpwr, acid_volume)
	. = 1
	visible_message("<span class='danger'>[src] melts away!</span>")
	var/obj/effect/decal/cleanable/molten_object/I = new (get_turf(src))
	I.desc = "Looks like this was \an [src] some time ago."
	qdel(src)

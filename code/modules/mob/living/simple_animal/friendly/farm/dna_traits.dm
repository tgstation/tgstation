/datum/farm_animal_trait
	var/name = "Pornhub"
	var/description = "Sponsored By Brazzers"
	var/datum/farm_animal_trait/opposite_trait = null
	var/datum/farm_animal_dna/owner = null
	var/manifest_probability = 0
	var/continue_probability = 0
	var/random_blacklist = 0

/datum/farm_animal_trait/proc/on_apply(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_life(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_priority_life(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_breed(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_create_young(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_death(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_remove(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	return



/datum/farm_animal_trait/pigish
	name = "Pigish"
	description = "This animal will eat more than its fair share of food."
	manifest_probability = 35
	continue_probability = 55

/datum/farm_animal_trait/pigish/on_apply(var/mob/living/simple_animal/farm/M)
	M.amount_eaten_herbivore++
	M.amount_eaten_carnivore++
	return

/datum/farm_animal_trait/thirsty
	name = "Thirsty"
	description = "This animal will drink more water than it needs."
	opposite_trait = /datum/farm_animal_trait/hydrated
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/thirsty/on_apply(var/mob/living/simple_animal/farm/M)
	M.amount_drank += 10
	return

/datum/farm_animal_trait/hydrated
	name = "Hydrated"
	description = "This animal will drink less water than it needs."
	opposite_trait = /datum/farm_animal_trait/thirsty
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/hydrated/on_apply(var/mob/living/simple_animal/farm/M)
	M.amount_drank -= 5
	return

/datum/farm_animal_trait/talkative
	name = "Talkative"
	description = "This animal will attempt to talk more often and mimic what others say."
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/talkative/on_apply(var/mob/living/simple_animal/farm/M)
	M.speak_chance = 15
	return

/datum/farm_animal_trait/talkative/on_hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(speaker != owner.owner && prob(40)) //Dont imitate ourselves
		if(owner.owner.speak.len >= 40)
			owner.owner.speak -= pick(owner.owner.speak)
		owner.owner.speak |= html_decode(raw_message)
	..()

/datum/farm_animal_trait/herbivore
	name = "Herbivore"
	description = "This animal will eat from troughs for food."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
	var/walking_to_trough = FALSE
	var/eating_from_trough = FALSE

/datum/farm_animal_trait/herbivore/on_priority_life(var/mob/living/simple_animal/farm/M)
	if(walking_to_trough || eating_from_trough)
		return
	var/getting_water = 0
	var/getting_food = 0
	if(M.thirst <= M.thirst_threshold_thirsty)
		getting_water = 1
	if(M.hunger <= M.hunger_threshold_hungry)
		getting_food = 1
	if(getting_water || getting_food)
		var/list/usable_troughs = list()
		for(var/obj/machinery/trough/T in orange(M,7))
			if(T.feed.len <= 0 && getting_food)
				continue
			if(T.reagents.total_volume <= 0 && getting_water)
				continue
			usable_troughs += T
		var/obj/machinery/trough/picked_trough = get_closest_atom(/obj/machinery/trough, usable_troughs, M)
		walking_to_trough = TRUE
		walk_to(M, picked_trough, 1)
		spawn(30)
			if(M.Adjacent(picked_trough) && (getting_water || getting_food))
				walking_to_trough = FALSE
				eating_from_trough = TRUE
				walk(M,0)
				if(getting_food && picked_trough.feed.len >= M.amount_eaten_herbivore)
					for(var/i in 1 to M.amount_eaten_herbivore)
						var/obj/item/weapon/reagent_containers/food/snacks/S = pick_n_take(picked_trough.feed)
						if(S)
							M.hunger += S.reagents.total_volume * 2
							S.reagents.trans_to(M, S.reagents.total_volume)
							M.visible_message("[M] chews on [S].")
							qdel(S)
					if(M.hunger > M.hunger_max)
						M.hunger = M.hunger_max
				if(getting_water && picked_trough.reagents.total_volume >= M.amount_drank)
					M.thirst += M.amount_drank * 2
					picked_trough.reagents.trans_to(M, M.amount_drank)
					M.visible_message("[M] drinks from [picked_trough].")
					if(M.thirst > M.thirst_max)
						M.thirst = M.thirst_max
				eating_from_trough = FALSE
			else
				return

/proc/get_low_or_high_farm_animal_strength(list, setting = 0)
	if(setting)
		var/strongest_animal
		var/most_strength
		for(var/mob/living/simple_animal/farm/animal_picked in list)
			if(!istype(animal_picked))
				continue
			var/strength = animal_picked.dna.strength
			if(!most_strength)
				most_strength = strength
				strongest_animal = animal_picked
			else
				if(most_strength <= strength)
					most_strength = strength
					strongest_animal = animal_picked
		return strongest_animal
	else
		var/weakest_animal
		var/least_strength
		for(var/mob/living/simple_animal/farm/animal_picked in list)
			if(!istype(animal_picked))
				continue
			var/strength = animal_picked.dna.strength
			if(!least_strength)
				least_strength = strength
				weakest_animal = animal_picked
			else
				if(least_strength >= strength)
					least_strength = strength
					weakest_animal = animal_picked
		return weakest_animal

/datum/farm_animal_trait/carnivore
	name = "Carnivore"
	description = "This animal will eat living things for food."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
	var/walking_to_trough = FALSE
	var/drinking_from_trough = FALSE
	var/attacking_animal = FALSE
	var/eating_animal = FALSE
	var/target


/datum/farm_animal_trait/carnivore/on_apply(var/mob/living/simple_animal/farm/M)
	M.a_intent = "harm"
	return

/datum/farm_animal_trait/carnivore/on_priority_life(var/mob/living/simple_animal/farm/M)
	if(drinking_from_trough)
		return
	var/getting_water = 0
	var/getting_food = 0
	if(M.thirst_threshold_thirsty >= M.thirst)
		getting_water = 1
		world << "THIRSTY"
	if(M.hunger_threshold_hungry >= M.hunger)
		getting_food = 1
	if(getting_water)
		var/list/usable_troughs = list()
		for(var/obj/machinery/trough/T in orange(M,7))
			if(T.reagents.total_volume <= 0 && getting_water)
				continue
			world << "ADDED [T] TO TROUGHS"
			usable_troughs += T
		var/obj/machinery/trough/picked_trough = get_closest_atom(/obj/machinery/trough, usable_troughs, M)
		walking_to_trough = TRUE
		walk_to(M, picked_trough, 1)
		world << "WALKING TO TROUGHS"
		spawn(30)
			if(M.Adjacent(picked_trough) && getting_water)
				world << "ARRIVED AT TROUGH"
				walking_to_trough = FALSE
				drinking_from_trough = TRUE
				walk(M,0)
				if(getting_water && picked_trough.reagents.total_volume >= M.amount_drank)
					M.thirst += M.amount_drank * 2
					picked_trough.reagents.trans_to(M, M.amount_drank)
					M.visible_message("[M] drinks from [picked_trough].")
					if(M.thirst > M.thirst_max)
						M.thirst = M.thirst_max
				drinking_from_trough = FALSE
	if(getting_food && !walking_to_trough && !drinking_from_trough)
		world << "GETTING FOOD"
		var/list/orange_grab = orange(M,7)
		var/list/potential_prey = list()
		var/list/farm_animal_prey = list()
		var/list/preferred_farm_animal_prey = list()
		var/list/corpses = list()
		var/list/meat = list()
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in orange_grab)
			if(is_type_in_list(S, types_of_meat))
				world << "ADDED [S] TO MEAT"
				meat += S
		for(var/mob/living/C in orange_grab)
			if(istype(C, /mob/living/silicon))
				continue
			if(C.stat == DEAD)
				world << "ADDED [C] TO CORPSE"
				corpses += C
				continue
			potential_prey += C
		for(var/mob/living/C in potential_prey)
			if(istype(C, /mob/living/simple_animal/farm))
				if(!istype(C, M.type))
					world << "ADDED [C] TO PREFERRED PREY"
					preferred_farm_animal_prey += C
					continue
				world << "ADDED [C] TO FARM ANIMAL PREY"
				farm_animal_prey += C
		attacking_animal = TRUE
		if(meat.len)
			target = get_closest_atom(/obj/item/weapon/reagent_containers/food/snacks, meat, M)
			world << "TARGET IS [target] MEAT"
		else if(corpses.len)
			target = get_closest_atom(/mob/living, corpses, M)
			world << "TARGET IS [target] CORPSE"
		else if(preferred_farm_animal_prey.len)
			target = get_low_or_high_farm_animal_strength(preferred_farm_animal_prey, 0)
			world << "TARGET IS [target] PREFERRED PREY"
		else if(potential_prey.len)
			target = get_closest_atom(/mob/living, potential_prey, M)
			world << "TARGET IS [target] PREY"
		else if(farm_animal_prey.len)
			target = get_low_or_high_farm_animal_strength(farm_animal_prey, 0)
			world << "TARGET IS [target] FARM PREY"
		else
			world << "NO TARGET"
			attacking_animal = FALSE
			return
		if(target)
			world << "TARGET FOUND"
			if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
				world << "TARGET IS MEAT"
				var/obj/item/weapon/reagent_containers/food/snacks/S = target
				if(S && !M.Adjacent(target))
					world << "WALKING TO TARGET(MEAT"
					walk_to(M, S, 1)
					spawn(30)
						if(S && M.Adjacent(S))
							world << "ADJACENT TO TARGET, EATING IT(MEAT"
							eating_animal = FALSE
							attacking_animal = FALSE
							M.do_attack_animation(S)
							M.visible_message("[M] consumes [S].")
							M.hunger += S.reagents.total_volume * 3
							S.reagents.trans_to(M, S.reagents.total_volume)
							if(M.hunger > M.hunger_max)
								M.hunger = M.hunger_max
							qdel(S)
				else
					if(S && M.Adjacent(S))
						world << "ALREADY ADJACENT, EATING"
						eating_animal = FALSE
						attacking_animal = FALSE
						M.do_attack_animation(S)
						M.visible_message("[M] consumes [S].")
						M.hunger += S.reagents.total_volume
						S.reagents.trans_to(M, S.reagents.total_volume)
						if(M.hunger > M.hunger_max)
							M.hunger = M.hunger_max
			else if(istype(target, /mob/living))
				world << "TARGET IS MOB"
				var/mob/living/T = target
				if(T && !M.Adjacent(T))
					world << "TARGET IS MOB, NOT ADJACENT, WALKING TO"
					walk_to(M, T, 1)
					spawn(30)
						if(T && M.Adjacent(T))
							world << "MOB, ADJACENT, EATING"
							if(T.stat != DEAD)
								world << "MOB NOT DEAD, FIGHTING"
								T.attack_animal(M)
								M.do_attack_animation(T)
							else
								world << "MOB DEAD, EATING"
								eating_animal = TRUE
								attacking_animal = FALSE
								M.visible_message("[M] takes a bite out of [T].")
								T.times_eaten_from++
								M.hunger += 25
								if(T.times_eaten_from >= M.amount_eaten_carnivore)
									T.gib()
									T = null
									M.visible_message("[M] finishes eating [T].")
				else
					if(T && T.stat != DEAD)
						world << "MOB NOT DEAD, FIGHTING"
						T.attack_animal(M)
						M.do_attack_animation(T)
					else if(T && T.stat == DEAD)
						world << "MOB DEAD, EATING"
						eating_animal = TRUE
						attacking_animal = FALSE
						M.visible_message("[M] takes a bite out of [T].")
						T.times_eaten_from++
						M.hunger += 25
						if(T.times_eaten_from >= M.amount_eaten_carnivore)
							T.gib()
							T = null
							M.visible_message("[M] finishes eating [T].")
	attacking_animal = FALSE
	eating_animal = FALSE
	return

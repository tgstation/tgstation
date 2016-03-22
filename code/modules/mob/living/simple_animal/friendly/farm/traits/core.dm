/datum/farm_animal_trait/herbivore
	name = "Herbivore"
	description = "This animal will eat from troughs for food."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
	var/walking_to_trough = FALSE
	var/eating_from_trough = FALSE

/datum/farm_animal_trait/herbivore/on_priority_life(var/mob/living/simple_animal/farm/M)
	if(M.stat)
		return
	if(walking_to_trough || eating_from_trough)
		if(M.hunger >= M.hunger_threshold_hungry && M.thirst >= M.thirst_threshold_thirsty)
			walking_to_trough = 0
			eating_from_trough = 0
		return
	var/getting_water = 0
	var/getting_food = 0
	if(M.thirst <= M.thirst_threshold_thirsty)
		getting_water = 1
	if(M.hunger <= M.hunger_threshold_hungry)
		getting_food = 1
	if(getting_water || getting_food)
		var/list/usable_troughs = list()
		for(var/obj/machinery/trough/T in oview(M,7))
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
							M.hunger += S.reagents.total_volume * 5
							S.reagents.trans_to(M, S.reagents.total_volume)
							M.visible_message("[M] chews on [S].")
							qdel(S)
					if(M.hunger > M.hunger_max)
						M.hunger = M.hunger_max
				if(getting_water && picked_trough.reagents.total_volume >= M.amount_drank)
					M.thirst += M.amount_drank * 5
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
	if(M.stat)
		return
	if(walking_to_trough || drinking_from_trough || attacking_animal || eating_animal)
		if(M.thirst >= M.thirst_threshold_thirsty)
			walking_to_trough = FALSE
			drinking_from_trough = FALSE
		if(M.hunger >= M.hunger_threshold_hungry)
			attacking_animal = FALSE
			eating_animal = FALSE
			target = null
	var/getting_water = 0
	var/getting_food = 0
	if(M.thirst_threshold_thirsty + 50 >= M.thirst)
		getting_water = 1
	if(M.hunger_threshold_hungry + 50 >= M.hunger)
		getting_food = 1
	if(getting_water)
		var/list/usable_troughs = list()
		for(var/obj/machinery/trough/T in oview(M,7))
			if(T.reagents.total_volume <= 0 && getting_water)
				continue
			usable_troughs += T
		var/obj/machinery/trough/picked_trough = get_closest_atom(/obj/machinery/trough, usable_troughs, M)
		walking_to_trough = TRUE
		walk_to(M, picked_trough, 1)
		spawn(30)
			if(M.Adjacent(picked_trough) && getting_water)
				walking_to_trough = FALSE
				drinking_from_trough = TRUE
				walk(M,0)
				if(getting_water && picked_trough.reagents.total_volume >= M.amount_drank)
					M.thirst += M.amount_drank * 5
					picked_trough.reagents.trans_to(M, M.amount_drank)
					M.visible_message("[M] drinks from [picked_trough].")
					if(M.thirst > M.thirst_max)
						M.thirst = M.thirst_max
				drinking_from_trough = FALSE
	if(getting_food && !walking_to_trough && !drinking_from_trough)
		var/list/orange_grab = oview(M,7)
		var/list/potential_prey = list()
		var/list/farm_animal_prey = list()
		var/list/preferred_farm_animal_prey = list()
		var/list/corpses = list()
		var/list/meat = list()
		for(var/obj/item/weapon/reagent_containers/food/snacks/S in orange_grab)
			if(is_type_in_list(S, types_of_meat))
				meat += S
		for(var/mob/living/C in orange_grab)
			if(istype(C, /mob/living/silicon))
				continue
			if(C.stat == DEAD)
				corpses += C
				continue
			potential_prey += C
		for(var/mob/living/C in potential_prey)
			if(istype(C, /mob/living/simple_animal/farm))
				if(!istype(C, M.type))
					preferred_farm_animal_prey += C
					continue
				farm_animal_prey += C
		attacking_animal = TRUE
		if(meat.len)
			target = get_closest_atom(/obj/item/weapon/reagent_containers/food/snacks, meat, M)
		else if(corpses.len)
			target = get_closest_atom(/mob/living, corpses, M)
		else if(preferred_farm_animal_prey.len)
			target = get_low_or_high_farm_animal_strength(preferred_farm_animal_prey, 0)
		else if(potential_prey.len)
			target = get_closest_atom(/mob/living, potential_prey, M)
		else if(farm_animal_prey.len)
			target = get_low_or_high_farm_animal_strength(farm_animal_prey, 0)
		else
			attacking_animal = FALSE
			return
		if(target)
			if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
				var/obj/item/weapon/reagent_containers/food/snacks/S = target
				if(S && !M.Adjacent(target))
					walk_to(M, S, 1)
					spawn(30)
						walk(M,0)
						if(S && M.Adjacent(S))
							eating_animal = FALSE
							attacking_animal = FALSE
							M.do_attack_animation(S)
							M.visible_message("[M] consumes [S].")
							M.hunger += S.reagents.total_volume * 5
							S.reagents.trans_to(M, S.reagents.total_volume)
							qdel(S)
							if(M.hunger > M.hunger_max)
								M.hunger = M.hunger_max
				else
					walk(M,0)
					if(S && M.Adjacent(S))
						eating_animal = FALSE
						attacking_animal = FALSE
						M.do_attack_animation(S)
						M.visible_message("[M] consumes [S].")
						M.hunger += S.reagents.total_volume * 5
						S.reagents.trans_to(M, S.reagents.total_volume)
						qdel(S)
						if(M.hunger > M.hunger_max)
							M.hunger = M.hunger_max
			else if(istype(target, /mob/living))
				var/mob/living/T = target
				if(T && !M.Adjacent(T))
					walk_to(M, T, 1)
					spawn(30)
						walk(M,0)
						if(T && M.Adjacent(T))
							if(T.stat != DEAD)
								T.attack_animal(M)
								M.do_attack_animation(T)
								for(var/datum/farm_animal_trait/TA in owner.traits)
									TA.on_attack_mob(M, T)
								return
							else
								eating_animal = TRUE
								attacking_animal = FALSE
								M.visible_message("[M] takes a bite out of [T].")
								T.times_eaten_from++
								M.hunger += 150
								if(T)
									if(T.times_eaten_from >= M.amount_eaten_carnivore)
										M.visible_message("[M] finishes eating [T].")
										T.gib()
										T = null
								return
				else
					walk(M,0)
					if(T && T.stat != DEAD)
						T.attack_animal(M)
						M.do_attack_animation(T)
						for(var/datum/farm_animal_trait/TA in owner.traits)
							TA.on_attack_mob(M, T)
					else if(T && T.stat == DEAD)
						eating_animal = TRUE
						attacking_animal = FALSE
						M.visible_message("[M] takes a bite out of [T].")
						T.times_eaten_from++
						M.hunger += 150
						if(T)
							if(T.times_eaten_from >= M.amount_eaten_carnivore)
								M.visible_message("[M] finishes eating [T].")
								T.gib()
								T = null
						return
	attacking_animal = FALSE
	eating_animal = FALSE
	return

/datum/farm_animal_trait/egg_layer
	name = "Egg Layer"
	description = "This animal will reproduce by breeding and then laying eggs."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
	var/breeding_timer = 0
	var/breed_max = 150
	var/is_breeding = 0
	var/is_laying_egg = 0
	var/mob/living/simple_animal/farm/mate
	var/obj/machinery/nest/nest

/datum/farm_animal_trait/egg_layer/on_apply(var/mob/living/simple_animal/farm/M)
	breed_max = rand(300,500)
	return

/datum/farm_animal_trait/egg_layer/on_priority_life(var/mob/living/simple_animal/farm/M)
	if(M.stat)
		return
	if(M.gender != FEMALE)
		return
	if(M.child) // no
		return // nee non nyet nien no nej never ever
	if(is_breeding || is_laying_egg)
		if(is_breeding)
			if(!mate)
				var/list/potential_mates = list()
				for(var/mob/living/simple_animal/farm/F in oview(M,7))
					if(F.child || F.stat)
						continue
					potential_mates += F
				if(potential_mates.len)
					mate = get_closest_atom(/mob/living/simple_animal/farm, potential_mates, M)
			else
				if(!M.Adjacent(mate))
					walk_to(M, mate, 1)
					sleep(30)
					if(mate && M.Adjacent(mate))
						M.visible_message("[M] and [mate] breed.")
						is_breeding = 0
						is_laying_egg = 1
						for(var/datum/farm_animal_trait/T in M.dna.traits)
							T.on_breed(M, mate)
						return
				else
					if(mate && M.Adjacent(mate))
						M.visible_message("[M] and [mate] breed.")
						is_breeding = 0
						is_laying_egg = 1
						for(var/datum/farm_animal_trait/T in M.dna.traits)
							T.on_breed(M, mate)
						return
	if(is_laying_egg)
		if(!nest)
			var/list/potential_nests = list()
			for(var/obj/machinery/nest/F in oview(M,7))
				potential_nests += F
			if(potential_nests.len)
				nest = get_closest_atom(/obj/machinery/nest, potential_nests, M)
		else
			if(M.loc != get_turf(nest))
				walk_to(M, nest, 1)
				sleep(30)
				if(nest && M.loc == get_turf(nest))
					M.visible_message("[M] lays an egg.")
					var/obj/item/weapon/reagent_containers/food/snacks/egg/E = new M.egg_type(M.loc)
					E.mother = M
					E.father = mate
					is_laying_egg = 0
					for(var/datum/farm_animal_trait/T in M.dna.traits)
						T.on_create_young(E, M)
					return
			else
				if(nest && M.loc == get_turf(nest))
					M.visible_message("[M] lays an egg.")
					var/obj/item/weapon/reagent_containers/food/snacks/egg/E = new M.egg_type(M.loc)
					E.mother = M
					E.father = mate
					is_laying_egg = 0
					for(var/datum/farm_animal_trait/T in M.dna.traits)
						T.on_create_young(E, M)
					return
	else
		breeding_timer++
		if(breeding_timer >= breed_max)
			is_breeding = 1
			breeding_timer = 0
	return

/datum/farm_animal_trait/mammal
	name = "Mammal"
	description = "This animal will reproduce by breeding and then giving birth to its young."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
	var/breeding_timer = 0
	var/breed_max = 150
	var/preg_timer = 0
	var/preg_max = 150
	var/is_breeding = 0
	var/is_preg = 0
	var/mob/living/simple_animal/farm/mate
	var/obj/machinery/nest/nest

/datum/farm_animal_trait/mammal/on_apply(var/mob/living/simple_animal/farm/M)
	breed_max = rand(300,500)
	return

/datum/farm_animal_trait/mammal/on_priority_life(var/mob/living/simple_animal/farm/M)
	if(M.stat)
		return
	if(M.gender != FEMALE)
		return
	if(M.child) // no
		return // nee non nyet nien no nej never ever
	if(is_breeding || is_preg)
		if(is_breeding)
			if(!mate)
				var/list/potential_mates = list()
				for(var/mob/living/simple_animal/farm/F in oview(M,7))
					if(F.child || F.stat)
						continue
					potential_mates += F
				if(potential_mates.len)
					mate = get_closest_atom(/mob/living/simple_animal/farm, potential_mates, M)
			else
				if(!M.Adjacent(mate))
					walk_to(M, mate, 1)
					sleep(30)
					if(mate && M.Adjacent(mate))
						M.visible_message("[M] and [mate] breed.")
						is_breeding = 0
						is_preg = 1
						return
				else
					if(mate && M.Adjacent(mate))
						M.visible_message("[M] and [mate] breed.")
						is_breeding = 0
						is_preg = 1
						return
		if(is_preg)
			if(!nest)
				var/list/potential_nests = list()
				for(var/obj/machinery/nest/F in oview(M,7))
					potential_nests += F
				if(potential_nests.len)
					nest = get_closest_atom(/obj/machinery/nest, potential_nests, M)
			else
				if(M.loc != get_turf(nest))
					walk_to(M, nest, 1)
				else
					preg_timer++
					if(preg_timer >= breed_max) // you know
						is_preg = 0 // this is probably going to attract some creepy people
						preg_timer = 0 // if people use this for erp
						M.visible_message("[M] gives birth.") // or if they jack off to it
						var/mob/living/simple_animal/farm/F = new M.mob_birth_type(M.loc) // you have permission to enact DEFCON 1 and arm the nukes
						F.dna = create_child_from_dna(M, mate, F) // i suggest application of CLF3 foam to all involved individuals and then a bullet through the skull to remove all memories
						for(var/datum/farm_animal_trait/T in M.dna.traits)// i pledge allegiance to the flag of the United States of America,
							T.on_create_young(E, M) // and to the republic for which it stands
						return // one nation under God, indivisible, with liberty and justice for all
	else
		breeding_timer++
		if(breeding_timer >= breed_max)
			is_breeding = 1
			breeding_timer = 0
	return


/datum/farm_animal_trait/defensive
	name = "Defensive"
	description = "This animal will defend itself if attacked, but will not seek out conflict unless it has to.."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
	var/target

/datum/farm_animal_trait/defensive/on_life(var/mob/living/simple_animal/farm/M)
	if(M.stat)
		return
	if(target)
		var/mob/living/T = target
		if(T && !M.Adjacent(T))
			walk_to(M, T, 1)
			spawn(30)
				if(T && M.Adjacent(T))
					walk_to(M,0)
					if(T.stat != DEAD)
						T.attack_animal(M)
						M.do_attack_animation(T)
						for(var/datum/farm_animal_trait/TA in owner.traits)
							TA.on_attack_mob(M, T)
						return
					else
						target = null
						return
		else
			if(T && M.Adjacent(T))
				walk_to(M,0)
				if(T.stat != DEAD)
					T.attack_animal(M)
					M.do_attack_animation(T)
					for(var/datum/farm_animal_trait/TA in owner.traits)
						TA.on_attack_mob(M, T)
					return
				else
					target = null
					return

/datum/farm_animal_trait/defensive/on_attacked(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	attack_retaliate(M, L)
	return

/datum/farm_animal_trait/defensive/on_attack_by(var/mob/living/simple_animal/farm/M, obj/item/O, mob/living/user, params)
	if(user.a_intent != "help" || O.force)
		attack_retaliate(M, user)
	return

/datum/farm_animal_trait/defensive/proc/attack_retaliate(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	if(L)
		target = L
	return

/datum/farm_animal_trait/coward
	name = "Coward"
	description = "This animal will not fight back when attacked."
	manifest_probability = 0
	continue_probability = 0
	random_blacklist = 1
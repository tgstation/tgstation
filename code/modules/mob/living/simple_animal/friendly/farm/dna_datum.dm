proc/create_child_from_dna(var/mob/living/simple_animal/farm/mother, var/mob/living/simple_animal/farm/father, var/mob/living/simple_animal/farm/self)
	var/datum/farm_animal_dna/mother_dna = mother.dna
	var/datum/farm_animal_dna/father_dna = father.dna
	var/datum/farm_animal_dna/child_dna = new
	child_dna.owner = self

	child_dna.strength = Mean(mother_dna.strength, father_dna.strength)
	child_dna.yield = Mean(mother_dna.yield, father_dna.yield)
	child_dna.health = Mean(mother_dna.endurance, father_dna.endurance)
	child_dna.endurance = Mean(mother_dna.endurance, father_dna.endurance)
	child_dna.fertility = Mean(mother_dna.fertility, father_dna.fertility)

	self.melee_damage_upper = child_dna.strength
	self.melee_damage_lower = child_dna.strength
	self.health *= child_dna.health
	self.maxHealth *= child_dna.health

	switch(prob(50))
		if(TRUE)
			for(var/datum/farm_animal_trait/T in mother_dna.traits)
				if(T.random_blacklist)
					continue
				if(prob(T.continue_probability))
					child_dna.add_trait(T)
				else
					continue
			for(var/datum/farm_animal_trait/T in father_dna.traits)
				if(T.random_blacklist)
					continue
				if(prob(T.continue_probability))
					child_dna.add_trait(T)
				else
					continue
		if(FALSE)
			for(var/datum/farm_animal_trait/T in father_dna.traits)
				if(T.random_blacklist)
					continue
				if(prob(T.continue_probability))
					child_dna.add_trait(T)
				else
					continue
			for(var/datum/farm_animal_trait/T in mother_dna.traits)
				if(T.random_blacklist)
					continue
				if(prob(T.continue_probability))
					child_dna.add_trait(T)
				else
					continue

	var/max_new_traits = rand(1,2)
	var/added_traits = 0
	var/list/potential_traits = subtypesof(/datum/farm_animal_trait) - /datum/farm_animal_trait
	for(var/TR in potential_traits)
		var/datum/farm_animal_trait/temp_TR = TR
		if(initial(temp_TR.random_blacklist))
			potential_traits -= temp_TR
	var/list/shuffled_traits = shuffle(potential_traits)

	for(var/T in shuffled_traits)
		if(added_traits >= max_new_traits)
			break
		added_traits++
		var/datum/farm_animal_trait/temp_T = T
		if(child_dna.has_trait(initial(temp_T)))
			continue
		if(initial(temp_T.opposite_trait))
			if(child_dna.has_trait(initial(temp_T.opposite_trait)))
				continue
		if(prob(initial(temp_T.manifest_probability)))
			child_dna.add_trait(temp_T)

	if(mother_dna.has_trait(/datum/farm_animal_trait/herbivore) && father_dna.has_trait(/datum/farm_animal_trait/herbivore))
		child_dna.add_trait(/datum/farm_animal_trait/herbivore)

	else if(mother_dna.has_trait(/datum/farm_animal_trait/carnivore) && father_dna.has_trait(/datum/farm_animal_trait/carnivore))
		child_dna.add_trait(/datum/farm_animal_trait/carnivore)

	else if((mother_dna.has_trait(/datum/farm_animal_trait/herbivore) && father_dna.has_trait(/datum/farm_animal_trait/carnivore)) || (mother_dna.has_trait(/datum/farm_animal_trait/carnivore) && father_dna.has_trait(/datum/farm_animal_trait/herbivore)))
		if(prob(50))
			child_dna.add_trait(/datum/farm_animal_trait/herbivore)
		else
			child_dna.add_trait(/datum/farm_animal_trait/carnivore)

	return child_dna

proc/create_child_from_scratch(var/mob/living/simple_animal/farm/self)
	var/datum/farm_animal_dna/child_dna = new
	child_dna.owner = self
	child_dna.strength = rand(0.1,10)
	child_dna.yield = rand(0.1,10)
	child_dna.health = pick(0.5,1,1.5,2)
	child_dna.endurance = rand(0.1,10)
	child_dna.fertility = rand(0.1,10)

	self.melee_damage_upper = child_dna.strength
	self.melee_damage_lower = child_dna.strength
	self.health *= child_dna.health
	self.maxHealth *= child_dna.health

	var/max_new_traits = rand(1,3)
	var/added_traits = 0
	var/list/potential_traits = typesof(/datum/farm_animal_trait) - /datum/farm_animal_trait

	for(var/TR in potential_traits)
		var/datum/farm_animal_trait/temp_TR = TR
		if(initial(temp_TR.random_blacklist))
			potential_traits -= temp_TR
	var/list/shuffled_traits = shuffle(potential_traits)

	for(var/T in shuffled_traits)
		if(added_traits >= max_new_traits)
			break
		added_traits++
		var/datum/farm_animal_trait/temp_T = T
		if(child_dna.has_trait(initial(temp_T)))
			continue
		if(initial(temp_T.opposite_trait))
			if(child_dna.has_trait(initial(temp_T.opposite_trait)))
				continue
		if(prob(initial(temp_T.manifest_probability) + 20))
			child_dna.add_trait(temp_T)

	if(prob(50))
		child_dna.add_trait(/datum/farm_animal_trait/herbivore)
	else
		child_dna.add_trait(/datum/farm_animal_trait/carnivore)

	return child_dna

/datum/farm_animal_dna
	var/strength = 1 // From 1 to 10
	var/yield = 1 // multiplier for physical outputs: eg. meat from a cow
	var/health = 1 // health multiplier
	var/endurance = 1 // from 1 to 10
	var/fertility = 1

	var/max_young = 1

	var/mob/living/simple_animal/farm/owner = null

	var/list/traits = list()

/datum/farm_animal_dna/proc/add_trait(var/datum/farm_animal_trait/T)
	if(initial(T.opposite_trait))
		if(has_trait(initial(T.opposite_trait)))
			return 0
	if(has_trait(T))
		return 0
	else
		var/datum/farm_animal_trait/new_T = new T
		traits.Add(new_T)
		new_T.owner = src
		new_T.on_apply(owner)
		return 1

/datum/farm_animal_dna/proc/remove_trait(var/datum/farm_animal_trait/T)
	if(doesnt_has_trait(T))
		return 0
	else
		for(var/datum/farm_animal_trait/TR in traits)
			if(istype(TR, T))
				TR.on_remove(owner)
				traits -= TR
				qdel(TR)
				return 1
			else
				continue
		return 0

/datum/farm_animal_dna/proc/has_trait(var/datum/farm_animal_trait/T)
	for(var/datum/farm_animal_trait/TR in traits)
		if(istype(TR, T))
			return 1
		else
			continue
	return 0

/datum/farm_animal_dna/proc/doesnt_has_trait(var/datum/farm_animal_trait/T)
	for(var/datum/farm_animal_trait/TR in traits)
		if(istype(TR, T))
			return 0
		else
			continue
	return 1
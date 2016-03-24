/datum/farm_animal_trait/reagent_infused
	name = "Reagent Infused"
	description = "This animal is infused with a reagent, and will vomit it up on occasion, along with applying it in combat."
	manifest_probability = 55
	continue_probability = 75
	var/reagent_produced = "milk"

/datum/farm_animal_trait/reagent_infused/on_apply(var/mob/living/simple_animal/farm/M)
	var/picked = rand(1,3)
	switch(picked)
		if(1)
			var/list/reagent_list_of_types = subtypesof(/datum/reagent/medicine)
			var/list/potential_reagents = list()
			for(var/R in reagent_list_of_types)
				var/datum/reagent/RE = R
				potential_reagents += initial(RE.id)
			reagent_produced = pick(potential_reagents)
		if(2)
			var/list/reagent_list_of_types = subtypesof(/datum/reagent/toxin)
			var/list/potential_reagents = list()
			for(var/R in reagent_list_of_types)
				var/datum/reagent/RE = R
				potential_reagents += initial(RE.id)
			reagent_produced = pick(potential_reagents)
		if(3)
			var/list/reagent_list_of_types = subtypesof(/datum/reagent/pyro)
			var/list/potential_reagents = list()
			for(var/R in reagent_list_of_types)
				var/datum/reagent/RE = R
				potential_reagents += initial(RE.id)
			reagent_produced = pick(potential_reagents)
	return

/datum/farm_animal_trait/reagent_infused/on_attack_mob(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	if(L)
		L.reagents.add_reagent(reagent_produced, rand(5,10))
	return

/datum/farm_animal_trait/reagent_infused/on_life(var/mob/living/simple_animal/farm/M)
	if(prob(5))
		M.visible_message("[M] throws up!")
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(M.loc)
		V.reagents.add_reagent(reagent_produced, rand(5,10))
	return

/datum/farm_animal_trait/udders
	name = "Udders"
	description = "This animal has udders and will produce either milk or another reagent if infused. Use a bucket to milk the animal."
	manifest_probability = 55
	continue_probability = 75
	var/obj/reagent_holder
	var/reagent_produced = "milk"

/datum/farm_animal_trait/udders/on_apply(var/mob/living/simple_animal/farm/M)
	reagent_holder = new
	reagent_holder.create_reagents(50)
	var/datum/farm_animal_trait/reagent_infused/R = owner.has_trait(/datum/farm_animal_trait/reagent_infused)
	if(R)
		reagent_produced = R.reagent_produced
	reagent_holder.reagents.add_reagent(reagent_produced, rand(5,10))
	return

/datum/farm_animal_trait/udders/on_life(var/mob/living/simple_animal/farm/M)
	if(!M.stat)
		return
	if(prob(5))
		reagent_holder.reagents.add_reagent(reagent_produced, rand(5,10))
	return

/datum/farm_animal_trait/udders/on_attack_by(var/mob/living/simple_animal/farm/M, obj/item/O, mob/living/user, params)
	if(!user || !O)
		return
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		var/obj/item/weapon/reagent_containers/glass/G = O
		if(G.reagents.total_volume >= G.volume)
			user << "<span class='danger'>[O] is full.</span>"
			return
		var/transfered = reagent_holder.reagents.trans_to(G, rand(5,10))
		if(transfered)
			user.visible_message("[user] milks [M] using \the [O].", "<span class='notice'>You milk [M] using \the [O].</span>")
		else
			user << "<span class='danger'>The udder is dry. Wait a bit longer...</span>"
	return
/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	health = 180
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 3
		processing_objects.Add(src)

	Del()
		processing_objects.Remove(src)
		..()


	process()
		if(!loc)	return
		var/datum/gas_mixture/environment = loc.return_air()
		if(!environment)	return
		switch(environment.temperature)
			if(0 to T0C)
				health = 180
				return
			if(T0C to (T0C + 100))
				health = max(0, health - 1)
		if(health <= 0)
			rot()

/obj/item/weapon/reagent_containers/food/snacks/meat/proc/rot()
	desc = "A slab of meat. It looks rotten."
	icon_state = "rottenmeat"
	var/toxin_amount = reagents.get_reagent_amount("nutriment") * 3
	reagents.add_reagent("toxin",toxin_amount)
	processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh/rot()
	desc = "A slab of synthetic meat. It looks rotten."
	icon_state = "rottenmeat"
	var/toxin_amount = reagents.get_reagent_amount("nutriment") * 3
	reagents.add_reagent("toxin",toxin_amount)
	processing_objects.Remove(src)



/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null


/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	//same as plain meat
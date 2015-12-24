/obj/item/weapon/reagent_containers/food/snacks/roach_eggs
	name = "cockroach eggs"
	desc = "A bunch of tiny, brown eggs, each of them housing a bunch of cockroach larvae."

	food_flags = FOOD_ANIMAL

	icon_state = "roach_eggs1"

	var/amount_grown = 0

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("toxin", 0.2)
	src.bitesize = 1.1

	icon_state = "roach_eggs[rand(1,3)]"

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/process()
	if(isturf(loc))
		amount_grown += rand(1,3)

		if(amount_grown >= 50)
			if(animal_count[/mob/living/simple_animal/cockroach] < ANIMAL_CHILD_CAP)
				hatch()
			else
				processing_objects.Remove(src)
	else
		processing_objects.Remove(src)

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/proc/hatch()
	new /mob/living/simple_animal/cockroach(get_turf(src))

	processing_objects.Remove(src)
	qdel(src)

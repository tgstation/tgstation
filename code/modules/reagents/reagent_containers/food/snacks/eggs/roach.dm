var/global/cockroach_egg_amount = 0

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs
	name = "cockroach eggs"
	desc = "A bunch of tiny, brown eggs, each of them housing a bunch of cockroach larvae."

	food_flags = FOOD_ANIMAL

	icon_state = "roach_eggs1"

	var/amount_grown = 0

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/New()
	..()
	reagents.add_reagent(NUTRIMENT, 2)
	reagents.add_reagent(TOXIN, 0.2)
	src.bitesize = 1.1

	icon_state = "roach_eggs[rand(1,3)]"

	cockroach_egg_amount++

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/process()
	if(is_in_valid_nest(src)) //_macros.dm
		amount_grown += rand(1,2)

		if(amount_grown >= 41)
			if(animal_count[/mob/living/simple_animal/cockroach] < ANIMAL_CHILD_CAP)
				hatch()
			else
				die()
	else
		die()

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/Destroy()
	if(amount_grown)
		die()

	cockroach_egg_amount--

	return ..()

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/proc/hatch()
	new /mob/living/simple_animal/cockroach(get_turf(src))

	processing_objects.Remove(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/proc/fertilize()
	processing_objects.Add(src)

	amount_grown = 1 //So there's a way of checking if the egg is fertilized without doing processing_objects.Find(src)

/obj/item/weapon/reagent_containers/food/snacks/roach_eggs/proc/die()
	processing_objects.Remove(src)

	amount_grown = 0

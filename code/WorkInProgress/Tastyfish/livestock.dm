// Base Class
/mob/living/simple_animal/livestock
	desc = "Tasty!"
	icon = 'icons/mob/livestock.dmi'
	emote_see = list("shakes its head", "kicks the ground")
	speak_chance = 1
	turns_per_move = 15
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	var/max_nutrition = 100	// different animals get hungry faster, basically number of 5-second steps from full to starving (60 == 5 minutes)
	var/nutrition_step		// cycle step in nutrition system
	var/obj/movement_target // eating-ing target

	New()
		if(!nutrition)
			nutrition = max_nutrition * 0.33 // at 1/3 nutrition

		reagents = new()
		reagents.my_atom = src

	Life()
		..()

		if(stat != DEAD)
			meat_amount = round(nutrition / 50)

			nutrition_step--
			if(nutrition_step <= 0)
				// handle animal digesting
				if(nutrition > 0)
					nutrition--
				else
					health--
				nutrition_step = 50 // only tick this every 5 seconds

				// handle animal eating (borrowed from Ian code)

				// not hungry if full
				if(nutrition >= max_nutrition)
					return

				if((movement_target) && !(isturf(movement_target.loc)))
					movement_target = null
					a_intent = "help"
					turns_per_move = initial(turns_per_move)
				if( !movement_target || !(movement_target.loc in oview(src, 3)) )
					movement_target = null
					a_intent = "help"
					turns_per_move = initial(turns_per_move)
					for(var/obj/item/weapon/reagent_containers/food/snacks/S in oview(src,3))
						if(isturf(S.loc) || ishuman(S.loc))
							movement_target = S
							break
				if(movement_target)
					stop_automated_movement = 1
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)

					if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
						if (movement_target.loc.x < src.x)
							dir = WEST
						else if (movement_target.loc.x > src.x)
							dir = EAST
						else if (movement_target.loc.y < src.y)
							dir = SOUTH
						else if (movement_target.loc.y > src.y)
							dir = NORTH
						else
							dir = SOUTH

					if(isturf(movement_target.loc))
						movement_target.attack_animal(src)
						if(istype(movement_target, /obj/item/weapon/reagent_containers/food/snacks))
							var/obj/item/I = movement_target
							I.attack(src, src, "mouth")	// eat it, if it's food

						if(a_intent == "hurt")		// to make raging critter harm, then disarm, then stop
							a_intent = "disarm"
						else if(a_intent == "disarm")
							a_intent = "help"
							movement_target = null
							turns_per_move = initial(turns_per_move)
					else if(ishuman(movement_target.loc))
						if(prob(20))
							emote("stares at the [movement_target] that [movement_target.loc] has with a longing expression.")

	proc/rage_at(mob/living/M)
		movement_target = M		// pretty simple
		turns_per_move = 1
		emote("becomes enraged")
		a_intent = "hurt"

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(nutrition < max_nutrition && istype(O,/obj/item/weapon/reagent_containers/food/snacks))
			O.attack_animal(src)
		else
			..(O, user)

// Cow
/mob/living/simple_animal/livestock/cow
	name = "\improper Cow"
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_d"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/cow
	meat_amount = 10
	max_nutrition = 1000
	speak = list("Moo.","Moooo!","Snort.")
	speak_emote = list("moos")
	emote_hear = list("moos", "snorts")

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O,/obj/item/weapon/reagent_containers/glass))
			var/datum/reagents/R = O:reagents

			R.add_reagent("milk", 50)
			nutrition -= 50
			usr << "\blue You milk the cow."
		else if(O.force > 0 && O.w_class >= 2)
			rage_at(user)
		else
			..(O, user)

	attack_hand(var/mob/user as mob)
		..()
		if(user.a_intent == "hurt")
			rage_at(user)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/cow
	name = "Beef"
	desc = "It's what's for dinner!"

// Chicken
/mob/living/simple_animal/livestock/chicken
	name = "\improper Chicken"
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_d"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/chicken
	meat_amount = 3
	max_nutrition = 200
	speak = list("Bock bock!","Cl-cluck.","Click.")
	speak_emote = list("bocks","clucks")
	emote_hear = list("bocks", "clucks", "squawks")

/mob/living/simple_animal/livestock/chicken/Life()
	..()

	// go right before cycle elapses, and if animal isn't starving
	if(stat != DEAD && nutrition_step == 1 && nutrition > max_nutrition / 2)
		// lay an egg with probability of 5% in 5 second time period
		if(prob(33))
			new/obj/item/weapon/reagent_containers/food/snacks/egg(src.loc) // lay an egg
			nutrition -= 25

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meat/chicken
	name = "Chicken"
	desc = "Tasty!"

/obj/structure/closet/critter
	desc = "\improper Critter crate."
	name = "Critter Crate"
	icon = 'icons/obj/storage.dmi'
	icon_state = "critter"
	density = 1
	icon_opened = "critteropen"
	icon_closed = "critter"

/datum/supply_packs/chicken
	name = "\improper Chicken crate"
	contains = list("/mob/living/simple_animal/livestock/chicken",
					"/obj/item/weapon/reagent_containers/food/snacks/grown/corn")
	cost = 10
	containertype = "/obj/structure/closet/critter"
	containername = "Chicken crate"
	//group = "Hydroponics"

/datum/supply_packs/cow
	name = "\improper Cow crate"
	contains = list("/mob/living/simple_animal/livestock/cow",
					"/obj/item/weapon/reagent_containers/food/snacks/grown/corn")
	cost = 50
	containertype = "/obj/structure/closet/critter"
	containername = "Cow crate"
	//group = "Hydroponics"

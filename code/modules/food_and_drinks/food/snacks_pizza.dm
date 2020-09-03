
/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/pizza
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	slices_num = 6
	volume = 80
	list_reagents = list(/datum/reagent/consumable/nutriment = 28, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES

/obj/item/reagent_containers/food/snacks/pizzaslice
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	foodtype = GRAIN | DAIRY | VEGETABLES
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/pizza/margherita
	name = "pizza margherita"
	desc = "The most cheezy pizza in galaxy."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/margherita
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/pizza/margherita/robo/Initialize()
	bonus_reagents += list(/datum/reagent/nanomachines = 70)
	return ..()

/obj/item/reagent_containers/food/snacks/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/meat
	name = "meatpizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/meat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 8)
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 8)
	foodtype = GRAIN | VEGETABLES| DAIRY | MEAT
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meatpizza."
	icon_state = "meatpizzaslice"
	filling_color = "#A52A2A"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/reagent_containers/food/snacks/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/mushroom
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 28, /datum/reagent/consumable/nutriment/protein = 3,  /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#FFE4C4"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/vegetable
	name = "vegetable pizza"
	desc = "No one of Tomatos Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/vegetable
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/oculine = 12, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/donkpocket
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/medicine/omnizine = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | JUNKFOOD

/obj/item/reagent_containers/food/snacks/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/dank
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/doctor_delight = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	filling_color = "#2E8B57"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can really smell the sassiness."
	icon_state = "sassysagepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/sassysage
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2,  /datum/reagent/consumable/nutriment/protein =  6, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 15, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	filling_color = "#FF4500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY

/obj/item/reagent_containers/food/snacks/pizza/pineapple
	name = "\improper Hawaiian pizza"
	desc = "The pizza equivalent of Einstein's riddle."
	icon_state = "pineapplepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/pineapple
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 7)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/tomatojuice = 6, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/pineapplejuice = 8)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/pizzaslice/pineapple
	name = "\improper Hawaiian pizza slice"
	desc = "A slice of delicious controversy."
	icon_state = "pineapplepizzaslice"
	filling_color = "#FF4500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pineapple" = 2, "ham" = 2)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT | FRUIT | PINEAPPLE

/obj/item/reagent_containers/food/snacks/pizza/arnold
	name = "\improper Arnold pizza"
	desc = "Hello, you've reached Arnold's pizza shop. I'm not here now, I'm out killing pepperoni."
	icon_state = "arnoldpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/arnold
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 25, /datum/reagent/consumable/nutriment/protein = 9, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/iron = 10, /datum/reagent/medicine/omnizine = 30)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	value = FOOD_ILLEGAL

/obj/item/reagent_containers/food/snacks/proc/try_break_off(mob/living/M, mob/living/user) //maybe i give you a pizza maybe i break off your arm
	if(prob(50) || (M != user) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/obj/item/bodypart/l_arm = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = user.get_bodypart(BODY_ZONE_R_ARM)
	var/did_the_thing = (l_arm?.dismember() || r_arm?.dismember()) //not all limbs can be removed, so important to check that we did. the. thing.
	if(!did_the_thing)
		return
	to_chat(user, "<span class='userdanger'>Maybe I'll give you a pizza, maybe I'll break off your arm.</span>") //makes the reference more obvious
	user.visible_message("<span class='warning'>\The [src] breaks off [user]'s arm!</span>", "<span class='warning'>\The [src] breaks off your arm!</span>")
	playsound(user, "desecration", 50, TRUE, -1)

/obj/item/reagent_containers/food/snacks/proc/i_kill_you(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/pineappleslice))
		to_chat(user, "<font color='red' size='7'>If you want something crazy like pineapple, I'll kill you.</font>") //this is in bigger text because it's hard to spam something that gibs you, and so that you're perfectly aware of the reason why you died
		user.gib() //if you want something crazy like pineapple, i'll kill you
	else if(istype(I, /obj/item/reagent_containers/food/snacks/grown/mushroom) && iscarbon(user))
		to_chat(user, "<span class='userdanger'>So, if you want mushroom, shut up.</span>") //not as large as the pineapple text, because you could in theory spam it
		var/mob/living/carbon/shutup = user
		shutup.gain_trauma(/datum/brain_trauma/severe/mute)

/obj/item/reagent_containers/food/snacks/pizza/arnold/attack(mob/living/M, mob/living/user)
	. = ..()
	try_break_off(M, user)

/obj/item/reagent_containers/food/snacks/pizza/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()


/obj/item/reagent_containers/food/snacks/pizzaslice/arnold
	name = "\improper Arnold pizza slice"
	desc = "I come over, maybe I give you a pizza, maybe I break off your arm."
	icon_state = "arnoldpizzaslice"
	filling_color = "#A52A2A"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "pepperoni" = 2, "9 millimeter bullets" = 2)
	foodtype = GRAIN | VEGETABLES | DAIRY | MEAT

/obj/item/reagent_containers/food/snacks/pizzaslice/arnold/attack(mob/living/M, mob/living/user)
	. =..()
	try_break_off(M, user)

/obj/item/reagent_containers/food/snacks/pizzaslice/arnold/attackby(obj/item/I, mob/user)
	i_kill_you(I, user)
	. = ..()


/obj/item/reagent_containers/food/snacks/pizzaslice/custom
	name = "pizza slice"
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFFFFF"
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/pizzaslice/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(!isturf(loc))
			to_chat(user, "<span class='warning'>You need to put [src] on a surface to roll it out!</span>")
			return
		new /obj/item/stack/sheet/pizza(loc)
		to_chat(user, "<span class='notice'>You smoosh [src] into a cheesy sheet.</span>")
		qdel(src)
		return
	return ..()

/obj/item/reagent_containers/food/snacks/pizzaslice/moldy
	name = "moldy pizza slice"
	desc = "This was once a perfectly good slice of pizza pie, but now it lies here, rancid and bursting with spores. What a bummer! But we should not dwell on the past, only look towards the future."
	icon_state = "moldy_slice"
	filling_color = "#e9d075"
	bitesize = 4
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/peptides = 3, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/toxin/amatoxin = 2)
	tastes = list("stale crust" = 1, "rancid cheese" = 2, "mushroom" = 1)
	foodtype = GRAIN | VEGETABLES | DAIRY | GROSS

/obj/item/reagent_containers/food/snacks/pizzaslice/moldy/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOLD, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 25)

/obj/item/food/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in its own packaging."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "icecreamsandwich"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/ice = 4)
	tastes = list("ice cream" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/strawberryicecreamsandwich
	name = "strawberry ice cream sandwich"
	desc = "Portable ice-cream in its own packaging of the strawberry variety."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "strawberryicecreamsandwich"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/ice = 4)
	tastes = list("ice cream" = 2, "berry" = 2)
	foodtypes = FRUIT | DAIRY | SUGAR


/obj/item/food/spacefreezy
	name = "space freezy"
	desc = "The best icecream in space."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "spacefreezy"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/bluecherryjelly = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("blue cherries" = 2, "ice cream" = 2)
	foodtypes = FRUIT | DAIRY | SUGAR

/obj/item/food/sundae
	name = "sundae"
	desc = "A classic dessert."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "sundae"
	w_class = WEIGHT_CLASS_SMALL
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("ice cream" = 1, "banana" = 1)
	foodtypes = FRUIT | DAIRY | SUGAR

/obj/item/food/honkdae
	name = "honkdae"
	desc = "The clown's favorite dessert."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "honkdae"
	w_class = WEIGHT_CLASS_SMALL
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("ice cream" = 1, "banana" = 1, "a bad joke" = 1)
	foodtypes = FRUIT | DAIRY | SUGAR

/////////////
//SNOWCONES//
/////////////

/obj/item/food/snowcones //We use this as a base for all other snowcones
	name = "flavorless snowcone"
	desc = "It's just shaved ice. Still fun to chew on."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "flavorless_sc"
	w_class = WEIGHT_CLASS_SMALL
	trash_type = /obj/item/reagent_containers/food/drinks/sillycup //We dont eat paper cups
	food_reagents = list(/datum/reagent/water = 11) // We dont get food for water/juices
	tastes = list("ice" = 1, "water" = 1)
	foodtypes = SUGAR //We use SUGAR as a base line to act in as junkfood, other wise we use fruit

/obj/item/food/snowcones/lime
	name = "lime snowcone"
	desc = "Lime syrup drizzled over a snowball in a paper cup."
	icon_state = "lime_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/limejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "limes" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/lemon
	name = "lemon snowcone"
	desc = "Lemon syrup drizzled over a snowball in a paper cup."
	icon_state = "lemon_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "lemons" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/apple
	name = "apple snowcone"
	desc = "Apple syrup drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/applejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "apples" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/grape
	name = "grape snowcone"
	desc = "Grape syrup drizzled over a snowball in a paper cup."
	icon_state = "grape_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/grapejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "grape" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/orange
	name = "orange snowcone"
	desc = "Orange syrup drizzled over a snowball in a paper cup."
	icon_state = "orange_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/orangejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "orange" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/blue
	name = "bluecherry snowcone"
	desc = "Bluecherry syrup drizzled over a snowball in a paper cup, how rare!"
	icon_state = "blue_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/bluecherryjelly = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "blue" = 5, "cherries" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/red
	name = "cherry snowcone"
	desc = "Cherry syrup drizzled over a snowball in a paper cup."
	icon_state = "red_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "red" = 5, "cherries" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/berry
	name = "berry snowcone"
	desc = "Berry syrup drizzled over a snowball in a paper cup."
	icon_state = "berry_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/berryjuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "berries" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/fruitsalad
	name = "fruit salad snowcone"
	desc = "A delightful mix of citrus syrups drizzled over a snowball in a paper cup."
	icon_state = "fruitsalad_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/limejuice = 5, /datum/reagent/consumable/orangejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "oranges" = 5, "limes" = 5, "lemons" = 5, "citrus" = 5, "salad" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/pineapple
	name = "pineapple snowcone"
	desc = "Pineapple syrup drizzled over a snowball in a paper cup."
	icon_state = "pineapple_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/pineapplejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "pineapples" = 5)
	foodtypes = PINEAPPLE //Pineapple to allow all that like pineapple to enjoy

/obj/item/food/snowcones/mime
	name = "mime snowcone"
	desc = "..."
	icon_state = "mime_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nothing = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "nothing" = 5)

/obj/item/food/snowcones/clown
	name = "clown snowcone"
	desc = "Laughter drizzled over a snowball in a paper cup."
	icon_state = "clown_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/laughter = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "jokes" = 5, "brainfreeze" = 5, "joy" = 5)

/obj/item/food/snowcones/soda
	name = "space cola snowcone"
	desc = "Space Cola drizzled over a snowball in a paper cup."
	icon_state = "soda_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/space_cola = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "cola" = 5)

/obj/item/food/snowcones/spacemountainwind
	name = "Space Mountain Wind snowcone"
	desc = "Space Mountain Wind drizzled over a snowball in a paper cup."
	icon_state = "mountainwind_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/spacemountainwind = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "mountain wind" = 5)


/obj/item/food/snowcones/pwrgame
	name = "pwrgame snowcone"
	desc = "Pwrgame soda drizzled over a snowball in a paper cup."
	icon_state = "pwrgame_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/pwr_game = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "valid" = 5, "salt" = 5, "wats" = 5)

/obj/item/food/snowcones/honey
	name = "honey snowcone"
	desc = "Honey drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/honey = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "flowers" = 5, "sweetness" = 5, "wax" = 1)

/obj/item/food/snowcones/rainbow
	name = "rainbow snowcone"
	desc = "A very colorful snowball in a paper cup."
	icon_state = "rainbow_sc"
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/laughter = 25, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "sunlight" = 5, "light" = 5, "slime" = 5, "paint" = 3, "clouds" = 3)

/obj/item/food/popsicle
	name = "bug popsicle"
	desc = "Mmmm, this should not exist."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "popsicle_stick_s"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/vanilla = 2, /datum/reagent/consumable/sugar = 4)
	tastes = list("beetlejuice")
	trash_type = /obj/item/popsicle_stick
	w_class = WEIGHT_CLASS_SMALL
	var/overlay_state = "creamsicle_o" //This is the edible part of the popsicle.
	var/bite_states = 4 //This value value is used for correctly setting the bite_consumption to ensure every bite changes the sprite. Do not set to zero.
	var/bitecount = 0
	foodtypes = DAIRY | SUGAR

/obj/item/food/popsicle/Initialize()
	. = ..()
	bite_consumption = reagents.total_volume / bite_states

/obj/item/food/popsicle/MakeEdible()
	AddComponent(/datum/component/edible,\
				initial_reagents = food_reagents,\
				food_flags = food_flags,\
				foodtypes = foodtypes,\
				volume = max_volume,\
				eat_time = eat_time,\
				tastes = tastes,\
				eatverbs = eatverbs,\
				bite_consumption = bite_consumption,\
				microwaved_type = microwaved_type,\
				junkiness = junkiness,\
				after_eat = CALLBACK(src, .proc/after_bite))


/obj/item/food/popsicle/update_overlays()
	. = ..()
	if(bitecount)
		. += "[initial(overlay_state)]_[min(bitecount, 3)]"
	else
		. += initial(overlay_state)

/obj/item/food/popsicle/proc/after_bite(mob/living/eater, mob/living/feeder, bitecount)
	src.bitecount = bitecount
	update_icon()

/obj/item/popsicle_stick
	name = "popsicle stick"
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "popsicle_stick"
	desc = "This humble little stick usually carries a frozen treat, at the moment it seems freed from this atlassian burden."
	custom_materials = list(/datum/material/wood=20)
	w_class = WEIGHT_CLASS_TINY
	force = 0

/obj/item/food/popsicle/creamsicle_orange
	name = "orange creamsicle"
	desc = "A classic orange creamsicle. A sunny frozen treat."
	food_reagents = list(/datum/reagent/consumable/orangejuice = 4, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/vanilla = 2, /datum/reagent/consumable/sugar = 4)
	foodtypes = FRUIT | DAIRY | SUGAR

/obj/item/food/popsicle/creamsicle_berry
	name = "berry creamsicle"
	desc = "A vibrant berry creamsicle. A berry good frozen treat."
	food_reagents = list(/datum/reagent/consumable/berryjuice = 4, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/vanilla = 2, /datum/reagent/consumable/sugar = 4)
	overlay_state = "creamsicle_m"
	foodtypes = FRUIT | DAIRY | SUGAR

/obj/item/food/popsicle/jumbo
	name = "jumbo icecream"
	desc = "A luxurius icecream covered in rich chocolate. It seems smaller than you remember it being."
	food_reagents = list(/datum/reagent/consumable/hot_coco = 4, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/vanilla = 3, /datum/reagent/consumable/sugar = 2)
	overlay_state = "jumbo"

/obj/item/food/popsicle/nogga_black
	name = "nogga black"
	desc = "A salty licorice icecream recently reintroduced due to all the records of the controversy being lost to time. Those who cannot remember the past are doomed to repeat it."
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/salt = 1,  /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/sugar = 4)
	tastes = list("salty liquorice")
	overlay_state = "nogga_black"

/obj/item/food/cornuto
	name = "cornuto"
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "cornuto"
	desc = "A neapolitan vanilla and chocolate icecream cone. It menaces with a sprinkling of caramelized nuts."
	tastes = list("chopped hazelnuts", "waffle")
	food_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/hot_coco = 4, /datum/reagent/consumable/cream = 2, /datum/reagent/consumable/vanilla = 4, /datum/reagent/consumable/sugar = 2)
	foodtypes = DAIRY | SUGAR


/////////////////
//Misc. Frozen.//
/////////////////

/obj/item/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in its own packaging."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "icecreamsandwich"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/ice = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/ice = 2)
	tastes = list("ice cream" = 1)
	foodtype = GRAIN | DAIRY | SUGAR

/obj/item/reagent_containers/food/snacks/spacefreezy
	name = "space freezy"
	desc = "The best icecream in space."
	icon_state = "spacefreezy"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/bluecherryjelly = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#87CEFA"
	tastes = list("blue cherries" = 2, "ice cream" = 2)
	foodtype = FRUIT | DAIRY | SUGAR

/obj/item/reagent_containers/food/snacks/sundae
	name = "sundae"
	desc = "A classic dessert."
	icon_state = "sundae"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	filling_color = "#FFFACD"
	tastes = list("ice cream" = 1, "banana" = 1)
	foodtype = FRUIT | DAIRY | SUGAR

/obj/item/reagent_containers/food/snacks/honkdae
	name = "honkdae"
	desc = "The clown's favorite dessert."
	icon_state = "honkdae"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	filling_color = "#FFFACD"
	tastes = list("ice cream" = 1, "banana" = 1, "a bad joke" = 1)
	foodtype = FRUIT | DAIRY | SUGAR

/////////////
//SNOWCONES//
/////////////

/obj/item/reagent_containers/food/snacks/snowcones //We use this as a base for all other snowcones
	name = "flaverless snowcone"
	desc = "Its just harden water slivers. Still fun to chew on."
	icon = 'icons/obj/food/snowcones.dmi'
	icon_state = "flaverless_sc"
	trash = /obj/item/reagent_containers/food/drinks/sillycup //We dont eat paper cups
	bonus_reagents = list(/datum/reagent/water = 10) //Base line will allways give water
	list_reagents = list(/datum/reagent/water = 1) // We dont get food for water/juices
	filling_color = "#FFFFFF" //Ice is white
	tastes = list("ice" = 1, "water" = 1)
	foodtype = SUGAR //We use SUGAR as a base line to act in as junkfood, other wise we use fruit

/obj/item/reagent_containers/food/snacks/snowcones/lime
	name = "lime flavored snowcone"
	desc = "A lime flavord snowball in a paper cup."
	icon_state = "lime_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/limejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "limes" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/lemon
	name = "lemon flavored snowcone"
	desc = "A lemon flavord snowball in a paper cup."
	icon_state = "lemon_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5)
	tastes = list("ice" = 1, "water" = 1, "lemons" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/apple
	name = "apple flavored snowcone"
	desc = "A apple flavord snowball in a paper cup."
	icon_state = "blue_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/applejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "apples" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/grape
	name = "grape flavored snowcone"
	desc = "A grape flavord snowball in a paper cup."
	icon_state = "grape_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/grapejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "grape" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/orange
	name = "orange flavored snowcone"
	desc = "A orange flavors dizzled on a snowball in a paper cup."
	icon_state = "orange_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/orangejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "orange" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/blue
	name = "bluecherry flavored snowcone"
	desc = "A bluecharry flavord snowball in a paper cup, how rare!"
	icon_state = "red_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/bluecherryjelly = 5)
	tastes = list("ice" = 1, "water" = 1, "blue" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/red
	name = "cherry flavored snowcone"
	desc = "A cherry flavord snowball in a paper cup."
	icon_state = "blue_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 5)
	tastes = list("ice" = 1, "water" = 1, "red" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/mix
	name = "mixed berry flavored snowcone"
	desc = "A mix of different flavors dizzled on a snowball in a paper cup."
	icon_state = "berry_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/berryjuice = 10)
	tastes = list("ice" = 1, "water" = 1, "berries" = 5)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/fruitsalad
	name = "mixed fruit flavored snowcone"
	desc = "A mix of different flavors dizzled on a snowball in a paper cup."
	icon_state = "fruitsalad_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/limejuice = 5, /datum/reagent/consumable/orangejuice = 5)
	tastes = list("ice" = 1, "water" = 1, "fruits" = 25)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/snowcones/pineapple
	name = "pineapple flavored snowcone"
	desc = "A pineapple flavord snowball in a paper cup."
	icon_state = "pineapple_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water = 10)
	tastes = list("ice" = 1, "water" = 1, "pineapples" = 5)
	foodtype = PINEAPPLE //Pineapple to allow all that like pineapple to enjoy

/obj/item/reagent_containers/food/snacks/snowcones/mime
	name = "mime snowcone"
	desc = "..."
	icon_state = "mime_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nothing = 5)
	tastes = list("nothing" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/clown
	name = "joke flavored snowcone"
	desc = "A waterd down jokeful flavord snowball in a paper cup."
	icon_state = "clown_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/pwr_game = 5)
	tastes = list("jokes" = 5, "brainfreeze" = 5, "joy" = 5)

/obj/item/reagent_containers/food/snacks/snowcones/soda
	name = "sodawater flavored snowcone"
	desc = "A waterd down sodawater flavored snowcone snowball in a paper cup."
	icon_state = "soda_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sodawater = 5)
	tastes = list("surgar" = 1, "water" = 5, "soda" = 5)
	foodtype = JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/snowcones/pwgrmer
	name = "pwergamer flavored snowcone"
	desc = "A waterd down pwergamer soda flavord snowball in a paper cup."
	icon_state = "pwergamer_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/laughter = 1)
	tastes = list("vaild" = 5, "salt" = 5, "wats" = 5)
	foodtype = JUNKFOOD | SUGAR

/obj/item/reagent_containers/food/snacks/snowcones/honey
	name = "honey flavored snowcone"
	desc = "A honey flavord snowball in a paper cup."
	icon_state = "honey_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/honey = 5)
	tastes = list("pollen" = 5, "sweetness" = 5, "wax" = 1)

/obj/item/reagent_containers/food/snacks/snowcones/rainbow
	name = "rainbow color snowcone"
	desc = "A rainbow color snowball in a paper cup."
	icon_state = "rainbow_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/laughter = 25)
	tastes = list("sunlight" = 5, "light" = 5, "slime" = 5, "paint" = 3, "clouds" = 3)

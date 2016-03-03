// Berries
/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = /obj/item/seeds/berryseed
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	gender = PLURAL
	filling_color = "#FF00FF"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize_mod = 2


// Poison Berries
/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison
	seed = /obj/item/seeds/poisonberryseed
	name = "bunch of poison-berries"
	desc = "Taste so good, you could die!"
	icon_state = "poisonberrypile"
	filling_color = "#C71585"
	reagents_add = list("toxin" = 0.25, "vitamin" = 0.04, "nutriment" = 0.1)


// Death Berries
/obj/item/weapon/reagent_containers/food/snacks/grown/berries/death
	seed = /obj/item/seeds/deathberryseed
	name = "bunch of death-berries"
	desc = "Taste so good, you could die!"
	icon_state = "deathberrypile"
	filling_color = "#708090"
	reagents_add = list("lexorin" = 0.25, "toxin" = 0.35, "vitamin" = 0.04, "nutriment" = 0.1)


// Glow Berries
/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow
	seed = /obj/item/seeds/glowberryseed
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	var/on = 1
	var/brightness_on = 2 //luminosity when on
	icon_state = "glowberrypile"
	filling_color = "#7CFC00"
	reagents_add = list("uranium" = 0.25, "vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/Destroy()
	if(istype(loc,/mob))
		loc.AddLuminosity(round(-potency / 5))
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/pickup(mob/user)
	..()
	src.SetLuminosity(0)
	user.AddLuminosity(round(potency / 5))

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/glow/dropped(mob/user)
	..()
	user.AddLuminosity(round(-potency / 5))
	src.SetLuminosity(round(potency / 5))


// Cherries
/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	seed = /obj/item/seeds/cherryseed
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	filling_color = "#FF0000"
	reagents_add = list("nutriment" = 0.07, "sugar" = 0.07)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries
	seed = /obj/item/seeds/bluecherryseed
	name = "blue cherries"
	desc = "They're cherries that are blue."
	icon_state = "bluecherry"
	filling_color = "#6495ED"
	reagents_add = list("nutriment" = 0.07, "sugar" = 0.07)
	bitesize_mod = 2


// Grapes
/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	seed = /obj/item/seeds/grapeseed
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	dried_type = /obj/item/weapon/reagent_containers/food/snacks/no_raisin
	filling_color = "#FF1493"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1, "sugar" = 0.1)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/green
	seed = /obj/item/seeds/greengrapeseed
	name = "bunch of green grapes"
	icon_state = "greengrapes"
	filling_color = "#7FFF00"
	reagents_add = list("salglu_solution" = 0.25, "vitamin" = 0.04, "nutriment" = 0.1, "sugar" = 0.1)
/obj/item/cheapcuisine
	name = "Carbonhell's Can of Cheap Cuisine"
	desc = "A one-use miniature microwave that was meant to replace rations on the battlefield, produced by a Space Italian company. \
	It's said that the food they produce is so terrible, it makes all sorts of aliens attack Nanotrasen facilities. Which is, coincidentally, where you happen to be right now."
	force = 5
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "carboncan-off"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/smash.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	sharpness = IS_BLUNT
	materials = list(MAT_METAL=4000)
	var/datum/looping_sound/microwave/soundloop
	var/selected_food
	var/used = FALSE

	var/list/possibleFood = list(
	"Corn Potato Pizza" = /obj/item/reagent_containers/food/snacks/pizza/cornpotato/carbon,
	"Insta-Jelly" = /obj/item/reagent_containers/food/snacks/soup/amanitajelly/carbon,
	"Hot Dog" = /obj/item/reagent_containers/food/snacks/butterdog/carbon,
	"Ham Disc" = /obj/item/reagent_containers/food/snacks/hamdisc,
	"A Drink" = /obj/item/reagent_containers/food/drinks/carbonhell)

/obj/item/cheapcuisine/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)

/obj/item/cheapcuisine/attack_self(mob/user)
	if(!used)
		var/choice = input(user, "What would you like to dispense?", "Carbonhell's Can of Cheap Cuisine") as null|anything in possibleFood
		addtimer(CALLBACK(src, .proc/spawnFood, possibleFood[choice]), 50)
		soundloop.start()
		used = TRUE
		icon_state = "carboncan-on"
	else
		to_chat(user, "<span class='notice'>It's already been used!</span>")

/obj/item/cheapcuisine/proc/spawnFood(var/foodtype)
	soundloop.stop()
	if(isnull(foodtype))
		icon_state = "carboncan-off"
		used = FALSE
		return
	new foodtype(get_turf(src))
	icon_state = "carboncan-open"
	desc = "It's been used already."

// Foods

/obj/item/reagent_containers/food/snacks/pizza/cornpotato/carbon
	name = "cornpotato-pizza"
	desc = "A sanity destroying other thing. Somehow worse than the Cook's."
	icon = 'hippiestation/icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzacornpotato"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/cornpotato/carbon
	bitesize = 3
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "toxin" = 3, "fartium" = 5, "mushroomhallucinogen" = 3)
	bonus_reagents = list("methamphetamine" = 2.5, "histamine" = 2)
	tastes = list("pure, unadulterated misery" = 5)
	foodtype = GROSS | TOXIC // none of the food is actually real, it's just gross.

/obj/item/reagent_containers/food/snacks/pizzaslice/cornpotato/carbon
	name = "cornpotato-pizza slice"
	desc = "A slice of a sanity destroying other thing. Somehow worse than the Cook's."
	icon = 'hippiestation/icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzacornpotatoslice"
	filling_color = "#FFA500"
	bitesize = 1
	list_reagents = list("nutriment" = 2, "vitamin" = 0.5, "toxin" = 1.5, "fartium" = 2)
	bonus_reagents = list("methamphetamine" = 0.5, "histamine" = 0.5)
	tastes = list("pure, unadulterated misery" = 2)
	foodtype = GROSS | TOXIC

/obj/item/reagent_containers/food/snacks/soup/amanitajelly/carbon
	name = "insta-jelly"
	desc = "The jelly was so corrupted that it ended up gaining sentience."
	list_reagents = list("nutriment" = 1, "vitamin" = 3, "amatoxin" = 7, "mushroomhallucinogen" = 3) // will KILL you
	bonus_reagents = list("formaldehyde" = 3, "rotatium" = 3, "skewium" = 3) // who knows what you're gonna get
	tastes = list("death" = 10)
	bitesize = 2
	foodtype = GROSS | TOXIC

/obj/item/reagent_containers/food/snacks/butterdog/carbon
	name = "butterdog"
	desc = "This isn't a hot dog! It smells of heart disease!"
	list_reagents = list("nutriment" = 4, "vitamin" = 2, "slimejelly" = 5, "mushroomhallucinogen" = 3)
	bonus_reagents = list("impedrezene" = 3, "sulfonal" = 2) // nerfed but still dangerous
	tastes = list("cardiac arrest" = 10)
	bitesize = 2
	foodtype = GROSS | TOXIC

/obj/item/reagent_containers/food/snacks/hamdisc
	name = "ham disc"
	desc = "The laziest food someone could possibly make, alongside some corn."
	icon = 'hippiestation/icons/obj/food/food.dmi'
	icon_state = "ham_disk"
	list_reagents = list("nutriment" = 1, "vitamin" = 1, "soymilk" = 6)
	tastes = list("laziness" = 2)
	foodtype = GROSS | RAW | MEAT | VEGETABLES

/obj/item/reagent_containers/food/drinks/carbonhell
	name = "spanish vegetable oil"
	desc = "Tastes about as terrible as you'd expect."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "oliveoil"
	list_reagents = list("amanitin" = 5, "soymilk" = 12, "atomicbomb" = 10, "hearty_punch" = 8) //guaranteed to fuck you up, soylent. also surprisingly robust if used before crit
	foodtype = GROSS | ALCOHOL
/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
=======
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
>>>>>>> Updated this old code to fork
	mob_react = FALSE

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)
=======
	required_reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
>>>>>>> Updated this old code to fork

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
=======
	required_reagents = list("chocolate_milk" = 4, "sugar" = 2)
>>>>>>> Updated this old code to fork
	mob_react = FALSE

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
<<<<<<< HEAD
	id = /datum/reagent/consumable/hot_coco
	results = list(/datum/reagent/consumable/hot_coco = 5)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/coco = 1)

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = /datum/reagent/consumable/coffee
	results = list(/datum/reagent/consumable/coffee = 5)
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/tea
	name = "Tea"
	id = /datum/reagent/consumable/tea
	results = list(/datum/reagent/consumable/tea = 5)
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = /datum/reagent/consumable/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/corn_syrup
	name = /datum/reagent/consumable/corn_syrup
	id = /datum/reagent/consumable/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/caramel
	name = "Caramel"
	id = /datum/reagent/consumable/caramel
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	mob_react = FALSE

/datum/chemical_reaction/caramel_burned
	name = "Caramel burned"
	id = "caramel_burned"
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	mob_react = FALSE

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
=======
	id = "hot_coco"
	results = list("hot_coco" = 5)
	required_reagents = list("water" = 5, "cocoa" = 1)

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = "coffee"
	results = list("coffee" = 5)
	required_reagents = list("coffeepowder" = 1, "water" = 5)

/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	results = list("tea" = 5)
	required_reagents = list("teapowder" = 1, "water" = 5)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	results = list("soysauce" = 5)
	required_reagents = list("soymilk" = 4, "sacid" = 1)

/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	results = list("corn_syrup" = 5)
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	required_temp = 374

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
>>>>>>> Updated this old code to fork

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/store/cheesewheel(location)

/datum/chemical_reaction/synthmeat
	name = "synthmeat"
	id = "synthmeat"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
=======
	required_reagents = list("blood" = 5, "cryoxadone" = 1)
>>>>>>> Updated this old code to fork
	mob_react = FALSE

/datum/chemical_reaction/synthmeat/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
<<<<<<< HEAD
	id = /datum/reagent/consumable/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = /datum/reagent/consumable/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)
=======
	id = "hot_ramen"
	results = list("hot_ramen" = 3)
	required_reagents = list("water" = 1, "dry_ramen" = 3)

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	results = list("hell_ramen" = 6)
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
>>>>>>> Updated this old code to fork

/datum/chemical_reaction/imitationcarpmeat
	name = "Imitation Carpmeat"
	id = "imitationcarpmeat"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
=======
	required_reagents = list("carpotoxin" = 5)
>>>>>>> Updated this old code to fork
	required_container = /obj/item/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/imitationcarpmeat/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/carpmeat/imitation(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/dough
	name = "Dough"
	id = "dough"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
=======
	required_reagents = list("water" = 10, "flour" = 15)
>>>>>>> Updated this old code to fork
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/cakebatter
	name = "Cake Batter"
	id = "cakebatter"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/consumable/eggyolk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
=======
	required_reagents = list("eggyolk" = 15, "flour" = 15, "sugar" = 5)
>>>>>>> Updated this old code to fork
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/cakebatter/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cakebatter(location)

/datum/chemical_reaction/cakebatter/vegan
	id = "vegancakebatter"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
=======
	required_reagents = list("soymilk" = 15, "flour" = 15, "sugar" = 5)
>>>>>>> Updated this old code to fork

/datum/chemical_reaction/ricebowl
	name = "Rice Bowl"
	id = "ricebowl"
<<<<<<< HEAD
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
=======
	required_reagents = list("rice" = 10, "water" = 10)
>>>>>>> Updated this old code to fork
	required_container = /obj/item/reagent_containers/glass/bowl
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/ricebowl/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/salad/ricebowl(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)
<<<<<<< HEAD

/datum/chemical_reaction/nutriconversion
	name = "Nutriment Conversion"
	id = "nutriconversion"
	results = list(/datum/reagent/consumable/nutriment/peptides = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment/ = 0.5)
	required_catalysts = list(/datum/reagent/medicine/metafactor = 0.5)
=======
>>>>>>> Updated this old code to fork

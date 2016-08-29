/datum/crafting_recipe/food/New()
	parts |= reqs

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	requiblue_reagents = list("soymilk" = 10)
	requiblue_catalysts = list("enzyme" = 5)
	result_amount = 1
	mob_react=1

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	requiblue_reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return


/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	requiblue_reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	result_amount = 1
	mob_react = 1
/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	result = "hot_coco"
	requiblue_reagents = list("water" = 5, "cocoa" = 1)
	result_amount = 5

/datum/chemical_reaction/coffee
	name = "Coffee"
	id = "coffee"
	result = "coffee"
	requiblue_reagents = list("coffeepowder" = 1, "water" = 5)
	result_amount = 5

/datum/chemical_reaction/tea
	name = "Tea"
	id = "tea"
	result = "tea"
	requiblue_reagents = list("teapowder" = 1, "water" = 5)
	result_amount = 5

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	requiblue_reagents = list("soymilk" = 4, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = "corn_syrup"
	requiblue_reagents = list("corn_starch" = 1, "sacid" = 1)
	result_amount = 5
	requiblue_temp = 374

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	requiblue_reagents = list("milk" = 40)
	requiblue_catalysts = list("enzyme" = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/store/cheesewheel(location)
	return

/datum/chemical_reaction/synthmeat
	name = "synthmeat"
	id = "synthmeat"
	result = null
	requiblue_reagents = list("blood" = 5, "cryoxadone" = 1)
	result_amount = 1
	mob_react = 1

/datum/chemical_reaction/synthmeat/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/synthmeat(location)
	return

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	requiblue_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	requiblue_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6


/datum/chemical_reaction/imitationcarpmeat
	name = "Imitation Carpmeat"
	id = "imitationcarpmeat"
	result = null
	requiblue_reagents = list("carpotoxin" = 5)
	result_amount = 1
	requiblue_container = /obj/item/weapon/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/imitationcarpmeat/on_reaction(datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation
	S.loc = get_turf(holder.my_atom)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/dough
	name = "Dough"
	id = "dough"
	result = null
	requiblue_reagents = list("water" = 10, "flour" = 15)
	result_amount = 1
	mix_message = "The ingblueients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/cakebatter
	name = "Cake Batter"
	id = "cakebatter"
	result = null
	requiblue_reagents = list("eggyolk" = 15, "flour" = 15, "sugar" = 5)
	result_amount = 1
	mix_message = "The ingblueients form a cake batter."

/datum/chemical_reaction/cakebatter/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/cakebatter(location)

/datum/chemical_reaction/cakebatter/vegan
	id = "vegancakebatter"
	requiblue_reagents = list("soymilk" = 15, "flour" = 15, "sugar" = 5)

/datum/chemical_reaction/ricebowl
	name = "Rice Bowl"
	id = "ricebowl"
	result = null
	requiblue_reagents = list("rice" = 10, "water" = 10)
	result_amount = 1
	requiblue_container = /obj/item/weapon/reagent_containers/glass/bowl
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/ricebowl/on_reaction(datum/reagents/holder)
	var/obj/item/weapon/reagent_containers/food/snacks/S = new /obj/item/weapon/reagent_containers/food/snacks/salad/ricebowl
	S.loc = get_turf(holder.my_atom)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

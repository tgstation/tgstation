/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/tofu
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mob_react = FALSE

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)
	return

/datum/chemical_reaction/chocolatepudding
	results = list(/datum/reagent/consumable/chocolatepudding = 20)
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 10, /datum/reagent/consumable/eggyolk = 5)

/datum/chemical_reaction/vanillapudding
	results = list(/datum/reagent/consumable/vanillapudding = 20)
	required_reagents = list(/datum/reagent/consumable/vanilla = 5, /datum/reagent/consumable/milk = 5, /datum/reagent/consumable/eggyolk = 5)

/datum/chemical_reaction/chocolate_bar
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/coco = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/chocolate_bar2
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
	mob_react = FALSE

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)
	return

/datum/chemical_reaction/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/caramel
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	mob_react = FALSE

/datum/chemical_reaction/caramel_burned
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	mob_react = FALSE

/datum/chemical_reaction/cheesewheel
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/store/cheesewheel(location)

/datum/chemical_reaction/synthmeat
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	mob_react = FALSE

/datum/chemical_reaction/synthmeat/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat(location)

/datum/chemical_reaction/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

/datum/chemical_reaction/imitationcarpmeat
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	required_container = /obj/item/reagent_containers/food/snacks/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/imitationcarpmeat/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/carpmeat/imitation(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/dough
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/cakebatter
	required_reagents = list(/datum/reagent/consumable/eggyolk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/cakebatter/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/cakebatter(location)

/datum/chemical_reaction/cakebatter/vegan
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)

/datum/chemical_reaction/ricebowl
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
	required_container = /obj/item/reagent_containers/glass/bowl
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/ricebowl/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/salad/ricebowl(location)
	if(holder && holder.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/nutriconversion
	results = list(/datum/reagent/consumable/nutriment/peptides = 0.5)
	required_reagents = list(/datum/reagent/consumable/nutriment/ = 0.5)
	required_catalysts = list(/datum/reagent/medicine/metafactor = 0.5)

/datum/chemical_reaction/bbqsauce
	results = list(/datum/reagent/consumable/bbqsauce = 5)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/medicine/salglu_solution = 3, /datum/reagent/consumable/blackpepper = 1)

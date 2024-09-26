/datum/supply_pack/organic
	group = "Food & Hydroponics"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/organic/hydroponics
	access_view = ACCESS_HYDROPONICS

/datum/supply_pack/organic/hydroponics/beekeeping_suits
	name = "Beekeeper Suit Crate"
	desc = "Bee business booming? Better be benevolent and boost botany by \
		bestowing bi-Beekeeper-suits! Contains two beekeeper suits and matching headwear."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/head/utility/beekeeper_head,
					/obj/item/clothing/suit/utility/beekeeper_suit,
					/obj/item/clothing/head/utility/beekeeper_head,
					/obj/item/clothing/suit/utility/beekeeper_suit,
				)
	crate_name = "beekeeper suits"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Crate"
	desc = "BEES BEES BEES. Contains three honey frames, a beekeeper suit and helmet, \
		flyswatter, bee house, and, of course, a pure-bred Nanotrasen-Standardized Queen Bee!"
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/structure/beebox/unwrenched,
					/obj/item/honey_frame = 3,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/utility/beekeeper_head,
					/obj/item/clothing/suit/utility/beekeeper_suit,
					/obj/item/melee/flyswatter,
				)
	crate_name = "beekeeping starter crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/randomized/chef
	name = "Excellent Meat Crate"
	desc = "The best cuts in the whole galaxy. Contains a random assortment of exotic meats."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/food/meat/slab/human/mutant/slime,
					/obj/item/food/meat/slab/killertomato,
					/obj/item/food/meat/slab/bear,
					/obj/item/food/meat/slab/xeno,
					/obj/item/food/meat/slab/spider,
					/obj/item/food/meat/rawbacon,
					/obj/item/food/meat/slab/penguin,
					/obj/item/food/spiderleg,
					/obj/item/food/fishmeat/carp,
					/obj/item/food/meat/slab/human,
					/obj/item/food/meat/slab/grassfed,
				)
	crate_name = "food crate"

/datum/supply_pack/organic/randomized/chef/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 15)
		var/item = pick(contains)
		new item(C)

/datum/supply_pack/organic/exoticseeds
	name = "Exotic Seeds Crate"
	desc = "Any entrepreneuring botanist's dream. Contains twelve different seeds, \
		including one replica-pod seed and two mystery seeds!"
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_HYDROPONICS
	contains = list(
		/obj/item/seeds/amanita,
		/obj/item/seeds/bamboo,
		/obj/item/seeds/eggplant/eggy,
		/obj/item/seeds/liberty,
		/obj/item/seeds/nettle,
		/obj/item/seeds/plump,
		/obj/item/seeds/replicapod,
		/obj/item/seeds/reishi,
		/obj/item/seeds/rainbow_bunch,
		/obj/item/seeds/seedling,
		/obj/item/seeds/shrub,
		/obj/item/seeds/random = 2,
	)
	crate_name = "exotic seeds crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/food
	name = "Food Crate"
	desc = "Get things cooking with this crate full of useful ingredients! \
		Contains a dozen eggs, three bananas, and some flour, rice, milk, \
		soymilk, salt, pepper, enzyme, sugar, and monkeymeat."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/reagent_containers/condiment/flour,
					/obj/item/reagent_containers/condiment/rice,
					/obj/item/reagent_containers/condiment/milk,
					/obj/item/reagent_containers/condiment/soymilk,
					/obj/item/reagent_containers/condiment/saltshaker,
					/obj/item/reagent_containers/condiment/peppermill,
					/obj/item/storage/fancy/egg_box,
					/obj/item/reagent_containers/condiment/enzyme,
					/obj/item/reagent_containers/condiment/sugar,
					/obj/item/food/meat/slab/monkey,
					/obj/item/food/grown/banana = 3,
				)
	crate_name = "food crate"

/datum/supply_pack/organic/randomized/chef/fruits
	name = "Fruit Crate"
	desc = "Rich in vitamins. Contains a lime, orange, watermelon, apple, \
		berries and a lemon."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/food/grown/citrus/lime,
					/obj/item/food/grown/citrus/orange,
					/obj/item/food/grown/watermelon,
					/obj/item/food/grown/apple,
					/obj/item/food/grown/berries,
					/obj/item/food/grown/citrus/lemon,
				)
	crate_name = "food crate"

/datum/supply_pack/organic/cream_piee
	name = "High-yield Clown-grade Cream Pie Crate"
	desc = "Designed by Aussec's Advanced Warfare Research Division, \
		these high-yield, Clown-grade cream pies are powered by a synergy \
		of performance and efficiency. Guaranteed to provide maximum results."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(/obj/item/storage/backpack/duffelbag/clown/cream_pie)
	crate_name = "party equipment crate"
	contraband = TRUE
	access = ACCESS_THEATRE
	access_view = ACCESS_THEATRE
	crate_type = /obj/structure/closet/crate/secure
	discountable = SUPPLY_PACK_RARE_DISCOUNTABLE

/datum/supply_pack/organic/hydroponics
	name = "Hydroponics Crate"
	desc = "Supplies for growing a great garden! Contains two bottles of ammonia, \
		two Plant-B-Gone spray bottles, a hatchet, cultivator, plant analyzer, \
		as well as a pair of leather gloves and a botanist's apron."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/reagent_containers/spray/plantbgone = 2,
					/obj/item/reagent_containers/cup/bottle/ammonia = 2,
					/obj/item/hatchet,
					/obj/item/cultivator,
					/obj/item/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron,
				)
	crate_name = "hydroponics crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/hydroponics/hydrotank
	name = "Hydroponics Backpack Crate"
	desc = "Bring on the flood with this high-capacity backpack crate. \
		Contains 500 units of life-giving H2O."
	cost = CARGO_CRATE_VALUE * 2
	access = ACCESS_HYDROPONICS
	contains = list(/obj/item/watertank)
	crate_name = "hydroponics backpack crate"
	crate_type = /obj/structure/closet/crate/secure/hydroponics

/datum/supply_pack/organic/pizza
	name = "Pizza Crate"
	desc = "Why visit the kitchen when you can have five random pizzas in a fraction of the time? \
			Best prices this side of the galaxy! All deliveries are guaranteed to be 99% anomaly-free."
	cost = CARGO_CRATE_VALUE * 10 // Best prices this side of the galaxy.
	contains = list()
	crate_name = "pizza crate"

	///Whether we've provided an infinite pizza box already this shift or not.
	var/anomalous_box_provided = FALSE
	/// one percent chance for a pizza box to be the ininfite pizza box
	var/infinite_pizza_chance = 1
	///Whether we've provided a bomb pizza box already this shift or not.
	var/boombox_provided = FALSE
	/// three percent chance for a pizza box to be the pizza bomb box
	var/bomb_pizza_chance = 3
	/// 1 in 3 pizza bombs spawned will be a dud
	var/bomb_dud_chance = 33

	/// list of pizza that can randomly go inside of a crate, weighted by how disruptive it would be
	var/list/pizza_types = list(
		/obj/item/food/pizza/margherita = 10,
		/obj/item/food/pizza/meat = 10,
		/obj/item/food/pizza/mushroom = 10,
		/obj/item/food/pizza/vegetable = 10,
		/obj/item/food/pizza/donkpocket = 10,
		/obj/item/food/pizza/dank = 7,
		/obj/item/food/pizza/sassysage = 10,
		/obj/item/food/pizza/pineapple = 10,
		/obj/item/food/pizza/arnold = 3,
		/obj/item/food/pizza/energy = 5
	)

/datum/supply_pack/organic/pizza/fill(obj/structure/closet/crate/new_crate)
	. = ..()
	var/list/rng_pizza_list = pizza_types.Copy()
	for(var/i in 1 to 5)
		if(add_anomalous(new_crate))
			continue
		if(add_boombox(new_crate))
			continue
		add_normal_pizza(new_crate, rng_pizza_list)

/// adds the chance for an infinite pizza box
/datum/supply_pack/organic/pizza/proc/add_anomalous(obj/structure/closet/crate/new_crate)
	if(anomalous_box_provided)
		return FALSE
	if(!prob(infinite_pizza_chance))
		return FALSE
	new /obj/item/pizzabox/infinite(new_crate)
	anomalous_box_provided = TRUE
	log_game("An anomalous pizza box was provided in a pizza crate at during cargo delivery.")
	if(prob(50))
		addtimer(CALLBACK(src, PROC_REF(anomalous_pizza_report)), rand(30 SECONDS, 180 SECONDS))
		message_admins("An anomalous pizza box was provided in a pizza crate at during cargo delivery.")
	else
		message_admins("An anomalous pizza box was silently created with no command report in a pizza crate delivery.")
	return TRUE

/// adds a chance of a pizza bomb replacing a pizza
/datum/supply_pack/organic/pizza/proc/add_boombox(obj/structure/closet/crate/new_crate)
	if(boombox_provided)
		return FALSE
	if(!prob(bomb_pizza_chance))
		return FALSE
	var/boombox_type = (prob(bomb_dud_chance)) ? /obj/item/pizzabox/bomb : /obj/item/pizzabox/bomb/armed
	new boombox_type(new_crate)
	boombox_provided = TRUE
	log_game("A pizza box bomb was created by a pizza crate delivery.")
	message_admins("A pizza box bomb has arrived in a pizza crate delivery.")
	return TRUE

/// adds a randomized pizza from the pizza list
/datum/supply_pack/organic/pizza/proc/add_normal_pizza(obj/structure/closet/crate/new_crate, list/rng_pizza_list)
	var/randomize_pizza = pick_weight(rng_pizza_list)
	rng_pizza_list -= randomize_pizza
	var/obj/item/pizzabox/new_pizza_box = new(new_crate)
	new_pizza_box.pizza = new randomize_pizza
	new_pizza_box.boxtag = new_pizza_box.pizza.boxtag
	new_pizza_box.boxtag_set = TRUE
	new_pizza_box.update_appearance(UPDATE_ICON | UPDATE_DESC)

/// tells crew that an infinite pizza box exists, half of the time, based on a roll in the anamolous box proc
/datum/supply_pack/organic/pizza/proc/anomalous_pizza_report()
	print_command_report("[station_name()], our anomalous materials divison has reported a missing object that is highly likely to have been sent to your station during a routine cargo \
	delivery. Please search all crates and manifests provided with the delivery and return the object if is located. The object resembles a standard <b>\[DATA EXPUNGED\]</b> and is to be \
	considered <b>\[REDACTED\]</b> and returned at your leisure. Note that objects the anomaly produces are specifically attuned exactly to the individual opening the anomaly; regardless \
	of species, the individual will find the object edible and it will taste great according to their personal definitions, which vary significantly based on person and species.")

/datum/supply_pack/organic/potted_plants
	name = "Potted Plants Crate"
	desc = "Spruce up the station with these lovely plants! Contains a random \
		assortment of five potted plants from Nanotrasen's potted plant research division. \
		Warranty void if thrown."
	cost = CARGO_CRATE_VALUE * 1.5
	contains = list(/obj/item/kirbyplants/random = 5)
	crate_name = "potted plants crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/organic/seeds
	name = "Seeds Crate"
	desc = "Big things have small beginnings. Contains fifteen different seeds."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/seeds/chili,
					/obj/item/seeds/cotton,
					/obj/item/seeds/berry,
					/obj/item/seeds/corn,
					/obj/item/seeds/eggplant,
					/obj/item/seeds/tomato,
					/obj/item/seeds/soya,
					/obj/item/seeds/wheat,
					/obj/item/seeds/wheat/rice,
					/obj/item/seeds/carrot,
					/obj/item/seeds/sunflower,
					/obj/item/seeds/rose,
					/obj/item/seeds/chanter,
					/obj/item/seeds/potato,
					/obj/item/seeds/sugarcane,
					/obj/item/seeds/cucumber,
				)
	crate_name = "seeds crate"
	crate_type = /obj/structure/closet/crate/hydroponics

/datum/supply_pack/organic/randomized/chef/vegetables
	name = "Vegetables Crate"
	desc = "Grown in vats. Contains a chili, corn, tomato, potato, carrot, \
		chanterelle, onion, pumpkin, and cucumber."
	cost = CARGO_CRATE_VALUE * 1.8
	contains = list(/obj/item/food/grown/chili,
					/obj/item/food/grown/corn,
					/obj/item/food/grown/tomato,
					/obj/item/food/grown/potato,
					/obj/item/food/grown/carrot,
					/obj/item/food/grown/mushroom/chanterelle,
					/obj/item/food/grown/onion,
					/obj/item/food/grown/pumpkin,
					/obj/item/food/grown/cucumber,
				)
	crate_name = "food crate"

/datum/supply_pack/organic/grill
	name = "Grilling Starter Kit"
	desc = "Hey dad I'm Hungry. Hi Hungry I'm THE NEW GRILLING STARTER KIT \
		ONLY 5000 BUX GET NOW! Contains a grill and fuel."
	cost = CARGO_CRATE_VALUE * 4
	crate_type = /obj/structure/closet/crate
	contains = list(
		/obj/item/stack/sheet/mineral/coal/five,
		/obj/item/kitchen/tongs,
		/obj/item/reagent_containers/cup/soda_cans/monkey_energy,
		/obj/machinery/grill/unwrenched,
	)
	crate_name = "grilling starter kit crate"
	discountable = SUPPLY_PACK_UNCOMMON_DISCOUNTABLE

/datum/supply_pack/organic/grillfuel
	name = "Grilling Fuel Kit"
	desc = "Contains propane and propane accessories. \
		(Note: doesn't contain any actual propane.)"
	cost = CARGO_CRATE_VALUE * 4
	crate_type = /obj/structure/closet/crate
	contains = list(/obj/item/stack/sheet/mineral/coal/ten,
					/obj/item/reagent_containers/cup/soda_cans/monkey_energy,
				)
	crate_name = "grilling fuel kit crate"
	discountable = SUPPLY_PACK_UNCOMMON_DISCOUNTABLE

/datum/supply_pack/organic/tiziran_supply
	name = "Tiziran Supply Box"
	desc = "A packaged box of supplies from the heart of the Lizard Empire. \
		Contains a selection of Tiziran ingredients and basic foods."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/storage/box/tiziran_goods,
					/obj/item/storage/box/tiziran_cans,
					/obj/item/storage/box/tiziran_meats,
				)
	crate_name = "\improper Tiziran Supply box"
	crate_type = /obj/structure/closet/crate/cardboard/tiziran

/datum/supply_pack/organic/mothic_supply
	name = "Mothic Supply Box"
	desc = "A packaged box of surplus supplies from the Mothic Fleet. \
		Contains a selection of Mothic ingredients and basic foods."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/storage/box/mothic_goods,
					/obj/item/storage/box/mothic_cans_sauces,
					/obj/item/storage/box/mothic_rations,
				)
	crate_name = "\improper Mothic Supply box"
	crate_type = /obj/structure/closet/crate/cardboard/mothic

/datum/supply_pack/organic/syrup
	name = "Coffee Syrups Box"
	desc = "A packaged box of various syrups, perfect for making your delicious coffee even more diabetic."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel,
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/liqueur,
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/korta_nectar,
	)
	crate_name = "coffee syrups box"
	crate_type = /obj/structure/closet/crate/cardboard

/datum/supply_pack/organic/syrup_contraband
	contraband = TRUE
	name = "Contraband Syrups Box"
	desc = "A packaged box containing illegal coffee syrups. Possession of these carries a penalty established in the galactic penal code."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/laughsyrup,
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/laughsyrup,
	)
	crate_name = "illegal syrups box"
	crate_type = /obj/structure/closet/crate/cardboard

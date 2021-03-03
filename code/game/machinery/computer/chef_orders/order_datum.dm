
#define CATEGORY_FRUITS_VEGGIES 1
#define CATEGORY_MILK_EGGS 2
#define CATEGORY_SAUCES_REAGENTS 3

///A datum for chef ordering options from the chef's computer.
/datum/orderable_item
	var/name = "Orderable Item Name"
	//description set automatically unless it's hard set by the subtype
	var/desc
	var/category_index = CATEGORY_FRUITS_VEGGIES
	var/obj/item/item_instance
	var/cost_per_order = 10

/datum/orderable_item/New()
	. = ..()
	if(type == /datum/orderable_item)
		return
	if(!item_instance)
		CRASH("[type] orderable item datum has NO ITEM PATH!")
	item_instance = new item_instance
	if(!desc)
		desc = item_instance.desc

/datum/orderable_item/Destroy(force, ...)
	. = ..()
	qdel(item_instance)

//Fruits and Veggies

/datum/orderable_item/potato
	name = "Potato"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/potato

/datum/orderable_item/tomato
	name = "Tomato"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/tomato

/datum/orderable_item/carrot
	name = "Carrot"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/carrot

/datum/orderable_item/eggplant
	name = "Eggplant"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/eggplant

/datum/orderable_item/mushroom
	name = "Plump Helmet"
	desc = "Plumus Hellmus: Plump, soft and s-so inviting~"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/mushroom/plumphelmet

/datum/orderable_item/cabbage
	name = "Cabbage"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/cabbage

/datum/orderable_item/beets
	name = "Onion"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/onion

/datum/orderable_item/apple
	name = "Apple"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance =/obj/item/food/grown/apple

/datum/orderable_item/pumpkin
	name = "Pumpkin"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance =/obj/item/food/grown/pumpkin

/datum/orderable_item/watermelon
	name = "Watermelon"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance =/obj/item/food/grown/watermelon

/datum/orderable_item/corn
	name = "Corn"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/corn

/datum/orderable_item/soybean
	name = "Soybeans"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/soybeans

/datum/orderable_item/garlic
	name = "Garlic"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/garlic

/datum/orderable_item/cherries
	name = "Cherries"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/cherries

//Milk and Eggs

/datum/orderable_item/milk
	name = "Milk"
	category_index = CATEGORY_MILK_EGGS
	item_instance = /obj/item/reagent_containers/food/condiment/milk
	cost_per_order = 30

/datum/orderable_item/soymilk
	name = "Soy Milk"
	category_index = CATEGORY_MILK_EGGS
	item_instance = /obj/item/reagent_containers/food/condiment/soymilk
	cost_per_order = 30

/datum/orderable_item/eggs
	name = "Egg Carton"
	category_index = CATEGORY_MILK_EGGS
	item_instance = /obj/item/storage/fancy/egg_box
	cost_per_order = 40

/datum/orderable_item/fillet
	name = "Fish Fillet"
	category_index = CATEGORY_MILK_EGGS
	item_instance = /obj/item/food/fishmeat
	cost_per_order = 12

/datum/orderable_item/spider_eggs
	name = "Spider Eggs"
	category_index = CATEGORY_MILK_EGGS
	item_instance = /obj/item/food/spidereggs

//Reagents

/datum/orderable_item/flour
	name = "Flour Sack"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/flour
	cost_per_order = 30

/datum/orderable_item/sugar
	name = "Sugar Sack"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/sugar
	cost_per_order = 30

/datum/orderable_item/enzyme
	name = "Universal Enzyme"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/enzyme
	cost_per_order = 40

/datum/orderable_item/salt
	name = "Salt Shaker"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/saltshaker
	cost_per_order = 15

/datum/orderable_item/pepper
	name = "Pepper Mill"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/peppermill
	cost_per_order = 15

/datum/orderable_item/soysauce
	name = "Soy Sauce"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/soysauce
	cost_per_order = 15

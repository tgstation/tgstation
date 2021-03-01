
#define CATEGORY_FRUITS_VEGGIES 1
#define CATEGORY_MILK_EGGS 2
#define CATEGORY_SAUCES_REAGENTS 3

///A datum for chef ordering options from the chef's computer.
/datum/orderable_item
	var/name = "Orderable Item Name"
	var/desc = "Description Gets Set By The Item Itself"
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
	desc = item_instance.desc

/datum/orderable_item/Destroy(force, ...)
	. = ..()
	qdel(item_instance)

//Fruits and Veggies

/datum/orderable_item/potatoes
	name = "Potato"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/potato

/datum/orderable_item/tomatoes
	name = "Tomato"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/tomato

/datum/orderable_item/garlic
	name = "Garlic"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/food/grown/garlic

//Milk and Eggs

/datum/orderable_item/milk
	name = "Milk"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/reagent_containers/food/condiment/milk
	cost_per_order = 30

/datum/orderable_item/soymilk
	name = "Soy Milk"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/reagent_containers/food/condiment/soymilk
	cost_per_order = 30

/datum/orderable_item/eggs
	name = "Egg Carton"
	category_index = CATEGORY_FRUITS_VEGGIES
	item_instance = /obj/item/storage/fancy/egg_box
	cost_per_order = 40

//Reagents

/datum/orderable_item/flour
	name = "Flour Sack"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/flour
	cost_per_order = 30

/datum/orderable_item/enzyme
	name = "Universal Enzyme"
	category_index = CATEGORY_SAUCES_REAGENTS
	item_instance = /obj/item/reagent_containers/food/condiment/enzyme
	cost_per_order = 40

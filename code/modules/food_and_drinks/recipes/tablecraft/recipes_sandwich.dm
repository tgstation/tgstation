
// see code/datums/recipe.dm


// see code/module/crafting/table.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/crafting_recipe/food/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/cheese = 1
	)
	result = /obj/item/food/sandwich
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/food/cheese_sandwich
	name = "Cheese sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/cheese = 2
	)
	result = /obj/item/food/cheese_sandwich
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/food/slimesandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	result = /obj/item/food/jellysandwich/slime
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/food/cherrysandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	result = /obj/item/food/jellysandwich/cherry
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/food/notasandwich
	name = "Not a sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	result = /obj/item/food/notasandwich
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/food/hotdog
	name = "Hot dog"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/sausage = 1
	)
	result = /obj/item/food/hotdog
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/food/blt
	name = "BLT"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/bacon = 2,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/blt
	subcategory = CAT_SANDWICH


// see code/datums/recipe.dm


// see code/module/crafting/table.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/crafting_recipe/food/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/cheese/wedge = 1
	)
	result = /obj/item/food/sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cheese_sandwich
	name = "Cheese sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/cheese/wedge = 2
	)
	result = /obj/item/food/cheese_sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/slimesandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	result = /obj/item/food/jellysandwich/slime
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cherrysandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	result = /obj/item/food/jellysandwich/cherry
	category = CAT_SANDWICH

/datum/crafting_recipe/food/notasandwich
	name = "Not a sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	result = /obj/item/food/notasandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/hotdog
	name = "Hot dog"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/sausage = 1
	)
	result = /obj/item/food/hotdog
	category = CAT_SANDWICH

/datum/crafting_recipe/food/danish_hotdog
	name = "Danish hot dog"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/sausage = 1,
		/obj/item/food/pickle = 1,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/danish_hotdog
	category = CAT_SANDWICH

/datum/crafting_recipe/food/blt
	name = "BLT"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/bacon = 2,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/blt
	category = CAT_SANDWICH

/datum/crafting_recipe/food/peanut_butter_jelly_sandwich
	name = "Peanut butter and jelly sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/datum/reagent/consumable/peanut_butter = 5,
		/datum/reagent/consumable/cherryjelly = 5
	)
	result = /obj/item/food/peanut_butter_jelly_sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/peanut_butter_banana_sandwich
	name = "Peanut butter and banana sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/peanut_butter_banana_sandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/philly_cheesesteak
	name = "Philly Cheesesteak"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/philly_cheesesteak
	category = CAT_SANDWICH


// see code/datums/recipe.dm


// see code/module/crafting/table.dm

////////////////////////////////////////////////SANDWICHES////////////////////////////////////////////////

/datum/crafting_recipe/food/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/grown/cabbage = 1,
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
	result = /obj/item/food/sandwich/cheese
	category = CAT_SANDWICH

/datum/crafting_recipe/food/slimesandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	added_foodtypes = TOXIC
	result = /obj/item/food/sandwich/jelly/slime
	category = CAT_SANDWICH

/datum/crafting_recipe/food/cherrysandwich
	name = "Jelly sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 2,
	)
	added_foodtypes = FRUIT|SUGAR
	result = /obj/item/food/sandwich/jelly/cherry
	category = CAT_SANDWICH

/datum/crafting_recipe/food/notasandwich
	name = "Not a sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/clothing/mask/fakemoustache = 1
	)
	added_foodtypes = GROSS
	result = /obj/item/food/sandwich/notasandwich
	category = CAT_SANDWICH

/datum/crafting_recipe/food/hotdog
	name = "Hot dog"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/sausage = 1
	)
	result = /obj/item/food/hotdog
	removed_foodtypes = BREAKFAST
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
	removed_foodtypes = BREAKFAST
	category = CAT_SANDWICH

/datum/crafting_recipe/food/blt
	name = "BLT"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/bacon = 2,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/sandwich/blt
	category = CAT_SANDWICH

/datum/crafting_recipe/food/peanut_butter_jelly_sandwich
	name = "Peanut butter and jelly sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/datum/reagent/consumable/peanut_butter = 5,
		/datum/reagent/consumable/cherryjelly = 5
	)
	result = /obj/item/food/sandwich/peanut_butter_jelly
	added_foodtypes = FRUIT|NUTS
	category = CAT_SANDWICH

/datum/crafting_recipe/food/peanut_butter_banana_sandwich
	name = "Peanut butter and banana sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/datum/reagent/consumable/peanut_butter = 5,
		/obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/sandwich/peanut_butter_banana
	added_foodtypes = NUTS
	category = CAT_SANDWICH

/datum/crafting_recipe/food/philly_cheesesteak
	name = "Philly Cheesesteak"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/sandwich/philly_cheesesteak
	category = CAT_SANDWICH

/datum/crafting_recipe/food/death_sandwich
	name = "Death Sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/salami = 4,
		/obj/item/food/meatball = 4,
		/obj/item/food/grown/tomato = 1,
	)
	result = /obj/item/food/sandwich/death
	category = CAT_SANDWICH
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/food/toast_sandwich
	name = "Toast Sandwich"
	reqs = list(
		/obj/item/food/breadslice/plain = 2,
		/obj/item/food/butteredtoast = 1,
	)
	result = /obj/item/food/sandwich/toast_sandwich
	removed_foodtypes = BREAKFAST
	category = CAT_SANDWICH

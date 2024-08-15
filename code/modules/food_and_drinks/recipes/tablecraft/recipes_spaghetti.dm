
// see code/module/crafting/table.dm

////////////////////////////////////////////////SPAGHETTI////////////////////////////////////////////////

/datum/crafting_recipe/food/tomatopasta
	name = "Tomato pasta"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/grown/tomato = 2
	)
	result = /obj/item/food/spaghetti/pastatomato
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/copypasta
	name = "Copypasta"
	reqs = list(
		/obj/item/food/spaghetti/pastatomato = 2
	)
	result = /obj/item/food/spaghetti/copypasta
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spaghettimeatball
	name = "Spaghetti meatball"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meatball = 2
	)
	result = /obj/item/food/spaghetti/meatballspaghetti
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/spesslaw
	name = "Spesslaw"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meatball = 4
	)
	result = /obj/item/food/spaghetti/spesslaw
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/beefnoodle
	name = "Beef noodle"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/spaghetti/beefnoodle
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/chowmein
	name = "Chowmein"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/cabbage = 2,
		/obj/item/food/grown/carrot = 1
	)
	result = /obj/item/food/spaghetti/chowmein
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/butternoodles
	name = "Butter Noodles"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/butterslice = 1
	)
	result = /obj/item/food/spaghetti/butternoodles
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/mac_n_cheese
	name = "Mac n' cheese"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/bechamel_sauce = 1,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/breadslice/plain = 1,
		/datum/reagent/consumable/blackpepper = 2
	)
	result = /obj/item/food/spaghetti/mac_n_cheese
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/shoyu_tonkotsu_ramen
	name = "Shoyu Tonkotsu ramen"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/seaweedsheet = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/onion = 1,
	)
	result = /obj/item/food/spaghetti/shoyu_tonkotsu_ramen
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/kitakata_ramen
	name = "Kitakata ramen"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/obj/item/food/grown/garlic = 1,
	)
	result = /obj/item/food/spaghetti/kitakata_ramen
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/kitsune_udon
	name = "Kitsune udon"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/tofu = 2,
		/obj/item/food/grown/onion = 1,
		/datum/reagent/consumable/soysauce = 5,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/spaghetti/kitsune_udon
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/nikujaga
	name = "Nikujaga"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/peas = 1,
	)
	result = /obj/item/food/spaghetti/nikujaga
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/pho
	name = "Pho"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	result = /obj/item/food/spaghetti/pho
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/pad_thai
	name = "Pad thai"
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/peanut = 1,
		/obj/item/food/grown/citrus/lime = 1,
	)
	result = /obj/item/food/spaghetti/pad_thai
	category = CAT_SPAGHETTI

/datum/crafting_recipe/food/carbonara
	name = "Spaghetti Carbonara"
	reqs = list(
		/obj/item/food/spaghetti/boiledspaghetti = 1,
		/obj/item/food/cheese/firm_cheese_slice = 1,
		/obj/item/food/meat/bacon = 1,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/blackpepper = 2,
	)
	result = /obj/item/food/spaghetti/carbonara
	category = CAT_SPAGHETTI

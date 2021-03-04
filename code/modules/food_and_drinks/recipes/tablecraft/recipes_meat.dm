// see code/module/crafting/table.dm

////////////////////////////////////////////////KEBABS////////////////////////////////////////////////

/datum/crafting_recipe/food/humankebab
	name = "Human kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/meat/steak/plain/human = 2
	)
	result = /obj/item/food/kebab/human
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/kebab
	name = "Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/meat/steak = 2
	)
	result = /obj/item/food/kebab/monkey
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/tofukebab
	name = "Tofu kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/tofu = 2
	)
	result = /obj/item/food/kebab/tofu
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/tailkebab
	name = "Lizard tail kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/organ/tail/lizard = 1
	)
	result = /obj/item/food/kebab/tail
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fiestaskewer
	name = "Fiesta Skewer"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/kebab/fiesta
	subcategory = CAT_MEAT

////////////////////////////////////////////////FISH////////////////////////////////////////////////

/datum/crafting_recipe/food/cubancarp
	name = "Cuban carp"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/fishmeat/carp = 1
	)
	result = /obj/item/food/cubancarp
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fishandchips
	name = "Fish and chips"
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/fishmeat = 1
	)
	result = /obj/item/food/fishandchips
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fishfingers
	name = "Fish fingers"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/fishmeat = 1
	)
	result = /obj/item/food/fishfingers
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/fishfry
	name = "Fish fry"
	reqs = list(
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/peas = 1,
		/obj/item/food/fishmeat = 1
	)
	result = /obj/item/food/fishfry
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/sashimi
	name = "Sashimi"
	reqs = list(
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/fishmeat = 1
	)
	result = /obj/item/food/sashimi
	subcategory = CAT_MEAT

////////////////////////////////////////////////MR SPIDER////////////////////////////////////////////////

/datum/crafting_recipe/food/spidereggsham
	name = "Spider eggs ham"
	reqs = list(
		/datum/reagent/consumable/salt = 1,
		/obj/item/food/spidereggs = 1,
		/obj/item/food/meat/cutlet/spider = 2
	)
	result = /obj/item/food/spidereggsham
	subcategory = CAT_MEAT

////////////////////////////////////////////////MISC RECIPE's////////////////////////////////////////////////

/datum/crafting_recipe/food/cornedbeef
	name = "Corned beef"
	reqs = list(
		/datum/reagent/consumable/salt = 5,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/grown/cabbage = 2
	)
	result = /obj/item/food/cornedbeef
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/bearsteak
	name = "Filet migrawr"
	reqs = list(
		/datum/reagent/consumable/ethanol/manly_dorf = 5,
		/obj/item/food/meat/steak/bear = 1,
	)
	tool_paths = list(/obj/item/lighter)
	result = /obj/item/food/bearsteak
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/enchiladas
	name = "Enchiladas"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 2,
		/obj/item/food/tortilla = 2
	)
	result = /obj/item/food/enchiladas
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/stewedsoymeat
	name = "Stewed soymeat"
	reqs = list(
		/obj/item/food/soydope = 2,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/stewedsoymeat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/sausage
	name = "Raw sausage"
	reqs = list(
		/obj/item/food/raw_meatball = 1,
		/obj/item/food/meat/rawcutlet = 2
	)
	result = /obj/item/food/raw_sausage
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/nugget
	name = "Chicken nugget"
	reqs = list(
		/obj/item/food/meat/cutlet = 1
	)
	result = /obj/item/food/nugget
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/rawkhinkali
	name = "Raw Khinkali"
	reqs = list(
		/obj/item/food/doughslice = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/meatball = 1
	)
	result =  /obj/item/food/rawkhinkali
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/pigblanket
	name = "Pig in a Blanket"
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 1,
		/obj/item/food/meat/cutlet = 1
	)
	result = /obj/item/food/pigblanket
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ratkebab
	name = "Rat Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/deadmouse = 1
	)
	result = /obj/item/food/kebab/rat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/doubleratkebab
	name = "Double Rat Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/deadmouse = 2
	)
	result = /obj/item/food/kebab/rat/double
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ricepork
	name = "Rice and Pork"
	reqs = list(
		/obj/item/food/salad/boiledrice = 1,
		/obj/item/food/meat/cutlet = 2
	)
	result = /obj/item/food/salad/ricepork
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/ribs
	name = "BBQ Ribs"
	reqs = list(
		/datum/reagent/consumable/bbqsauce = 5,
		/obj/item/food/meat/steak/plain = 2,
		/obj/item/stack/rods = 2
	)
	result = /obj/item/food/bbqribs
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/meatclown
	name = "Meat Clown"
	reqs = list(
		/obj/item/food/meat/steak/plain = 1,
		/obj/item/food/grown/banana = 1
	)
	result = /obj/item/food/meatclown
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/lasagna
	name = "Lasagna"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/cheese = 2,
		/obj/item/food/spaghetti = 1
	)
	result = /obj/item/food/lasagna
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/gumbo
	name = "Black eyed gumbo"
	reqs = list(
		/obj/item/food/salad/boiledrice = 1,
		/obj/item/food/grown/peas = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/meat/cutlet = 1
	)
	result = /obj/item/food/salad/gumbo
	subcategory = CAT_MEAT


/datum/crafting_recipe/food/fried_chicken
	name = "Fried Chicken"
	reqs = list(
		/obj/item/food/meat/slab/chicken = 1,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/corn_starch = 5,
	)
	result = /obj/item/food/fried_chicken
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/beef_stroganoff
	name = "Beef Stroganoff"
	reqs = list(
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/consumable/salt = 5,
		/datum/reagent/consumable/blackpepper = 5,
		/obj/item/food/grown/mushroom = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/steak = 1,
	)
	result = /obj/item/food/beef_stroganoff
	subcategory = CAT_MEAT

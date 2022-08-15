/datum/crafting_recipe/food/tiziran_sausage
	name = "Raw Tiziran blood sausage"
	reqs = list(
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/meat/rawbacon = 1,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/salt = 2
	)
	result = /obj/item/food/raw_tiziran_sausage
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/headcheese
	name = "Raw headcheese"
	reqs = list(
		/obj/item/food/meat/slab = 1,
		/datum/reagent/consumable/salt = 10,
		/datum/reagent/consumable/blackpepper = 5
	)
	result = /obj/item/food/raw_headcheese
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/shredded_lungs
	name = "Crispy shredded lung stirfry"
	reqs = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/chili = 1
	)
	result = /obj/item/food/shredded_lungs
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/tsatsikh
	name = "Tsatsikh"
	reqs = list(
		/obj/item/organ/internal/heart = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/organ/internal/lungs = 1,
		/obj/item/organ/internal/stomach = 1,
		/datum/reagent/consumable/salt = 2,
		/datum/reagent/consumable/blackpepper = 2
	)
	result = /obj/item/food/tsatsikh
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/liver_pate
	name = "Liver pate"
	reqs = list(
		/obj/item/organ/internal/liver = 1,
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/grown/onion = 1
	)
	result = /obj/item/food/liver_pate
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/moonfish_caviar
	name = "Moonfish caviar paste"
	reqs = list(
		/obj/item/food/moonfish_eggs = 1,
		/datum/reagent/consumable/salt = 2
	)
	result = /obj/item/food/moonfish_caviar
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_escargot
	name = "Desert snail cocleas"
	reqs = list(
		/obj/item/food/desert_snails = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/lemonjuice = 3,
		/datum/reagent/consumable/blackpepper = 2,
		/datum/reagent/consumable/quality_oil = 3
	)
	result = /obj/item/food/lizard_escargot
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/fried_blood_sausage
	name = "Fried blood sausage"
	reqs = list(
		/obj/item/food/raw_tiziran_sausage = 1,
		/datum/reagent/consumable/korta_flour = 5,
		/datum/reagent/water = 5
	)
	result = /obj/item/food/fried_blood_sausage
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_fries
	name = "Loaded poms-franzisks"
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/meat/cutlet = 2,
		/datum/reagent/consumable/bbqsauce = 5
	)
	result = /obj/item/food/lizard_fries
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/brain_pate
	name = "Eyeball-and-brain pate"
	reqs = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/organ/internal/eyes = 1,
		/obj/item/food/grown/onion = 1,
		/datum/reagent/consumable/salt = 3
	)
	result = /obj/item/food/brain_pate
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/crispy_headcheese
	name = "Crispy breaded headcheese"
	reqs = list(
		/obj/item/food/headcheese_slice = 1,
		/obj/item/food/breadslice/root = 1
	)
	result = /obj/item/food/crispy_headcheese
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/picoss_skewers
	name = "Picoss skewers"
	reqs = list(
		/obj/item/food/fishmeat/armorfish = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/stack/rods = 1,
		/datum/reagent/consumable/vinegar = 5
	)
	result = /obj/item/food/kebab/picoss_skewers
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/nectar_larvae
	name = "Nectar larvae"
	reqs = list(
		/obj/item/food/larvae = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/grown/chili = 1,
		/datum/reagent/consumable/korta_nectar = 5
	)
	result = /obj/item/food/nectar_larvae
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/mushroomy_stirfry
	name = "Mushroomy Stirfry"
	reqs = list(
		/obj/item/food/steeped_mushrooms = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1,
		/datum/reagent/consumable/quality_oil = 5
	)
	result = /obj/item/food/mushroomy_stirfry
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/moonfish_demiglace
	name = "Moonfish demiglace"
	reqs = list(
		/obj/item/food/grilled_moonfish = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/datum/reagent/consumable/korta_milk = 5,
		/datum/reagent/consumable/ethanol/wine = 5
	)
	result = /obj/item/food/moonfish_demiglace
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_surf_n_turf
	name = "Zagosk surf n turf smorgasbord"
	reqs = list(
		/obj/item/food/grilled_moonfish = 1,
		/obj/item/food/kebab/picoss_skewers = 2,
		/obj/item/food/meat/steak = 1,
		/obj/item/food/bbqribs = 1
	)
	result = /obj/item/food/lizard_surf_n_turf
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/rootdough
	name = "Rootdough"
	reqs = list(
		/obj/item/food/grown/potato = 2,
		/obj/item/food/egg = 1,
		/datum/reagent/consumable/korta_flour = 5,
		/datum/reagent/water = 10
	)
	result = /obj/item/food/rootdough
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/snail_nizaya
	name = "Desert snail nizaya"
	reqs = list(
		/obj/item/food/desert_snails = 1,
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/ethanol/wine = 5
	)
	result = /obj/item/food/spaghetti/snail_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/garlic_nizaya
	name = "Garlic nizaya"
	reqs = list(
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/datum/reagent/consumable/quality_oil = 5
	)
	result = /obj/item/food/spaghetti/garlic_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/demit_nizaya
	name = "Demit nizaya"
	reqs = list(
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/eggplant = 1,
		/datum/reagent/consumable/korta_milk = 5,
		/datum/reagent/consumable/korta_nectar = 5
	)
	result = /obj/item/food/spaghetti/demit_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/mushroom_nizaya
	name = "Mushroom nizaya"
	reqs = list(
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/steeped_mushrooms = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/quality_oil = 5
	)
	result = /obj/item/food/spaghetti/mushroom_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/rustic_flatbread
	name = "Rustic flatbread"
	reqs = list(
		/obj/item/food/root_flatbread = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/lemonjuice = 2,
		/datum/reagent/consumable/quality_oil = 3
	)
	result = /obj/item/food/pizza/rustic_flatbread
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/italic_flatbread
	name = "Italic flatbread"
	reqs = list(
		/obj/item/food/root_flatbread = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meatball = 2,
		/datum/reagent/consumable/quality_oil = 3
	)
	result = /obj/item/food/pizza/italic_flatbread
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/imperial_flatbread
	name = "Imperial flatbread"
	reqs = list(
		/obj/item/food/root_flatbread = 1,
		/obj/item/food/liver_pate = 1,
		/obj/item/food/sauerkraut = 1,
		/obj/item/food/headcheese = 1
	)
	result = /obj/item/food/pizza/imperial_flatbread
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/emperor_roll
	name = "Emperor roll"
	reqs = list(
		/obj/item/food/rootroll = 1,
		/obj/item/food/liver_pate = 1,
		/obj/item/food/headcheese_slice = 2,
		/obj/item/food/moonfish_caviar = 1
	)
	result = /obj/item/food/emperor_roll
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/honey_sweetroll
	name = "Honey sweetroll"
	reqs = list(
		/obj/item/food/rootroll = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/food/grown/banana = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/honey_roll
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/atrakor_dumplings
	name = "Atrakor dumpling soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/lizard_dumplings = 1,
		/datum/reagent/consumable/soysauce = 5
	)
	result = /obj/item/food/soup/atrakor_dumplings
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/meatball_noodles
	name = "Meatball noodle soup"
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/spaghetti/nizaya = 1,
		/obj/item/food/meatball = 2,
		/obj/item/food/grown/peanut = 1
	)
	result = /obj/item/food/soup/meatball_noodles
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/black_broth
	name = "Tiziran black broth"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/tiziran_sausage = 1,
		/obj/item/food/grown/onion = 1,
		/datum/reagent/consumable/vinegar = 5,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/ice = 2
	)
	result = /obj/item/food/soup/black_broth
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/jellyfish_stew
	name = "Jellyfish stew"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/canned_jellyfish = 1,
		/obj/item/food/grown/soybeans = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/potato = 1
	)
	result = /obj/item/food/soup/jellyfish
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/rootbread_soup
	name = "Rootbread soup"
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/breadslice/root = 2,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 1
	)
	result = /obj/item/food/soup/rootbread_soup
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/black_eggs
	name = "Black scrambled eggs"
	reqs = list(
		/obj/item/food/egg = 2,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/vinegar = 2
	)
	result = /obj/item/food/black_eggs
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/patzikula
	name = "Patzikula"
	reqs = list(
		/obj/item/food/grown/tomato = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 2
	)
	result = /obj/item/food/patzikula
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/korta_brittle
	name = "Korta brittle slab"
	reqs = list(
		/obj/item/food/grown/korta_nut = 2,
		/obj/item/food/butter = 1,
		/datum/reagent/consumable/korta_nectar = 5,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/salt = 2
	)
	result = /obj/item/food/cake/korta_brittle
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/korta_ice
	name = "Korta ice"
	reqs = list(
		/obj/item/reagent_containers/food/drinks/sillycup = 1,
		/datum/reagent/consumable/ice = 15,
		/datum/reagent/consumable/korta_nectar = 5,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/snowcones/korta_ice
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/candied_mushrooms
	name = "Candied mushrooms"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/food/steeped_mushrooms = 1,
		/datum/reagent/consumable/caramel = 5,
		/datum/reagent/consumable/salt = 1
	)
	result = /obj/item/food/kebab/candied_mushrooms
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/sauerkraut
	name = "Sauerkraut"
	reqs = list(
		/obj/item/food/grown/cabbage = 2,
		/datum/reagent/consumable/salt = 10
	)
	result = /obj/item/food/sauerkraut
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_dumplings
	name = "Tiziran dumplings"
	reqs = list(
		/obj/item/food/grown/potato = 1,
		/datum/reagent/consumable/korta_flour = 5
	)
	result = /obj/item/food/lizard_dumplings
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/steeped_mushrooms
	name = "Steeped mushrooms"
	reqs = list(
		/obj/item/food/grown/ash_flora/seraka = 1,
		/datum/reagent/lye = 5
	)
	result = /obj/item/food/steeped_mushrooms
	subcategory = CAT_LIZARD

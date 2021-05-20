/datum/crafting_recipe/food/tiziran_sausage
	name = "Tiziran blood sausage"
	always_available = FALSE
	reqs = list(
		/obj/item/food/raw_cutlet = 1,
		/obj/item/food/meat/rawbacon = 1,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/salt = 2
	)
	result = /obj/item/food/raw_tiziran_sausage
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/headcheese
	name = "Headcheese"
	always_available = FALSE
	reqs = list(
		/obj/item/food/meat/slab = 1,
		/datum/reagent/consumable/salt = 10,
		/datum/reagent/consumable/blackpepper = 5
	)

/datum/crafting_recipe/food/shredded_lungs
	name = "Crispy shredded lung stirfry"
	always_available = FALSE
	reqs = list(
		/obj/item/organ/lungs = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/chili = 1
	)
	result = /obj/item/food/shredded_lungs
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/tsatsikh
	name = "Tsatsikh"
	always_available = FALSE
	reqs = list(
		/obj/item/organ/heart = 1,
		/obj/item/organ/liver = 1,
		/obj/item/organ/lungs = 1,
		/obj/item/organ/stomach = 1,
		/datum/reagent/consumable/salt = 2,
		/datum/reagent/consumable/pepper = 2
	)
	result = /obj/item/food/tsatsikh
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/liver_pate
	name = "Liver pate"
	reqs = list(
		/obj/item/organ/liver = 1,
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/grown/onion = 1
	)
	result = /obj/item/food/liver_pate
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/moonfish_caviar
	name = "Moonfish caviar paste"
	always_available = FALSE
	reqs = list(
		/obj/item/food/moonfish_eggs = 1,
		/datum/reagent/consumable/salt = 2
	)
	result = /obj/item/food/moonfish_caviar
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_escargot
	name = "Desert snail cocleas"
	always_available = FALSE
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
	always_available = FALSE
	reqs = list(
		/obj/item/food/raw_tiziran_sausage = 1,
		/datum/reagent/consumable/korta_flour = 5,
		/datum/reagent/water = 5
	)
	result = /obj/item/food/fried_blood_sausage
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_fries
	name = "Loaded poms-franzisks"
	always_available = FALSE
	reqs = list(
		/obj/item/food/fries = 1,
		/obj/item/food/meat/cutlet = 2,
		/datum/reagent/consumable/bbqsauce = 5
	)
	result = /obj/item/food/lizard_fries
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/brain_pate
	name = "Eyeball-and-brain pate"
	always_available = FALSE
	reqs = list(
		/obj/item/organ/brain = 1,
		/obj/item/organ/eyes = 1,
		/obj/item/food/grown/onion = 1,
		/datum/reagent/consumable/salt = 3
	)
	result = /obj/item/food/brain_pate
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/crispy_headcheese
	name = "Crispy breaded headcheese"
	always_available = FALSE
	reqs = list(
		/obj/item/food/headcheese/slice = 1,
		/obj/item/food/breadslice/root = 1
	)
	result = /obj/item/food/crispy_headcheese
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/picoss_skewers
	name = "Picoss skewers"
	always_available = FALSE
	reqs = list(
		/obj/item/food/meat = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/stack/rods = 1,
		/datum/reagent/consumable/vinegar = 5
	)
	result = /obj/item/food/picoss_skewers
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/rootdough
	name = "Rootdough"
	always_available = FALSE
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
	always_available = FALSE
	reqs = list(
		/obj/item/food/desert_snails = 1,
		/obj/item/food/nizaya = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/ethanol/wine = 5
	)
	result = /obj/item/food/snail_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/garlic_nizaya
	name = "Garlic nizaya"
	always_available = FALSE
	reqs = list(
		/obj/item/food/nizaya = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/chili = 1,
		/datum/reagent/consumable/quality_oil = 5
	)
	result = /obj/item/food/garlic_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/demit_nizaya
	name = "Demit nizaya"
	always_available = FALSE
	reqs = list(
		/obj/item/food/nizaya = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/eggplant = 1,
		/datum/reagent/consumable/korta_milk = 5,
		/datum/reagent/consumable/korta_nectar = 5
	)
	result = /obj/item/food/demit_nizaya
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/rustic_flatbread
	name = "Rustic flatbread"
	always_available = FALSE
	reqs = list(
		/obj/item/food/root_flatbread = 1,
		/obj/item/food/grown/garlic = 1,
		/datum/reagent/consumable/lemonjuice = 2,
		/datum/reagent/consumable/quality_oil = 3
	)
	result = /obj/item/food/rustic_flatbread
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/italic_flatbread
	name = "Italic flatbread"
	always_available = FALSE
	reqs = list(
		/obj/item/food/root_flatbread = 1,
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meatball = 2,
		/datum/reagent/consumable/quality_oil = 3
	)
	result = /obj/item/food/italic_flatbread
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/imperial_flatbread
	name = "Imperial flatbread"
	always_available = FALSE
	reqs = list(
		/obj/item/food/root_flatbread = 1,
		/obj/item/food/liver_pate = 1,
		/obj/item/food/sauerkraut = 1,
		/obj/item/food/headcheese = 1
	)
	result = /obj/item/food/imperial_flatbread
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/emperor_roll
	name = "Emperor roll"
	always_available = FALSE
	reqs = list(
		/obj/item/food/rootroll = 1,
		/obj/item/food/liver_pate = 1,
		/obj/item/food/headcheese/slice = 2,
		/obj/item/food/moonfish_caviar = 1
	)
	result = /obj/item/food/emperor_roll
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/atrakor_dumplings
	name = "Atrakor dumpling soup"
	always_available = FALSE
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/lizard_dumplings = 1,
		/datum/reagent/consumable/soysauce = 5
	)
	result = /obj/item/food/atrakor_dumplings
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/meatball_noodles
	name = "Meatball noodle soup"
	always_available = FALSE
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/meat/rawcutlet = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/nizaya = 1,
		/obj/item/food/meatball = 2,
		/obj/item/food/peanuts = 1
	)
	result = /obj/item/food/meatball_noodles
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/black_broth
	name = "Tiziran black broth"
	always_available = FALSE
	reqs = list(
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/food/tiziran_sausage = 1,
		/obj/item/food/grown/onion = 1,
		/datum/reagent/consumable/vinegar = 5,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/ice = 2
	)
	result = /obj/item/food/black_broth
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/black_eggs
	name = "Black scrambled eggs"
	always_available = FALSE
	reqs = list(
		/obj/item/food/egg = 2,
		/datum/reagent/blood = 5,
		/datum/reagent/consumable/vinegar = 2
	)
	result = /obj/item/food/black_eggs
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/patzikula
	name = "Patzikula"
	always_available = FALSE
	reqs = list(
		/obj/item/food/grown/tomato = 2,
		/obj/item/food/grown/onion = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/egg = 2
	)
	result = /obj/item/food/patzikula
	subcategory = CAT_LIZARD

/datum/crafting_recipe/food/lizard_dumplings
	name = "Tiziran dumplings"
	always_available = FALSE
	reqs = list(
		/obj/item/food/grown/potato = 1,
		/datum/reagent/consumable/korta_flour = 5
	)
	result = /obj/item/food/lizard_dumplings
	subcategory = CAT_LIZARD

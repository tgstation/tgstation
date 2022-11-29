// Recipes that provide crafting instructions and don't yield any result

// Food reactions

/datum/crafting_recipe/food/reaction
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/reaction/tofu
	reaction = /datum/chemical_reaction/food/tofu
	result = /obj/item/food/tofu

/datum/crafting_recipe/food/reaction/candycorn
	reaction = /datum/chemical_reaction/food/candycorn
	result = /obj/item/food/candy_corn
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/reaction/chocolatepudding
	reaction = /datum/chemical_reaction/food/chocolatepudding
	result = /datum/reagent/consumable/chocolatepudding
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/reaction/vanillapudding
	reaction = /datum/chemical_reaction/food/vanillapudding
	result = /datum/reagent/consumable/vanillapudding
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/reaction/chocolatebar
	name = "Chocolate bar"
	reaction = /datum/chemical_reaction/food/chocolate_bar3
	result = /obj/item/food/chocolatebar
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/reaction/chocolatebar/chocomilk
	name = "Chocolate bar (choco milk)"
	reaction = /datum/chemical_reaction/food/chocolate_bar2

/datum/crafting_recipe/food/reaction/chocolatebar/vegan
	name = "Chocolate bar (vegan)"
	reaction = /datum/chemical_reaction/food/chocolate_bar

/datum/crafting_recipe/food/reaction/soysauce
	reaction = /datum/chemical_reaction/food/soysauce
	result = /datum/reagent/consumable/soysauce

/datum/crafting_recipe/food/reaction/corn_syrup
	reaction = /datum/chemical_reaction/food/corn_syrup
	result = /datum/reagent/consumable/corn_syrup

/datum/crafting_recipe/food/reaction/caramel
	reaction = /datum/chemical_reaction/food/caramel
	result = /datum/reagent/consumable/caramel
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/reaction/cheesewheel
	reaction = /datum/chemical_reaction/food/cheesewheel
	result = /obj/item/food/cheese/wheel

/datum/crafting_recipe/food/reaction/synthmeat
	reaction = /datum/chemical_reaction/food/synthmeat
	result = /obj/item/food/meat/slab/synthmeat
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/reaction/imitationcarpmeat
	reaction = /datum/chemical_reaction/food/imitationcarpmeat
	result = /obj/item/food/fishmeat/carp/imitation
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/reaction/dough
	reaction = /datum/chemical_reaction/food/dough
	result = /obj/item/food/dough
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/reaction/cakebatter
	name = "Cake batter"
	reaction = /datum/chemical_reaction/food/cakebatter
	result = /obj/item/food/cakebatter
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/reaction/cakebatter/vegan
	name = "Cake batter (vegan)"
	reaction = /datum/chemical_reaction/food/cakebatter/vegan

/datum/crafting_recipe/food/reaction/pancakebatter
	result = /datum/reagent/consumable/pancakebatter
	reaction = /datum/chemical_reaction/food/pancakebatter
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/reaction/ricebowl
	result = /obj/item/food/salad/ricebowl
	reaction = /datum/chemical_reaction/food/ricebowl
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/reaction/bbqsauce
	result = /datum/reagent/consumable/bbqsauce
	reaction = /datum/chemical_reaction/food/bbqsauce

/datum/crafting_recipe/food/reaction/gravy
	result = /datum/reagent/consumable/gravy
	reaction = /datum/chemical_reaction/food/gravy

/datum/crafting_recipe/food/reaction/mothic_pizza_dough
	result = /obj/item/food/mothic_pizza_dough
	reaction = /datum/chemical_reaction/food/mothic_pizza_dough
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/reaction/curd_cheese
	result = /obj/item/food/cheese/curd_cheese
	reaction = /datum/chemical_reaction/food/curd_cheese

/datum/crafting_recipe/food/reaction/mozzarella
	result = /obj/item/food/cheese/mozzarella
	reaction = /datum/chemical_reaction/food/mozzarella

/datum/crafting_recipe/food/reaction/cornmeal_batter
	result = /datum/reagent/consumable/cornmeal_batter
	reaction = /datum/chemical_reaction/food/cornmeal_batter
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/reaction/cornbread
	result = /obj/item/food/bread/corn
	reaction = /datum/chemical_reaction/food/cornbread
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/reaction/yoghurt
	result = /datum/reagent/consumable/yoghurt
	reaction = /datum/chemical_reaction/food/yoghurt

/datum/crafting_recipe/food/reaction/quality_oil
	result = /datum/reagent/consumable/quality_oil
	reaction = /datum/chemical_reaction/food/quality_oil

/datum/crafting_recipe/food/reaction/quality_oil/upconvert
	reaction = /datum/chemical_reaction/food/quality_oil_upconvert

/datum/crafting_recipe/food/reaction/moonshine
	reaction = /datum/chemical_reaction/drink/moonshine
	result = /datum/reagent/consumable/ethanol/moonshine

// Tools: Rolling pin

/datum/crafting_recipe/food/rollingpin
	tool_paths = list(/obj/item/kitchen/rollingpin)
	steps = list("Flatten with a rolling pin")
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/rollingpin/flatdough
	reqs = list(/obj/item/food/dough = 1)
	result = /obj/item/food/flatdough
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/rollingpin/flatrootdough
	reqs = list(/obj/item/food/rootdough = 1)
	result = /obj/item/food/flatrootdough
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/rollingpin/piedough
	reqs = list(/obj/item/food/cakebatter = 1)
	result = /obj/item/food/piedough
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/rollingpin/raw_patty
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/raw_patty
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/rollingpin/pizza_sheet
	reqs = list(/obj/item/food/pizzaslice/margherita = 1)
	result = /obj/item/stack/sheet/pizza

// Tools: Knife

/datum/crafting_recipe/food/knife
	tool_paths = list(/obj/item/knife)
	steps = list("Slice with knife")
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/knife/breadslice
	reqs = list(/obj/item/food/bread/plain = 1)
	result = /obj/item/food/breadslice/plain
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/knife/breadslice/root
	reqs = list(/obj/item/food/bread/root = 1)
	result = /obj/item/food/breadslice/root

/datum/crafting_recipe/food/knife/cakeslice
	reqs = list(/obj/item/food/cake/plain = 1)
	result = /obj/item/food/cakeslice/plain
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/knife/pizzaslice
	reqs = list(/obj/item/food/pizza/margherita = 1)
	result = /obj/item/food/pizzaslice/margherita
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/knife/doughslice
	reqs = list(/obj/item/food/flatdough = 1)
	result = /obj/item/food/doughslice
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/knife/rootdoughslice
	reqs = list(/obj/item/food/flatrootdough = 1)
	result = /obj/item/food/rootdoughslice
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/knife/pastrybase
	reqs = list(/obj/item/food/piedough = 1)
	result = /obj/item/food/pastrybase
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/knife/doughball
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/bait/doughball
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/knife/nizaya
	reqs = list(/obj/item/food/rootdoughslice = 1)
	result = /obj/item/food/spaghetti/nizaya
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/knife/rawcutlet
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/meat/rawcutlet
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/knife/headcheese_slice
	reqs = list(/obj/item/food/headcheese = 1)
	result = /obj/item/food/headcheese_slice
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/knife/potatowedge
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/grown/potato/wedges

/datum/crafting_recipe/food/knife/pineappleslice
	reqs = list(/obj/item/food/grown/pineapple = 1)
	result = /obj/item/food/pineappleslice

/datum/crafting_recipe/food/knife/onionslice
	reqs = list(/obj/item/food/grown/onion = 1)
	result = /obj/item/food/onion_slice

/datum/crafting_recipe/food/knife/cheesewedge
	reqs = list(/obj/item/food/cheese/wheel = 1)
	result = /obj/item/food/cheese/wedge

/datum/crafting_recipe/food/knife/firm_cheese_slice
	reqs = list(/obj/item/food/cheese/firm_cheese = 1)
	result = /obj/item/food/cheese/firm_cheese_slice

/datum/crafting_recipe/food/knife/salami
	reqs = list(/obj/item/food/sausage = 1)
	result = /obj/item/food/salami
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/knife/american_sausage
	reqs = list(/obj/item/food/sausage = 1)
	result = /obj/item/food/sausage/american
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/knife/tempehslice
	reqs = list(/obj/item/food/tempeh = 1)
	result = /obj/item/food/tempehslice

/datum/crafting_recipe/food/knife/brownie
	reqs = list(/obj/item/food/brownie_sheet = 1)
	result = /obj/item/food/brownie
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/knife/spicyfiletsushislice
	reqs = list(/obj/item/food/spicyfiletsushiroll = 1)
	result = /obj/item/food/spicyfiletsushislice
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/knife/vegetariansushislice
	reqs = list(/obj/item/food/vegetariansushiroll = 1)
	result = /obj/item/food/vegetariansushislice
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/knife/beef_wellington_slice
	reqs = list(/obj/item/food/beef_wellington = 1)
	result = /obj/item/food/beef_wellington_slice
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/knife/green_lasagne_slice
	reqs = list(/obj/item/food/green_lasagne = 1)
	result = /obj/item/food/green_lasagne_slice
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/knife/lil_baked_rice
	reqs = list(/obj/item/food/big_baked_rice = 1)
	result = /obj/item/food/lil_baked_rice
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/knife/watermelonslice
	reqs = list(/obj/item/food/grown/watermelon = 1)
	result = /obj/item/food/watermelonslice
	subcategory = CAT_SALAD

// Machinery: Grill

/datum/crafting_recipe/food/grill
	machinery = list(/obj/machinery/griddle)
	steps = list("Grill until ready")
	subcategory = CAT_MEAT
	non_craftable = TRUE

/datum/crafting_recipe/food/grill/meatball
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/meatball

/datum/crafting_recipe/food/grill/patty
	reqs = list(/obj/item/food/raw_patty = 1)
	result = /obj/item/food/patty

/datum/crafting_recipe/food/grill/cutlet
	reqs = list(/obj/item/food/meat/rawcutlet = 1)
	result = /obj/item/food/meat/cutlet

/datum/crafting_recipe/food/grill/steak
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/meat/steak

/datum/crafting_recipe/food/grill/steak/chicken
	reqs = list(/obj/item/food/meat/slab/chicken = 1)
	result = /obj/item/food/meat/steak/chicken

/datum/crafting_recipe/food/grill/crab
	reqs = list(/obj/item/food/meat/slab/rawcrab = 1)
	result = /obj/item/food/meat/crab

/datum/crafting_recipe/food/grill/bacon
	reqs = list(/obj/item/food/meat/rawbacon = 1)
	result = /obj/item/food/meat/bacon

/datum/crafting_recipe/food/grill/sausage
	reqs = list(/obj/item/food/raw_sausage = 1)
	result = /obj/item/food/sausage

/datum/crafting_recipe/food/grill/moonfish
	reqs = list(/obj/item/food/fishmeat/moonfish = 1)
	result = /obj/item/food/grilled_moonfish
	subcategory = CAT_SEAFOOD

/datum/crafting_recipe/food/grill/rootflatbread
	reqs = list(/obj/item/food/flatrootdough = 1)
	result = /obj/item/food/root_flatbread
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/grill/griddle_toast
	reqs = list(/obj/item/food/breadslice/plain = 1)
	result = /obj/item/food/griddle_toast
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/grill/frenchtoast
	reqs = list(/obj/item/food/raw_frenchtoast = 1)
	result = /obj/item/food/frenchtoast
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/grill/khinkali
	reqs = list(/obj/item/food/rawkhinkali = 1)
	result = /obj/item/food/khinkali
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/grill/grilled_cheese_sandwich
	reqs = list(/obj/item/food/cheese_sandwich = 1)
	result = /obj/item/food/grilled_cheese_sandwich
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/grill/moonfish
	reqs = list(/obj/item/food/cheese/firm_cheese_slice = 1)
	result = /obj/item/food/grilled_cheese
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/grill/friedegg
	reqs = list(/obj/item/food/egg = 1)
	result = /obj/item/food/friedegg
	subcategory = CAT_EGG
	steps = list(
		"Break the egg onto a griddle",
		"Fry until ready"
	)

/datum/crafting_recipe/food/grill/pancake
	reqs = list(/datum/reagent/consumable/pancakebatter = 5)
	result = /obj/item/food/pancakes
	subcategory = CAT_BREAD
	steps = list(
		"Pour batter onto a griddle",
		"Bake until ready"
	)

/datum/crafting_recipe/food/grill/pancake/blueberry
	reqs = list(
		/datum/reagent/consumable/pancakebatter = 5,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/pancakes/blueberry
	steps = list(
		"Pour batter onto a griddle",
		"Add berries",
		"Bake until ready"
	)

/datum/crafting_recipe/food/grill/pancake/choco
	reqs = list(
		/datum/reagent/consumable/pancakebatter = 5,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/pancakes/chocolatechip
	steps = list(
		"Pour batter onto a griddle",
		"Add chocolate",
		"Bake until ready"
	)

// Machinery: Grinder
/datum/crafting_recipe/food/grinder
	machinery = list(/obj/machinery/reagentgrinder)
	steps = list("Put into grinder and grind")
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/grinder/capsaicin
	reqs = list(/obj/item/food/grown/chili = 1)
	result = /datum/reagent/consumable/capsaicin

/datum/crafting_recipe/food/grinder/frostoil
	reqs = list(/obj/item/food/grown/icepepper = 1)
	result = /datum/reagent/consumable/frostoil

/datum/crafting_recipe/food/grinder/ketchup
	reqs = list(/obj/item/food/grown/tomato = 1)
	result = /datum/reagent/consumable/ketchup

/datum/crafting_recipe/food/grinder/kortaflour
	reqs = list(/obj/item/food/grown/korta_nut = 1)
	result = /datum/reagent/consumable/korta_flour

/datum/crafting_recipe/food/grinder/kortamilk
	reqs = list(/obj/item/food/grown/korta_nut = 1)
	result = /datum/reagent/consumable/korta_milk
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/kortanectar
	reqs = list(/obj/item/food/grown/korta_nut/sweet = 1)
	result = /datum/reagent/consumable/korta_nectar
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/mushroom_powder
	reqs = list(/obj/item/food/grown/ash_flora/seraka = 1)
	result = /datum/reagent/toxin/mushroom_powder

/datum/crafting_recipe/food/grinder/flour
	reqs = list(/obj/item/food/grown/wheat = 1)
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/grinder/flour/oat
	reqs = list(/obj/item/food/grown/oat = 1)
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/grinder/butter
	reqs = list(/datum/reagent/consumable/milk = 15)
	result = /obj/item/food/butter
	steps = list("Put into grinder and mix")

/datum/crafting_recipe/food/grinder/mayonnaise
	reqs = list(/datum/reagent/consumable/eggyolk = 1)
	result = /datum/reagent/consumable/mayonnaise
	steps = list("Put into grinder and mix")

/datum/crafting_recipe/food/grinder/sugar
	reqs = list(/obj/item/food/grown/sugarcane = 1)
	result = /datum/reagent/consumable/sugar

/datum/crafting_recipe/food/grinder/sugar/beet
	reqs = list(/obj/item/food/grown/whitebeet = 1)
	result = /datum/reagent/consumable/sugar

/datum/crafting_recipe/food/grinder/cornstarch
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /datum/reagent/consumable/corn_starch
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/sprinkles
	reqs = list(/obj/item/food/donut/plain = 1)
	result = /datum/reagent/consumable/sprinkles

/datum/crafting_recipe/food/grinder/cherryjelly
	reqs = list(/obj/item/food/grown/cherries = 1)
	result = /datum/reagent/consumable/cherryjelly

/datum/crafting_recipe/food/grinder/bluecherryjelly
	reqs = list(/obj/item/food/grown/bluecherries = 1)
	result = /datum/reagent/consumable/bluecherryjelly

/datum/crafting_recipe/food/grinder/olivepaste
	reqs = list(/obj/item/food/grown/olive = 1)
	result = /datum/reagent/consumable/olivepaste

/datum/crafting_recipe/food/grinder/peanutbutter
	reqs = list(/obj/item/food/grown/peanut = 1)
	result = /datum/reagent/consumable/peanut_butter

// Machinery: Processor
/datum/crafting_recipe/food/processor
	machinery = list(/obj/machinery/processor)
	steps = list("Put into processor and activate")
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/processor/rawbacon
	reqs = list(/obj/item/food/meat/rawcutlet = 1)
	result = /obj/item/food/meat/rawbacon
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/processor/rawmeatball
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/raw_meatball
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/processor/tatortot
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/tatortot

/datum/crafting_recipe/food/processor/fries
	reqs = list(/obj/item/food/grown/potato/wedges = 1)
	result = /obj/item/food/fries

/datum/crafting_recipe/food/processor/carrotfries
	reqs = list(/obj/item/food/grown/carrot = 1)
	result = /obj/item/food/carrotfries

/datum/crafting_recipe/food/processor/roastparsnip
	reqs = list(/obj/item/food/grown/parsnip = 1)
	result = /obj/item/food/roastparsnip

/datum/crafting_recipe/food/processor/soydope
	reqs = list(/obj/item/food/grown/soybeans = 1)
	result = /obj/item/food/soydope

/datum/crafting_recipe/food/processor/spaghetti
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/spaghetti/raw
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/processor/tortilla
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/tortilla
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/processor/tempeh
	reqs = list(/obj/item/food/tempehstarter = 1)
	result = /obj/item/food/tempeh

/datum/crafting_recipe/food/processor/yakiimo
	reqs = list(/obj/item/food/grown/potato/sweet = 1)
	result = /obj/item/food/yakiimo

/datum/crafting_recipe/food/processor/popsicle_stick
	reqs = list(/obj/item/grown/log = 1)
	result = /obj/item/popsicle_stick

/datum/crafting_recipe/food/processor/spidereggs
	reqs = list(/obj/item/food/spidereggs = 1)
	result = /obj/item/food/spidereggs/processed

// Machinery: Microwave
/datum/crafting_recipe/food/microwave
	machinery = list(/obj/machinery/microwave)
	steps = list("Microwave until ready")
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/microwave/boiledegg
	reqs = list(/obj/item/food/egg = 1)
	result = /obj/item/food/boiledegg
	subcategory = CAT_EGG

/datum/crafting_recipe/food/microwave/boiledrice
	reqs = list(/obj/item/food/salad/ricebowl = 1)
	result = /obj/item/food/salad/boiledrice
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/microwave/boiledspaghetti
	reqs = list(/obj/item/food/spaghetti/raw = 1)
	result = /obj/item/food/spaghetti/boiledspaghetti
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/microwave/khinkali
	reqs = list(/obj/item/food/rawkhinkali = 1)
	result = /obj/item/food/khinkali
	subcategory = CAT_BREAD

/datum/crafting_recipe/food/microwave/onionrings
	reqs = list(/obj/item/food/onion_slice = 1)
	result = /obj/item/food/onionrings
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/microwave/popcorn
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/popcorn

/datum/crafting_recipe/food/microwave/cakehat
	reqs = list(/obj/item/food/cake/birthday = 1)
	result = /obj/item/clothing/head/utility/hardhat/cakehat
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/microwave/cakehat/energycake
	reqs = list(/obj/item/food/cake/birthday/energy = 1)
	result = /obj/item/clothing/head/utility/hardhat/cakehat/energycake

/datum/crafting_recipe/food/microwave/cheese_curds
	reqs = list(/obj/item/food/cheese/curd_cheese = 1)
	result = /obj/item/food/cheese_curds

// Machinery: Oven
/datum/crafting_recipe/food/oven
	machinery = list(/obj/machinery/oven)
	steps = list("Bake in oven until ready")
	subcategory = CAT_BREAD
	non_craftable = TRUE

/datum/crafting_recipe/food/oven/bread
	reqs = list(/obj/item/food/dough = 1)
	result = /obj/item/food/bread/plain

/datum/crafting_recipe/food/oven/rootbread
	reqs = list(/obj/item/food/rootdough = 1)
	result = /obj/item/food/bread/root

/datum/crafting_recipe/food/oven/bun
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/bun

/datum/crafting_recipe/food/oven/rootroll
	reqs = list(/obj/item/food/rootdoughslice = 1)
	result = /obj/item/food/rootroll

/datum/crafting_recipe/food/oven/pastrybase
	reqs = list(/obj/item/food/rawpastrybase = 1)
	result = /obj/item/food/pastrybase
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oven/pizzabread
	reqs = list(/obj/item/food/flatdough = 1)
	result = /obj/item/food/pizzabread
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/oven/pizza
	reqs = list(/obj/item/food/pizza/margherita/raw = 1)
	result = /obj/item/food/pizza/margherita
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/oven/rootflatbread
	reqs = list(/obj/item/food/flatrootdough = 1)
	result = /obj/item/food/root_flatbread

/datum/crafting_recipe/food/oven/pie
	reqs = list(/obj/item/food/piedough = 1)
	result = /obj/item/food/pie/plain
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oven/cake
	reqs = list(/obj/item/food/cakebatter = 1)
	result = /obj/item/food/cake/plain
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oven/breadstick
	reqs = list(/obj/item/food/raw_breadstick = 1)
	result = /obj/item/food/breadstick

/datum/crafting_recipe/food/oven/baked_cheese
	reqs = list(/obj/item/food/cheese/wheel = 1)
	result = /obj/item/food/baked_cheese
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/oven/browniesheet
	reqs = list(/obj/item/food/raw_brownie_batter = 1)
	result = /obj/item/food/brownie_sheet
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oven/green_lasagne
	reqs = list(/obj/item/food/raw_green_lasagnee = 1)
	result = /obj/item/food/green_lasagne
	subcategory = CAT_SPAGHETTI

/datum/crafting_recipe/food/oven/big_baked_rice
	reqs = list(/obj/item/food/raw_baked_rice = 1)
	result = /obj/item/food/big_baked_rice
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/oven/ratatouille
	reqs = list(/obj/item/food/raw_ratatouille = 1)
	result = /obj/item/food/ratatouille
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/oven/stuffed_peppers
	reqs = list(/obj/item/food/raw_stuffed_peppers = 1)
	result = /obj/item/food/stuffed_peppers
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/oven/roasted_bell_pepper
	reqs = list(/obj/item/food/grown/bell_pepper = 1)
	result = /obj/item/food/roasted_bell_pepper
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/oven/oven_baked_corn
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/oven_baked_corn
	subcategory = CAT_SALAD

/datum/crafting_recipe/food/oven/yakiimo
	reqs = list(/obj/item/food/grown/potato/sweet = 1)
	result = /obj/item/food/yakiimo
	subcategory = CAT_SALAD

// Machinery: Drying rack
/datum/crafting_recipe/food/drying
	machinery = list(/obj/machinery/smartfridge/drying_rack)
	steps = list("Put into the rack and dry")
	subcategory = CAT_MISCFOOD
	non_craftable = TRUE

/datum/crafting_recipe/food/drying/firm_cheese
	reqs = list(/obj/item/food/cheese/cheese_curds = 1)
	result = /obj/item/food/cheese/firm_cheese

/datum/crafting_recipe/food/drying/headcheese
	reqs = list(/obj/item/food/raw_headcheese = 1)
	result = /obj/item/food/headcheese

/datum/crafting_recipe/food/drying/sosjerky
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/sosjerky/healthy

/datum/crafting_recipe/food/drying/no_raisin/healthy
	reqs = list(/obj/item/food/grown/grapes = 1)
	result = /obj/item/food/no_raisin/healthy

/datum/crafting_recipe/food/drying/semki
	reqs = list(/obj/item/food/grown/sunflower = 1)
	result = /obj/item/food/semki/healthy

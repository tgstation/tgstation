// Recipes that provide crafting instructions and don't yield any result

// Crafting recipes

/datum/crafting_recipe/shiv
	reqs = list(
		/obj/item/shard = 1,
		/obj/item/stack/sheet/cloth = 1,
	)
	result = /obj/item/knife/shiv
	category = CAT_WEAPON_MELEE
	non_craftable = TRUE
	steps = list("Use cloth on a glass shard of any type")

/datum/crafting_recipe/runed_metal
	reqs = list(/obj/item/stack/sheet/plasteel = 1)
	requirements_mats_blacklist = list(/obj/item/stack/sheet/plasteel) // runed metal has its own material
	result = /obj/item/stack/sheet/runed_metal
	category = CAT_CULT
	non_craftable = TRUE
	crafting_flags = parent_type::crafting_flags | CRAFT_MUST_BE_LEARNED
	steps = list("Use Twisted Construction on plasteel")

/datum/crafting_recipe/constructshell
	reqs = list(/obj/item/stack/sheet/iron = 50)
	result = /obj/structure/constructshell
	category = CAT_CULT
	non_craftable = TRUE
	crafting_flags = parent_type::crafting_flags | CRAFT_MUST_BE_LEARNED
	steps = list("Use Twisted Construction on iron")

// Things related to cement and concrete

/datum/crafting_recipe/concrete_wall
	result = /datum/reagent/concrete::wall_type
	reqs = list(
		/obj/structure/grille = 1,
		/datum/reagent/concrete = /datum/reagent/concrete::units_per_wall,
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Pour concrete over a grille")

/datum/crafting_recipe/concrete_wall/hexacrete
	result = /datum/reagent/concrete/hexacrete::wall_type
	reqs = list(
		/obj/structure/girder = 1,
		/datum/reagent/concrete/hexacrete = /datum/reagent/concrete/hexacrete::units_per_wall,
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Pour hexacrete over a girder")

/datum/crafting_recipe/concrete_tile
	result = /turf/open/floor/concrete
	reqs = list(
		/turf/open/floor/catwalk_floor = 1,
		/datum/reagent/concrete = /datum/reagent/concrete::units_per_floor,
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Pour concrete onto a catwalk floor")

/datum/crafting_recipe/concrete_tile/tiles
	result = /turf/open/floor/concrete/tiles
	reqs = list(
		/turf/open/floor/concrete = 1,
		/obj/item/chisel = 1
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Form the pattern on a wet tile")

/datum/crafting_recipe/concrete_tile/reinforced
	result = /turf/open/floor/concrete/reinforced
	reqs = list(
		/turf/open/floor/catwalk_floor = 1,
		/datum/reagent/concrete/hexacrete = /datum/reagent/concrete/hexacrete::units_per_floor,
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Pour hexacrete onto a catwalk floor")

/datum/crafting_recipe/concrete_tile/pavement
	result = /turf/open/floor/concrete/pavement
	reqs = list(
		/turf/open/floor/catwalk_floor = 1,
		/datum/reagent/concrete/pavement = /datum/reagent/concrete/pavement::units_per_floor,
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Pour pavement concrete onto a catwalk floor")

/datum/crafting_recipe/concrete
	result = /datum/reagent/concrete
	reqs = list(
		/datum/reagent/cement = /datum/reagent/cement::units_per_aggregate,
		/obj/item/stack/ore/glass = 1
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Add sand to the cement")

/datum/crafting_recipe/concrete/hexacrete
	result = /datum/reagent/concrete/hexacrete
	reqs = list(
		/datum/reagent/cement/hexement = /datum/reagent/cement/hexement::units_per_aggregate,
		/obj/item/stack/ore/glass = 1
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Add sand to the hexement")

/datum/crafting_recipe/concrete/pavement
	result = /datum/reagent/concrete/pavement
	reqs = list(
		/datum/reagent/cement/pavement = /datum/reagent/cement/pavement::units_per_aggregate,
		/obj/item/stack/ore/glass = 1
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Add sand to the road mix")

/datum/crafting_recipe/wall_support
	result = /obj/structure/wall_support
	reqs = list(
		/obj/structure/wall_support::rods_type = /obj/structure/wall_support::rods_amount
	)
	category = CAT_CONSTRUCTION
	non_craftable = TRUE
	steps = list("Use rods on the wall")

// Food reactions

/datum/crafting_recipe/food/reaction
	meal_category = MEAL_COMPONENT
	non_craftable = TRUE

/datum/crafting_recipe/food/reaction/New()
	. = ..()
	if(!ispath(reaction, /datum/chemical_reaction))
		return

	if(length(GLOB.chemical_reactions_list))
		setup_chemical_reaction_details(GLOB.chemical_reactions_list[reaction])
	else
		// May be called before chemical reactions list is instantiated
		var/datum/chemical_reaction/chemical_reaction = new reaction()
		setup_chemical_reaction_details(chemical_reaction)
		qdel(chemical_reaction)
	..()

/**
 * Sets up information for our recipe based on the chemical reaction we have set.
 */
/datum/crafting_recipe/food/reaction/proc/setup_chemical_reaction_details(datum/chemical_reaction/chemical_reaction)
	reqs = chemical_reaction.required_reagents?.Copy()
	chem_catalysts = LAZYLISTDUPLICATE(chemical_reaction.required_catalysts)
	if(isnull(result) && length(chemical_reaction.results))
		result = chemical_reaction.results[1]
		result_amount = chemical_reaction.results[result]

/datum/crafting_recipe/food/reaction/candle
	reaction = /datum/chemical_reaction/candlefication
	result = /obj/item/flashlight/flare/candle
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/food/reaction/tofu
	reaction = /datum/chemical_reaction/food/tofu
	result = /obj/item/food/tofu
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/reaction/candycorn
	reaction = /datum/chemical_reaction/food/candycorn
	result = /obj/item/food/candy_corn
	dish_category = DISH_CANDY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/reaction/chocolatepudding
	reaction = /datum/chemical_reaction/food/chocolatepudding
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/reaction/vanillapudding
	reaction = /datum/chemical_reaction/food/vanillapudding
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/reaction/chocolatebar
	name = "Chocolate bar"
	reaction = /datum/chemical_reaction/food/chocolate_bar3
	result = /obj/item/food/chocolatebar
	dish_category = DISH_CANDY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/reaction/chocolatebar/chocomilk
	name = "Chocolate bar (choco milk)"
	reaction = /datum/chemical_reaction/food/chocolate_bar2

/datum/crafting_recipe/food/reaction/chocolatebar/vegan
	name = "Chocolate bar (vegan)"
	reaction = /datum/chemical_reaction/food/chocolate_bar

/datum/crafting_recipe/food/reaction/soysauce
	reaction = /datum/chemical_reaction/food/soysauce
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/reaction/corn_syrup
	reaction = /datum/chemical_reaction/food/corn_syrup
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/reaction/caramel
	reaction = /datum/chemical_reaction/food/caramel
	dish_category = DISH_CANDY
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/reaction/cheesewheel
	reaction = /datum/chemical_reaction/food/cheesewheel
	result = /obj/item/food/cheese/wheel

/datum/crafting_recipe/food/reaction/synthmeat
	reaction = /datum/chemical_reaction/food/synthmeat
	result = /obj/item/food/meat/slab/synthmeat
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/reaction/imitationcarpmeat
	reaction = /datum/chemical_reaction/food/imitationcarpmeat
	result = /obj/item/food/fishmeat/carp/imitation
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/reaction/dough
	reaction = /datum/chemical_reaction/food/dough
	result = /obj/item/food/dough
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/reaction/cakebatter
	name = "Cake batter"
	reaction = /datum/chemical_reaction/food/cakebatter
	result = /obj/item/food/cakebatter
	dish_category = DISH_CAKE

/datum/crafting_recipe/food/reaction/cakebatter/vegan
	name = "Cake batter (vegan)"
	reaction = /datum/chemical_reaction/food/cakebatter/vegan
	result = /obj/item/food/cakebatter/vegan

/datum/crafting_recipe/food/reaction/pancakebatter
	result = /datum/reagent/consumable/pancakebatter
	reaction = /datum/chemical_reaction/food/pancakebatter
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/reaction/uncooked_rice
	result = /obj/item/food/uncooked_rice
	reaction = /datum/chemical_reaction/food/uncooked_rice
	dish_category = DISH_RICE

/datum/crafting_recipe/food/reaction/bbqsauce
	result = /datum/reagent/consumable/bbqsauce
	reaction = /datum/chemical_reaction/food/bbqsauce
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/reaction/gravy
	result = /datum/reagent/consumable/gravy
	reaction = /datum/chemical_reaction/food/gravy
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/reaction/mothic_pizza_dough
	result = /obj/item/food/mothic_pizza_dough
	reaction = /datum/chemical_reaction/food/mothic_pizza_dough
	cuisine_category = CUISINE_MOTHIC
	dish_category = DISH_PIZZA

/datum/crafting_recipe/food/reaction/curd_cheese
	result = /obj/item/food/cheese/curd_cheese
	reaction = /datum/chemical_reaction/food/curd_cheese

/datum/crafting_recipe/food/reaction/mozzarella
	result = /obj/item/food/cheese/mozzarella
	reaction = /datum/chemical_reaction/food/mozzarella

/datum/crafting_recipe/food/reaction/cornmeal_batter
	result = /datum/reagent/consumable/cornmeal_batter
	reaction = /datum/chemical_reaction/food/cornmeal_batter
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/reaction/cornbread
	result = /obj/item/food/bread/corn
	reaction = /datum/chemical_reaction/food/cornbread
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/reaction/yoghurt
	result = /datum/reagent/consumable/yoghurt
	reaction = /datum/chemical_reaction/food/yoghurt
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/reaction/olive_oil
	result = /datum/reagent/consumable/nutriment/fat/oil/olive
	reaction = /datum/chemical_reaction/food/olive_oil
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/reaction/olive_oil/upconvert
	reaction = /datum/chemical_reaction/food/olive_oil_upconvert

/datum/crafting_recipe/food/reaction/moonshine
	reaction = /datum/chemical_reaction/drink/moonshine
	category = CAT_DRINK

/datum/crafting_recipe/food/reaction/martian_batter
	reaction = /datum/chemical_reaction/food/martian_batter
	cuisine_category = CUISINE_MARTIAN

/datum/crafting_recipe/food/reaction/grounding_neutralise
	reaction = /datum/chemical_reaction/food/grounding_neutralise
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/reaction/saltwater
	reaction = /datum/chemical_reaction/saltwater

/datum/crafting_recipe/food/reaction/teslium
	reaction = /datum/chemical_reaction/teslium

/datum/crafting_recipe/food/reaction/vinegar_grape
	reaction = /datum/chemical_reaction/food/grape_vinegar

/datum/crafting_recipe/food/reaction/vinegar_wine
	reaction = /datum/chemical_reaction/food/wine_vinegar

/datum/crafting_recipe/food/reaction/salt
	reaction = /datum/chemical_reaction/sodiumchloride
	dish_category = DISH_CONDIMENT

// Tools: Rolling pin

/datum/crafting_recipe/food/rollingpin
	tool_behaviors =  list(TOOL_ROLLINGPIN)
	steps = list("Flatten with a rolling pin")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/rollingpin/flatdough
	reqs = list(/obj/item/food/dough = 1)
	result = /obj/item/food/flatdough
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/rollingpin/flatrootdough
	reqs = list(/obj/item/food/rootdough = 1)
	result = /obj/item/food/flatrootdough
	dish_category = DISH_BREAD
	cuisine_category = CUISINE_LIZARD

/datum/crafting_recipe/food/rollingpin/piedough
	reqs = list(/obj/item/food/cakebatter = 1)
	result = /obj/item/food/piedough
	dish_category = DISH_PIE

/datum/crafting_recipe/food/rollingpin/raw_patty
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/raw_patty
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/rollingpin/pizza_sheet
	reqs = list(/obj/item/food/pizzaslice/margherita = 1)
	result = /obj/item/stack/sheet/pizza
	cuisine_category = CUISINE_ITALIAN
	dish_category = DISH_PIZZA

/datum/crafting_recipe/food/rollingpin/meat_patty
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/raw_patty
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/rollingpin/chicken_patty
	reqs = list(/obj/item/food/raw_meatball/chicken = 1)
	result = /obj/item/food/raw_patty/chicken
	dish_category = DISH_MEAT

// Tools: Knife

/datum/crafting_recipe/food/knife
	tool_behaviors =  list(TOOL_KNIFE)
	steps = list("Slice with a knife")
	non_craftable = TRUE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/breadslice
	reqs = list(/obj/item/food/bread/plain = 1)
	result = /obj/item/food/breadslice/plain
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/knife/breadslice/root
	reqs = list(/obj/item/food/bread/root = 1)
	result = /obj/item/food/breadslice/root

/datum/crafting_recipe/food/knife/cakeslice
	reqs = list(/obj/item/food/cake/plain = 1)
	result = /obj/item/food/cakeslice/plain
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/pizzaslice
	reqs = list(/obj/item/food/pizza/margherita = 1)
	result = /obj/item/food/pizzaslice/margherita
	cuisine_category = CUISINE_ITALIAN
	dish_category = DISH_PIZZA
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/doughslice
	reqs = list(/obj/item/food/flatdough = 1)
	result = /obj/item/food/doughslice
	dish_category = DISH_BREAD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/rootdoughslice
	reqs = list(/obj/item/food/flatrootdough = 1)
	result = /obj/item/food/rootdoughslice
	dish_category = DISH_BREAD
	cuisine_category = CUISINE_LIZARD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/rawpastrybase
	reqs = list(/obj/item/food/piedough = 1)
	result = /obj/item/food/rawpastrybase
	dish_category = DISH_BREAD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/butterslice
	reqs = list(/obj/item/food/butter = 1)
	result = /obj/item/food/butterslice
	meal_category = MEAL_COMPONENT
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/knife/doughball
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/bait/doughball
	dish_category = DISH_BREAD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/nizaya
	reqs = list(/obj/item/food/rootdoughslice = 1)
	result = /obj/item/food/spaghetti/nizaya
	dish_category = DISH_NOODLES
	cuisine_category = CUISINE_LIZARD
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/rawcutlet
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/meat/rawcutlet
	dish_category = DISH_MEAT
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/headcheese_slice
	reqs = list(/obj/item/food/headcheese = 1)
	result = /obj/item/food/headcheese_slice
	dish_category = DISH_MEAT
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/potatowedge
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/grown/potato/wedges
	dish_category = DISH_SALAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/pineappleslice
	reqs = list(/obj/item/food/grown/pineapple = 1)
	result = /obj/item/food/pineappleslice
	dish_category = DISH_SALAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/onionslice
	reqs = list(/obj/item/food/grown/onion = 1)
	result = /obj/item/food/onion_slice
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/cheesewedge
	reqs = list(/obj/item/food/cheese/wheel = 1)
	result = /obj/item/food/cheese/wedge
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/firm_cheese_slice
	reqs = list(/obj/item/food/cheese/firm_cheese = 1)
	result = /obj/item/food/cheese/firm_cheese_slice
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/salami
	reqs = list(/obj/item/food/sausage = 1)
	result = /obj/item/food/salami
	dish_category = DISH_MEAT
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/knife/american_sausage
	reqs = list(/obj/item/food/sausage = 1)
	result = /obj/item/food/sausage/american
	dish_category = DISH_MEAT
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/knife/tempehslice
	reqs = list(/obj/item/food/tempeh = 1)
	result = /obj/item/food/tempehslice
	dish_category = DISH_MEAT
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/brownie
	reqs = list(/obj/item/food/brownie_sheet = 1)
	result = /obj/item/food/brownie
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/knife/spicyfiletsushislice
	reqs = list(/obj/item/food/spicyfiletsushiroll = 1)
	result = /obj/item/food/spicyfiletsushislice
	dish_category = DISH_SUSHI
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/vegetariansushislice
	reqs = list(/obj/item/food/vegetariansushiroll = 1)
	result = /obj/item/food/vegetariansushislice
	dish_category = DISH_SUSHI
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/beef_wellington_slice
	reqs = list(/obj/item/food/beef_wellington = 1)
	result = /obj/item/food/beef_wellington_slice
	dish_category = DISH_MEAT
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/green_lasagne_slice
	reqs = list(/obj/item/food/green_lasagne = 1)
	result = /obj/item/food/green_lasagne_slice
	dish_category = DISH_NOODLES
	meal_category = MEAL_MAIN_COURSE

/datum/crafting_recipe/food/knife/lil_baked_rice
	reqs = list(/obj/item/food/big_baked_rice = 1)
	result = /obj/item/food/lil_baked_rice
	cuisine_category = CUISINE_MOTHIC
	dish_category = DISH_RICE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/watermelonslice
	reqs = list(/obj/item/food/grown/melonlike/watermelon = 1)
	result = /obj/item/food/watermelonslice
	dish_category = DISH_SALAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/appleslice
	reqs = list(/obj/item/food/grown/apple = 1)
	result = /obj/item/food/appleslice
	dish_category = DISH_SALAD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/kamaboko_slice
	reqs = list(/obj/item/food/kamaboko = 1)
	result = /obj/item/food/kamaboko_slice
	cuisine_category = CUISINE_MARTIAN
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/raw_noodles
	reqs = list(/obj/item/food/rice_dough = 1)
	result = /obj/item/food/spaghetti/rawnoodles
	cuisine_category = CUISINE_MARTIAN
	dish_category = DISH_NOODLES
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/chapslice
	reqs = list(/obj/item/food/canned/chap = 1)
	result = /obj/item/food/chapslice
	dish_category = DISH_MEAT
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/knife/reispan_slice
	reqs = list(/obj/item/food/bread/reispan = 1)
	result = /obj/item/food/breadslice/reispan
	dish_category = DISH_RICE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/knife/jellyfish_fillet
	reqs = list(/obj/item/fish/gunner_jellyfish = 1)
	result = /obj/item/food/fishmeat/gunner_jellyfish
	cuisine_category = CUISINE_LIZARD
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/knife/moonfish_fillet
	reqs = list(/obj/item/fish/moonfish = 1)
	result = /obj/item/food/fishmeat/moonfish
	cuisine_category = CUISINE_LIZARD
	dish_category = DISH_MEAT

// Machinery: Grill

/datum/crafting_recipe/food/grill
	machinery = list(/obj/machinery/griddle)
	steps = list("Grill until ready")
	dish_category = DISH_MEAT
	non_craftable = TRUE

/datum/crafting_recipe/food/grill/meatball
	reqs = list(/obj/item/food/raw_meatball = 1)
	result = /obj/item/food/meatball
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/grill/patty
	reqs = list(/obj/item/food/raw_patty = 1)
	result = /obj/item/food/patty
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/grill/cutlet
	reqs = list(/obj/item/food/meat/rawcutlet = 1)
	result = /obj/item/food/meat/cutlet
	meal_category = MEAL_APPETIZER

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
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/grill/sausage
	reqs = list(/obj/item/food/raw_sausage = 1)
	result = /obj/item/food/sausage
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/grill/moonfish
	reqs = list(/obj/item/food/fishmeat/moonfish = 1)
	result = /obj/item/food/grilled_moonfish
	cuisine_category = CUISINE_LIZARD
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/grill/rootflatbread
	reqs = list(/obj/item/food/flatrootdough = 1)
	result = /obj/item/food/root_flatbread
	dish_category = DISH_BREAD
	cuisine_category = CUISINE_LIZARD

/datum/crafting_recipe/food/grill/griddle_toast
	reqs = list(/obj/item/food/breadslice/plain = 1)
	result = /obj/item/food/griddle_toast
	dish_category = DISH_BREAD
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/grill/frenchtoast
	reqs = list(/obj/item/food/raw_frenchtoast = 1)
	result = /obj/item/food/frenchtoast
	dish_category = DISH_BREAD
	meal_category = MEAL_BREAKFAST

/datum/crafting_recipe/food/grill/khinkali
	reqs = list(/obj/item/food/rawkhinkali = 1)
	result = /obj/item/food/khinkali
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/grill/grilled_cheese_sandwich
	reqs = list(/obj/item/food/sandwich/cheese = 1)
	result = /obj/item/food/sandwich/grilled_cheese
	dish_category = DISH_SANDWICH

/datum/crafting_recipe/food/grill/grilled_cheese
	reqs = list(/obj/item/food/cheese/firm_cheese_slice = 1)
	result = /obj/item/food/grilled_cheese
	dish_category = DISH_UNCATEGORIZED // this is just cheese?

/datum/crafting_recipe/food/grill/ballpark_pretzel
	reqs = list(/obj/item/food/raw_ballpark_pretzel = 1)
	result = /obj/item/food/ballpark_pretzel
	dish_category = DISH_PASTRY
	cuisine_category = CUISINE_MARTIAN
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/grill/ballpark_tsukune
	reqs = list(/obj/item/food/kebab/raw_ballpark_tsukune = 1)
	result = /obj/item/food/kebab/ballpark_tsukune
	cuisine_category = CUISINE_MARTIAN
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/grill/chapslice
	reqs = list(/obj/item/food/chapslice = 1)
	result = /obj/item/food/grilled_chapslice

/datum/crafting_recipe/food/grill/friedegg
	reqs = list(/obj/item/food/egg = 1)
	result = /obj/item/food/friedegg
	meal_category = MEAL_APPETIZER
	dish_category = DISH_UNCATEGORIZED
	steps = list(
		"Break the egg onto a griddle",
		"Fry until ready"
	)

/datum/crafting_recipe/food/grill/pancake
	reqs = list(/datum/reagent/consumable/pancakebatter = 5)
	result = /obj/item/food/pancakes
	dish_category = DISH_BREAD
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

/datum/crafting_recipe/food/grill/hard_taco_shell
	reqs = list(/obj/item/food/tortilla = 1)
	result = /obj/item/food/hard_taco_shell
	cuisine_category = CUISINE_MEXICAN
	dish_category = DISH_TACO
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/grill/pita_bread
	reqs = list(/obj/item/food/raw_pita_bread = 1)
	result = /obj/item/food/pita_bread
	dish_category = DISH_BREAD

/datum/crafting_recipe/food/grill/octapus_tentacle
	reqs = list(/obj/item/food/fishmeat/octopus = 1)
	result = /obj/item/food/grilled_octopus
	dish_category = DISH_MEAT

// Machinery: Grinder
/datum/crafting_recipe/food/grinder
	machinery = list(/obj/machinery/reagentgrinder)
	steps = list("Put into grinder and grind")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/grinder/capsaicin
	reqs = list(/obj/item/food/grown/chili = 1)
	result = /datum/reagent/consumable/capsaicin
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/frostoil
	reqs = list(/obj/item/food/grown/icepepper = 1)
	result = /datum/reagent/consumable/frostoil
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/ketchup
	reqs = list(/obj/item/food/grown/tomato = 1)
	result = /datum/reagent/consumable/ketchup
	dish_category = DISH_CONDIMENT

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
	name = "Fresh Wheat Flour"
	reqs = list(/obj/item/food/grown/wheat = 1)
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/grinder/flour/oat
	name = "Fresh Oat Flour"
	reqs = list(/obj/item/food/grown/oat = 1)
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/grinder/rice
	name = "Fresh Rice"
	reqs = list(/obj/item/food/grown/rice = 1)
	result = /datum/reagent/consumable/rice

/datum/crafting_recipe/food/grinder/butter
	reqs = list(/datum/reagent/consumable/milk = MILK_TO_BUTTER_COEFF)
	result = /obj/item/food/butter
	steps = list("Put into grinder and mix")
	meal_category = MEAL_COMPONENT
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/mayonnaise
	reqs = list(/datum/reagent/consumable/eggyolk = 1)
	result = /datum/reagent/consumable/mayonnaise
	steps = list("Put into grinder and mix")
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/sugar
	reqs = list(/obj/item/food/grown/sugarcane = 1)
	result = /datum/reagent/consumable/sugar
	dish_category = DISH_CONDIMENT

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
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/cherryjelly
	reqs = list(/obj/item/food/grown/cherries = 1)
	result = /datum/reagent/consumable/cherryjelly
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/bluecherryjelly
	reqs = list(/obj/item/food/grown/bluecherries = 1)
	result = /datum/reagent/consumable/bluecherryjelly
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/olivepaste
	reqs = list(/obj/item/food/grown/olive = 1)
	result = /datum/reagent/consumable/olivepaste
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/peanutbutter
	reqs = list(/obj/item/food/grown/peanut = 1)
	result = /datum/reagent/consumable/peanut_butter
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/slime_jelly
	reqs = list(/obj/item/slime_extract = 1)
	result = /datum/reagent/toxin/slimejelly

/datum/crafting_recipe/food/grinder/nutriment
	reqs = list(/obj/item/food = 1)
	result = /datum/reagent/consumable/nutriment

/datum/crafting_recipe/food/grinder/laugh_syrup
	reqs = list(/obj/item/food/grown/laugh = 1)
	result = /datum/reagent/consumable/laughsyrup
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/coco_powder
	reqs = list(/obj/item/food/grown/cocoapod = 1)
	result = /datum/reagent/consumable/coco

/datum/crafting_recipe/food/grinder/vanilla_powder
	reqs = list(/obj/item/food/grown/vanillapod = 1)
	result = /datum/reagent/consumable/vanilla

/datum/crafting_recipe/food/grinder/apple_juice
	name = "Fresh Apple Juice"
	reqs = list(/obj/item/food/grown/apple = 1)
	result = /datum/reagent/consumable/applejuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/lemon_juice
	name = "Fresh Lemon Juice"
	reqs = list(/obj/item/food/grown/citrus/lemon = 1)
	result = /datum/reagent/consumable/lemonjuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/lime_juice
	name = "Fresh Lime Juice"
	reqs = list(/obj/item/food/grown/citrus/lime = 1)
	result = /datum/reagent/consumable/limejuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/orange_juice
	name = "Fresh Orange Juice"
	reqs = list(/obj/item/food/grown/citrus/orange = 1)
	result = /datum/reagent/consumable/orangejuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/pineapple_juice
	name = "Fresh Pineapple Juice"
	reqs = list(/obj/item/food/grown/pineapple = 1)
	result = /datum/reagent/consumable/pineapplejuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/berry_juice
	name = "Fresh Berry Juice"
	reqs = list(/obj/item/food/grown/berries = 1)
	result = /datum/reagent/consumable/berryjuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/blumpkin_juice
	name = "Fresh Blumpkin Juice"
	reqs = list(/obj/item/food/grown/pumpkin/blumpkin = 1)
	result = /datum/reagent/consumable/blumpkinjuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/bungo_juice
	name = "Fresh Bungo Juice"
	reqs = list(/obj/item/food/grown/bungofruit = 1)
	result = /datum/reagent/consumable/bungojuice
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/honey
	name = "Fresh Honey"
	reqs = list(/obj/item/food/honeycomb = 1)
	result = /datum/reagent/consumable/honey
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/grinder/oligomers
	reqs = list(/obj/item/seeds/poppy/lily/trumpet= 1)
	result = /datum/reagent/medicine/polypyr
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/tea_leaves
	reqs = list(/obj/item/food/grown/tea = 1)
	result = /datum/reagent/toxin/teapowder

/datum/crafting_recipe/food/grinder/black_pepper
	reqs = list(/obj/item/food/grown/peppercorn = 1)
	result = /datum/reagent/consumable/blackpepper

/datum/crafting_recipe/food/grinder/soymilk
	reqs = list(/obj/item/food/grown/soybeans = 1)
	result = /datum/reagent/consumable/soymilk
	steps = list("Put into grinder and juice")

/datum/crafting_recipe/food/grinder/milk
	name = "Fresh Plant-Based Milk"

	reqs = list(/obj/item/food/grown/butterbeans = 1)
	result = /datum/reagent/consumable/milk

/datum/crafting_recipe/food/grinder/cream
	name = "Fresh Plant-Based Cream"
	reqs = list(/obj/item/food/grown/butterbeans = 1)
	result = /datum/reagent/consumable/cream

/datum/crafting_recipe/food/grinder/vege_oil
	name = "Fresh Plant-Based Vegetable Oil"
	reqs = list(/obj/item/food/grown/soybeans = 1)
	result = /datum/reagent/consumable/nutriment/fat/oil

/datum/crafting_recipe/food/honeycomb
	result = /obj/item/food/honeycomb
	non_craftable = TRUE
	steps = list(
		"Set up an apiary with a queen bee and honey frames",
		"Plant crops nearby of any type",
		"Wait for pollination - takes some time",
		"Remove honey frame from apiary",
	)

// Machinery: Processor
/datum/crafting_recipe/food/processor
	machinery = list(/obj/machinery/processor)
	steps = list("Put into processor and activate")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/processor/rawbacon
	reqs = list(/obj/item/food/meat/rawcutlet = 1)
	result = /obj/item/food/meat/rawbacon
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/processor/rawmeatball
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/raw_meatball
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/processor/tatortot
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/tatortot
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/processor/fries
	reqs = list(/obj/item/food/grown/potato/wedges = 1)
	result = /obj/item/food/fries
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/processor/carrotfries
	reqs = list(/obj/item/food/grown/carrotlike/carrot = 1)
	result = /obj/item/food/carrotfries
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/processor/roastparsnip
	reqs = list(/obj/item/food/grown/carrotlike/parsnip = 1)
	result = /obj/item/food/roastparsnip
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/processor/soydope
	reqs = list(/obj/item/food/grown/soybeans = 1)
	result = /obj/item/food/soydope

/datum/crafting_recipe/food/processor/spaghetti
	reqs = list(/obj/item/food/doughslice = 1)
	result = /obj/item/food/spaghetti/raw
	dish_category = DISH_NOODLES

/datum/crafting_recipe/food/processor/tortilla
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/tortilla
	dish_category = DISH_BREAD
	cuisine_category = CUISINE_MEXICAN

/datum/crafting_recipe/food/processor/tempeh
	reqs = list(/obj/item/food/tempehstarter = 1)
	result = /obj/item/food/tempeh
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/processor/popsicle_stick
	reqs = list(/obj/item/grown/log = 1)
	result = /obj/item/popsicle_stick
	category = CAT_MISC

/datum/crafting_recipe/food/processor/spidereggs
	reqs = list(/obj/item/food/spidereggs = 1)
	result = /obj/item/food/spidereggs/processed

// Machinery: Microwave
/datum/crafting_recipe/food/microwave
	machinery = list(/obj/machinery/microwave)
	steps = list("Microwave until ready")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/microwave/boiledegg
	reqs = list(/obj/item/food/egg = 1)
	result = /obj/item/food/boiledegg

/datum/crafting_recipe/food/microwave/boiledrice
	reqs = list(/obj/item/food/uncooked_rice = 1)
	result = /obj/item/food/boiledrice
	dish_category = DISH_RICE

/datum/crafting_recipe/food/microwave/boiledspaghetti
	reqs = list(/obj/item/food/spaghetti/raw = 1)
	result = /obj/item/food/spaghetti/boiledspaghetti
	dish_category = DISH_NOODLES

/datum/crafting_recipe/food/microwave/onionrings
	reqs = list(/obj/item/food/onion_slice = 1)
	result = /obj/item/food/onionrings
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/microwave/popcorn
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/popcorn
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/microwave/cakehat
	reqs = list(/obj/item/food/cake/birthday = 1)
	result = /obj/item/clothing/head/utility/hardhat/cakehat
	dish_category = DISH_CAKE
	meal_category = MEAL_UNCATEGORIZED

/datum/crafting_recipe/food/microwave/cakehat/energycake
	reqs = list(/obj/item/food/cake/birthday/energy = 1)
	result = /obj/item/clothing/head/utility/hardhat/cakehat/energycake

/datum/crafting_recipe/food/microwave/cheese_curds
	reqs = list(/obj/item/food/cheese/curd_cheese = 1)
	result = /obj/item/food/cheese/cheese_curds

// Machinery: Oven
/datum/crafting_recipe/food/oven
	machinery = list(/obj/machinery/oven)
	steps = list("Bake in the oven until ready")
	dish_category = DISH_BREAD
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
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/rootroll
	reqs = list(/obj/item/food/rootdoughslice = 1)
	result = /obj/item/food/rootroll
	cuisine_category = CUISINE_LIZARD
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/oven/pastrybase
	reqs = list(/obj/item/food/rawpastrybase = 1)
	result = /obj/item/food/pastrybase
	dish_category = DISH_PASTRY
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/oven/pizzabread
	reqs = list(/obj/item/food/flatdough = 1)
	result = /obj/item/food/pizzabread
	cuisine_category = CUISINE_ITALIAN
	dish_category = DISH_PIZZA

/datum/crafting_recipe/food/oven/pizza
	reqs = list(/obj/item/food/pizza/margherita/raw = 1)
	result = /obj/item/food/pizza/margherita
	cuisine_category = CUISINE_ITALIAN
	dish_category = DISH_PIZZA

/datum/crafting_recipe/food/oven/rootflatbread
	reqs = list(/obj/item/food/flatrootdough = 1)
	result = /obj/item/food/root_flatbread
	cuisine_category = CUISINE_LIZARD

/datum/crafting_recipe/food/oven/pie
	reqs = list(/obj/item/food/piedough = 1)
	result = /obj/item/food/pie/plain
	dish_category = DISH_PIE

/datum/crafting_recipe/food/oven/cake
	reqs = list(/obj/item/food/cakebatter = 1)
	result = /obj/item/food/cake/plain
	dish_category = DISH_CAKE
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/oven/breadstick
	reqs = list(/obj/item/food/raw_breadstick = 1)
	result = /obj/item/food/breadstick
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/oven/baked_cheese
	reqs = list(/obj/item/food/cheese/wheel = 1)
	result = /obj/item/food/baked_cheese
	dish_category = DISH_UNCATEGORIZED

/datum/crafting_recipe/food/oven/browniesheet
	reqs = list(/obj/item/food/raw_brownie_batter = 1)
	result = /obj/item/food/brownie_sheet
	meal_category = MEAL_DESSERT

/datum/crafting_recipe/food/oven/green_lasagne
	reqs = list(/obj/item/food/raw_green_lasagne = 1)
	result = /obj/item/food/green_lasagne
	dish_category = DISH_NOODLES

/datum/crafting_recipe/food/oven/big_baked_rice
	reqs = list(/obj/item/food/raw_baked_rice = 1)
	result = /obj/item/food/big_baked_rice
	cuisine_category = CUISINE_MOTHIC
	dish_category = DISH_RICE

/datum/crafting_recipe/food/oven/ratatouille
	reqs = list(/obj/item/food/raw_ratatouille = 1)
	result = /obj/item/food/ratatouille
	dish_category = DISH_SALAD
	// cuisine_category = CUISINE_FRENCH

/datum/crafting_recipe/food/oven/stuffed_peppers
	name = "Voltölpapriken (Stuffed peppers)"
	reqs = list(/obj/item/food/raw_stuffed_peppers = 1)
	result = /obj/item/food/stuffed_peppers
	cuisine_category = CUISINE_MOTHIC

/datum/crafting_recipe/food/oven/roasted_bell_pepper
	reqs = list(/obj/item/food/grown/bell_pepper = 1)
	result = /obj/item/food/roasted_bell_pepper
	dish_category = DISH_SALAD

/datum/crafting_recipe/food/oven/oven_baked_corn
	reqs = list(/obj/item/food/grown/corn = 1)
	result = /obj/item/food/oven_baked_corn
	dish_category = DISH_SALAD

/datum/crafting_recipe/food/oven/yakiimo
	reqs = list(/obj/item/food/grown/potato/sweet = 1)
	result = /obj/item/food/yakiimo
	dish_category = DISH_UNCATEGORIZED
	cuisine_category = CUISINE_JAPANESE

/datum/crafting_recipe/food/oven/reispan
	reqs = list(/obj/item/food/rice_dough = 1)
	result = /obj/item/food/bread/reispan
	cuisine_category = CUISINE_MARTIAN

/datum/crafting_recipe/food/oven/ballpark_pretzel
	reqs = list(/obj/item/food/raw_ballpark_pretzel = 1)
	result = /obj/item/food/ballpark_pretzel
	cuisine_category = CUISINE_MARTIAN
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/oven/baked_potato
	reqs = list(/obj/item/food/grown/potato = 1)
	result = /obj/item/food/baked_potato
	dish_category = DISH_UNCATEGORIZED
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/oven/pita_bread
	reqs = list(/obj/item/food/raw_pita_bread = 1)
	result = /obj/item/food/pita_bread
	dish_category = DISH_BREAD

// Machinery: Drying rack
/datum/crafting_recipe/food/drying
	machinery = list(/obj/machinery/smartfridge/drying)
	steps = list("Put into the rack and dry")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/drying/firm_cheese
	reqs = list(/obj/item/food/cheese/cheese_curds = 1)
	result = /obj/item/food/cheese/firm_cheese

/datum/crafting_recipe/food/drying/headcheese
	reqs = list(/obj/item/food/raw_headcheese = 1)
	result = /obj/item/food/headcheese
	dish_category = DISH_MEAT
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/drying/tiziran_sausage
	reqs = list(/obj/item/food/raw_tiziran_sausage = 1)
	result = /obj/item/food/tiziran_sausage
	dish_category = DISH_MEAT
	meal_category = MEAL_APPETIZER

/datum/crafting_recipe/food/drying/sosjerky
	reqs = list(/obj/item/food/meat/slab = 1)
	result = /obj/item/food/sosjerky/healthy
	dish_category = DISH_MEAT
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/drying/no_raisin/healthy
	reqs = list(/obj/item/food/grown/grapes = 1)
	result = /obj/item/food/no_raisin/healthy
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/drying/semki
	reqs = list(/obj/item/food/grown/flower/sunflower = 1)
	result = /obj/item/food/semki/healthy
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/drying/kamaboko
	reqs = list(/obj/item/food/surimi = 1)
	result = /obj/item/food/kamaboko
	cuisine_category = CUISINE_MARTIAN
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/order
	steps = list("Place an order in the produce order console")
	machinery = list(/obj/machinery/computer/order_console/cook)
	meal_category = MEAL_COMPONENT
	non_craftable = TRUE

/datum/crafting_recipe/food/order/New()
	. = ..()
	name = "Store Bought [name]"

/datum/crafting_recipe/food/order/red_bay
	result = /datum/reagent/consumable/red_bay

/datum/crafting_recipe/food/order/dashi
	result = /datum/reagent/consumable/dashi_concentrate

/datum/crafting_recipe/food/order/curry
	result = /datum/reagent/consumable/curry_powder

/datum/crafting_recipe/food/order/bbq
	result = /datum/reagent/consumable/bbqsauce

/datum/crafting_recipe/food/order/soy
	result = /datum/reagent/consumable/soysauce

/datum/crafting_recipe/food/order/vegetable_oil
	result = /datum/reagent/consumable/nutriment/fat/oil

/datum/crafting_recipe/food/order/vinegar

	result = /datum/reagent/consumable/vinegar

/datum/crafting_recipe/food/order/chap_can
	result = /obj/item/food/canned/chap

/datum/crafting_recipe/food/order/flour
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/order/rice
	result = /datum/reagent/consumable/rice

/datum/crafting_recipe/food/order/cornmeal
	result = /datum/reagent/consumable/cornmeal

/datum/crafting_recipe/food/order/enzyme
	result = /datum/reagent/consumable/enzyme

/datum/crafting_recipe/food/order/salt
	result = /datum/reagent/consumable/salt
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/pepper
	result = /datum/reagent/consumable/blackpepper
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/oliveoil
	result = /datum/reagent/consumable/nutriment/fat/oil/olive

/datum/crafting_recipe/food/order/peanutbutter
	result = /datum/reagent/consumable/peanut_butter
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/cherryjelly
	result = /datum/reagent/consumable/cherryjelly
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/worcestershire_sauce

	result = /datum/reagent/consumable/worcestershire
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/coconut_milk
	result = /datum/reagent/consumable/coconut_milk

/datum/crafting_recipe/food/order/grounding_solution
	result = /datum/reagent/consumable/grounding_solution

/datum/crafting_recipe/food/order/canned_tomatoes
	result = /obj/item/food/canned/tomatoes

/datum/crafting_recipe/food/order/honey
	result = /datum/reagent/consumable/honey
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/yoghurt
	result = /datum/reagent/consumable/yoghurt
	dish_category = DISH_CONDIMENT

/datum/crafting_recipe/food/order/milk
	result = /datum/reagent/consumable/milk

/datum/crafting_recipe/food/order/soymilk
	result = /datum/reagent/consumable/soymilk

/datum/crafting_recipe/food/order/canned_bee_larva
	result = /obj/item/food/canned/larvae

/datum/crafting_recipe/food/order/canned_gunner_jellyfish
	result = /obj/item/food/canned/jellyfish

/datum/crafting_recipe/food/order/canned_desert_snails
	result = /obj/item/food/canned/desert_snails

/datum/crafting_recipe/food/order/canned_squid_ink
	result = /obj/item/food/canned/squid_ink

/datum/crafting_recipe/food/order/octapus_tentacle
	result = /obj/item/food/fishmeat/octopus
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/order/armorfish
	result = /obj/item/food/fishmeat/armorfish
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/order/moonfish
	result = /obj/item/food/fishmeat/moonfish
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/order/moonfish_eggs
	result = /obj/item/food/moonfish_eggs
	dish_category = DISH_MEAT

/datum/crafting_recipe/food/order/voltvine
	result = /obj/item/food/pickled_voltvine

/datum/crafting_recipe/food/order/pickles
	result = /obj/item/food/pickle

/datum/crafting_recipe/food/order/cream
	result = /datum/reagent/consumable/cream

/datum/crafting_recipe/food/order/egg
	result = /obj/item/food/egg
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/egg_chicken
	name = "Fresh Eggs"
	reqs = list(/mob/living/basic/chicken = 1)
	result = /obj/item/food/egg
	steps = list("Feed a chicken wheat or oats")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/milk_cow
	name = "Fresh Cow Milk"
	reqs = list(/mob/living/basic/cow = 1)
	result = /datum/reagent/consumable/milk
	steps = list("Use a beaker or bucket on a cow")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/milk_goat
	name = "Fresh Goat Milk"
	reqs = list(/mob/living/basic/goat = 1)
	result = /datum/reagent/consumable/milk
	steps = list("Use a beaker or bucket on a goat")
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/egg_yolk
	reqs = list(/obj/item/food/egg = 1)
	result = /datum/reagent/consumable/eggyolk
	steps = list("Break the egg into a beaker or bowl")
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/egg_white
	reqs = list(/obj/item/food/egg = 1)
	result = /datum/reagent/consumable/eggwhite
	steps = list("Break the egg into a beaker or bowl")
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/vending
	steps = list("Purchase from a vending machine")
	machinery = list(/obj/machinery/vending/snack)
	non_craftable = TRUE
	meal_category = MEAL_SNACK

/datum/crafting_recipe/food/vending/raisins
	result = /obj/item/food/no_raisin

/datum/crafting_recipe/food/vending/cds
	result = /obj/item/food/cnds

/datum/crafting_recipe/food/vending/chips
	result = /obj/item/food/chips

/datum/crafting_recipe/food/vending/gallery_peanut
	result = /obj/item/food/peanuts

/datum/crafting_recipe/food/vending/corn_chip
	result = /obj/item/food/cornchips

/datum/crafting_recipe/food/vending/sm_wind
	machinery = list(/obj/machinery/vending/cola)
	result = /datum/reagent/consumable/spacemountainwind

/datum/crafting_recipe/food/vending/volt_energy
	machinery = list(/obj/machinery/vending/cola)
	result = /datum/reagent/consumable/volt_energy

/datum/crafting_recipe/food/biogenerator
	steps = list("Insert organic material into the biogenerator", "Process into desired product")
	machinery = list(/obj/machinery/biogenerator)
	non_craftable = TRUE
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/biogenerator/New()
	. = ..()
	name = "Synthetic [name]"

/datum/crafting_recipe/food/biogenerator/seaweed_sheet
	result = /obj/item/food/seaweedsheet

/datum/crafting_recipe/food/biogenerator/monkey_cube
	result = /obj/item/food/monkeycube

/datum/crafting_recipe/food/biogenerator/sugar
	result = /datum/reagent/consumable/sugar

/datum/crafting_recipe/food/biogenerator/milk
	result = /datum/reagent/consumable/milk

/datum/crafting_recipe/food/biogenerator/soymilk
	result = /datum/reagent/consumable/soymilk

/datum/crafting_recipe/food/biogenerator/flour
	result = /datum/reagent/consumable/flour

/datum/crafting_recipe/food/biogenerator/enzyme
	result = /datum/reagent/consumable/enzyme

/datum/crafting_recipe/food/biogenerator/black_pepper
	result = /datum/reagent/consumable/blackpepper

/datum/crafting_recipe/food/biogenerator/cream
	result = /datum/reagent/consumable/cream

/datum/crafting_recipe/food/biogenerator/ethanol
	result = /datum/reagent/consumable/ethanol

// Distilling
/datum/crafting_recipe/food/distill
	steps = list("Distill in a barrel")
	structures = list(/obj/structure/fermenting_barrel)
	non_craftable = TRUE

/datum/crafting_recipe/food/distill/enzyme
	name = "Fresh Universal Enzyme"
	reqs = list(/obj/item/food/grown/tomato = 1)
	result = /datum/reagent/consumable/enzyme

/datum/crafting_recipe/food/distill/soysauce
	name = "Fresh Soy Sauce"
	reqs = list(/obj/item/food/grown/soybeans = 1)
	result = /datum/reagent/consumable/soysauce

/datum/crafting_recipe/food/distill/yoghurt
	name = "Fresh Yoghurt"
	reqs = list(/obj/item/food/grown/butterbeans = 1)
	result = /datum/reagent/consumable/yoghurt

/datum/crafting_recipe/food/icecream
	name = "Waffle Cone"
	machinery = list(/obj/machinery/icecream_vat)
	result = /obj/item/food/icecream
	non_craftable = TRUE
	steps = list("Retrieve cone from holder")

/datum/crafting_recipe/food/egg_from_egg_plant
	name = "Fresh Plant-Based Eggs"
	reqs = list(/obj/item/food/grown/eggy = 1)
	result = /obj/item/food/egg
	non_craftable = TRUE
	steps = list("Open an egg-plant in your hands")
	meal_category = MEAL_COMPONENT

/datum/crafting_recipe/food/butter_from_plant
	name = "Fresh Plant-Based Butter"
	reqs = list(/obj/item/food/grown/butterbeans = 1)
	result = /obj/item/food/butterslice
	non_craftable = TRUE
	steps = list("Crush a butterbean in your hands")
	meal_category = MEAL_COMPONENT
	dish_category = DISH_CONDIMENT

// Ratwood's crop data by hand: code/modules/farming/plant_def.dm (the crops), seeds.dm and roguejobs/alchemist/herb_seeds.dm
// (what every seed grows and what it is), produce.dm and rogueitems/magic/magic_resources.dm (what seeds produce gives).

#define SLOW_GROWING (6 MINUTES)
#define FAST_GROWING (5 MINUTES)
#define VERY_FAST_GROWING (4 MINUTES)
#define HUNGRINESS_EXTREME 60
#define HUNGRINESS_DEMANDING 35
#define HUNGRINESS_NORMAL 25
#define HUNGRINESS_TINY 15

/// A Ratwood crop: one definition per crop, shared by every soil that grows it (farming/soil.dm). Times are deciseconds of growth
/// at the normal rate; maturing eats maturation_nutrition from the soil, every later harvest produce_nutrition.
/datum/plant_def
	abstract_type = /datum/plant_def
	/// Name of the plant
	var/name = "Some plant"
	/// Description of the plant
	var/desc = "Sure is a plant."
	var/icon = ROGUE_CROPS_ICON
	var/icon_state
	/// Loot the plant yields for uprooting it once matured: a type a time, or type = count.
	var/list/uproot_loot
	/// Deciseconds the plant needs to mature, before it starts making produce
	var/maturation_time = 6 MINUTES
	/// Deciseconds the plant needs for each harvest
	var/produce_time = 3 MINUTES
	/// What a harvest yields. Text while the porter has not brought the item: it becomes the type once it is compiled in.
	var/produce_type
	/// Least produce of a harvest
	var/produce_amount_min = 2
	/// Most produce of a harvest
	var/produce_amount_max = 3
	/// How much nutrition the plant needs to mature fully
	var/maturation_nutrition = HUNGRINESS_NORMAL
	/// How much nutrition the plant needs for each harvest
	var/produce_nutrition = 20
	/// If not perennial, the plant uproots itself on its first harvest
	var/perennial = FALSE
	/// Whether the plant is immune to weeds and chokes them out
	var/weed_immune = FALSE
	/// Water the plant drinks every decisecond; zero - it lives without water
	var/water_drain_rate = 2 / (1 MINUTES)
	/// Colour every seed of this plant has, picked anew every round
	var/seed_color
	/// Whether the plant grows away from the open sky
	var/can_grow_underground = FALSE
	/// The icon states of its four looks, found in the icon the first time they are needed.
	var/list/stage_states
	/// Ratwood's sheet lacks its dead look; the matured one stands in, withered.
	var/dead_look_missing = FALSE

/datum/plant_def/New()
	. = ..()
	var/static/list/random_colors = list("#fffbf7", "#f3c877", "#5e533e", "#db7f62", "#f39945")
	seed_color = pick(random_colors)
	if(istext(produce_type))
		produce_type = text2path(produce_type)

/// Whether its harvest exists: produce the porter has not brought yet (not compiled in, or declared only for its farming vars and
/// so without a sprite) keeps the crop from being sown.
/datum/plant_def/proc/can_grow()
	var/obj/item/produce = produce_type
	return ispath(produce, /obj/item) && length(initial(produce.icon_state))

/// The icon state of one of its looks (ROGUE_CROP_*). Ratwood's sheet lacks a few ("poppy0", "tangerine3"); the nearest look
/// it has stands in, as Ratwood would show nothing.
/datum/plant_def/proc/stage_state(stage)
	if(!stage_states)
		stage_states = list()
		for(var/look in 0 to 3)
			var/state = "[icon_state][look]"
			if(!icon_exists(icon, state))
				if(look == 3)
					state = "[icon_state]1"
					dead_look_missing = TRUE
				else if(icon_exists(icon, icon_state))
					state = icon_state
				else
					state = "[icon_state][max(look - 1, 0)]"
			stage_states += state
	return stage_states[stage]

/// One definition of each crop by type (Ratwood GLOB.plant_defs).
GLOBAL_LIST_INIT(rogue_plant_defs, rogue_build_plant_defs())

/proc/rogue_build_plant_defs()
	. = list()
	for(var/datum/plant_def/path as anything in subtypesof(/datum/plant_def))
		if(initial(path.abstract_type) != path)
			.[path] = new path()

//................ Quick-growing plants ...............................
/datum/plant_def/cabbage
	name = "cabbages"
	icon_state = "cabbage"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/cabbage/rogue
	produce_amount_min = 3
	produce_amount_max = 4
	maturation_time = FAST_GROWING

/datum/plant_def/onion
	name = "onion patch"
	icon_state = "onion"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/onion/rogue
	produce_amount_min = 3
	produce_amount_max = 4
	maturation_time = FAST_GROWING

/datum/plant_def/wheat
	name = "wheat stalks"
	icon_state = "wheat"
	produce_type = /obj/item/natural/chaff/wheat
	produce_amount_min = 3
	produce_amount_max = 5
	uproot_loot = list(/obj/item/natural/fibers, /obj/item/natural/fibers)
	maturation_time = FAST_GROWING
	produce_time = 2 MINUTES

/datum/plant_def/oat
	name = "oat stalks"
	icon_state = "oat"
	produce_type = /obj/item/natural/chaff/oat
	produce_amount_min = 3
	produce_amount_max = 5
	uproot_loot = list(/obj/item/natural/fibers, /obj/item/natural/fibers)
	maturation_time = FAST_GROWING
	produce_time = 2 MINUTES

// Rice are faster growing but drain way more water
/datum/plant_def/rice
	name = "rice stalks"
	icon_state = "rice"
	produce_type = /obj/item/natural/chaff/rice
	produce_amount_min = 3
	produce_amount_max = 5
	uproot_loot = list(/obj/item/natural/fibers, /obj/item/natural/fibers)
	maturation_time = VERY_FAST_GROWING
	produce_time = 2 MINUTES
	water_drain_rate = 4 / (1 MINUTES)

/datum/plant_def/pipeweed
	name = "westleach plant"
	icon_state = "westleach"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed
	produce_amount_min = 3
	produce_amount_max = 5
	maturation_time = FAST_GROWING
	produce_time = 2 MINUTES

//................ Perennial Trees ............................... (No replanting needed)
// Long growth time, fast-ish produce time. High initial nutrition cost.
/datum/plant_def/tree
	abstract_type = /datum/plant_def/tree
	name = "Testing Plant Do Not Use"
	perennial = TRUE
	produce_amount_min = 2
	produce_amount_max = 4
	uproot_loot = list(/obj/item/grown/log/tree/small)
	maturation_nutrition = HUNGRINESS_EXTREME
	maturation_time = SLOW_GROWING
	produce_time = 3 MINUTES

/datum/plant_def/tree/apple
	name = "apple tree"
	icon_state = "apple"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/apple

/datum/plant_def/tree/pear
	name = "pear tree"
	icon_state = "pear"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/pear

/datum/plant_def/tree/plum
	name = "plum tree"
	icon_state = "plum"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/plum

/datum/plant_def/tree/tangerine
	name = "tangerine tree"
	icon_state = "tangerine"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/tangerine

/datum/plant_def/tree/lime
	name = "lime tree"
	icon_state = "lime"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/lime

/datum/plant_def/tree/lemon
	name = "lemon tree"
	icon_state = "lemon"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/lemon

//................ Perennial Bushes ............................... (No replanting needed)
// Medium growth time, fast-ish produce time. Moderate Initial Nutrition Cost. Less Harvest. Stick
/datum/plant_def/bush
	abstract_type = /datum/plant_def/bush
	name = "Testing Bush Do Not Use"
	perennial = TRUE
	produce_amount_min = 2
	produce_amount_max = 3
	uproot_loot = list(/obj/item/grown/log/tree/stick)
	maturation_nutrition = HUNGRINESS_EXTREME
	produce_nutrition = HUNGRINESS_NORMAL
	maturation_time = FAST_GROWING

/datum/plant_def/bush/berry
	name = "jackberry bush"
	icon_state = "berry"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/berries/rogue

/datum/plant_def/bush/berry_poison
	name = "jackberry bush"
	icon_state = "berry"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison

/datum/plant_def/bush/strawberry
	name = "strawberry bush"
	icon_state = "strawberry"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/strawberry

/datum/plant_def/bush/blackberry
	name = "blackberry bush"
	icon_state = "blackberry"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/blackberry

/datum/plant_def/bush/raspberry
	name = "raspberry bush"
	icon_state = "raspberry"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/raspberry

/datum/plant_def/bush/tomato
	name = "tomato vines"
	icon_state = "tomato"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/fruit/tomato

/datum/plant_def/sugarcane
	name = "sugarcane"
	icon_state = "sugarcane"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/sugarcane
	perennial = TRUE
	produce_amount_min = 2
	produce_amount_max = 4

//................ Nutrition-efficient plants ...............................
/datum/plant_def/potato
	name = "potato plant"
	icon_state = "potato"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/potato/rogue
	produce_amount_min = 3
	produce_amount_max = 5
	maturation_nutrition = HUNGRINESS_TINY
	water_drain_rate = 1 / (1 MINUTES)

/datum/plant_def/turnip
	name = "turnip patch"
	icon_state = "turnip"
	produce_type = "/obj/item/reagent_containers/food/snacks/grown/vegetable/turnip"
	produce_amount_min = 4
	produce_amount_max = 6
	maturation_nutrition = HUNGRINESS_TINY
	maturation_time = FAST_GROWING
	water_drain_rate = 1 / (1 MINUTES)

//................ Water-efficient plants ...............................
/datum/plant_def/swampweed
	name = "swampweed plant"
	icon_state = "swampweed"
	produce_amount_min = 3
	produce_amount_max = 5
	produce_type = /obj/item/reagent_containers/food/snacks/grown/rogue/swampweed
	water_drain_rate = 0

//................ Flowers ...............................
/datum/plant_def/sunflower
	name = "sunflowers"
	icon_state = "sunflower"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/sunflower
	produce_amount_min = 3
	produce_amount_max = 4
	maturation_nutrition = HUNGRINESS_TINY
	maturation_time = VERY_FAST_GROWING
	water_drain_rate = 1 / (2 MINUTES)

/datum/plant_def/fyritiusflower
	name = "fyritius flowers"
	icon_state = "fyritius"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/rogue/fyritius
	produce_amount_min = 1
	produce_amount_max = 3 // Let's keep the production rate low because it is an anti-antag item
	maturation_time = FAST_GROWING

/datum/plant_def/manabloom
	name = "manabloom"
	icon_state = "manabloom"
	produce_amount_min = 1
	produce_amount_max = 3
	produce_type = /obj/item/reagent_containers/food/snacks/grown/manabloom
	maturation_time = FAST_GROWING

/datum/plant_def/garlick
	name = "garlick sprouts"
	icon_state = "onion"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/garlick/rogue
	produce_amount_min = 2
	produce_amount_max = 3

/datum/plant_def/poppy
	name = "poppies"
	icon_state = "poppy"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/rogue/poppy
	produce_amount_min = 1
	produce_amount_max = 2
	maturation_nutrition = 30
	water_drain_rate = 1 / (2 MINUTES)

/datum/plant_def/nut
	name = "rocknut tree"
	icon_state = "nuts"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/nut
	uproot_loot = list(/obj/item/grown/log/tree/small)
	perennial = TRUE
	produce_amount_max = 3
	maturation_nutrition = 60
	produce_nutrition = 35
	maturation_time = 6 MINUTES
	produce_time = 3 MINUTES
	water_drain_rate = 1 / (2 MINUTES)

/datum/plant_def/coffee
	name = "coffee bush"
	icon_state = "coffee"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/coffee
	produce_amount_min = 2
	produce_amount_max = 3

/datum/plant_def/tea
	name = "tea bush"
	icon_state = "tea"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/tea
	produce_amount_min = 2
	produce_amount_max = 3

/datum/plant_def/pumpkin
	name = "pumpkin plant"
	icon_state = "pumpkin"
	produce_type = "/obj/item/natural/shellplant/pumpkin"
	produce_amount_min = 2
	produce_amount_max = 4
	uproot_loot = list(/obj/item/natural/fibers = 3)
	maturation_nutrition = HUNGRINESS_DEMANDING
	maturation_time = SLOW_GROWING
	produce_time = 3 MINUTES

/datum/plant_def/carrot
	name = "carrot tops"
	icon_state = "carrot"
	produce_type = /obj/item/reagent_containers/food/snacks/grown/carrot
	produce_amount_min = 1
	produce_amount_max = 3
	maturation_nutrition = HUNGRINESS_TINY
	maturation_time = SLOW_GROWING

/datum/plant_def/cucumber
	name = "cucumber vines"
	icon_state = "cucumber"
	produce_type = "/obj/item/reagent_containers/food/snacks/grown/cucumber"
	produce_amount_min = 2
	produce_amount_max = 3

/datum/plant_def/eggplant
	name = "eggplant stalk"
	icon_state = "eggplant"
	produce_type = "/obj/item/reagent_containers/food/snacks/grown/eggplant"
	produce_amount_min = 2
	produce_amount_max = 4
	maturation_nutrition = HUNGRINESS_DEMANDING

/// What each Ratwood seed grows (Ratwood plant_def_type of crop seeds, makes_herb of herb seeds, the sapling of tree and bush
/// seeds), by the seed's own type and no other (TG seed packs have subtypes Ratwood does not): a plant definition grows in soil, a
/// herb blooms out of a seedling in soil, a sapling takes root in its soil. Many crop seeds share their path with TG seed packs
/// (/obj/item/seeds/wheat), which is what the map has there; farming/seeds.dm gives those the Ratwood look on medieval maps.
GLOBAL_LIST_INIT(rogue_seed_grows, rogue_seed_table(2))
/// What a farmer can tell a seed is (Ratwood seed_identity).
GLOBAL_LIST_INIT(rogue_seed_identities, rogue_seed_table(3))

/proc/rogue_seed_table(column)
	. = list()
	for(var/list/row as anything in rogue_seed_rows())
		var/seed_type = istext(row[1]) ? text2path(row[1]) : row[1]
		if(seed_type)
			.[seed_type] = row[column]

/// Ratwood's seeds: the seed, what it grows, what it is. Seeds written as text are those the porter has not brought yet; each
/// counts as soon as it is compiled in.
/proc/rogue_seed_rows()
	return list(
		list(/obj/item/seeds/wheat, /datum/plant_def/wheat, "wheat seeds"),
		list(/obj/item/seeds/wheat/oat, /datum/plant_def/oat, "oat seeds"),
		list(/obj/item/seeds/rice, /datum/plant_def/rice, "rice seeds"),
		list(/obj/item/seeds/apple, /datum/plant_def/tree/apple, "apple seeds"),
		list(/obj/item/seeds/pear, /datum/plant_def/tree/pear, "pear seeds"),
		list(/obj/item/seeds/lemon, /datum/plant_def/tree/lemon, "lemon seeds"),
		list(/obj/item/seeds/lime, /datum/plant_def/tree/lime, "lime seeds"),
		list(/obj/item/seeds/tangerine, /datum/plant_def/tree/tangerine, "tangerine seeds"),
		list(/obj/item/seeds/plum, /datum/plant_def/tree/plum, "plum seeds"),
		list(/obj/item/seeds/strawberry, /datum/plant_def/bush/strawberry, "strawberry seeds"),
		list(/obj/item/seeds/blackberry, /datum/plant_def/bush/blackberry, "blackberry seeds"),
		list(/obj/item/seeds/raspberry, /datum/plant_def/bush/raspberry, "raspberry seeds"),
		list(/obj/item/seeds/tomato, /datum/plant_def/bush/tomato, "tomato seeds"),
		list(/obj/item/seeds/nut, /datum/plant_def/nut, "rocknut seeds"),
		list(/obj/item/seeds/sugarcane, /datum/plant_def/sugarcane, "sugarcane seeds"),
		list(/obj/item/seeds/pipeweed, /datum/plant_def/pipeweed, "westleach leaf seeds"),
		list(/obj/item/seeds/swampweed, /datum/plant_def/swampweed, "swampweed seeds"),
		list(/obj/item/seeds/berryrogue, /datum/plant_def/bush/berry, "berry seeds"),
		list(/obj/item/seeds/berryrogue/poison, /datum/plant_def/bush/berry_poison, "berry seeds"),
		list("/obj/item/seeds/turnip", /datum/plant_def/turnip, "turnip seeds"),
		list(/obj/item/seeds/sunflower, /datum/plant_def/sunflower, "sunflower seeds"),
		list(/obj/item/seeds/onion, /datum/plant_def/onion, "onion seeds"),
		list(/obj/item/seeds/cabbage, /datum/plant_def/cabbage, "cabbage seeds"),
		list(/obj/item/seeds/potato, /datum/plant_def/potato, "potato seeds"),
		list("/obj/item/seeds/fyritius", /datum/plant_def/fyritiusflower, "fyritius seeds"),
		list(/obj/item/seeds/poppy, /datum/plant_def/poppy, "poppy seeds"),
		list(/obj/item/seeds/garlick, /datum/plant_def/garlick, "garlick seeds"),
		list(/obj/item/seeds/coffee, /datum/plant_def/coffee, "coffee seeds"),
		list(/obj/item/seeds/tea, /datum/plant_def/tea, "tea seeds"),
		list(/obj/item/seeds/pumpkin, /datum/plant_def/pumpkin, "pumpkin seeds"),
		list(/obj/item/seeds/carrot, /datum/plant_def/carrot, "carrot seeds"),
		list(/obj/item/seeds/cucumber, /datum/plant_def/cucumber, "cucumber seeds"),
		list(/obj/item/seeds/eggplant, /datum/plant_def/eggplant, "eggplant seeds"),
		list(/obj/item/seeds/treesap, /obj/structure/tree_sapling, "tree seeds"),
		list("/obj/item/seeds/treesap/pine", /obj/structure/tree_sapling/pine, "pine seeds"),
		list("/obj/item/seeds/treesap/sakura", /obj/structure/tree_sapling/sakura, "sakura seeds"),
		list("/obj/item/seeds/bush", /obj/structure/bush_sapling, "bush seeds"),
		list(/obj/item/herbseed/atropa, /obj/structure/flora/roguegrass/herb/atropa, "atropa seeds"),
		list(/obj/item/herbseed/matricaria, /obj/structure/flora/roguegrass/herb/matricaria, "matricaria seeds"),
		list(/obj/item/herbseed/symphitum, /obj/structure/flora/roguegrass/herb/symphitum, "symphitum seeds"),
		list(/obj/item/herbseed/taraxacum, /obj/structure/flora/roguegrass/herb/taraxacum, "taraxacum seeds"),
		list(/obj/item/herbseed/euphrasia, /obj/structure/flora/roguegrass/herb/euphrasia, "euphrasia seeds"),
		list(/obj/item/herbseed/paris, /obj/structure/flora/roguegrass/herb/paris, "paris seeds"),
		list(/obj/item/herbseed/calendula, /obj/structure/flora/roguegrass/herb/calendula, "calendula seeds"),
		list(/obj/item/herbseed/mentha, /obj/structure/flora/roguegrass/herb/mentha, "mentha seeds"),
		list(/obj/item/herbseed/urtica, /obj/structure/flora/roguegrass/herb/urtica, "urtica seeds"),
		list(/obj/item/herbseed/salvia, /obj/structure/flora/roguegrass/herb/salvia, "salvia seeds"),
		list(/obj/item/herbseed/hypericum, /obj/structure/flora/roguegrass/herb/hypericum, "hypericum seeds"),
		list(/obj/item/herbseed/benedictus, /obj/structure/flora/roguegrass/herb/benedictus, "benedictus seeds"),
		list(/obj/item/herbseed/valeriana, /obj/structure/flora/roguegrass/herb/valeriana, "valeriana seeds"),
		list(/obj/item/herbseed/artemisia, /obj/structure/flora/roguegrass/herb/artemisia, "artemisia seeds"),
		list(/obj/item/herbseed/rosa, /obj/structure/flora/roguegrass/herb/rosa, "rosa seeds"),
		list(/obj/item/herbseed/manabloom, /obj/structure/flora/roguegrass/herb/manabloom, "manabloom seeds"),
	)

/// The seeds Ratwood's random seed packet turns into (Ratwood /obj/item/seeds/random), those whose crop can grow.
/proc/rogue_random_seeds()
	var/static/list/seeds
	if(!seeds)
		seeds = list()
		var/list/ratwood_random = list(
			/obj/item/seeds/wheat, /obj/item/seeds/wheat/oat, /obj/item/seeds/rice, /obj/item/seeds/apple, /obj/item/seeds/pear,
			/obj/item/seeds/lemon, /obj/item/seeds/lime, /obj/item/seeds/tangerine, /obj/item/seeds/plum, /obj/item/seeds/strawberry,
			/obj/item/seeds/blackberry, /obj/item/seeds/raspberry, /obj/item/seeds/tomato, /obj/item/seeds/nut,
			/obj/item/seeds/sugarcane, /obj/item/seeds/pipeweed, /obj/item/seeds/swampweed, /obj/item/seeds/berryrogue,
			"/obj/item/seeds/turnip", /obj/item/seeds/sunflower, /obj/item/seeds/onion, /obj/item/seeds/cabbage,
			/obj/item/seeds/potato, "/obj/item/seeds/fyritius", /obj/item/seeds/poppy, /obj/item/seeds/garlick,
			/obj/item/seeds/coffee, /obj/item/seeds/tea, /obj/item/seeds/pumpkin, /obj/item/seeds/carrot, /obj/item/seeds/cucumber,
			/obj/item/seeds/eggplant,
		)
		for(var/entry in ratwood_random)
			var/seed_type = istext(entry) ? text2path(entry) : entry
			if(!seed_type)
				continue
			var/datum/plant_def/plant = GLOB.rogue_plant_defs[GLOB.rogue_seed_grows[seed_type]]
			if(plant?.can_grow())
				seeds += seed_type
	return seeds

/// What seeds each produce gives when knocked about with something blunt (Ratwood grown seed, also inherited by
/// fyritius/bloodied and fruit/blackberry/skysugarbase), by the produce's own type, the same way as the seeds.
GLOBAL_LIST_INIT(rogue_produce_seeds, rogue_produce_seed_table())

/proc/rogue_produce_seed_table()
	. = list()
	var/list/rows = list(
		list(/obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/seeds/wheat),
		list(/obj/item/reagent_containers/food/snacks/grown/oat, /obj/item/seeds/wheat/oat),
		list(/obj/item/reagent_containers/food/snacks/grown/rice, /obj/item/seeds/rice),
		list(/obj/item/reagent_containers/food/snacks/grown/apple, /obj/item/seeds/apple),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/pear, /obj/item/seeds/pear),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/lemon, /obj/item/seeds/lemon),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/lime, /obj/item/seeds/lime),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine, /obj/item/seeds/tangerine),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/plum, /obj/item/seeds/plum),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/strawberry, /obj/item/seeds/strawberry),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry, /obj/item/seeds/blackberry),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry/skysugarbase, /obj/item/seeds/blackberry),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/raspberry, /obj/item/seeds/raspberry),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/tomato, /obj/item/seeds/tomato),
		list(/obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sliced, /obj/item/seeds/tomato),
		list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue, /obj/item/seeds/berryrogue),
		list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison, /obj/item/seeds/berryrogue/poison),
		list(/obj/item/reagent_containers/food/snacks/grown/nut, /obj/item/seeds/nut),
		list(/obj/item/reagent_containers/food/snacks/grown/sugarcane, /obj/item/seeds/sugarcane),
		list("/obj/item/reagent_containers/food/snacks/grown/vegetable/turnip", "/obj/item/seeds/turnip"),
		list(/obj/item/reagent_containers/food/snacks/grown/sunflower, /obj/item/seeds/sunflower),
		list(/obj/item/reagent_containers/food/snacks/grown/rogue/fyritius, "/obj/item/seeds/fyritius"),
		list(/obj/item/reagent_containers/food/snacks/grown/rogue/fyritius/bloodied, "/obj/item/seeds/fyritius"),
		list(/obj/item/reagent_containers/food/snacks/grown/rogue/swampweed, /obj/item/seeds/swampweed),
		list(/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed, /obj/item/seeds/pipeweed),
		list(/obj/item/reagent_containers/food/snacks/grown/onion/rogue, /obj/item/seeds/onion),
		list(/obj/item/reagent_containers/food/snacks/grown/cabbage/rogue, /obj/item/seeds/cabbage),
		list(/obj/item/reagent_containers/food/snacks/grown/potato/rogue, /obj/item/seeds/potato),
		list(/obj/item/reagent_containers/food/snacks/grown/garlick/rogue, /obj/item/seeds/garlick),
		list(/obj/item/reagent_containers/food/snacks/grown/rogue/poppy, /obj/item/seeds/poppy),
		list(/obj/item/reagent_containers/food/snacks/grown/coffee, /obj/item/seeds/coffee),
		list(/obj/item/reagent_containers/food/snacks/grown/tea, /obj/item/seeds/tea),
		list(/obj/item/reagent_containers/food/snacks/grown/carrot, /obj/item/seeds/carrot),
		list("/obj/item/reagent_containers/food/snacks/grown/eggplant", /obj/item/seeds/eggplant),
		list(/obj/item/reagent_containers/food/snacks/grown/manabloom, /obj/item/herbseed/manabloom),
	)
	for(var/list/row as anything in rows)
		var/produce_type = istext(row[1]) ? text2path(row[1]) : row[1]
		var/seed_type = istext(row[2]) ? text2path(row[2]) : row[2]
		if(produce_type && seed_type)
			.[produce_type] = seed_type

#undef SLOW_GROWING
#undef FAST_GROWING
#undef VERY_FAST_GROWING
#undef HUNGRINESS_EXTREME
#undef HUNGRINESS_DEMANDING
#undef HUNGRINESS_NORMAL
#undef HUNGRINESS_TINY

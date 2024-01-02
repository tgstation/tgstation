/obj/structure/flora/firebush
	name = "flaming bush"
	desc = "A bush being consumed by flames. Maybe it'll rise from its ashes like a phoenix?"
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	icon_state = "hell_bush"
	density = FALSE
	light_color = "#e08300"
	light_power = 2
	light_range = 3
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/fullgrass/hell
	name = "thick hellish grass"
	desc = "A thick patch of grass tinted red."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_range = 2
	light_power = 3
	resistance_flags = LAVA_PROOF
	gender = PLURAL

/obj/structure/flora/ausbushes/fullgrass/hell/Initialize()
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"
	light_color = pick("#e87800", "#780606")

/obj/structure/flora/ausbushes/sparsegrass/hell
	name = "sparse hellish grass"
	desc = "A sparse patch of grass tinted red."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_range = 2
	light_power = 3
	resistance_flags = LAVA_PROOF
	gender = PLURAL

/obj/structure/flora/ausbushes/sparsegrass/hell/Initialize()
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"
	light_color = pick("#e87800", "#780606")

/obj/structure/flora/ausbushes/grassybush/hell
	name = "crimson bush"
	desc = "A crimson bush, native to lava planets."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_color = "#c70404"
	light_range = 2
	light_power = 3
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/hell
	name = "smouldering bush"
	desc = "Some kind of orange plant that appears to be slowly burning."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_range = 2
	light_power = 1
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/hell/Initialize()
	. = ..()
	if(icon_state == "firstbush_1")
		icon_state = "firstbush_[rand(1, 4)]"
	light_color = pick("#e87800", "#780606")

/obj/structure/flora/ausbushes/fernybush/hell
	name = "hellish fern"
	desc = "Some kind of orange fern."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_range = 2
	light_power = 1
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/fernybush/hell/Initialize()
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"
	light_color = pick("#e87800", "#780606")

/obj/structure/flora/ausbushes/genericbush/hell
	name = "hellish bush"
	desc = "A small crimson bush."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_range = 2
	light_power = 2
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/genericbush/hell/Initialize()
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"
	light_color = pick("#e87800", "#780606")

/obj/structure/flora/ausbushes/ywflowers/hell
	name = "lavablossom"
	desc = "Some red and orange flowers. They appear to be faintly glowing."
	icon = 'voidcrew/icons/obj/flora/hellflora.dmi'
	light_color = "#aba507"
	light_power = 3
	light_range = 2
	resistance_flags = LAVA_PROOF
	gender = PLURAL

/obj/structure/flora/rock/lava
	name = "lavatic rock"
	desc = "A volcanic rock. Lava is gushing from it. "
	icon = 'voidcrew/icons/obj/flora/lavarocks.dmi'
	icon_state = "basalt"
	light_color = "#ab4907"
	light_power = 3
	light_range = 2

/obj/structure/flora/rock/pile/lava
	name = "rock shards"
	desc = "Jagged shards of volcanic rock protuding from the ground."
	icon = 'voidcrew/icons/obj/flora/lavarocks.dmi'
	icon_state = "lavarocks"
	gender = PLURAL
	light_color = "#ff8800"
	light_power = 2
	light_range = 2

/obj/structure/flora/rock/asteroid
	name = "pebbles"
	desc = "Some small pebbles, sheared off a larger rock."
	icon = 'voidcrew/icons/turf/wasteland.dmi'
	icon_state = "asteroid0"
	base_icon_state = "asteroid"
	density = FALSE
	gender = PLURAL

/obj/structure/flora/rock/asteroid/Initialize()
	. = ..()
	icon_state = "[base_icon_state][rand(0,9)]"

/obj/structure/flora/tree/dead/hell
	name = "crimson tree"
	desc = "A crimson tree with lava oozing from it, providing a slight glow."
	icon = 'voidcrew/icons/obj/flora/lavatrees.dmi'
	pixel_x = -16
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 2
	light_power = 0.85
	resistance_flags = LAVA_PROOF

//Barren tree default (brown)
/obj/structure/flora/tree/dead/barren
	name = "barren tree"
	desc = "A dead tree, devoid of all life."
	icon = 'voidcrew/icons/obj/flora/barren_tree.dmi'
	icon_state = "barren_large"
	pixel_x = -16

/obj/structure/flora/tree/dead/barren/Initialize()
	. = ..()
	icon_state = "barren_large"

//Barren tree (purple)
/obj/structure/flora/tree/dead/barren/purple
	name = "barren tree"
	desc = "A tree turned purple from mutations to adapt to its environment. They don't appear to have worked."
	color = "#846996"

/obj/structure/flora/tree/dead/barren/purple/Initialize()
	. = ..()
	color = pick( "#846996", "#7b4e99", "#924fab")
	icon_state = "barren_large"

/obj/structure/flora/tree/stonepine
	name = "stone pine"
	desc = "A pine tree that miraculously survived the apocalypse."
	icon = 'voidcrew/icons/obj/flora/tall_trees.dmi'
	icon_state = "stonepine_0"
	pixel_x = -16
	anchored = TRUE

/obj/structure/flora/tree/dead_pine
	name = "dead pine"
	desc = "A dead pine tree, its leaves stripped away."
	icon = 'voidcrew/icons/obj/flora/bigtrees.dmi'
	icon_state = "med_pine_dead"
	pixel_x = -16

/obj/structure/flora/tree/dead_african
	name = "dead tree"
	desc = "A tree consumed by apocalypse."
	icon = 'voidcrew/icons/obj/flora/bigtrees.dmi'
	icon_state = "african_acacia_dead"
	pixel_x = -16

//Tall tree (grey)
/obj/structure/flora/tree/dead/tall
	name = "dead tall tree"
	desc = "The last vestiges of an once majestic tree."
	icon = 'voidcrew/icons/obj/flora/tall_trees.dmi'
	icon_state = "tree_1"
	base_icon_state = "tree"
	pixel_x = -16
	resistance_flags = LAVA_PROOF

/obj/structure/flora/tree/dead/tall/Initialize()
	. = ..()
	icon_state = "[base_icon_state]_[rand(1,3)]"

/obj/structure/flora/tree/dead/tall/grey
	name = "ashen tree"
	desc = "A tree carbonized by the heat of the planet."
	icon = 'voidcrew/icons/obj/flora/tall_trees_dead.dmi'

/obj/structure/flora/deadgrass
	name = "dead grass"
	desc = "Some grass. It appears to have wasted away."
	icon = 'voidcrew/icons/obj/flora/dead_jungleflora.dmi'
	icon_state = "1"
	gender = PLURAL

/obj/structure/flora/deadgrass/Initialize()
	. = ..()
	icon_state = "[rand(1,30)]"

/obj/structure/flora/deadgrass/tall
	name = "tall grass"
	desc = "Some overgrown grass."
	icon = 'voidcrew/icons/obj/flora/wild.dmi'
	icon_state = "tall_grass_6"
	gender = PLURAL

/obj/structure/flora/deadgrass/tall/Initialize()
	. = ..()
	icon_state = "[pick("tall_grass_6", "tall_grass_7")]"

/obj/structure/flora/deadgrass/tall/dense
	name = "dense grass"
	desc = "A thick patch of grass."
	icon = 'voidcrew/icons/obj/flora/wild.dmi'
	icon_state = "tall_grass_8"
	gender = PLURAL

/obj/structure/flora/deadgrass/tall/dense/Initialize()
	. = ..()
	icon_state = "[pick("tall_grass_8", "tall_grass_9")]"

/obj/structure/flora/branches
	name = "branch"
	desc = "The branch of some tree."
	icon = 'voidcrew/icons/obj/flora/wild.dmi'
	icon_state = "stick1"
	base_icon_state = "stick"

/obj/structure/flora/branches/Initialize()
	. = ..()
	icon_state = "[base_icon_state][rand(1,5)]"

/obj/structure/flora/cactus
	name = "cactus"
	desc = "One of the last remaining flora in the wastes."
	icon = 'voidcrew/icons/obj/flora/bigtrees.dmi'
	icon_state = "cactus"
	pixel_x = -16
	density = TRUE

/obj/structure/flora/glowshroom
	name = "glowshroom"
	desc = "Curious mushrooms that glow in the dark."
	icon = 'voidcrew/icons/obj/flora/wild.dmi'
	icon_state = "glowshroom0"
	base_icon_state = "glowshroom"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN
	light_range = 2
	light_power = 0.85

/obj/structure/flora/glowshroom/Initialize()
	. = ..()
	icon_state = "[base_icon_state][rand(0,3)]"

/obj/structure/flora/rock/wasteland
	name = "boulder"
	desc = "A large boulder, unaffected by the bringing of the end."
	icon_state = "basalt"
	icon = 'voidcrew/icons/obj/flora/rocks.dmi'

/obj/structure/flora/rock/hell
	name = "rock"
	desc = "A volcanic rock, one of the few familiar things on this planet."
	icon_state = "basalt"
	icon = 'voidcrew/icons/obj/flora/rocks.dmi'

/obj/structure/flora/rock/beach
	name = "sea stack"
	desc = "A column of rock, formed by wave erosion."
	icon_state = "basalt"
	icon = 'voidcrew/icons/obj/flora/rocks.dmi'

/obj/structure/flora/rock/snow
	name = "rock"
	desc = "A rock that's been missed by the freezing cold."
	icon_state = "basalt"
	icon = 'voidcrew/icons/obj/flora/rocks.dmi'

/obj/structure/flora/ausbushes
	name = "bush"
	desc = "Some kind of plant."
	icon = 'voidcrew/icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"

/obj/structure/flora/ausbushes/Initialize()
	if(icon_state == "firstbush_1")
		icon_state = "firstbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/reedbush
	name = "reeds"
	desc = "Some grass-like plants. They favour wet climates."
	icon_state = "reedbush_1"
	gender = PLURAL

/obj/structure/flora/ausbushes/reedbush/Initialize()
	icon_state = "reedbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/leafybush
	desc = "Some kind of leafy bush."
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/Initialize()
	icon_state = "leafybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/palebush
	desc = "Some kind of small bush."
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/Initialize()
	icon_state = "palebush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/stalkybush
	desc = "Some kind of bush with many stalks."
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/Initialize()
	icon_state = "stalkybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/grassybush
	desc = "Some kind of grassy bush."
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/Initialize()
	icon_state = "grassybush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/fernybush
	desc = "Some kind of bush with ferns."
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/Initialize()
	icon_state = "fernybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/sunnybush
	desc = "Some kind of bush that seems to have grown particularly well."
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/Initialize()
	icon_state = "sunnybush_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/genericbush
	desc = "Some kind of bush with no distinct features."
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/Initialize()
	icon_state = "genericbush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/Initialize()
	icon_state = "pointybush_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/lavendergrass
	name = "lavender"
	desc = "Some wild lavender. It smells good."
	icon_state = "lavendergrass_1"
	gender = PLURAL

/obj/structure/flora/ausbushes/lavendergrass/Initialize()
	icon_state = "lavendergrass_[rand(1, 4)]"
	. = ..()

/obj/structure/flora/ausbushes/ywflowers
	name = "flowers"
	desc = "Some yellow and white flowers. Pretty."
	icon_state = "ywflowers_1"
	gender = PLURAL

/obj/structure/flora/ausbushes/ywflowers/Initialize()
	icon_state = "ywflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/brflowers
	name = "flowers"
	desc = "Some blue and red flowers. Pretty."
	icon_state = "brflowers_1"
	gender = PLURAL

/obj/structure/flora/ausbushes/brflowers/Initialize()
	icon_state = "brflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/ppflowers
	name = "flowers"
	desc = "Some purple and pink flowers. Pretty."
	icon_state = "ppflowers_1"
	gender = PLURAL


/obj/structure/flora/ausbushes/ppflowers/Initialize()
	icon_state = "ppflowers_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/sparsegrass
	name = "grass"
	desc = "Some sparsely grown grass."
	icon_state = "sparsegrass_1"
	gender = PLURAL

/obj/structure/flora/ausbushes/sparsegrass/Initialize()
	icon_state = "sparsegrass_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/ausbushes/fullgrass
	name = "grass"
	desc = "A thick patch of grass."
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/Initialize()
	icon_state = "fullgrass_[rand(1, 3)]"
	. = ..()

/obj/structure/flora/junglebush
	name = "bush"
	desc = "A wild plant that is found in jungles."
	icon = 'voidcrew/icons/obj/flora/jungleflora.dmi'
	icon_state = "busha"

//Jungle rocks

/obj/structure/flora/rock/jungle
	name = "jungle rocks"
	icon_state = "rock"
	desc = "A pile of rocks, partially covered with grass."
	icon = 'icons/obj/fluff/flora/jungleflora.dmi'
	density = FALSE
	gender = PLURAL

/obj/structure/flora/rock/jungle/Initialize()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,5)]"


/obj/structure/flora/junglebush/Initialize()
	icon_state = "[icon_state][rand(1, 3)]"
	. = ..()

/obj/structure/flora/junglebush/b
	icon_state = "bushb"

/obj/structure/flora/junglebush/c
	icon_state = "bushc"

/obj/structure/flora/junglebush/large
	desc = "A large plant that is found in jungles."
	icon_state = "bush"
	icon = 'voidcrew/icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/flora/rock/pile/largejungle
	name = "rocks"
	desc = "A large pile of rocks. Grass is interspersed among the rocks."
	icon_state = "rocks"
	icon = 'voidcrew/icons/obj/flora/largejungleflora.dmi'
	density = FALSE
	pixel_x = -16
	pixel_y = -16
	gender = PLURAL

/obj/structure/flora/rock/pile/largejungle/Initialize()
	. = ..()
	icon_state = "[initial(icon_state)][rand(1,3)]"

/obj/structure/decoration
	name = "plastic decoration"
	desc = "A cheap plastic imitation of nature. At least it doesn't need watering."
	icon = 'icons/obj/fluff/flora/ausflora.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 20
	anchored = TRUE
	alpha = 210
	/// No material refund on deconstruction, it's cheap plastic
	custom_materials = null

/obj/structure/decoration/Initialize(mapload)
	. = ..()

/obj/structure/decoration/atom_deconstruct(disassembled = TRUE)
	return

/obj/structure/decoration/examine(mob/user)
	. = ..()
	. += span_notice("It's made of cheap, hollow plastic.")



/obj/structure/decoration/grass
	name = "plastic grass patch"
	desc = "Fake grass. Feels like a brillo pad."
	icon = 'icons/obj/fluff/flora/snowflora.dmi'
	icon_state = "snowgrass1gb"

/obj/structure/decoration/grass/first
	icon_state = "snowgrass1gb"

/obj/structure/decoration/grass/second
	icon_state = "snowgrass2gb"

/obj/structure/decoration/grass/third
	icon_state = "snowgrass3gb"

/obj/structure/decoration/grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"
	update_appearance()

/obj/structure/decoration/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/decoration/grass/brown/first
	icon_state = "snowgrass1bb"

/obj/structure/decoration/grass/brown/second
	icon_state = "snowgrass2bb"

/obj/structure/decoration/grass/brown/third
	icon_state = "snowgrass3bb"

/obj/structure/decoration/grass/brown/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"
	update_appearance()

/obj/structure/decoration/jungle_grass
	name = "plastic jungle grass"
	desc = "Plastic alien-looking grass. The jungle vibe without the jungle bugs."
	icon = 'icons/obj/fluff/flora/jungleflora.dmi'
	icon_state = "grassa1"

/obj/structure/decoration/jungle_grass/first
	icon_state = "grassa1"

/obj/structure/decoration/jungle_grass/second
	icon_state = "grassa2"

/obj/structure/decoration/jungle_grass/third
	icon_state = "grassa3"

/obj/structure/decoration/jungle_grass/fourth
	icon_state = "grassa4"

/obj/structure/decoration/jungle_grass/fifth
	icon_state = "grassa5"

/obj/structure/decoration/jungle_grass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "grassa[rand(1, 5)]"
	update_appearance()

/obj/structure/decoration/jungle_grass/b
	icon_state = "grassb1"

/obj/structure/decoration/jungle_grass/b/first
	icon_state = "grassb1"

/obj/structure/decoration/jungle_grass/b/second
	icon_state = "grassb2"

/obj/structure/decoration/jungle_grass/b/third
	icon_state = "grassb3"

/obj/structure/decoration/jungle_grass/b/fourth
	icon_state = "grassb4"

/obj/structure/decoration/jungle_grass/b/fifth
	icon_state = "grassb5"

/obj/structure/decoration/jungle_grass/b/style_random/Initialize(mapload)
	. = ..()
	icon_state = "grassb[rand(1, 5)]"
	update_appearance()



/obj/structure/decoration/bush
	name = "plastic bush"
	desc = "A plastic shrub. Bristly to the touch and slightly off-color."
	icon = 'icons/obj/fluff/flora/ausflora.dmi'
	icon_state = "firstbush_1"

/obj/structure/decoration/bush/first
	icon_state = "firstbush_1"

/obj/structure/decoration/bush/second
	icon_state = "firstbush_2"

/obj/structure/decoration/bush/third
	icon_state = "firstbush_3"

/obj/structure/decoration/bush/fourth
	icon_state = "firstbush_4"

/obj/structure/decoration/bush/style_random/Initialize(mapload)
	. = ..()
	icon_state = "firstbush_[rand(1, 4)]"
	update_appearance()

/obj/structure/decoration/bush/reed
	name = "plastic reeds"
	icon_state = "reedbush_1"

/obj/structure/decoration/bush/reed/first
	icon_state = "reedbush_1"

/obj/structure/decoration/bush/reed/second
	icon_state = "reedbush_2"

/obj/structure/decoration/bush/reed/third
	icon_state = "reedbush_3"

/obj/structure/decoration/bush/reed/fourth
	icon_state = "reedbush_4"

/obj/structure/decoration/bush/reed/style_random/Initialize(mapload)
	. = ..()
	icon_state = "reedbush_[rand(1, 4)]"
	update_appearance()

/obj/structure/decoration/bush/leafy
	name = "plastic leafy bush"
	icon_state = "leafybush_1"

/obj/structure/decoration/bush/leafy/first
	icon_state = "leafybush_1"

/obj/structure/decoration/bush/leafy/second
	icon_state = "leafybush_2"

/obj/structure/decoration/bush/leafy/third
	icon_state = "leafybush_3"

/obj/structure/decoration/bush/leafy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "leafybush_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/pale
	name = "plastic pale bush"
	icon_state = "palebush_1"

/obj/structure/decoration/bush/pale/first
	icon_state = "palebush_1"

/obj/structure/decoration/bush/pale/second
	icon_state = "palebush_2"

/obj/structure/decoration/bush/pale/third
	icon_state = "palebush_3"

/obj/structure/decoration/bush/pale/fourth
	icon_state = "palebush_4"

/obj/structure/decoration/bush/pale/style_random/Initialize(mapload)
	. = ..()
	icon_state = "palebush_[rand(1, 4)]"
	update_appearance()

/obj/structure/decoration/bush/stalky
	name = "plastic stalky bush"
	icon_state = "stalkybush_1"

/obj/structure/decoration/bush/stalky/first
	icon_state = "stalkybush_1"

/obj/structure/decoration/bush/stalky/second
	icon_state = "stalkybush_2"

/obj/structure/decoration/bush/stalky/third
	icon_state = "stalkybush_3"

/obj/structure/decoration/bush/stalky/style_random/Initialize(mapload)
	. = ..()
	icon_state = "stalkybush_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/grassy
	name = "plastic grassy bush"
	icon_state = "grassybush_1"

/obj/structure/decoration/bush/grassy/first
	icon_state = "grassybush_1"

/obj/structure/decoration/bush/grassy/second
	icon_state = "grassybush_2"

/obj/structure/decoration/bush/grassy/third
	icon_state = "grassybush_3"

/obj/structure/decoration/bush/grassy/fourth
	icon_state = "grassybush_4"

/obj/structure/decoration/bush/grassy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "grassybush_[rand(1, 4)]"
	update_appearance()

/obj/structure/decoration/bush/sparsegrass
	name = "plastic sparse grass"
	icon_state = "sparsegrass_1"

/obj/structure/decoration/bush/sparsegrass/first
	icon_state = "sparsegrass_1"

/obj/structure/decoration/bush/sparsegrass/second
	icon_state = "sparsegrass_2"

/obj/structure/decoration/bush/sparsegrass/third
	icon_state = "sparsegrass_3"

/obj/structure/decoration/bush/sparsegrass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/fullgrass
	name = "plastic full grass"
	icon_state = "fullgrass_1"

/obj/structure/decoration/bush/fullgrass/first
	icon_state = "fullgrass_1"

/obj/structure/decoration/bush/fullgrass/second
	icon_state = "fullgrass_2"

/obj/structure/decoration/bush/fullgrass/third
	icon_state = "fullgrass_3"

/obj/structure/decoration/bush/fullgrass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/ferny
	name = "plastic ferny bush"
	icon_state = "fernybush_1"

/obj/structure/decoration/bush/ferny/first
	icon_state = "fernybush_1"

/obj/structure/decoration/bush/ferny/second
	icon_state = "fernybush_2"

/obj/structure/decoration/bush/ferny/third
	icon_state = "fernybush_3"

/obj/structure/decoration/bush/ferny/style_random/Initialize(mapload)
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/sunny
	name = "plastic sunny bush"
	icon_state = "sunnybush_1"

/obj/structure/decoration/bush/sunny/first
	icon_state = "sunnybush_1"

/obj/structure/decoration/bush/sunny/second
	icon_state = "sunnybush_2"

/obj/structure/decoration/bush/sunny/third
	icon_state = "sunnybush_3"

/obj/structure/decoration/bush/sunny/style_random/Initialize(mapload)
	. = ..()
	icon_state = "sunnybush_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/generic
	name = "plastic generic bush"
	icon_state = "genericbush_1"

/obj/structure/decoration/bush/generic/first
	icon_state = "genericbush_1"

/obj/structure/decoration/bush/generic/second
	icon_state = "genericbush_2"

/obj/structure/decoration/bush/generic/third
	icon_state = "genericbush_3"

/obj/structure/decoration/bush/generic/fourth
	icon_state = "genericbush_4"

/obj/structure/decoration/bush/generic/style_random/Initialize(mapload)
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"
	update_appearance()

/obj/structure/decoration/bush/pointy
	name = "plastic pointy bush"
	icon_state = "pointybush_1"

/obj/structure/decoration/bush/pointy/first
	icon_state = "pointybush_1"

/obj/structure/decoration/bush/pointy/second
	icon_state = "pointybush_2"

/obj/structure/decoration/bush/pointy/third
	icon_state = "pointybush_3"

/obj/structure/decoration/bush/pointy/fourth
	icon_state = "pointybush_4"

/obj/structure/decoration/bush/pointy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "pointybush_[rand(1, 4)]"
	update_appearance()

/obj/structure/decoration/bush/lavendergrass
	name = "plastic lavender grass"
	icon_state = "lavendergrass_1"

/obj/structure/decoration/bush/lavendergrass/first
	icon_state = "lavendergrass_1"

/obj/structure/decoration/bush/lavendergrass/second
	icon_state = "lavendergrass_2"

/obj/structure/decoration/bush/lavendergrass/third
	icon_state = "lavendergrass_3"

/obj/structure/decoration/bush/lavendergrass/fourth
	icon_state = "lavendergrass_4"

/obj/structure/decoration/bush/lavendergrass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "lavendergrass_[rand(1, 4)]"
	update_appearance()



/obj/structure/decoration/bush/flowers_yw
	name = "plastic yellow-white flowers"
	icon_state = "ywflowers_1"

/obj/structure/decoration/bush/flowers_yw/first
	icon_state = "ywflowers_1"

/obj/structure/decoration/bush/flowers_yw/second
	icon_state = "ywflowers_2"

/obj/structure/decoration/bush/flowers_yw/third
	icon_state = "ywflowers_3"

/obj/structure/decoration/bush/flowers_yw/style_random/Initialize(mapload)
	. = ..()
	icon_state = "ywflowers_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/flowers_br
	name = "plastic blue-red flowers"
	icon_state = "brflowers_1"

/obj/structure/decoration/bush/flowers_br/first
	icon_state = "brflowers_1"

/obj/structure/decoration/bush/flowers_br/second
	icon_state = "brflowers_2"

/obj/structure/decoration/bush/flowers_br/third
	icon_state = "brflowers_3"

/obj/structure/decoration/bush/flowers_br/style_random/Initialize(mapload)
	. = ..()
	icon_state = "brflowers_[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/flowers_pp
	name = "plastic purple flowers"
	icon_state = "ppflowers_1"

/obj/structure/decoration/bush/flowers_pp/first
	icon_state = "ppflowers_1"

/obj/structure/decoration/bush/flowers_pp/second
	icon_state = "ppflowers_2"

/obj/structure/decoration/bush/flowers_pp/third
	icon_state = "ppflowers_3"

/obj/structure/decoration/bush/flowers_pp/style_random/Initialize(mapload)
	. = ..()
	icon_state = "ppflowers_[rand(1, 3)]"
	update_appearance()



/obj/structure/decoration/bush/snow
	name = "plastic snowy bush"
	desc = "A plastic bush dusted with fake snow. Year-round winter cheer."
	icon = 'icons/obj/fluff/flora/snowflora.dmi'
	icon_state = "snowbush1"

/obj/structure/decoration/bush/snow/first
	icon_state = "snowbush1"

/obj/structure/decoration/bush/snow/second
	icon_state = "snowbush2"

/obj/structure/decoration/bush/snow/third
	icon_state = "snowbush3"

/obj/structure/decoration/bush/snow/fourth
	icon_state = "snowbush4"

/obj/structure/decoration/bush/snow/fifth
	icon_state = "snowbush5"

/obj/structure/decoration/bush/snow/sixth
	icon_state = "snowbush6"

/obj/structure/decoration/bush/snow/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"
	update_appearance()


/obj/structure/decoration/bush/jungle
	name = "plastic jungle bush"
	desc = "Plastic jungle foliage. All the looks, none of the allergens."
	icon = 'icons/obj/fluff/flora/jungleflora.dmi'
	icon_state = "busha1"

/obj/structure/decoration/bush/jungle/first
	icon_state = "busha1"

/obj/structure/decoration/bush/jungle/second
	icon_state = "busha2"

/obj/structure/decoration/bush/jungle/third
	icon_state = "busha3"

/obj/structure/decoration/bush/jungle/style_random/Initialize(mapload)
	. = ..()
	icon_state = "busha[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/jungle/b
	icon_state = "bushb1"

/obj/structure/decoration/bush/jungle/b/first
	icon_state = "bushb1"

/obj/structure/decoration/bush/jungle/b/second
	icon_state = "bushb2"

/obj/structure/decoration/bush/jungle/b/third
	icon_state = "bushb3"

/obj/structure/decoration/bush/jungle/b/style_random/Initialize(mapload)
	. = ..()
	icon_state = "bushb[rand(1, 3)]"
	update_appearance()

/obj/structure/decoration/bush/jungle/c
	icon_state = "bushc1"

/obj/structure/decoration/bush/jungle/c/first
	icon_state = "bushc1"

/obj/structure/decoration/bush/jungle/c/second
	icon_state = "bushc2"

/obj/structure/decoration/bush/jungle/c/third
	icon_state = "bushc3"

/obj/structure/decoration/bush/jungle/c/style_random/Initialize(mapload)
	. = ..()
	icon_state = "bushc[rand(1, 3)]"
	update_appearance()


/obj/structure/decoration/bush/large
	name = "large plastic bush"
	desc = "A large plastic bush. Dominates the room with its hollow presence."
	icon = 'icons/obj/fluff/flora/largejungleflora.dmi'
	icon_state = "bush1"
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	density = FALSE

/obj/structure/decoration/bush/large/first
	icon_state = "bush1"

/obj/structure/decoration/bush/large/second
	icon_state = "bush2"

/obj/structure/decoration/bush/large/third
	icon_state = "bush3"

/obj/structure/decoration/bush/large/style_random/Initialize(mapload)
	. = ..()
	icon_state = "bush[rand(1, 3)]"
	update_appearance()

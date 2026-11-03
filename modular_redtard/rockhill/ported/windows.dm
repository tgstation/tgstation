/obj/structure/roguewindow
	parent_type = /obj/structure/rockhill/window
	name = "window"
	desc = "A glass window, it separates a small slice of civilization from the savage outside world."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "window-solid"
	density = TRUE
	opacity = FALSE
	repair_cost_first = /obj/item/grown/log/tree/small
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "window-solid"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW

/obj/structure/roguewindow/harem2
	name = "harem window"
	desc = "An opaque glass window, it promises delights and opportunities you may never see realized."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "harem2-solid"
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/natural/glass
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "harem2-solid"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_HAREM2

/obj/structure/roguewindow/harem3
	name = "harem window"
	desc = "An opaque glass window, the blur of colors and shapes behind it serve as ever more temptation to the mind."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "harem3-solid"
	density = TRUE
	opacity = FALSE
	repair_cost_first = /obj/item/natural/glass
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "harem3-solid"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_HAREM3

/obj/structure/roguewindow/harem3/frosted
	name = "frosted glass window"
	desc = "A frosted glass window, it obscures the view but focuses the mind on just what could be hiding behind it."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "harem3-solid"
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/natural/glass
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "harem3-solid"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_HAREM3_FROSTED

/obj/structure/roguewindow/openclose
	name = "window"
	desc = "A glass window, it separates a small slice of civilization from the savage outside world."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/grown/log/tree/small
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	icon_state = "woodwindow"
	layer = TABLE_LAYER
	base_state = "woodwindow"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_OPENCLOSE

/obj/structure/roguewindow/openclose/reinforced
	name = "window"
	desc = "A glass window reinforced with a metal mesh, it still won't keep you alive tonight."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/ingot/iron
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	icon_state = "reinforcedwindow"
	layer = TABLE_LAYER
	base_state = "reinforcedwindow"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_OPENCLOSE_REINFORCED

/obj/structure/roguewindow/openclose/reinforced/brick
	name = "window"
	desc = "A glass window reinforced with a metal frame, it should keep you safe from the outside world."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/ingot/iron
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	icon_state = "brickwindow"
	layer = TABLE_LAYER
	base_state = "brickwindow"

/obj/structure/roguewindow/stained/silver
	name = "psydonite window"
	desc = "A glass window stained in the silver of the Otavan Orthodoxy, it represents a time of hope long past which refuses to die."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "stained-silver"
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/natural/glass
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "stained-silver"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_STAINED_SILVER

/obj/structure/roguewindow/stained/yellow
	name = "astratan window"
	desc = "A glass window stained in the gold of the Sun Cult, it represents the undying authority of their faith, ever-present as the wilting gaze of the sun above."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "stained-yellow"
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/natural/glass
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "stained-yellow"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_STAINED_YELLOW

/obj/structure/roguewindow/stained/zizo
	name = "zizite window"
	desc = "A glass window stained in the red of the Zizo Cabal, it represents the endless ambition of their cause and goddess, that which is unsatisfied with just one life to live."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/roguewindow.dmi'
	icon_state = "stained-zizo"
	density = TRUE
	opacity = TRUE
	repair_cost_first = /obj/item/natural/glass
	repair_cost_second = /obj/item/natural/glass
	repair_skill = /datum/attribute/skill/craft/carpentry
	layer = TABLE_LAYER
	base_state = "stained-zizo"
	smoothing_groups = SMOOTH_GROUP_ROCKHILL_STRUCTURE_ROGUEWINDOW_STAINED_ZIZO

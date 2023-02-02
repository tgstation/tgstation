/obj/structure/window/reinforced/tram/front
	name = "tram wall"
	icon = 'icons/obj/smooth_structures/tram_window.dmi'
	desc = "A lightweight titanium composite structure with a windscreen installed."
	icon = 'icons/obj/smooth_structures/tram_window.dmi'
	icon_state = "tram_window-0"
	base_icon_state = "tram_window"
	max_integrity = 100
	wtype = "shuttle"
	reinf = TRUE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_tram
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2
	rad_insulation = RAD_MEDIUM_INSULATION

/obj/structure/window/reinforced/tram
	name = "tram window"
	desc = "A window made out of a titanium-silicate alloy. It looks tough to break. Is that a challenge?"
	icon = 'icons/obj/smooth_structures/tram_window.dmi'
	icon_state = "tram_mid"
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_tram
	max_integrity = 100
	explosion_block = 0
	glass_type = /obj/item/stack/sheet/titaniumglass
	rad_insulation = RAD_MEDIUM_INSULATION

/obj/structure/window/reinforced/tram/left/directional/north
	icon_state = "tram_left"
	layer = LOW_ITEM_LAYER

/obj/structure/window/reinforced/tram/left/directional/south
	icon_state = "tram_left"
	plane = WALL_PLANE_UPPER

/obj/structure/window/reinforced/tram/mid/directional/north
	icon_state = "tram_mid"
	layer = LOW_ITEM_LAYER

/obj/structure/window/reinforced/tram/mid/directional/south
	icon_state = "tram_mid"
	plane = WALL_PLANE_UPPER

/obj/structure/window/reinforced/tram/right/directional/north
	icon_state = "tram_right"
	layer = LOW_ITEM_LAYER

/obj/structure/window/reinforced/tram/right/directional/south
	icon_state = "tram_right"
	plane = WALL_PLANE_UPPER

/datum/armor/window_tram
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

/obj/structure/window/reinforced/tram/spawnDebris(location)
	. = list()
	. += new /obj/item/stack/sheet/titaniumglass(location)
	. += new /obj/item/stack/rods(location)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tram/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tram/mid, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tram/right, 0)

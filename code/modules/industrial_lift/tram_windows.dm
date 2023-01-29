/obj/structure/window/reinforced/tram
	name = "tram window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon = 'icons/obj/smooth_structures/tram_window.dmi'
	icon_state = "tram_mid"
	reinf = TRUE
	heat_resistance = 25000
	armor_type = /datum/armor/window_tram
	max_integrity = 100
	explosion_block = 0
	glass_type = /obj/item/stack/sheet/titaniumglass
	rad_insulation = RAD_MEDIUM_INSULATION

/obj/structure/window/reinforced/tram/left
	icon_state = "tram_left"

/obj/structure/window/reinforced/tram/right
	icon_state = "tram_right"

/datum/armor/window_tram
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

/obj/structure/window/reinforced/tram/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive)

/obj/structure/window/reinforced/tram/spawnDebris(location)
	. = list()
	. += new /obj/item/shard/plasma(location)
	. += new /obj/effect/decal/cleanable/glass/plasma(location)
	. += new /obj/item/stack/rods(location)

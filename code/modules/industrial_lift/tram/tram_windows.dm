/obj/structure/window/reinforced/tram
	name = "tram window"
	desc = "A window made out of a titanium-silicate alloy. It looks tough to break. Is that a challenge?"
	icon = 'icons/obj/smooth_structures/windows/tram_thindow.dmi'
	canSmoothWith = SMOOTH_GROUP_WINDOW_DIRECTIONAL_TRAM
	smoothing_groups = SMOOTH_GROUP_WINDOW_DIRECTIONAL_TRAM
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/window_tram
	max_integrity = 100
	explosion_block = 0
	glass_type = /obj/item/stack/sheet/titaniumglass
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/titaniumglass

/obj/structure/window/reinforced/tram/front
	name = "tram wall"
	desc = "A lightweight titanium composite structure with a windscreen installed."
	icon = 'icons/obj/smooth_structures/tram_window.dmi'
	icon_state = "tram_window-0"
	base_icon_state = "tram_window"
	wtype = "shuttle"
	fulltile = TRUE
	smoothing_flags = NONE
	canSmoothWith = null
	smoothing_groups = SMOOTH_GROUP_WINDOW_DIRECTIONAL_TRAM
	flags_1 = PREVENT_CLICK_UNDER_1
	explosion_block = 3
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2

/datum/armor/window_tram
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/window/reinforced/tram)

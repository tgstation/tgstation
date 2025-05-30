/// Create colored subtypes for sofas
#define COLORED_SOFA(path, color_name, sofa_color) \
path/middle/color_name {\
	color = sofa_color; \
} \
path/right/color_name {\
	color = sofa_color; \
} \
path/left/color_name {\
	color = sofa_color; \
} \
path/corner/color_name {\
	color = sofa_color; \
}

/obj/structure/chair/sofa
	name = "old ratty sofa"
	icon_state = "error"
	icon = 'icons/obj/chairs_wide.dmi'
	buildstackamount = 1
	item_chair = null
	fishing_modifier = -6
	has_armrest = TRUE

/obj/structure/chair/sofa/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/soft_landing)

/obj/structure/chair/sofa/electrify_self(obj/item/assembly/shock_kit/input_shock_kit, mob/user, list/overlays_from_child_procs)
	if(!overlays_from_child_procs)
		var/mutable_appearance/echair_overlay = mutable_appearance('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER, src, appearance_flags = KEEP_APART)
		echair_overlay.pixel_x = -1
		overlays_from_child_procs = list(echair_overlay)
	. = ..()

/obj/structure/chair/sofa/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

/obj/structure/chair/sofa/middle
	icon_state = "sofamiddle"

/obj/structure/chair/sofa/left
	icon_state = "sofaend_left"

/obj/structure/chair/sofa/right
	icon_state = "sofaend_right"

/obj/structure/chair/sofa/corner
	icon_state = "sofacorner"

COLORED_SOFA(/obj/structure/chair/sofa, brown, SOFA_BROWN)
COLORED_SOFA(/obj/structure/chair/sofa, maroon, SOFA_MAROON)

// Original icon ported from Eris(?) and updated to work here.
/obj/structure/chair/sofa/corp
	name = "sofa"
	desc = "Soft and cushy."
	icon_state = "corp_sofamiddle"

/obj/structure/chair/sofa/corp/left
	icon_state = "corp_sofaend_left"

/obj/structure/chair/sofa/corp/right
	icon_state = "corp_sofaend_right"

/obj/structure/chair/sofa/corp/corner
	icon_state = "corp_sofacorner"

/obj/structure/chair/sofa/corp/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

// Ported from Skyrat
/obj/structure/chair/sofa/bench
	name = "bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon = 'icons/map_icons/objects.dmi'
	icon_state = "/obj/structure/chair/sofa/bench"
	post_init_icon_state = "bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#af7d28"
	has_armrest = FALSE

/obj/structure/chair/sofa/bench/left
	icon_state = "/obj/structure/chair/sofa/bench/left"
	post_init_icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/right
	icon_state = "/obj/structure/chair/sofa/bench/right"
	post_init_icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/corner
	icon_state = "/obj/structure/chair/sofa/bench/corner"
	post_init_icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/solo
	icon_state = "/obj/structure/chair/sofa/bench/solo"
	post_init_icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo


// Bamboo benches
/obj/structure/chair/sofa/bamboo
	name = "bamboo bench"
	desc = "A makeshift bench with a rustic aesthetic."
	icon_state = "bamboo_sofamiddle"
	resistance_flags = FLAMMABLE
	max_integrity = 60
	buildstacktype = /obj/item/stack/sheet/mineral/bamboo
	buildstackamount = 3
	has_armrest = FALSE

/obj/structure/chair/sofa/bamboo/left
	icon_state = "bamboo_sofaend_left"

/obj/structure/chair/sofa/bamboo/right
	icon_state = "bamboo_sofaend_right"

#undef COLORED_SOFA

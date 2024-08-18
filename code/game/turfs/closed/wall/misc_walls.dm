/turf/closed/wall/mineral/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	turf_flags = IS_SOLID
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_BOSS_WALLS
	canSmoothWith = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_BOSS_WALLS
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/closed/wall/mineral/cult/Initialize(mapload)
	new /obj/effect/temp_visual/cult/turf(src)
	. = ..()

/turf/closed/wall/mineral/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/closed/wall/mineral/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/closed/wall/mineral/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/closed/wall/mineral/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

/turf/closed/wall/ice
	icon = 'icons/turf/walls/iced_metal_wall.dmi'
	desc = "A wall covered in a thick sheet of ice."
	turf_flags = IS_SOLID
	rcd_memory = null
	hardness = 35
	slicing_duration = 150 //welding through the ice+metal
	bullet_sizzle = TRUE

/turf/closed/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	smoothing_flags = SMOOTH_BITMASK
	hardness = 45
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = MAP_SWITCH(null, COLOR_ORANGE_BROWN)

/turf/closed/wall/rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust)

/turf/closed/wall/heretic_rust
	color = MAP_SWITCH(null, COLOR_GREEN_GRAY)

/turf/closed/wall/heretic_rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust/heretic)

/turf/closed/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	smoothing_flags = SMOOTH_BITMASK
	hardness = 15

/turf/closed/wall/r_wall/rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust)

/turf/closed/wall/r_wall/heretic_rust
	color = MAP_SWITCH(null, COLOR_GREEN_GRAY)
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'

/turf/closed/wall/r_wall/heretic_rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust/heretic)

/turf/closed/wall/mineral/bronze
	name = "clockwork wall"
	desc = "A huge chunk of bronze, decorated like gears and cogs."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	turf_flags = IS_SOLID
	smoothing_flags = SMOOTH_BITMASK
	sheet_type = /obj/item/stack/sheet/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze
	smoothing_groups = SMOOTH_GROUP_CLOCK_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOCK_WALLS

/turf/closed/wall/rock
	name = "reinforced rock"
	desc = "It has metal struts that need to be welded away before it can be mined."
	icon = 'icons/turf/walls/reinforced_red_rock_wall.dmi'
	turf_flags = NO_RUST
	sheet_amount = 1
	hardness = 50
	girder_type = null
	decon_type = /turf/closed/mineral/asteroid

/turf/closed/wall/rock/porous
	name = "reinforced porous rock"
	desc = "This rock is filled with pockets of breathable air. It has metal struts to protect it from mining."
	decon_type = /turf/closed/mineral/asteroid/porous

/turf/closed/wall/space
	name = "illusionist wall"
	icon = 'icons/turf/space.dmi'
	icon_state = "space"
	plane = PLANE_SPACE
	turf_flags = NO_RUST
	smoothing_flags = NONE
	canSmoothWith = null
	smoothing_groups = null
	use_splitvis = FALSE

/turf/closed/wall/fake_hierophant
	name = "vibrant wall"
	desc = "A wall made out of a strange metal. The squares on it pulse in a predictable pattern."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_HIERO_WALL + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_HIERO_WALL

/turf/closed/wall/material/meat
	name = "living wall"
	baseturfs = /turf/open/floor/material/meat
	girder_type = null
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/closed/wall/material/meat/Initialize(mapload)
	. = ..()
	set_custom_materials(list(GET_MATERIAL_REF(/datum/material/meat) = SHEET_MATERIAL_AMOUNT))

/turf/closed/wall/material/meat/airless
	baseturfs = /turf/open/floor/material/meat/airless

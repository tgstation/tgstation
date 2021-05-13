/turf/closed/wall/mineral/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	frill_icon = 'icons/effects/frills/wall_cult_frill.dmi'
	icon_state = "cult_wall-0"
	base_icon_state = "cult_wall"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult

/turf/closed/wall/mineral/cult/Initialize()
	new /obj/effect/temp_visual/cult/turf(src)
	. = ..()

/turf/closed/wall/mineral/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/closed/wall/mineral/cult/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(istype(AM, /mob/living/simple_animal/hostile/construct/harvester)) //harvesters can go through cult walls, dragging something with
		var/mob/living/simple_animal/hostile/construct/harvester/H = AM
		var/atom/movable/stored_pulling = H.pulling
		if(stored_pulling)
			stored_pulling.setDir(get_dir(stored_pulling.loc, newloc))
			stored_pulling.forceMove(src)
			H.start_pulling(stored_pulling, supress_message = TRUE)

/turf/closed/wall/mineral/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/closed/wall/mineral/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/closed/wall/mineral/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

/turf/closed/wall/vault
	name = "strange wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"
	base_icon_state = "rockvault"
	smoothing_flags = NONE
	canSmoothWith = null
	smoothing_groups = null
	rcd_memory = null

/turf/closed/wall/vault/rock
	name = "rocky wall"
	desc = "You feel a strange nostalgia from looking at this..."

/turf/closed/wall/vault/alien
	name = "alien wall"
	icon_state = "alienvault"
	base_icon_state = "alienvault"

/turf/closed/wall/vault/sandstone
	name = "sandstone wall"
	icon_state = "sandstonevault"
	base_icon_state = "sandstonevault"

/turf/closed/wall/ice
	icon = 'icons/turf/walls/icedmetal_wall.dmi'
	icon_state = "icedmetal_wall-0"
	base_icon_state = "icedmetal_wall"
	desc = "A wall covered in a thick sheet of ice."
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null
	rcd_memory = null
	hardness = 35
	slicing_duration = 150 //welding through the ice+metal
	bullet_sizzle = TRUE
	frill_icon = null

/turf/closed/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	frill_icon = 'icons/effects/frills/wall_rusty_frill.dmi'
	icon_state = "rusty_wall-0"
	base_icon_state = "rusty_wall"
	smoothing_flags = SMOOTH_BITMASK
	hardness = 45

/turf/closed/wall/rust/rust_heretic_act()
	ScrapeAway()

/turf/closed/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	frill_icon = 'icons/effects/frills/wall_rusty_reinforced_frill.dmi'
	icon_state = "rusty_reinforced_wall-0"
	base_icon_state = "rusty_reinforced_wall"
	smoothing_flags = SMOOTH_BITMASK
	hardness = 15

/turf/closed/wall/r_wall/rust/rust_heretic_act()
	if(prob(50))
		return
	ScrapeAway()

/turf/closed/wall/mineral/bronze
	name = "clockwork wall"
	desc = "A huge chunk of bronze, decorated like gears and cogs."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	frill_icon = 'icons/effects/frills/wall_clockwork_frill.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	smoothing_flags = SMOOTH_BITMASK
	sheet_type = /obj/item/stack/sheet/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze

/turf/closed/mineral/random/high_chance/wasteland
	baseturfs = /turf/open/misc/dust

/turf/closed/mineral/random/high_chance/mineral_chances()
	return list(
		/obj/item/stack/ore/uranium = 35,
		/obj/item/stack/ore/diamond = 30,
		/obj/item/stack/ore/gold = 45,
		/obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/iron = 55,
		/obj/item/stack/ore/silver = 50,
		/obj/item/stack/ore/plasma = 50,
		/obj/item/stack/ore/bluespace_crystal = 20,
		/turf/closed/mineral/gibtonite/wasteland = 4,
	)

/turf/closed/mineral/gibtonite/wasteland
	baseturfs = /turf/open/misc/dust

/turf/closed/mineral/random/beach
	baseturfs = /turf/open/misc/asteroid/sand/beach/dense

/turf/closed/wall/mineral/titanium/interior/blue
	color = "#9CE9F6"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/wall/mineral/titanium/interior/blue/Initialize()
	. = ..()
	add_atom_colour("#9CE9F6", FIXED_COLOUR_PRIORITY) // fuck you

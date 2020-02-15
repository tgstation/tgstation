/turf/thematic
	var/trait

/turf/thematic/New()
	var/turftype = SSmapping.level_trait(z, trait)
	ChangeTurf(turftype, flags = CHANGETURF_INHERIT_AIR)

/turf/thematic/floor
	trait = ZTRAIT_THEMATIC_PLATING

/turf/thematic/lava
	trait = ZTRAIT_THEMATIC_LAVA

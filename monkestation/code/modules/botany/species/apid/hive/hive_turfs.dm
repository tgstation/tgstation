/turf/open/indestructible/hive
	name = "wax floor"
	desc = "A floor made of beeswax"

	icon = 'goon/icons/floors.dmi'
	icon_state = "hive"

/turf/closed/indestructible/hive
	name = "wax wall"
	desc = "A wall made of wax"

	icon = 'goon/icons/walls_beehive.dmi'
	icon_state = "bee-0"
	base_icon_state = "bee"

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WAXWALL
	canSmoothWith = SMOOTH_GROUP_WAXWALL

/turf/closed/wall
	icon = 'monkestation/icons/turf/walls/wall.dmi'

/turf/closed/wall/r_wall
	icon = 'monkestation/icons/turf/walls/reinforced_wall.dmi'

/turf/closed/wall/rust/New()
	. = ..()
	var/mutable_appearance/rust = mutable_appearance(icon, "rust")
	add_overlay(rust)

/turf/closed/wall/r_wall/rust/New()
	. = ..()
	var/mutable_appearance/rust = mutable_appearance(icon, "rust")
	add_overlay(rust)


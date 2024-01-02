/datum/overmap/star
	var/name = "Star"
	var/desc = "A star."
	var/icon = 'voidcrew/modules/overmap/icons/effects/overmap.dmi'
	var/icon_state = "star1"

	var/colours_to_pick = 1
	var/colours_and_descs = list(
		"#ffffff" = "A white dwarf.",
		"#75ffff" = "A blue giant.",
		"#c0ffff" = "",
		"#ffff00" = "",
		"#ff7f00" = "",
		"#d50000" = "",
		"#a31300" = "",
		"#a60347" = "A brown dwarf.",
		"#4a3059" = "A brown dwarf.",
		"#c0ffff" = "A white dwarf."
	)

	var/bound_height
	var/bound_width
	var/pixel_x
	var/pixel_y
	var/pixel_z
	var/pixel_w

/datum/overmap/star/medium
	icon = 'voidcrew/modules/overmap/icons/effects/overmap_large.dmi'
	icon_state = "star2"

	bound_height = 64
	bound_width = 64
	pixel_x = -16
	pixel_y = -16

	colours_and_descs = list(
		"#c0ffff" = "",
		"#ffff00" = "",
		"#ff7f00" = "",
		"#d50000" = "",
		"#a31300" = "",
	)

/datum/overmap/star/big
	icon = 'voidcrew/modules/overmap/icons/effects/overmap_larger.dmi'
	icon_state = "star3"

	bound_height = 96
	bound_width = 96
	pixel_z = -32
	pixel_w = -32

	colours_and_descs = list(
		"#75ffff" = "A blue giant.",
		"#c0ffff" = "",
		"#ffff00" = "",
		"#ff7f00" = "",
		"#d50000" = "",
		"#a31300" = "",
	)

/datum/overmap/star/big/binary
	name = "Binary Star System"
	desc = "Two stars orbiting each other."


	icon_state = "binaryswoosh"
	colours_to_pick = 2

	colours_and_descs = list(
		"#75ffff" = "",
		"#c0ffff" = "",
		"#ffff00" = "",
		"#ff7f00" = "",
		"#d50000" = "",
		"#a31300" = "",
	)

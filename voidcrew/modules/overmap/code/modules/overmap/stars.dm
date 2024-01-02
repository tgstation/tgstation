/obj/structure/overmap/star
	/// Datum containing all of the information for the star
	var/datum/overmap/star/star_datum = /datum/overmap/star

/obj/structure/overmap/star/Initialize(mapload)
	. = ..()

	star_datum = new star_datum

	name = "[pick(GLOB.star_names)] [pick(GLOB.greek_letters)]"
	desc = star_datum.desc
	icon = star_datum.icon
	icon_state = star_datum.icon_state

	var/colour_one = pick(star_datum.colours_and_descs)
	var/colour_two = "[star_datum.colours_to_pick > 1 ? pick(star_datum.colours_and_descs) : ""]"

	apply_star_colours(colour_one, colour_two)

/obj/structure/overmap/star/Destroy()
	QDEL_NULL(star_datum)
	return ..()

/obj/structure/overmap/star/proc/apply_star_colours(colour_one, colour_two)
	if (colour_two == "")
		add_atom_colour(colour_one, FIXED_COLOUR_PRIORITY)
		return
	cut_overlays()

	var/mutable_appearance/star_one = mutable_appearance(icon_state = "binary1")
	var/mutable_appearance/star_two = mutable_appearance(icon_state = "binary2")
	star_one.color = colour_one
	star_two.color = colour_two
	add_overlay(star_one)
	add_overlay(star_two)

/obj/structure/overmap/star/medium
	star_datum = /datum/overmap/star/medium

/obj/structure/overmap/star/big
	star_datum = /datum/overmap/star/big

/obj/structure/overmap/star/big/binary
	star_datum = /datum/overmap/star/big/binary

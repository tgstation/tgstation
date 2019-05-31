/*
	This type poster is of 3 parts: picture, foreground, background

	background - Poster paper printed on
	foreground - Text on top of poster
	picture - The image on the poster: Typically a missing person or wanted individual.

*/

/obj/item/poster/wanted
	icon_state = "rolled_poster"
	var/foreground = "wanted_foreground"
	var/background = "wanted_background"
	var/postName = "wanted poster"
	var/postDesc = "A wanted poster for"

/obj/item/poster/wanted/missing
	foreground = "missing_foreground"
	postName = "missing poster"
	postDesc = "A missing poster for"

/obj/item/poster/wanted/Initialize(mapload, icon/person_icon, wanted_name, description)
	. = ..(mapload, new /obj/structure/sign/poster/wanted(src, person_icon, wanted_name, description, foreground, background, postName, postDesc))
	name = "[postName] ([wanted_name])"
	desc = "[postDesc] [wanted_name]."

/obj/structure/sign/poster/wanted
	var/wanted_name
	var/postName
	var/postDesc

/obj/structure/sign/poster/wanted/Initialize(mapload, icon/person_icon, person_name, description, foreground, background, pname, pdesc)
	. = ..()
	if(!person_icon)
		return INITIALIZE_HINT_QDEL

	postName = pname
	postDesc = pdesc
	wanted_name = person_name

	name = "[postName] ([wanted_name])"	
	desc = description

	person_icon = icon(person_icon, dir = SOUTH)//copy the image so we don't mess with the one in the record.
	var/icon/the_icon = icon("icon" = 'icons/obj/poster_wanted.dmi', "icon_state" = background)
	var/icon/icon_foreground = icon("icon" = 'icons/obj/poster_wanted.dmi', "icon_state" = foreground)
	person_icon.Shift(SOUTH, 7)
	person_icon.Crop(7,4,26,30)
	person_icon.Crop(-5,-2,26,29)
	the_icon.Blend(person_icon, ICON_OVERLAY)
	the_icon.Blend(icon_foreground, ICON_OVERLAY)

	the_icon.Insert(the_icon, "wanted")
	the_icon.Insert(icon('icons/obj/contraband.dmi', "poster_being_set"), "poster_being_set")
	the_icon.Insert(icon('icons/obj/contraband.dmi', "poster_ripped"), "poster_ripped")
	icon = the_icon

/obj/structure/sign/poster/wanted/roll_and_drop(turf/location)
	var/obj/item/poster/wanted/P = ..(location)
	P.name = "[postName] ([wanted_name])"
	P.desc = "[postDesc] [wanted_name]."
	return P
	
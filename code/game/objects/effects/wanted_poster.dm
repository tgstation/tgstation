/obj/item/weapon/poster/wanted
	icon_state = "rolled_poster"

/obj/item/weapon/poster/wanted/New(turf/loc, icon/person_icon, wanted_name, description)
	var/obj/structure/sign/poster/wanted/wanted_poster = new(person_icon, wanted_name, description)
	..(loc, wanted_poster)
	name = "wanted poster ([wanted_name])"
	desc = "A wanted poster for [wanted_name]."

/obj/structure/sign/poster/wanted
	var/wanted_name

/obj/structure/sign/poster/wanted/New(var/icon/person_icon, var/person_name, var/description)
	if(!person_icon)
		qdel(src)
		return
	name = "wanted poster ([person_name])"
	wanted_name = person_name
	desc = description

	person_icon = icon(person_icon, dir = SOUTH)//copy the image so we don't mess with the one in the record.
	var/icon/the_icon = icon("icon" = 'icons/obj/poster_wanted.dmi', "icon_state" = "wanted_background")
	var/icon/icon_foreground = icon("icon" = 'icons/obj/poster_wanted.dmi', "icon_state" = "wanted_foreground")
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
	var/obj/item/weapon/poster/P = ..(location)
	P.name = "wanted poster ([wanted_name])"
	P.desc = "A wanted poster for [wanted_name]."
	return P

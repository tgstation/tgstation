/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = 2.1

/obj/effect/decal/warning_stripes/New()
	. = ..()
	var/turf/T=get_turf(src)
	var/image/I=image(icon, icon_state = icon_state, dir = dir)
	I.color=color
	T.AddDecal(I)
	qdel(src)

/obj/effect/decal/warning_stripes/oldstyle
	icon = 'icons/effects/warning_stripes_old.dmi'

/obj/effect/decal/warning_stripes/pathmarkers
	name = "Path marker"
	desc = "Marks an important path."

	icon_state="pathmarker"

/obj/effect/decal/warning_stripes/pathmarkers/yellow
	color = "#ffff00"

// Pastels
/obj/effect/decal/warning_stripes/pathmarkers/red
	color = "#af6365"

/obj/effect/decal/warning_stripes/pathmarkers/blue
	color = "#719eb6"

//For people who lose themselves on defficiency
//Making it a decal makes it fuse with the plating and disappear under the pipes, I need a better solution but this will do for now
/obj/effect/nmpi
	name = "NMPI"
	desc = "If your sense of direction is under average, just follow the Nanotrasen-approved Maintenance Path Indicator to never get lost again. Nanotrasen declines all responsibility if you decide to stray off the path indicated by the Nanotrasen-approved Maintenance Path Indicator."

	icon = 'icons/effects/warning_stripes.dmi'
	icon_state = "maintguide"
	layer = 2.45
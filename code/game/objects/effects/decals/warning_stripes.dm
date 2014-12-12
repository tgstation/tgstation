/obj/effect/decal/warning_stripes
	icon = 'icons/effects/warning_stripes.dmi'
	layer = 2.1

/obj/effect/decal/warning_stripes/New()
	. = ..()
	var/turf/T=get_turf(src)
	T.AddDecal(image(icon, icon_state = icon_state, dir = dir))
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
	color = "#EF9DA2"
/obj/effect/decal/warning_stripes/pathmarkers/blue
	color = "#8FAEDA"
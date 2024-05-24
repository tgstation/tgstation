/obj/structure/nestbox
	name = "Nesting Box"
	desc = "A warm box perfect for a chicken"
	density = FALSE
	icon = 'monkestation/icons/obj/structures.dmi'
	icon_state = "nestbox"
	anchored = FALSE
	var/incubator = FALSE

/obj/structure/nestbox/Initialize(mapload)
	. = ..()
	incubator = TRUE

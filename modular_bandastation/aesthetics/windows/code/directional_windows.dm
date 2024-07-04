/obj/structure/window
	icon = 'modular_bandastation/aesthetics/windows/icons/directional.dmi'
	icon_state = "window"
	color = "#99BBFF"

/obj/structure/window/reinforced
	icon = 'modular_bandastation/aesthetics/windows/icons/directional.dmi'
	icon_state = "r_window"
	color = "#99BBFF"

/obj/structure/window/reinforced/tinted
	icon = 'modular_bandastation/aesthetics/windows/icons/directional.dmi'
	icon_state = "r_window"
	color = "#5A6E82"

/obj/structure/window/reinforced/tinted/Initialize(mapload,direct)
	. = ..()
	flags_1 |= UNPAINTABLE_1

/obj/structure/window/reinforced/tinted/frosted
	icon_state = "r_window"
	color = "#5A6E82"

/obj/structure/window/plasma
	icon = 'modular_bandastation/aesthetics/windows/icons/directional.dmi'
	icon_state = "window"
	color = "#C800FF"

/obj/structure/window/plasma/Initialize(mapload,direct)
	. = ..()
	flags_1 |= UNPAINTABLE_1

/obj/structure/window/reinforced/plasma
	icon = 'modular_bandastation/aesthetics/windows/icons/directional.dmi'
	icon_state = "r_window"
	color = "#C800FF"

/obj/structure/window/reinforced/plasma/Initialize(mapload,direct)
	. = ..()
	flags_1 |= UNPAINTABLE_1

// Delete colors
/obj/structure/window/bronze
	color = null

/obj/structure/window/paperframe
	color = null

/obj/structure/window/reinforced/shuttle
	color = null

/obj/structure/window/reinforced/survival_pod
	color = null

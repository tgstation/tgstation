/// Special wall mounted cryopod for the prison, making it easier to autospawn.
/obj/machinery/cryopod/prison
	icon_state = "prisonpod"
	base_icon_state = "prisonpod"
	open_icon_state = "prisonpod"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/cryopod/prison, 18)

/obj/machinery/cryopod/prison/close_machine(atom/movable/target, density_to_set)
	. = ..()
	flick("prisonpod-open", src)
	set_density(FALSE)

/obj/machinery/cryopod/prison/open_machine(drop = TRUE, density_to_set)
	. = ..()
	flick("prisonpod-open", src)

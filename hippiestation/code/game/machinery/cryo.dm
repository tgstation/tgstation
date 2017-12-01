/obj/machinery/atmospherics/components/unary/cryo_cell
	sleep_factor = 0
	unconscious_factor = 0
	var/opening = FALSE

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/living/user)
	if(opening)
		return
	opening = TRUE
	to_chat(user, "<span class='notice'>You begin to struggle out of [src].</span>")
	if(do_mob(user, user, 50))
		open_machine()
	else
		opening = FALSE

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = FALSE)
	. = ..()
	opening = FALSE
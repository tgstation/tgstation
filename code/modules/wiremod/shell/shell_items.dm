/**
 * # Shell Item
 *
 * Printed out by protolathes. Screwdriver to complete the shell.
 */
/obj/item/shell
	name = "assembly"
	desc = "A shell assembly that can be completed by screwdrivering it."
	icon = 'icons/obj/wiremod.dmi'
	var/shell_to_spawn
	var/screw_delay = 3 SECONDS

/obj/item/shell/screwdriver_act(mob/living/user, obj/item/tool)
	user.visible_message(span_notice("[user] begins finishing [src]."), span_notice("You begin finishing [src]."))
	tool.play_tool_sound(src)
	if(!do_after(user, screw_delay, src))
		return
	user.visible_message(span_notice("[user] finishes [src]."), span_notice("You finish [src]."))

	var/turf/drop_loc = drop_location()

	qdel(src)
	if(drop_loc)
		new shell_to_spawn(drop_loc)

	return TRUE

/obj/item/shell/bot
	name = "bot assembly"
	icon_state = "setup_medium_box-open"
	shell_to_spawn = /obj/structure/bot

/obj/item/shell/money_bot
	name = "money bot assembly"
	icon_state = "setup_large-open"
	shell_to_spawn = /obj/structure/money_bot

/obj/item/shell/drone
	name = "drone assembly"
	icon_state = "setup_medium_med-open"
	shell_to_spawn = /mob/living/circuit_drone

/obj/item/shell/server
	name = "server assembly"
	icon_state = "setup_stationary-open"
	shell_to_spawn = /obj/structure/server
	screw_delay = 10 SECONDS

/obj/item/shell/airlock
	name = "circuit airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	shell_to_spawn = /obj/machinery/door/airlock/shell
	screw_delay = 10 SECONDS

/obj/item/shell/dispenser
	name = "circuit dispenser assembly"
	icon_state = "setup_drone_arms-open"
	shell_to_spawn = /obj/structure/dispenser_bot

/obj/item/shell/bci
	name = "brain-computer interface assembly"
	icon_state = "bci-open"
	shell_to_spawn = /obj/item/organ/cyberimp/bci

/obj/item/shell/scanner_gate
	name = "scanner gate assembly"
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate_black_open"
	shell_to_spawn = /obj/structure/scanner_gate_shell

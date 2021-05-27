/**
 * # Bot
 *
 * Immobile (but not dense) shells that can interact with world.
 */
/obj/structure/bot
	name = "bot"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_medium_box"

	density = FALSE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

/obj/structure/bot/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, capacity = SHELL_CAPACITY_LARGE, shell_flags = SHELL_FLAG_USB_PORT)


/**
 * # Server
 *
 * Immobile and dense shells that can interact with the world,
 * that can contain more components than a bot.
 */
/obj/structure/server
	name = "server"
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "setup_stationary"

	density = TRUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

/obj/structure/server/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_VERY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)
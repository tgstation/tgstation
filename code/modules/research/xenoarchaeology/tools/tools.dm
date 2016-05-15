
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Miscellaneous xenoarchaeology tools

/obj/item/device/gps
	name = "relay positioning device"
	desc = "Triangulates the approximate co-ordinates using a nearby satellite network."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	item_state = "locator"
	w_class = W_CLASS_SMALL

/obj/item/device/gps/attack_self(var/mob/user as mob)
	var/turf/T = get_turf(src)
	to_chat(user, "<span class='notice'>[bicon(src)] [src] flashes <i>[T.x-WORLD_X_OFFSET[T.z]].[rand(0,9)]:[T.y-WORLD_Y_OFFSET[T.z]].[rand(0,9)]:[T.z].[rand(0,9)]</i>.</span>")

/obj/item/device/measuring_tape
	name = "measuring tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "measuring"
	w_class = W_CLASS_SMALL

//todo: dig site tape

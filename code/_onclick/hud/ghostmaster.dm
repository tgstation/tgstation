/datum/hud/ghostmaster

/datum/hud/ghostmaster/New(mob/owner)
	. = ..()
	var/obj/screen/button = new /obj/screen/ghostmaster/select_power
	button.screen_loc = ui_inventory
	static_inventory += button

/obj/screen/ghostmaster
	icon = 'icons/mob/blob.dmi'

/obj/screen/ghostmaster/select_power
	icon_state = "ui_help"
	name = "Select Power"

/obj/screen/ghostmaster/select_power/Click()
	var/mob/camera/ghostmaster/G = usr
	var/selected = input(usr,"Select power") as null|anything in G.cost_table
	if(selected)
		G.active_power = selected
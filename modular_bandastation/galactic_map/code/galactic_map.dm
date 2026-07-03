/obj/structure/statue/gold/galactic_map
	name = "galactic map"
	desc = "Политическая карта галактики."
	icon = 'modular_bandastation/galactic_map/icons/galactic_map.dmi'
	icon_state = "galactic_map_statue"
	anchored = TRUE

/obj/structure/statue/gold/galactic_map/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GalacticMap")
		ui.set_autoupdate(FALSE)
		ui.open()

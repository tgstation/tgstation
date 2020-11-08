/obj/machinery/button/door
	icon = 'modular_skyrat/modules/aesthetics/buttons/icons/buttons.dmi'
	var/light_mask = "button-light-mask"

/obj/machinery/button/door/update_overlays()
	. = ..()
	if(!light_mask)
		return

	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		SSvis_overlays.add_vis_overlay(src, icon, light_mask, EMISSIVE_LAYER, EMISSIVE_PLANE)

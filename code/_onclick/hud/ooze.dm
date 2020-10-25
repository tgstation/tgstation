///Hud type with targetting dol and a nutrition bar
/datum/hud/ooze/New(mob/living/owner)
	. = ..()

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.hud = src
	zone_select.update_icon()
	static_inventory += zone_select

	alien_plasma_display = new /obj/screen/ooze_nutrition_display //Just going to use the alien plasma display because making new vars for each object is braindead.
	alien_plasma_display.hud = src
	infodisplay += alien_plasma_display

/obj/screen/ooze_nutrition_display
	icon = 'icons/hud/screen_alien.dmi'
	icon_state = "power_display"
	name = "nutrition"
	screen_loc = ui_alienplasmadisplay

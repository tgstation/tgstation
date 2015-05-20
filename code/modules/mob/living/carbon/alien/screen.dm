/obj/screen/zone_sel/alien/update_icon()
	overlays.Cut()
	overlays += selecting

/mob/living/carbon/alien/proc/updatePlasmaDisplay()
	if(hud_used) //clientless aliens
		hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='magenta'>[storedPlasma]</font></div>"

/mob/living/carbon/alien/larva/updatePlasmaDisplay()
	return
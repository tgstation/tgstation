
/mob/living/carbon/human/species/alien/proc/updatePlasmaDisplay()
	if(hud_used) //clientless aliens
		hud_used.alien_plasma_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='magenta'>[round(getPlasma())]</font></div>")

/mob/living/carbon/human/species/alien/larva/updatePlasmaDisplay()
	return


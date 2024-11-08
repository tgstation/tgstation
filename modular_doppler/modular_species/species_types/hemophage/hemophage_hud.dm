/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"

///Maptext define for Hemophage HUDs
#define FORMAT_HEMOPHAGE_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[trunc(value)]</font></div>")

/atom/movable/screen/hemophage
	icon = 'modular_doppler/modular_species/species_types/hemophage/icons/hemophage_hud.dmi'

/atom/movable/screen/hemophage/blood
	name = "Blood Meter"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/hemophage/blood/proc/update_blood_hud(blood_volume)
	maptext = FORMAT_HEMOPHAGE_HUD_TEXT(hud_text_color(blood_volume), blood_volume)

/atom/movable/screen/hemophage/blood/proc/hud_text_color(blood_volume)
	return blood_volume > BLOOD_VOLUME_SAFE ? "#FFDDDD" : "#b16565"

#undef UI_BLOOD_DISPLAY
#undef FORMAT_HEMOPHAGE_HUD_TEXT

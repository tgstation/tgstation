/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"

///Maptext define for Hemophage HUDs
#define FORMAT_HEMOPHAGE_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")

/atom/movable/screen/hemophage
	icon = 'modular_zubbers/icons/mob/actions/bloodsucker.dmi'

/atom/movable/screen/hemophage/blood
	name = "Blood Meter"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/hemophage/blood_counter/proc/update_blood_hud(blood_volume)
	maptext = FORMAT_HEMOPHAGE_HUD_TEXT(hud_text_color(), blood_volume)

/atom/movable/screen/hemophage/proc/hud_text_color(blood_volume)
	return blood_volume > BLOOD_VOLUME_SAFE ? "#FFDDDD" : "#FFAAAA"

/// Updated every time blood is changed
/datum/antagonist/hemophage/proc/update_blood_hud()
	blood_display?.update_blood_hud(owner.blood_volume)

/// 1 tile down
#undef UI_BLOOD_DISPLAY

///Maptext define for Hemophage HUDs
#undef FORMAT_HEMOPHAGE_HUD_TEXT

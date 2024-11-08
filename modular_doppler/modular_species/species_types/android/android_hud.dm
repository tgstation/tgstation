/// 1 tile down
#define UI_ENERGY_DISPLAY "WEST:6,CENTER-1:0"

///Maptext define for Hemophage HUDs
#define FORMAT_ANDROID_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round((value/1000000), 0.01)]MJ</font></div>")

/atom/movable/screen/android
	icon = 'modular_doppler/modular_species/species_types/android/icons/android_hud.dmi'

/atom/movable/screen/android/energy
	name = "Energy Tracker"
	icon_state = "energy_display"
	screen_loc = UI_ENERGY_DISPLAY

/atom/movable/screen/android/energy/proc/update_energy_hud(core_energy)
	maptext = FORMAT_ANDROID_HUD_TEXT(hud_text_color(core_energy), core_energy)

/atom/movable/screen/android/energy/proc/hud_text_color(core_energy)
	return core_energy > 1.5 MEGA JOULES ? "#ffffff" : "#b64b4b"

#undef UI_ENERGY_DISPLAY
#undef FORMAT_ANDROID_HUD_TEXT

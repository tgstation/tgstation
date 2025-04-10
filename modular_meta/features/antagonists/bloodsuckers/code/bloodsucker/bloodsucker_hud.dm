/// 1 tile down
#define UI_BLOOD_DISPLAY "WEST:6,CENTER-1:0"
/// 2 tiles down
#define UI_VAMPRANK_DISPLAY "WEST:6,CENTER-2:-5"
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#define UI_SUNLIGHT_DISPLAY "WEST:6,CENTER-0:0"

///Maptext define for Bloodsucker HUDs
#define FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>")
///Maptext define for Bloodsucker Sunlight HUDs
#define FORMAT_BLOODSUCKER_SUNLIGHT_TEXT(valuecolor, value) MAPTEXT("<div align='center' valign='bottom' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[value]</font></div>")

/atom/movable/screen/bloodsucker
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/actions_bloodsucker.dmi'

/atom/movable/screen/bloodsucker/blood_counter
	name = "Blood Consumed"
	icon_state = "blood_display"
	screen_loc = UI_BLOOD_DISPLAY

/atom/movable/screen/bloodsucker/rank_counter
	name = "Bloodsucker Rank"
	icon_state = "rank"
	screen_loc = UI_VAMPRANK_DISPLAY

/atom/movable/screen/bloodsucker/sunlight_counter
	name = "Solar Flare Timer"
	icon_state = "sunlight"
	screen_loc = UI_SUNLIGHT_DISPLAY
#ifdef BLOODSUCKER_TESTING
	var/datum/controller/subsystem/sunlight/sunlight_subsystem

/atom/movable/screen/bloodsucker/sunlight_counter/New(loc, ...)
	. = ..()
	sunlight_subsystem = SSsunlight
#endif

/// Update Blood Counter + Rank Counter
/datum/antagonist/bloodsucker/proc/update_hud()
	var/valuecolor
	if(bloodsucker_blood_volume > BLOOD_VOLUME_SAFE)
		valuecolor = "#FFDDDD"
	else if(bloodsucker_blood_volume > BLOOD_VOLUME_BAD)
		valuecolor = "#FFAAAA"

	if(blood_display)
		blood_display.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, bloodsucker_blood_volume)

	if(vamprank_display)
		if(bloodsucker_level_unspent > 0)
			vamprank_display.icon_state = "[initial(vamprank_display.icon_state)]_up"
		else
			vamprank_display.icon_state = initial(vamprank_display.icon_state)
		vamprank_display.maptext = FORMAT_BLOODSUCKER_HUD_TEXT(valuecolor, bloodsucker_level)

	if(sunlight_display)
		if(SSsunlight.sunlight_active)
			valuecolor = "#FF5555"
			sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_day"
		else
			switch(round(SSsunlight.time_til_cycle, 1))
				if(0 to 30)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_30"
					valuecolor = "#FFCCCC"
				if(31 to 60)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_60"
					valuecolor = "#FFE6CC"
				if(61 to 90)
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_90"
					valuecolor = "#FFFFCC"
				else
					sunlight_display.icon_state = "[initial(sunlight_display.icon_state)]_night"
					valuecolor = "#FFFFFF"
		sunlight_display.maptext = FORMAT_BLOODSUCKER_SUNLIGHT_TEXT( \
			valuecolor, \
			(SSsunlight.time_til_cycle >= 60) ? "[round(SSsunlight.time_til_cycle / 60, 1)] m" : "[round(SSsunlight.time_til_cycle, 1)] s" \
		)

/// 1 tile down
#undef UI_BLOOD_DISPLAY
/// 2 tiles down
#undef UI_VAMPRANK_DISPLAY
/// 6 pixels to the right, zero tiles & 5 pixels DOWN.
#undef UI_SUNLIGHT_DISPLAY

///Maptext define for Bloodsucker HUDs
#undef FORMAT_BLOODSUCKER_HUD_TEXT
///Maptext define for Bloodsucker Sunlight HUDs
#undef FORMAT_BLOODSUCKER_SUNLIGHT_TEXT

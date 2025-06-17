// Constants and standard colors for the holomap

/// Icon file to start with when drawing holomaps (to get a 480x480 canvas).
#define HOLOMAP_ICON 'monkestation/code/modules/holomaps/icons/480x480.dmi'
/// Pixel width & height of the holomap icon. Used for auto-centering etc.
#define HOLOMAP_ICON_SIZE 480
#define ui_holomap "CENTER-7,CENTER-7" // Screen location of the holomap "hud"

#define HOLOMAP_EXTRA_STATIONMAP "stationmapformatted"
#define HOLOMAP_EXTRA_STATIONMAPAREAS "stationareas"
#define HOLOMAP_EXTRA_STATIONMAPSMALL "stationmapsmall"

// Holomap colors
#define HOLOMAP_OBSTACLE "#FFFFFFDD"	// Color of walls and barriers
#define HOLOMAP_SOFT_OBSTACLE "#ffffff54"	// Color of weak, climbable, or see-through barriers that aren't fulltile windows.
#define HOLOMAP_PATH "#66666699"	// Color of floors
#define HOLOMAP_ROCK "#66666644"	// Color of mineral walls
#define HOLOMAP_HOLOFIER "#0096bb"	// Whole map is multiplied by this to give it a green holoish look

#define HOLOMAP_AREACOLOR_SHIELD_1 rgb(0, 119, 255, 64)
#define HOLOMAP_AREACOLOR_SHIELD_2 rgb(0, 255, 255, 64)

#define HOLOMAP_AREACOLOR_COMMAND "#3434d499"
#define HOLOMAP_AREACOLOR_SECURITY "#AE121299"
#define HOLOMAP_AREACOLOR_MEDICAL "#447bc299"
#define HOLOMAP_AREACOLOR_SCIENCE "#A154A699"
#define HOLOMAP_AREACOLOR_ENGINEERING "#F1C23199"
#define HOLOMAP_AREACOLOR_CARGO "#e06f0099"
#define HOLOMAP_AREACOLOR_HALLWAYS "#b9b9b999"
#define HOLOMAP_AREACOLOR_MAINTENANCE "#5e5e5e99"
#define HOLOMAP_AREACOLOR_ARRIVALS "#6464ff99"
#define HOLOMAP_AREACOLOR_ESCAPE "#ff585899"
#define HOLOMAP_AREACOLOR_DORMS "#bfff8399"
#define HOLOMAP_AREACOLOR_SERVICE "#3ab33699"
#define HOLOMAP_AREACOLOR_HANGAR "#2681a599"
//#define HOLOMAP_AREACOLOR_MUNITION "#CC889999"

#define HOLOMAP_LEGEND_X 64
#define HOLOMAP_LEGEND_Y 96

#define HOLOMAP_LEGEND_WIDTH 64

#define HOLOMAP_CENTER_X round((HOLOMAP_ICON_SIZE - world.maxx) / 2)
#define HOLOMAP_CENTER_Y round((HOLOMAP_ICON_SIZE - world.maxy) / 2)

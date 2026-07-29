/*
 * Runescape-inspired Chat Effects
 * Implements visual effects for runechat maptext messages.
 * Effects are triggered by wrapping text in <rs-effect> tags.
 *
 * Example usage: say ".rs-red This text is red!"
 * Example usage: say ".rs-rainbow This text is rainbow colored!"
 */

// Effect type constants
#define RSEFFECT_NONE      0
#define RSEFFECT_YELLOW    1
#define RSEFFECT_RED       2
#define RSEFFECT_GREEN     3
#define RSEFFECT_CYAN      4
#define RSEFFECT_PURPLE    5
#define RSEFFECT_WHITE     6
#define RSEFFECT_FLASH1    7
#define RSEFFECT_FLASH2    8
#define RSEFFECT_FLASH3    9
#define RSEFFECT_GLOW1     10
#define RSEFFECT_GLOW2     11
#define RSEFFECT_GLOW3     12
#define RSEFFECT_RAINBOW   13
#define RSEFFECT_WAVE      14
#define RSEFFECT_WAVE2     15
#define RSEFFECT_SHAKE     16
#define RSEFFECT_SLIDE     17
#define RSEFFECT_SCROLL    18

// Animation speed defines (in deciseconds)
#define RSEFFECT_FLASH_SPEED   (0.4 SECONDS)
#define RSEFFECT_GLOW_SPEED    (0.5 SECONDS)
#define RSEFFECT_RAINBOW_SPEED (0.3 SECONDS)
#define RSEFFECT_WAVE_SPEED    (0.5 SECONDS)
#define RSEFFECT_SHAKE_SPEED   (0.2 SECONDS)
#define RSEFFECT_SLIDE_SPEED   (1.0 SECONDS)
#define RSEFFECT_SCROLL_SPEED  (2.0 SECONDS)

// Maximum number of effect animation loops before stopping
#define RSEFFECT_MAX_LOOPS  50

// Color hex defines for Runescape-style colors
#define RSCOLOR_YELLOW  "#FFFF00"
#define RSCOLOR_RED     "#FF0000"
#define RSCOLOR_GREEN   "#00FF00"
#define RSCOLOR_CYAN    "#00FFFF"
#define RSCOLOR_PURPLE  "#FF00FF"
#define RSCOLOR_WHITE   "#FFFFFF"

// Flash color pairs
#define RSFLASH1_COLOR1 "#FF0000"
#define RSFLASH1_COLOR2 "#FFFF00"
#define RSFLASH2_COLOR1 "#00FFFF"
#define RSFLASH2_COLOR2 "#0000FF"
#define RSFLASH3_COLOR1 "#90FF90"
#define RSFLASH3_COLOR2 "#006400"

// Glow gradient color sequences
#define RSGLOW1_COLORS list("#FF0000", "#FF8800", "#FFFF00", "#00FF00", "#00FFFF")
#define RSGLOW2_COLORS list("#FF0000", "#FF00FF", "#0000FF", "#880000")
#define RSGLOW3_COLORS list("#FFFFFF", "#00FF00", "#FFFFFF", "#00FFFF")

// Wave parameters
#define RS_WAVE_AMPLITUDE 2
#define RS_WAVE_FREQUENCY 1

// Shake parameters
#define RS_SHAKE_AMPLITUDE 2

// Scroll distance (pixels)
#define RS_SCROLL_DISTANCE 50

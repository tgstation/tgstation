
// Taken from https://www.byond.com/docs/ref/#/atom/var/blend_mode
// I want you to be able to get these values without using global.vars manually yourself.
// The suggestions here are from the ref, and therefore are NOT ALWAYS ACCURATE TO SS13

// Controls the way the atom's icon is blended onto the icons behind it.
// The blend mode used by an atom is inherited by any attached overlays, unless they override it.
// BLEND_DEFAULT will use the main atom's blend mode; for the atom itself, it's the same as BLEND_OVERLAY.
// #define BLEND_DEFAULT 0

// BLEND_OVERLAY will draw an icon the normal way.
// #define BLEND_OVERLAY 1

// BLEND_ADD will do additive blending, so that the colors in the icon are added to whatever is behind it.
// Light effects like explosions will tend to look better in this mode.
// #define BLEND_ADD 2

// BLEND_SUBTRACT is for subtractive blending. This may be useful for special effects.
// #define BLEND_SUBTRACT 3

// BLEND_MULTIPLY will multiply the icon's colors by whatever is behind it.
// This is typically only useful for applying a colored light effect; for simply darkening, using a translucent black icon with normal overlay blending is a better option.
// #define BLEND_MULTIPLY 4

// BLEND_INSET_OVERLAY overlays the icon, but masks it by the image being drawn on.
// This is pretty much not at all useful directly on the map, but can be very useful for an overlay for an atom that uses KEEP_TOGETHER (see appearance_flags), or for the layering filter.
// #define BLEND_INSET_OVERLAY 5

GLOBAL_LIST_INIT(blend_names, list(
	"0" = "BLEND_DEFAULT",
	"1" = "BLEND_OVERLAY",
	"2" = "BLEND_ADD",
	"3" = "BLEND_SUBTRACT",
	"4" = "BLEND_MULTIPLY",
	"5" = "BLEND_INSET_OVERLAY",
))

//Bay lighting engine shit, not in /code/modules/lighting because BYOND is being shit about it
#define LIGHTING_INTERVAL 5 // frequency, in 1/10ths of a second, of the lighting process

#define LIGHTING_FALLOFF 1 // type of falloff to use for lighting; 1 for circular, 2 for square
#define LIGHTING_LAMBERTIAN 1 // use lambertian shading for light sources
#define LIGHTING_HEIGHT 1 // height off the ground of light sources on the pseudo-z-axis, you should probably leave this alone
#define LIGHTING_TRANSITIONS 0 // smooth, animated transitions, similar to /tg/station

#define LIGHTING_RESOLUTION 1 // resolution of the lighting overlays, powers of 2 only, max of 32
#define LIGHTING_LAYER 10 // drawing layer for lighting overlays
#define LIGHTING_ICON 'icons/effects/lighting_overlay.dmi' // icon used for lighting shading effects

#ifdef LIGHTING_TRANSITIONS
#define LIGHTING_TRANSITION_SPEED (LIGHTING_INTERVAL - 2)
#endif

//Some defines to generalise colours used in lighting.
#define LIGHT_COLOR_RED "#A96666"
#define LIGHT_COLOR_GREEN "#66AA66"
#define LIGHT_COLOR_BLUE "#6699FF"

#define LIGHT_COLOR_CYAN "#7BF9FF"
#define LIGHT_COLOR_PINK "#AA66AA"
#define LIGHT_COLOR_YELLOW "#AAAA66"
#define LIGHT_COLOR_BROWN "#CC9966"
#define LIGHT_COLOR_ORANGE "#FF7A38"

//These ones aren't a direct colour like the ones above, because nothing would fit
#define LIGHT_COLOR_FIRE "#ED9200"
#define LIGHT_COLOR_FLARE "#AA0033"
#define LIGHT_COLOR_SLIME_LAMP "#333300"
#define LIGHT_COLOR_BULB "#A0A080" //Colour of light bulbs and stuff like candles & mining lanterns.

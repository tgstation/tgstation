//Arbitrary lighting related stuff

#define LIGHTING_CIRCULAR 1									//Comment this out to use old square lighting effects.
#define LIGHTING_CAP 10										//The lumcount level at which alpha is 0 and we're fully lit.
#define LIGHTING_CAP_FRAC (255/LIGHTING_CAP)				//A precal'd variable we'll use in turf/redraw_lighting()
#define LIGHTING_ICON 'icons/effects/alphacolors.dmi'
#define LIGHTING_ICON_STATE ""
#define LIGHTING_ANIMATE_TIME 2								//Time to animate() any lighting change. Actual number pulled out of my ass
#define LIGHTING_MIN_ALPHA_DELTA_TO_ANIMATE 20				//How much does the alpha have to change to warrent an animation.
#define LIGHTING_DARKEST_VISIBLE_ALPHA 250					//Anything darker than this is so dark, we'll just consider the whole tile unlit
#define LIGHTING_LUM_FOR_FULL_BRIGHT 6						//Anything who's lum is lower then this starts off less bright.
#define LIGHTING_MIN_RADIUS 4								//Lowest radius a light source can effect.


//different modes that lights can operate in
#define LIGHTING_REGULAR 1									//Apply all effects additively
#define LIGHTING_STARLIGHT 2								//Track all starlight but only apply brightest

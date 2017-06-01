//Thresholds for shuttle engines freezing, blowing up, and everything between. All temperatures here are in Kelvin.

#define ENGINE_TEMPERATURE_STABLE 533 //Anything between this and the cold threshold means that we're working at ideal temperature.
#define ENGINE_TEMPERATURE_WARM 588 //We're slightly overheating, but working fine.
#define ENGINE_TEMPERATURE_MELTING 1100 //It's so hot that we're melting! If it gets much hotter we'll explode.
#define ENGINE_TEMPERATURE_EXPLODE 1200 //We get so hot that we explode. If this happens the shuttle's probably about to go with it.

#define ENGINE_THRUST_OFF 0 //Self-explanatory.
#define ENGINE_THRUST_ON 0.1 //A little bit of passive heat generation while we're not moving.
#define ENGINE_THRUST_SLOW 0.5 //We're operating at half efficiency. Slower but safer.
#define ENGINE_THRUST_NORMAL 1 //Standard thrust means nothing special.
#define ENGINE_THRUST_FAST 2 //Double power! We heat up faster but move a bit quicker, too.
#define ENGINE_THRUST_FULL_POWER 5 //FULL POWER! The fastest we can go, but we'll explode very quickly unless we have good cooling.

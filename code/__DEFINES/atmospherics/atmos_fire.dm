//FIRE
///Minimum temperature for fire to move to the next turf (150 °C or 433 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD (150+T0C)
///Minimum temperature for fire to exist on a turf (100 °C or 373 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST (100+T0C)
///Multiplier for the temperature shared to other turfs
#define FIRE_SPREAD_RADIOSITY_SCALE 0.85
///Helper for small fires to grow
#define FIRE_GROWTH_RATE 40000
///Minimum temperature to burn plasma
#define PLASMA_MINIMUM_BURN_TEMPERATURE (100+T0C)
///Upper temperature ceiling for plasmafire reaction calculations for fuel consumption
#define PLASMA_UPPER_TEMPERATURE (1370+T0C)
///Multiplier for plasmafire with O2 moles * PLASMA_OXYGEN_FULLBURN for the maximum fuel consumption
#define PLASMA_OXYGEN_FULLBURN 10
///Minimum temperature to burn hydrogen
#define HYDROGEN_MINIMUM_BURN_TEMPERATURE (100+T0C)
///Upper temperature ceiling for h2fire reaction calculations for fuel consumption
#define HYDROGEN_UPPER_TEMPERATURE (1370+T0C)
///Multiplier for h2fire with O2 moles * HYDROGEN_OXYGEN_FULLBURN for the maximum fuel consumption
#define HYDROGEN_OXYGEN_FULLBURN 10

//COLD FIRE (this is used only for the freon-o2 reaction, there is no fire still)
///fire will spread if the temperature is -10 °C
#define COLD_FIRE_MAXIMUM_TEMPERATURE_TO_SPREAD 263
///fire will start if the temperature is 0 °C
#define COLD_FIRE_MAXIMUM_TEMPERATURE_TO_EXIST 273
#define COLD_FIRE_SPREAD_RADIOSITY_SCALE 0.95 //Not yet implemented
#define COLD_FIRE_GROWTH_RATE 40000 //Not yet implemented
///Maximum temperature to burn freon
#define FREON_MAXIMUM_BURN_TEMPERATURE 283
///Minimum temperature allowed for the burn to go, we would have negative pressure otherwise
#define FREON_LOWER_TEMPERATURE 60
///Multiplier for freonfire with O2 moles * FREON_OXYGEN_FULLBURN for the maximum fuel consumption
#define FREON_OXYGEN_FULLBURN 10

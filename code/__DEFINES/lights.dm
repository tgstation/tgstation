///How much power emergency lights will consume per tick
#define LIGHT_EMERGENCY_POWER_USE (0.0001 * STANDARD_CELL_RATE)
// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

///Min time for a spark to happen in a broken light
#define BROKEN_SPARKS_MIN (3 MINUTES)
///Max time for a spark to happen in a broken light
#define BROKEN_SPARKS_MAX (9 MINUTES)

///Amount of time that takes an ethereal to take energy from the lights
#define LIGHT_DRAIN_TIME (2.5 SECONDS)
///Amount of charge the ethereal gain after the drain
#define LIGHT_POWER_GAIN (0.035 * STANDARD_CELL_CHARGE)

///How many reagents the lights can hold
#define LIGHT_REAGENT_CAPACITY 20

//Status for light constructs
#define LIGHT_CONSTRUCT_EMPTY 1
#define LIGHT_CONSTRUCT_WIRED 2
#define LIGHT_CONSTRUCT_CLOSED 3

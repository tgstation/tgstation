// Math constants.
#define R_IDEAL_GAS_EQUATION       8.31    // kPa*L/(K*mol).
#define ONE_ATMOSPHERE             101.325 // kPa.
#define IDEAL_GAS_ENTROPY_CONSTANT 1164    // (mol^3 * s^3) / (kg^3 * L).

// Radiation constants.
#define STEFAN_BOLTZMANN_CONSTANT    5.6704e-8 // W/(m^2*K^4).
#define COSMIC_RADIATION_TEMPERATURE 3.15      // K.
#define AVERAGE_SOLAR_RADIATION      200       // W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.
#define RADIATOR_OPTIMUM_PRESSURE    3771      // kPa at 20 C. This should be higher as gases aren't great conductors until they are dense. Used the critical pressure for air.
#define GAS_CRITICAL_TEMPERATURE     132.65    // K. The critical point temperature for air.

#define RADIATOR_EXPOSED_SURFACE_AREA_RATIO 0.04 // (3 cm + 100 cm * sin(3deg))/(2*(3+100 cm)). Unitless ratio.
#define HUMAN_EXPOSED_SURFACE_AREA          5.2 //m^2, surface area of 1.7m (H) x 0.46m (D) cylinder

#define T0C   273.15 //    0.0 degrees celsius
#define T20C  293.15 //   20.0 degrees celsius
#define T100C 373.15 //  100.0 degrees celsius
#define TCMB  2.7    // -270.3 degrees celsius

#define CELSIUS + T0C

#define ATMOS_PRECISION 0.0001
#define QUANTIZE(variable) (round(variable, ATMOS_PRECISION))

// Determines the exchange ratio of reagents being converted to gas and vice versa.
#define REAGENT_GAS_EXCHANGE_FACTOR 10

//where a unit turf is 1 on a side, its diagonal is sqrt(2)
#define UNIT_DIAGONAL      1.41421356237
#define HALF_UNIT_DIAGONAL 0.70710678118

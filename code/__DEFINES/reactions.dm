//Defines used in atmos gas reactions. Used to be located in ..\modules\atmospherics\gasmixtures\reactions.dm, but were moved here because fusion added so fucking many.

// Atmos reaction priorities:
/// The prority used to indicate that a reaction should run immediately at the start of a reaction cycle. Currently used by a jumble of decomposition reactions and purgative reactions.
#define PRIORITY_PRE_FORMATION 1
/// The priority used for reactions that produce a useful or more advanced product. Goes after purgative reactions so that the purgers can be slightly more useful.
#define PRIORITY_FORMATION 2
/// The priority used for indicate that a reactions should run immediately before most forms of combustion. Used by two decomposition reactions and steam condensation.
#define PRIORITY_POST_FORMATION 3
/// The priority used to indicate that a reactions should run after all other types of reactions. Exclusively used for combustion reactions that produce fire or are freon.
#define PRIORITY_FIRE 4

/// An exponent used to make large volume gas mixtures significantly less likely to release rads. Used to prevent tritfires in distro from irradiating literally the entire station with no warning.
#define ATMOS_RADIATION_VOLUME_EXP 3

/// Maximum range a radiation pulse is allowed to be from a gas reaction.
#define GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE 20

// Water Vapor:
/// The temperature required for water vapor to condense.
#define WATER_VAPOR_CONDENSATION_POINT (T20C + 10)
/// The temperature required for water vapor to condense as ice instead of water.
#define WATER_VAPOR_DEPOSITION_POINT 200

// Miaster:
/// The minimum temperature miasma begins being sterilized at.
#define MIASTER_STERILIZATION_TEMP (FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70)
/// The maximum ratio of water vapor to other gases miasma can be sterilized at.
#define MIASTER_STERILIZATION_MAX_HUMIDITY 0.1
/// The minimum amount of miasma that will be sterilized in a reaction tick.
#define MIASTER_STERILIZATION_RATE_BASE 20
/// The temperature required to sterilize an additional mole of miasma in a reaction tick.
#define MIASTER_STERILIZATION_RATE_SCALE 20
/// The amount of energy released when a mole of miasma is sterilized.
#define MIASTER_STERILIZATION_ENERGY 2e-3

// Fire:

// - General:
/// Amount of heat released per mole of burnt carbon into the tile
#define FIRE_CARBON_ENERGY_RELEASED 1e5

// - Plasma:
/// Minimum temperature to burn plasma
#define PLASMA_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
/// Upper temperature ceiling for plasmafire reaction calculations for fuel consumption
#define PLASMA_UPPER_TEMPERATURE (PLASMA_MINIMUM_BURN_TEMPERATURE + 1270)
/// The maximum and default amount of plasma consumed as oxydizer per mole of plasma burnt.
#define OXYGEN_BURN_RATIO_BASE 1.4
/// Multiplier for plasmafire with O2 moles * PLASMA_OXYGEN_FULLBURN for the maximum fuel consumption
#define PLASMA_OXYGEN_FULLBURN 10
/// The minimum ratio of oxygen to plasma necessary to start producing tritium.
#define SUPER_SATURATION_THRESHOLD 96
/// The divisor for the maximum plasma burn rate. (1/9 of the plasma can burn in one reaction tick.)
#define PLASMA_BURN_RATE_DELTA 9
/// Amount of heat released per mole of burnt plasma into the tile
#define FIRE_PLASMA_ENERGY_RELEASED 3e6

// - Hydrogen:
/// The minimum temperature hydrogen combusts at.
#define HYDROGEN_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
/// The minimum thermal energy necessary for hydrogen fires to use the [HYDROGEN_OXYBURN_MULTIPLIER]. Used to prevent overpowered hydrogen/oxygen singletank bombs to moderate success.
#define MINIMUM_HYDROGEN_OXYBURN_ENERGY 2e6
/// A multiplier to released hydrogen fire energy when in an oxygen-rich mix.
#define HYDROGEN_OXYBURN_MULTIPLIER 10
/// What fraction of the oxygen content of the mix is used for the burn rate in an oxygen-poor mix.
#define HYDROGEN_BURN_OXY_FACTOR 100
/// What fraction of the hydrogen content of the mix is used for the burn rate in an oxygen-rich mix.
#define HYDROGEN_BURN_H2_FACTOR 10
/// The amount of energy released by burning one mole of hydrogen. (Before [HYDROGEN_OXYBURN_MULTIPLIER] is applied if applicable.)
#define FIRE_HYDROGEN_ENERGY_RELEASED 2.8e5

// - Tritium:
/// The minimum temperature tritium combusts at.
#define TRITIUM_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
/// The minimum thermal energy necessary for tritium fires to use the [TRITIUM_OXYBURN_MULTIPLIER]. Used to prevent overpowered tritium/oxygen singletank bombs to moderate success.
#define MINIMUM_TRITIUM_OXYBURN_ENERGY 2e6
/// A multiplier to all secondary tritium fire effects when in an oxygen-rich mix.
#define TRITIUM_OXYBURN_MULTIPLIER 10
/// What fraction of the oxygen content of the mix is used for the burn rate in an oxygen-poor mix.
#define TRITIUM_BURN_OXY_FACTOR 100
/// What fraction of the tritium content of the mix is used for the burn rate in an oxygen-rich mix.
#define TRITIUM_BURN_TRIT_FACTOR 10
/// The amount of energy released by burning one mole of tritium. (Before [TRITIUM_OXYBURN_MULTIPLIER] is applied if applicable.)
#define FIRE_TRITIUM_ENERGY_RELEASED 2.8e5
/// The minimum number of moles of trit that must be burnt for a tritium fire reaction to produce a radiation pulse. (0.01 moles trit or 10 moles oxygen to start producing rads.)
#define TRITIUM_RADIATION_MINIMUM_MOLES 0.1
/// The minimum released energy necessary for tritium to release radiation during combustion. (at a mix volume of [CELL_VOLUME]).
#define TRITIUM_RADIATION_RELEASE_THRESHOLD (FIRE_TRITIUM_ENERGY_RELEASED * TRITIUM_OXYBURN_MULTIPLIER)
/// A scaling factor for the range of radiation pulses produced by tritium fires.
#define TRITIUM_RADIATION_RANGE_DIVISOR 1.5
/// A scaling factor for the irradiation threshold of radiation pulses produced by tritium fires.
#define TRITIUM_RADIATION_THRESHOLD_BASE 15

// - Freon:
/// The maximum temperature freon can combust at.
#define FREON_MAXIMUM_BURN_TEMPERATURE 283
///Minimum temperature allowed for the burn to go at max speed, we would have negative pressure otherwise
#define FREON_LOWER_TEMPERATURE 60
///Terminal temperature after wich we stop the reaction
#define FREON_TERMINAL_TEMPERATURE 20
/// Multiplier for freonfire with O2 moles * FREON_OXYGEN_FULLBURN for the maximum fuel consumption
#define FREON_OXYGEN_FULLBURN 10
/// The maximum fraction of the freon in a mix that can combust each reaction tick.
#define FREON_BURN_RATE_DELTA 4
/// The amount of heat absorbed per mole of freon burnt.
#define FIRE_FREON_ENERGY_CONSUMED 3e5
/// The maximum temperature at which freon combustion can form hot ice.
#define HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE 160
/// The minimum temperature at which freon combustion can form hot ice.
#define HOT_ICE_FORMATION_MINIMUM_TEMPERATURE 120
/// The chance for hot ice to form when freon reacts on a turf.
#define HOT_ICE_FORMATION_PROB 2

// N2O:
/// The minimum temperature N2O can form from nitrogen and oxygen in the presence of BZ at.
#define N2O_FORMATION_MIN_TEMPERATURE 200
/// The maximum temperature N2O can form from nitrogen and oxygen in the presence of BZ at.
#define N2O_FORMATION_MAX_TEMPERATURE 250
/// The amount of energy released when a mole of N2O forms from nitrogen and oxygen in the presence of BZ.
#define N2O_FORMATION_ENERGY 10000

/// The minimum temperature N2O can decompose at.
#define N2O_DECOMPOSITION_MIN_TEMPERATURE 1400
/// The maximum temperature N2O can decompose at.
#define N2O_DECOMPOSITION_MAX_TEMPERATURE 100000
/// The maximum portion of the N2O that can decompose each reaction tick. (50%)
#define N2O_DECOMPOSITION_RATE_DIVISOR 2
/// One root of the parabola used to scale N2O decomposition rates.
#define N2O_DECOMPOSITION_MIN_SCALE_TEMP 0
/// The other root of the parabola used to scale N2O decomposition rates.
#define N2O_DECOMPOSITION_MAX_SCALE_TEMP 100000
/// The divisor used to normalize the N2O decomp scaling parabola. Basically the value of the apex/nadir of (x - [N2O_DECOMPOSITION_MIN_SCALE_TEMP]) * (x - [N2O_DECOMPOSITION_MAX_SCALE_TEMP]).
#define N2O_DECOMPOSITION_SCALE_DIVISOR ((-1/4) * ((N2O_DECOMPOSITION_MAX_SCALE_TEMP - N2O_DECOMPOSITION_MIN_SCALE_TEMP)**2))
/// The amount of energy released when one mole of N2O decomposes into nitrogen and oxygen.
#define N2O_DECOMPOSITION_ENERGY 200000

// BZ:
/// The maximum temperature BZ can form at. Deliberately set lower than the minimum burn temperature for most combustible gases in an attempt to prevent long fuse singlecaps.
#define BZ_FORMATION_MAX_TEMPERATURE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 60) // Yes, someone used this as a bomb timer. I hate players.
/// The amount of energy 1 mole of BZ forming from N2O and plasma releases.
#define BZ_FORMATION_ENERGY 80000

// Pluoxium:
/// The minimum temperature pluoxium can form from carbon dioxide, oxygen, and tritium at.
#define PLUOXIUM_FORMATION_MIN_TEMP 50
/// The maximum temperature pluoxium can form from carbon dioxide, oxygen, and tritium at.
#define PLUOXIUM_FORMATION_MAX_TEMP T0C
/// The maximum amount of pluoxium that can form from carbon dioxide, oxygen, and tritium per reaction tick.
#define PLUOXIUM_FORMATION_MAX_RATE 5
/// The amount of energy one mole of pluoxium forming from carbon dioxide, oxygen, and tritium releases.
#define PLUOXIUM_FORMATION_ENERGY 250

// Nitrium:
/// The minimum temperature necessary for nitrium to form from tritium, nitrogen, and BZ.
#define NITRIUM_FORMATION_MIN_TEMP 1500
/// A scaling divisor for the rate of nitrium formation relative to mix temperature.
#define NITRIUM_FORMATION_TEMP_DIVISOR (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8)
/// The amount of thermal energy consumed when a mole of nitrium is formed from tritium, nitrogen, and BZ.
#define NITRIUM_FORMATION_ENERGY 100000

/// The maximum temperature nitrium can decompose into nitrogen and hydrogen at.
#define NITRIUM_DECOMPOSITION_MAX_TEMP (T0C + 70) //Pretty warm, explicitly not fire temps. Time bombs are cool, but not that cool. If it makes you feel any better it's close.
/// A scaling divisor for the rate of nitrium decomposition relative to mix temperature.
#define NITRIUM_DECOMPOSITION_TEMP_DIVISOR (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8)
/// The amount of energy released when a mole of nitrium decomposes into nitrogen and hydrogen.
#define NITRIUM_DECOMPOSITION_ENERGY 30000

// Freon:
/// The minimum temperature freon can form from plasma, CO2, and BZ at.
#define FREON_FORMATION_MIN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100
/// The amount of energy 2.5 moles of freon forming from plasma, CO2, and BZ consumes.
#define FREON_FORMATION_ENERGY 100

// H-Nob:
/// The maximum temperature hyper-noblium can form from tritium and nitrogen at.
#define NOBLIUM_FORMATION_MIN_TEMP TCMB
/// The maximum temperature hyper-noblium can form from tritium and nitrogen at.
#define NOBLIUM_FORMATION_MAX_TEMP 15
/// The amount of energy a single mole of hyper-noblium forming from tritium and nitrogen releases.
#define NOBLIUM_FORMATION_ENERGY 2e7

/// The number of moles of hyper-noblium required to prevent reactions.
#define REACTION_OPPRESSION_THRESHOLD 5

// Halon:
/// The minimum temperature required for halon to form from tritium and BZ.
#define HALON_FORMATION_MIN_TEMPERATURE 30
/// The maximum temperature required for halon to form from tritium and BZ.
#define HALON_FORMATION_MAX_TEMPERATURE 55
/// The amount of energy 4.25 moles of halon forming from tritium and BZ releases.
#define HALON_FORMATION_ENERGY 300

/// How much energy a mole of halon combusting consumes.
#define HALON_COMBUSTION_ENERGY 2500

// Healium:
/// The minimum temperature healium can form from BZ and freon at.
#define HEALIUM_FORMATION_MIN_TEMP 25
/// The maximum temperature healium can form from BZ and freon at.
#define HEALIUM_FORMATION_MAX_TEMP 300
/// The amount of energy three moles of healium forming from BZ and freon releases.
#define HEALIUM_FORMATION_ENERGY 9000

// Zauker:
/// The minimum temperature zauker can form from hyper-noblium and nitrium at.
#define ZAUKER_FORMATION_MIN_TEMPERATURE 50000
/// The maximum temperature zauker can form from hyper-noblium and nitrium at.
#define ZAUKER_FORMATION_MAX_TEMPERATURE 75000
/// The temperature scaling factor for zauker formation. At most this many moles of zauker can form per reaction tick per kelvin.
#define ZAUKER_FORMATION_TEMPERATURE_SCALE 5e-6
/// The amount of energy half a mole of zauker forming from hypernoblium and nitrium consumes.
#define ZAUKER_FORMATION_ENERGY 5000

/// The maximum number of moles of zauker that can decompose per reaction tick.
#define ZAUKER_DECOMPOSITION_MAX_RATE 20
/// The amount of energy a mole of zauker decomposing in the presence of nitrogen releases.
#define ZAUKER_DECOMPOSITION_ENERGY 460

// Proto-Nitrate:
/// The minimum temperature proto-nitrate can form from pluoxium and hydrogen at.
#define PN_FORMATION_MIN_TEMPERATURE 5000
/// The maximum temperature proto-nitrate can form from pluoxium and hydrogen at.
#define PN_FORMATION_MAX_TEMPERATURE 10000
/// The temperature scaling factor for proto-nitrate formation. At most this many moles of zauker can form per reaction tick per kelvin.
#define PN_FORMATION_TEMPERATURE_SCALE 5e-3
/// The amount of energy 2.2 moles of proto-nitrate forming from pluoxium and hydrogen releases.
#define PN_FORMATION_ENERGY 650

/// The amount of hydrogen necessary for proto-nitrate to start converting it to more proto-nitrate.
#define PN_HYDROGEN_CONVERSION_THRESHOLD 150
/// The maximum number of moles of hydrogen that can be converted into proto-nitrate in a single reaction tick.
#define PN_HYDROGEN_CONVERSION_MAX_RATE 5
/// The amount of energy converting a mole of hydrogen into half a mole of proto-nitrate consumes.
#define PN_HYDROGEN_CONVERSION_ENERGY 2500

/// The minimum temperature proto-nitrate can convert tritium to hydrogen at.
#define PN_TRITIUM_CONVERSION_MIN_TEMP 150
/// The maximum temperature proto-nitrate can convert tritium to hydrogen at.
#define PN_TRITIUM_CONVERSION_MAX_TEMP 340
/// The amount of energy proto-nitrate converting a mole of tritium into hydrogen releases.
#define PN_TRITIUM_CONVERSION_ENERGY 10000
/// The minimum released energy necessary for proto-nitrate to release radiation when converting tritium. (With a reaction vessel volume of [CELL_VOLUME])
#define PN_TRITIUM_CONVERSION_RAD_RELEASE_THRESHOLD 10000
/// A scaling factor for the range of the radiation pulses generated when proto-nitrate converts tritium to hydrogen.
#define PN_TRITIUM_RAD_RANGE_DIVISOR 1.5
/// A scaling factor for the threshold of the radiation pulses generated when proto-nitrate converts tritium to hydrogen.
#define PN_TRITIUM_RAD_THRESHOLD_BASE 15

/// The minimum temperature proto-nitrate can break BZ down at.
#define PN_BZASE_MIN_TEMP 260
/// The maximum temperature proto-nitrate can break BZ down at.
#define PN_BZASE_MAX_TEMP 280
/// The amount of energy proto-nitrate breaking down a mole of BZ releases.
#define PN_BZASE_ENERGY 60000
/// The minimum released energy necessary for proto-nitrate to release rads when breaking down BZ (at a mix volume of [CELL_VOLUME]).
#define PN_BZASE_RAD_RELEASE_THRESHOLD 60000
/// A scaling factor for the range of the radiation pulses generated when proto-nitrate breaks down BZ.
#define PN_BZASE_RAD_RANGE_DIVISOR 1.5
/// A scaling factor for the threshold of the radiation pulses generated when proto-nitrate breaks down BZ.
#define PN_BZASE_RAD_THRESHOLD_BASE 15
/// A scaling factor for the nuclear particle production generated when proto-nitrate breaks down BZ.
#define PN_BZASE_NUCLEAR_PARTICLE_DIVISOR 5
/// The maximum amount of nuclear particles that can be produced from proto-nitrate breaking down BZ.
#define PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM 6
/// How much radiation in consumed amount does a nuclear particle take from radiation when proto-nitrate breaks down BZ.
#define PN_BZASE_NUCLEAR_PARTICLE_RADIATION_ENERGY_CONVERSION 2.5

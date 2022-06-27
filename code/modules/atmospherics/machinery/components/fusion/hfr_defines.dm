///Speed of light, in m/s
#define LIGHT_SPEED 299792458
///Calculation between the plank constant and the lambda of the lightwave
#define PLANCK_LIGHT_CONSTANT 2e-16
///Radius of the h2 calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_H2RADIUS 120e-4
///Radius of the trit calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_TRITRADIUS 230e-3
///Power conduction in the void, used to calculate the efficiency of the reaction
#define VOID_CONDUCTION 1e-2
///Mole count required (tritium/hydrogen) to start a fusion reaction
#define FUSION_MOLE_THRESHOLD 25
///Used to reduce the gas_power to a more useful amount
#define INSTABILITY_GAS_POWER_FACTOR 0.003
///Used to calculate the toroidal_size for the instability
#define TOROID_VOLUME_BREAKEVEN 1000
///Constant used when calculating the chance of emitting a radioactive particle
#define PARTICLE_CHANCE_CONSTANT (-20000000)
///Conduction of heat inside the fusion reactor
#define METALLIC_VOID_CONDUCTIVITY 0.38
///Conduction of heat near the external cooling loop
#define HIGH_EFFICIENCY_CONDUCTIVITY 0.975
///Sets the minimum amount of power the machine uses
#define MIN_POWER_USAGE 50000
///Sets the multiplier for the damage
#define DAMAGE_CAP_MULTIPLIER 0.005
///Sets the range of the hallucinations
#define HALLUCINATION_HFR(P) (min(7, round(abs(P) ** 0.25)))
///Chance in percentage points per fusion level of iron accumulation when operating at unsafe levels
#define IRON_CHANCE_PER_FUSION_LEVEL 17
///Amount of iron accumulated per second whenever we fail our saving throw, using the chance above
#define IRON_ACCUMULATED_PER_SECOND 0.005
///Maximum amount of iron that can be healed per second. Calculated to mostly keep up with fusion level 5.
#define IRON_OXYGEN_HEAL_PER_SECOND (IRON_ACCUMULATED_PER_SECOND * (100 - IRON_CHANCE_PER_FUSION_LEVEL) / 100)
///Amount of oxygen in moles required to fully remove 100% iron content. Currently about 2409mol. Calculated to consume at most 10mol/s.
#define OXYGEN_MOLES_CONSUMED_PER_IRON_HEAL (10 / IRON_OXYGEN_HEAL_PER_SECOND)

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define HYPERTORUS_MELTING_PERCENT 5
#define HYPERTORUS_EMERGENCY_PERCENT 25
#define HYPERTORUS_DANGER_PERCENT 50
#define HYPERTORUS_WARNING_PERCENT 100

#define WARNING_TIME_DELAY 60
///to prevent accent sounds from layering
#define HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN 3 SECONDS

#define HYPERTORUS_COUNTDOWN_TIME 30 SECONDS

//
// Damage source: Too much mass in the fusion mix at high fusion levels
//

// Currently, this is 2700 moles at 1 Kelvin, linearly scaling down to a maximum of 1800 safe moles at 1e8 degrees kelvin
// Settings:
/// Start taking overfull damage at this power level
#define HYPERTORUS_OVERFULL_MIN_POWER_LEVEL 6
/// Take 0 damage beneath this much fusion mass at 1 degree Kelvin
#define HYPERTORUS_OVERFULL_MAX_SAFE_COLD_FUSION_MOLES 2700
/// Take 0 damage beneath this much fusion mass at FUSION_TEMPERATURE_MAX degrees Kelvin
#define HYPERTORUS_OVERFULL_MAX_SAFE_HOT_FUSION_MOLES 1800
// From there, how quickly should things get bad?
/// Every 200 moles, 1 point of damage per second
#define HYPERTORUS_OVERFULL_MOLAR_SLOPE (1/200)
// Derived:
// Given these settings, derive the rest of the equation.
// Damage is the dependent variable, fusion_moles and damage_source_temperature are the independent variables
// So the equation takes the form:
//   damage = molar_slope * fusion_moles + temperature_slope * damage_source_temperature + constant
// Derive these constants here for readability
// Derive the temperature slope from the molar slope
#define HYPERTORUS_OVERFULL_TEMPERATURE_SLOPE (HYPERTORUS_OVERFULL_MOLAR_SLOPE * (HYPERTORUS_OVERFULL_MAX_SAFE_COLD_FUSION_MOLES - HYPERTORUS_OVERFULL_MAX_SAFE_HOT_FUSION_MOLES) / (FUSION_MAXIMUM_TEMPERATURE - 1))
// Derive the constant to set damage = 0 at our desired thresholds above
#define HYPERTORUS_OVERFULL_CONSTANT (-(HYPERTORUS_OVERFULL_MOLAR_SLOPE * HYPERTORUS_OVERFULL_MAX_SAFE_HOT_FUSION_MOLES + HYPERTORUS_OVERFULL_TEMPERATURE_SLOPE * FUSION_MAXIMUM_TEMPERATURE))

//
// Heal source: Small enough mass in the fusion mix
//

// Settings:
/// Start healing when fusion mass is below this threshold
#define HYPERTORUS_SUBCRITICAL_MOLES 1200
/// Heal one point per second per this many moles under the threshold
#define HYPERTORUS_SUBCRITICAL_SCALE 400

//
// Heal source: Cold enough coolant
//

// Settings:
/// Heal up to this many points of damage per second at 1 degree kelvin
#define HYPERTORUS_COLD_COOLANT_MAX_RESTORE 2.5
/// Start healing below this temperature
#define HYPERTORUS_COLD_COOLANT_THRESHOLD (10 ** 5)
// Derived:
#define HYPERTORUS_COLD_COOLANT_SCALE (HYPERTORUS_COLD_COOLANT_MAX_RESTORE / log(10, HYPERTORUS_COLD_COOLANT_THRESHOLD))

//
// Damage source: Iron content
//

// Settings:
/// Start taking damage over this threshold, up to a maximum of (1 - HYPERTORUS_MAX_SAFE_IRON) per tick at 100% iron
#define HYPERTORUS_MAX_SAFE_IRON 0.35

//
// Damage source: Extreme levels of mass in fusion mix at any power level
//

// Note: Ignores the damage cap!
// Settings:
/// Start taking damage over this threshold
#define HYPERTORUS_HYPERCRITICAL_MOLES 10000
/// Take this much damage per mole over the threshold per second
#define HYPERTORUS_HYPERCRITICAL_SCALE 0.002
/// Take at most this much damage per second
#define HYPERTORUS_HYPERCRITICAL_MAX_DAMAGE 20

// If the moderator goes hypercritical, it cracks and starts to spill
// If our pressure is weak, it can still spill, just weakly and infrequently
// Even a small amount is still extremely hazardous with fusion temperatures
#define HYPERTORUS_WEAK_SPILL_RATE 0.0005
#define HYPERTORUS_WEAK_SPILL_CHANCE 1
/// Start spilling superhot moderator gas when over this pressure threshold
#define HYPERTORUS_MEDIUM_SPILL_PRESSURE 10000
/// How much we should spill initially
#define HYPERTORUS_MEDIUM_SPILL_INITIAL 0.25
/// How much of the moderator mix we should spill per second until mended
#define HYPERTORUS_MEDIUM_SPILL_RATE 0.01
/// If the moderator gas goes over this threshold, REALLY spill it
#define HYPERTORUS_STRONG_SPILL_PRESSURE 12000
/// How much we should spill initially
#define HYPERTORUS_STRONG_SPILL_INITIAL 0.75
/// How much of the moderator mix we should spill per second until mended
#define HYPERTORUS_STRONG_SPILL_RATE 0.05


//
// Explosion flags for use in fuel recipes
//
#define HYPERTORUS_FLAG_BASE_EXPLOSION (1<<0)
#define HYPERTORUS_FLAG_MEDIUM_EXPLOSION (1<<1)
#define HYPERTORUS_FLAG_DEVASTATING_EXPLOSION (1<<2)
#define HYPERTORUS_FLAG_RADIATION_PULSE (1<<3)
#define HYPERTORUS_FLAG_EMP (1<<4)
#define HYPERTORUS_FLAG_MINIMUM_SPREAD (1<<5)
#define HYPERTORUS_FLAG_MEDIUM_SPREAD (1<<6)
#define HYPERTORUS_FLAG_BIG_SPREAD (1<<7)
#define HYPERTORUS_FLAG_MASSIVE_SPREAD (1<<8)
#define HYPERTORUS_FLAG_CRITICAL_MELTDOWN (1<<9)

///High power damage
#define HYPERTORUS_FLAG_HIGH_POWER_DAMAGE (1<<0)
///High fuel mix mole
#define HYPERTORUS_FLAG_HIGH_FUEL_MIX_MOLE (1<<1)
///iron content damage
#define HYPERTORUS_FLAG_IRON_CONTENT_DAMAGE (1<<2)
///Iron content increasing
#define HYPERTORUS_FLAG_IRON_CONTENT_INCREASE (1<<3)
///Emped hypertorus
#define HYPERTORUS_FLAG_EMPED (1<<4)

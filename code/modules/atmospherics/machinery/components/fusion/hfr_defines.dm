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
///Max reaction point per reaction cycle
#define MAX_FUSION_RESEARCH 1000
///Min amount of allowed heat change
#define MIN_HEAT_VARIATION -1e5
///Max amount of allowed heat change
#define MAX_HEAT_VARIATION 1e5
///Max mole consumption per reaction cycle
#define MAX_FUEL_USAGE 36
///Mole count required (tritium/hydrogen) to start a fusion reaction
#define FUSION_MOLE_THRESHOLD 25
///Used to reduce the gas_power to a more useful amount
#define INSTABILITY_GAS_POWER_FACTOR 0.003
///Used to calculate the toroidal_size for the instability
#define TOROID_VOLUME_BREAKEVEN 1000
///Constant used when calculating the chance of emitting a radioactive particle
#define PARTICLE_CHANCE_CONSTANT (-20000000)
///Conduction of heat inside the fusion reactor
#define METALLIC_VOID_CONDUCTIVITY 0.15
///Conduction of heat near the external cooling loop
#define HIGH_EFFICIENCY_CONDUCTIVITY 0.95
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

#define HYPERTORUS_SUBCRITICAL_MOLES 2000
#define HYPERTORUS_HYPERCRITICAL_MOLES 10000
#define HYPERTORUS_MAX_MOLE_DAMAGE 10

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

/// Determines brightness of the light emitted by kudzu with the light mutation
#define LIGHT_MUTATION_BRIGHTNESS 4
/// Kudzu light states
#define PASS_LIGHT 0
#define BLOCK_LIGHT 1
/// Determines the probability that the toxicity mutation will harm someone who passes through it
#define TOXICITY_MUTATION_PROB 10
/// Determines the impact radius of kudzu's explosive mutation
#define EXPLOSION_MUTATION_IMPACT_RADIUS 2
/// Determines the scale factor for the amount of gas removed by kudzu with a gas removal mutation, which is this scale factor * the kudzu's energy level
#define GAS_MUTATION_REMOVAL_MULTIPLIER 3
/// Determines the probability that the thorn mutation will harm someone who passes through or attacks it
#define THORN_MUTATION_CUT_PROB 10
/// Determines the probability that a kudzu plant with the flowering mutation will spawn a venus flower bud
#define FLOWERING_MUTATION_SPAWN_PROB 10
/// Maximum energy used per atmos tick that the temperature stabilisation mutation will use to bring the temperature to T20C
#define TEMP_STABILISATION_MUTATION_MAXIMUM_ENERGY 40000

/// Temperature below which the kudzu can't spread
#define VINE_FREEZING_POINT 100

/// Kudzu severity values for traits, based on severity in terms of how severely it impacts the game, the lower the severity, the more likely it is to appear
#define SEVERITY_TRIVIAL 1
#define SEVERITY_MINOR 2
#define SEVERITY_AVERAGE 4
#define SEVERITY_ABOVE_AVERAGE 7
#define SEVERITY_MAJOR 10

/// Kudzu mutativeness is based on a scale factor * potency
#define MUTATIVENESS_SCALE_FACTOR 0.2

/// Kudzu maximum mutation severity is a linear function of potency
#define MAX_SEVERITY_LINEAR_COEFF 0.15
#define MAX_SEVERITY_CONSTANT_TERM 10

/// Additional maximum mutation severity given to kudzu spawned by a random event
#define MAX_SEVERITY_EVENT_BONUS 10

/// The maximum possible productivity value of a (normal) kudzu plant, used for calculating a plant's spread cap and multiplier
#define MAX_POSSIBLE_PRODUCTIVITY_VALUE 10

/// Kudzu spread cap is a scaled version of production speed, such that the better the production speed, ie. the lower the speed value is, the faster is spreads
#define SPREAD_CAP_LINEAR_COEFF 4
#define SPREAD_CAP_CONSTANT_TERM 20
/// Kudzu spread multiplier is a reciporal function of production speed, such that the better the production speed, ie. the lower the speed value is, the faster it spreads
#define SPREAD_MULTIPLIER_MAX 50

/// Kudzu's maximum possible maximum mutation severity (assuming ideal potency), used to balance mutation appearance chance
#define IDEAL_MAX_SEVERITY 20

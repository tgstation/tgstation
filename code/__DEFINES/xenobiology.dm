//gold slime core spawning (used with var/gold_core_spawnable)
/// Mob cannot be spawned with a gold slime core
#define NO_SPAWN 0
/// Mob can spawned with a gold slime core with plasma reaction as a hostile creature
#define HOSTILE_SPAWN 1
/// Mob can be spawned with a gold slime core with blood reaction as a friendly creature
#define FRIENDLY_SPAWN 2

//slime core activation type
/// Jelly species slime ability that causes simple effects that require energized jelly
#define SLIME_ACTIVATE_MINOR 1
/// Jelly species slime ability that causes complex effects that require plasma jelly
#define SLIME_ACTIVATE_MAJOR 2

/// Determines how much light the jelly species emit
#define LUMINESCENT_DEFAULT_GLOW 2

/// How much gases and chemicals can xenoflora pod contain
#define XENOFLORA_MAX_MOLES 3000
#define XENOFLORA_MAX_CHEMS 500
/// How much gases our pod injects per tick(so if plant needs 3 moles of CO2 per tick, pod will inject CO2 until there's 3 * XENOFLORA_POD_INPUT_MULTIPLIER moles)
#define XENOFLORA_POD_INPUT_MULTIPLIER 10

// Mob health stats
#define STABLE 0
#define SOFT_CRIT 1
#define HARD_CRIT 2
#define DEAD 3

//Maximum healthiness an individual can have
#define MAX_SATIETY 600

// bitflags for machine stat variable

/// physically broken
#define BROKEN (1<<0)
/// not powered
#define NOPOWER (1<<1)
/// under maintaince
#define MAINT (1<<2)
/// temporary broken by EMP pulse
#define EMPED (1<<3)

//ai power requirement defines
#define POWER_REQ_ALL 1

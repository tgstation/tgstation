///if it allows multiple instances of the effect
#define STATUS_EFFECT_MULTIPLE 0
///if it allows only one, preventing new instances
#define STATUS_EFFECT_UNIQUE 1
///if it allows only one, but new instances replace
#define STATUS_EFFECT_REPLACE 2
/// if it only allows one, and new instances just instead refresh the timer
#define STATUS_EFFECT_REFRESH 3

///Processing flags - used to define the speed at which the status will work
///This is fast - 0.2s between ticks (I believe!)
#define STATUS_EFFECT_FAST_PROCESS 0
///This is slower and better for more intensive status effects - 1s between ticks
#define STATUS_EFFECT_NORMAL_PROCESS 1

//several flags for the Necropolis curse status effect
/ //makes the edges of the target's screen obscured
#define CURSE_BLINDING (1<<0)
///spawns creatures that attack the target only
#define CURSE_SPAWNING (1<<1)
///causes gradual damage
#define CURSE_WASTING (1<<2)
///hands reach out from the sides of the screen, doing damage and stunning if they hit the target
#define CURSE_GRASPING (1<<3)

// Grouped effect sources, see also code/__DEFINES/traits.dm

#define STASIS_MACHINE_EFFECT "stasis_machine"

#define STASIS_CHEMICAL_EFFECT "stasis_chemical"

#define STASIS_ASCENSION_EFFECT "heretic_ascension"

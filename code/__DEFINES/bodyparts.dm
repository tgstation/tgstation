///The standard amount of bodyparts a carbon has. Currently 6, HEAD/L_ARM/R_ARM/CHEST/L_LEG/R_LEG
#define BODYPARTS_DEFAULT_MAXIMUM 6

/// The max HP of surplus prosthetics.
#define PROSTHESIS_MAX_HP 20

// EMP
// Note most of these values are doubled on heavy EMP

/// The brute damage an augged limb takes from an EMP.
#define AUGGED_LIMB_EMP_BRUTE_DAMAGE 2
/// The brute damage an augged limb takes from an EMP.
#define AUGGED_LIMB_EMP_BURN_DAMAGE 1.5

/// When hit by an EMP, the time an augged limb will be paralyzed for if its above the damage threshold. 
#define AUGGED_LIMB_EMP_PARALYZE_TIME 3 SECONDS

/// When hit by an EMP, the time an augged leg will be knocked down for. 
#define AUGGED_LEG_EMP_KNOCKDOWN_TIME 3 SECONDS
/// When hit by an EMP, the time a augged chest will cause a hardstun for if its above the damage threshold. 
#define AUGGED_CHEST_EMP_STUN_TIME 3 SECONDS
/// When hit by an EMP, the time an augged chest will cause the mob to shake() for. 
#define AUGGED_CHEST_EMP_SHAKE_TIME 5 SECONDS
/// When hit by an EMP, the time an augged head will make vision fucky for. 
#define AUGGED_HEAD_EMP_GLITCH_DURATION 6 SECONDS

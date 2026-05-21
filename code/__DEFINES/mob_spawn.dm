///this mob spawn creates the corpse instantly
#define CORPSE_INSTANT 1
///this mob spawn creates the corpse during GAME_STATE_PLAYING
#define CORPSE_ROUNDSTART 2

// Flags for using your static for a ghost role
/// Ghost role will take on the player's species
#define GHOSTROLE_TAKE_PREFS_SPECIES (1<<0)
/// Ghost role will take on the player's apperance (though exlcuding name)
#define GHOSTROLE_TAKE_PREFS_APPEARANCE (1<<1)

/// Return from create to stop the spawn process. Falsy value so one can just check !create()
#define CANCEL_SPAWN FALSE

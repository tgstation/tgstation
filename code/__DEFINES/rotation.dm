/// If an object needs to be rotated with a wrench
#define ROTATION_REQUIRE_WRENCH (1<<0)
/// If ghosts can rotate an object (if the ghost config is enabled)
#define ROTATION_GHOSTS_ALLOWED (1<<1)
/// If an object will ignore anchored for rotation (used for chairs)
#define ROTATION_IGNORE_ANCHORED (1<<2)
/// If an object will omit flipping from rotation (used for pipes since they use custom handling)
#define ROTATION_NO_FLIPPING (1<<3)
/// If an object needs to have an empty spot available in target direction (used for windoors and railings)
#define ROTATION_NEEDS_ROOM (1<<4)
/// The turf the object is on needs to be unblocked for the rotation to occur
#define ROTATION_NEEDS_UNBLOCKED (1<<5)

/// Rotate an object clockwise
#define ROTATION_CLOCKWISE -90
/// Rotate an object counterclockwise
#define ROTATION_COUNTERCLOCKWISE 90
/// Rotate an object upside down
#define ROTATION_FLIP 180

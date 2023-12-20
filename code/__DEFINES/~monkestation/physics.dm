#define MOVABLE_PHYSICS_PRECISION 0.01
#define MOVABLE_PHYSICS_MINIMAL_VELOCITY 1

// movable physics component flags
/// Remove the component as soon as there's zero velocity, useful for movables that will no longer move after being initially moved (blood splatters)
#define MPHYSICS_QDEL_WHEN_NO_MOVEMENT (1<<0)
/// Movement has started, don't call start_movement() again
#define MPHYSICS_MOVING (1<<1)
/// The component has been "paused" and will not process
#define MPHYSICS_PAUSED (1<<2)

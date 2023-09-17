// Defines related to the mining rework circa June 2023
/// Durability of a large size boulder from a large size vent.
#define BOULDER_SIZE_LARGE 15
/// Durability of a medium size boulder from a medium size vent.
#define BOULDER_SIZE_MEDIUM 10
/// Durability of a small size boulder from a small size vent.
#define BOULDER_SIZE_SMALL 5
/// How many boulders can a single ore vent have on it's tile before it stops producing more?
#define MAX_BOULDERS_PER_VENT 10

/// Proximity to a vent that a wall ore needs to be for 5 ore to be mined.
#define VENT_PROX_VERY_HIGH 3
/// Proximity to a vent that a wall ore needs to be for 4 ore to be mined.
#define VENT_PROX_HIGH 6
/// Proximity to a vent that a wall ore needs to be for 3 ore to be mined.
#define VENT_PROX_MEDIUM 15
/// Proximity to a vent that a wall ore needs to be for 2 ore to be mined.
#define VENT_PROX_LOW 32
/// Proximity to a vent that a wall ore needs to be for 1 ore to be mined.
#define VENT_PROX_FAR 64

/// The number of points a miner gets for discovering a vent, multiplied by BOULDER_SIZE when completing a wave defense minus the discovery bonus.
#define MINER_POINT_MULTIPLIER 100



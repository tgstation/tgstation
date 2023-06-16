// Bitflags that describes what turfs a decal is NOT ok with sittin on

/// Blocks closed turfs
#define DECAL_BLOCK_CLOSED_TURF (1<<0)
/// Blocks groundless turfs
#define DECAL_BLOCK_GROUNDLESS_TURF (1<<1)
/// Allows groundless turfs IF the turf below exists
#define DECAL_GROUNDLESS_ALLOW_FLOOR_BELOW_TURF (1<<2)

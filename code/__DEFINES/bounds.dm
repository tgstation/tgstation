/// Creates a new set of bounds with the given min and size vectors.
#define BOUNDS_MIN_AND_SIZE(min, size) new /datum/bounds(min, min + size)

/// Creates a new set of bounds with the given min and extents vectors.
#define BOUNDS_MIN_AND_EXTENTS(min, extents) new /datum/bounds(min, min + extents * 2)

/// Creates a new set of bounds with the given center and size vectors.
#define BOUNDS_CENTER_AND_SIZE(center, size) new /datum/bounds(center - size / 2, center + size / 2)

/// Creates a new set of bounds with the given center and extents vectors.
#define BOUNDS_CENTER_AND_EXTENTS(center, extents) new /datum/bounds(center - extents, center + extents)

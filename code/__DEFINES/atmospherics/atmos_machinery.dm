/// Used when an atmos machine has "external" selected
#define ATMOS_EXTERNAL_BOUND (1 << 0)

/// Used when an atmos machine has "internal" selected
#define ATMOS_INTERNAL_BOUND (1 << 1)

/// The maximum bound of an atmos machine
#define ATMOS_BOUND_MAX (ATMOS_EXTERNAL_BOUND | ATMOS_INTERNAL_BOUND)

/// Used when an atmos machine is siphoning out air
#define ATMOS_DIRECTION_SIPHONING 0

/// Used when a vent is releasing air
#define ATMOS_DIRECTION_RELEASING 1

/// Used when a scrubber is scrubbing air
#define ATMOS_DIRECTION_SCRUBBING 1

/// The max pressure of pumps.
#define ATMOS_PUMP_MAX_PRESSURE (ONE_ATMOSPHERE * 50)
